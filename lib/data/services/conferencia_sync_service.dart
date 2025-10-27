import 'package:flutter/foundation.dart';
import 'package:wmsapp/data/models/estoque/recebimento/docto_fisico_model.dart';
import 'package:wmsapp/data/models/estoque/recebimento/it_doc_fisico_model.dart';
import 'package:wmsapp/data/repositories/estoque/recebimento/recebimento_repository.dart';

// ============================================================================
// CONFERENCIA SYNC SERVICE - Serviço de sincronização de conferência
// ============================================================================

/// Serviço responsável por sincronizar alterações de conferência com o backend
///
/// Funcionalidades:
/// - Detecta itens alterados (foiAlterado = true)
/// - Envia apenas itens modificados para o backend
/// - Atualiza versões locais após sincronização bem-sucedida
/// - Gerencia conflitos de versão (otimistic locking)
class ConferenciaSyncService {
  final RecebimentoRepository _repository;

  ConferenciaSyncService({required RecebimentoRepository repository})
      : _repository = repository;

  // ==========================================================================
  // SINCRONIZAR DOCUMENTO
  // ==========================================================================

  /// Sincroniza um documento com o backend
  ///
  /// Fluxo:
  /// 1. Filtra itens alterados (foiAlterado = true)
  /// 2. Se não há alterações, retorna sucesso sem fazer nada
  /// 3. Envia itens alterados para o backend
  /// 4. Backend retorna novos dados com versões atualizadas
  /// 5. Atualiza itens locais com novas versões
  /// 6. Marca itens como não alterados (foiAlterado = false)
  ///
  /// Retorna:
  /// - DoctoFisicoModel atualizado com novas versões
  /// - Throw Exception se houver erro de sincronização
  Future<DoctoFisicoModel> sincronizarDocumento({
    required DoctoFisicoModel documento,
    required String username,
    required String password,
  }) async {
    try {
      // 1. Filtra itens alterados
      final itensAlterados = documento.itensDoc
          .where((item) => item.foiAlterado)
          .toList();

      if (kDebugMode) {
        debugPrint(
          '[ConferenciaSyncService] Sincronizando documento ${documento.nroDocto}',
        );
        debugPrint(
          '[ConferenciaSyncService] Itens alterados: ${itensAlterados.length}/${documento.itensDoc.length}',
        );
      }

      // 2. Se não há alterações, retorna o documento original
      if (itensAlterados.isEmpty) {
        if (kDebugMode) {
          debugPrint(
            '[ConferenciaSyncService] Nenhum item alterado. Sincronização desnecessária.',
          );
        }
        return documento;
      }

      // 3. Envia para o backend
      final documentoAtualizado = await _repository.sincronizarItensConferencia(
        codEstabel: documento.codEstabel,
        codEmitente: documento.codEmitente,
        nroDocto: documento.nroDocto,
        serieDocto: documento.serieDocto,
        itensAlterados: itensAlterados,
        username: username,
        password: password,
      );

      if (kDebugMode) {
        debugPrint(
          '[ConferenciaSyncService] Sincronização concluída com sucesso',
        );
        debugPrint(
          '[ConferenciaSyncService] Novas versões recebidas do backend',
        );
      }

      // 4. Atualiza itens locais com as novas versões e marca como não alterado
      final itensAtualizados = documento.itensDoc.map((itemLocal) {
        // Procura o item correspondente na resposta do backend
        final itemBackend = documentoAtualizado.itensDoc.firstWhere(
          (itemBE) => itemBE.nrSequencia == itemLocal.nrSequencia,
          orElse: () => itemLocal,
        );

        // Se encontrou correspondência, atualiza versão e marca como não alterado
        if (itemBackend.nrSequencia == itemLocal.nrSequencia) {
          return itemLocal.copyWith(
            versao: itemBackend.versao,
            dataUltAlt: itemBackend.dataUltAlt,
            usuarioUltAlt: itemBackend.usuarioUltAlt,
            foiAlterado: false, // ✅ CRÍTICO: Marca como não alterado
          );
        }

        return itemLocal;
      }).toList();

      // 5. Retorna documento com itens atualizados
      return documento.copyWith(
        itensDoc: itensAtualizados,
        dtUltSinc: DateTime.now(), // Atualiza timestamp de sincronização
      );
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('[ConferenciaSyncService] ERRO ao sincronizar: $e');
        debugPrint('[ConferenciaSyncService] Stack: $stack');
      }
      rethrow;
    }
  }

  // ==========================================================================
  // VERIFICAR SE PRECISA SINCRONIZAR
  // ==========================================================================

  /// Verifica se um documento possui itens alterados que precisam ser sincronizados
  bool precisaSincronizar(DoctoFisicoModel documento) {
    return documento.itensDoc.any((item) => item.foiAlterado);
  }

  /// Retorna a quantidade de itens alterados
  int contarItensAlterados(DoctoFisicoModel documento) {
    return documento.itensDoc.where((item) => item.foiAlterado).length;
  }

  // ==========================================================================
  // MARCAR ITEM COMO ALTERADO
  // ==========================================================================

  /// Marca um item como alterado (helper para o ViewModel)
  ///
  /// Deve ser chamado sempre que:
  /// - qtdeConferida for alterada
  /// - Rateios forem adicionados/removidos/alterados
  ItDocFisicoModel marcarComoAlterado(ItDocFisicoModel item) {
    if (item.foiAlterado) {
      // Já está marcado, não precisa criar nova instância
      return item;
    }

    if (kDebugMode) {
      debugPrint(
        '[ConferenciaSyncService] Marcando item ${item.codItem} como alterado',
      );
    }

    return item.copyWith(foiAlterado: true);
  }

  // ==========================================================================
  // RESETAR FLAGS DE ALTERAÇÃO
  // ==========================================================================

  /// Reseta todas as flags de alteração (útil após finalizar conferência)
  DoctoFisicoModel resetarFlagsAlteracao(DoctoFisicoModel documento) {
    final itensResetados = documento.itensDoc.map((item) {
      return item.copyWith(foiAlterado: false);
    }).toList();

    return documento.copyWith(itensDoc: itensResetados);
  }
}
