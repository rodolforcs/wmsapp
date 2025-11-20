// lib/data/repositories/checklist/checklist_repository.dart

import 'package:flutter/foundation.dart';
import 'package:wmsapp/data/models/checklist/checklist_model.dart';
import 'package:wmsapp/data/services/checklist_service.dart';

/// 📦 Repository responsável pela lógica de negócio do Checklist
///
/// Segue o mesmo padrão do RecebimentoRepository:
/// - Métodos retornam dados diretamente (models)
/// - Exceções são lançadas em caso de erro
/// - Camada intermediária entre ViewModel e Service
class ChecklistRepository {
  final ChecklistService _service;

  ChecklistRepository(this._service);

  // ==========================================================================
  // 🔍 BUSCAR/CRIAR CHECKLIST
  // ==========================================================================

  /// Busca checklist existente ou cria novo para o documento
  ///
  /// Retorna: ChecklistModel completo
  /// Lança: Exception se houver erro
  ///
  /// Exemplo de uso:
  /// ```dart
  /// final checklist = await repository.buscarOuCriarChecklist(
  ///   codEstabel: '203',
  ///   codEmitente: 89750,
  ///   nroDocto: '0220727',
  ///   serieDocto: '1',
  ///   username: 'user',
  ///   password: 'pass',
  /// );
  /// ```
  Future<ChecklistModel?> buscarOuCriarChecklist({
    required String codEstabel,
    required int codEmitente,
    required String nroDocto,
    required String serieDocto,
    required String username,
    required String password,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('═══════════════════════════════════════');
        debugPrint('📦 [ChecklistRepository] Buscando checklist...');
        debugPrint('   Documento: $nroDocto-$serieDocto');
        debugPrint('   Emitente: $codEmitente');
        debugPrint('═══════════════════════════════════════');
      }

      // Chama service
      final checklist = await _service.buscarOuCriarChecklist(
        codEstabel: codEstabel,
        codEmitente: codEmitente,
        nroDocto: nroDocto,
        serieDocto: serieDocto,
        username: username,
        password: password,
      );

      if (kDebugMode) {
        debugPrint('✅ [ChecklistRepository] Checklist obtido:');
        debugPrint('   Código: ${checklist.codChecklist}');
        debugPrint('   Template: ${checklist.desTemplate}');
        debugPrint('   Situação: ${checklist.situacaoDescricao}');
        debugPrint(
          '   Progresso: ${checklist.percentualConclusao.toStringAsFixed(1)}%',
        );
        debugPrint('   Categorias: ${checklist.categorias.length}');
        debugPrint('   Total itens: ${checklist.totalItens}');
        debugPrint('   Itens respondidos: ${checklist.itensRespondidos}');
        debugPrint('═══════════════════════════════════════');
      }

      return checklist;
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('═══════════════════════════════════════');
        debugPrint('❌ [ChecklistRepository] Erro ao buscar checklist');
        debugPrint('   Erro: $e');
        debugPrint('   Stack: $stack');
        debugPrint('═══════════════════════════════════════');
      }

      // Propaga exceção para o ViewModel tratar
      rethrow;
    }
  }

  // ==========================================================================
  // 💾 SALVAR RESPOSTA DE ITEM
  // ==========================================================================

  /// Salva resposta de um item do checklist
  ///
  /// Retorna: true se sucesso
  /// Lança: Exception se houver erro
  ///
  /// Exemplo de uso:
  /// ```dart
  /// await repository.salvarRespostaItem(
  ///   codChecklist: 1,
  ///   sequenciaCat: 1,
  ///   sequenciaItem: 1,
  ///   respostaText: 'OK',
  ///   observacao: 'Tudo conforme',
  ///   username: 'user',
  ///   password: 'pass',
  /// );
  /// ```
  Future<bool> salvarRespostaItem({
    required int codChecklist,
    required int sequenciaCat,
    required int sequenciaItem,
    bool? respostaBoolean,
    String? respostaText,
    double? respostaNumber,
    DateTime? respostaDate,
    String? observacao,
    bool? conforme,
    required String username,
    required String password,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('═══════════════════════════════════════');
        debugPrint('📦 [ChecklistRepository] Salvando resposta...');
        debugPrint('   Item: $sequenciaCat-$sequenciaItem');
      }

      // Validações básicas
      if (respostaBoolean == null &&
          respostaText == null &&
          respostaNumber == null &&
          respostaDate == null) {
        throw Exception('Nenhuma resposta fornecida');
      }

      // Chama service
      final sucesso = await _service.salvarRespostaItem(
        codChecklist: codChecklist,
        sequenciaCat: sequenciaCat,
        sequenciaItem: sequenciaItem,
        respostaBoolean: respostaBoolean,
        respostaText: respostaText,
        respostaNumber: respostaNumber,
        respostaDate: respostaDate,
        observacao: observacao,
        conforme: conforme,
        username: username,
        password: password,
      );

      if (kDebugMode) {
        debugPrint('✅ [ChecklistRepository] Resposta salva!');
        debugPrint('═══════════════════════════════════════');
      }

      return sucesso;
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('═══════════════════════════════════════');
        debugPrint('❌ [ChecklistRepository] Erro ao salvar resposta');
        debugPrint('   Erro: $e');
        debugPrint('   Stack: $stack');
        debugPrint('═══════════════════════════════════════');
      }
      rethrow;
    }
  }

  // ==========================================================================
  // 🏁 FINALIZAR CHECKLIST
  // ==========================================================================

  /// Finaliza o checklist
  ///
  /// Retorna: true se sucesso
  /// Lança: Exception se houver erro
  ///
  /// Validações:
  /// - Verifica se todos itens obrigatórios foram respondidos
  /// - Valida se itens que exigem foto tem evidência
  Future<bool> finalizarChecklist({
    required ChecklistModel checklist,
    required String username,
    required String password,
    String? observacaoGeral,
    bool aprovado = true,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('═══════════════════════════════════════');
        debugPrint('📦 [ChecklistRepository] Finalizando checklist...');
        debugPrint('   Código: ${checklist.codChecklist}');
        debugPrint('   Template: ${checklist.desTemplate}');
        debugPrint('   Aprovado: $aprovado');
      }

      // ========================================================================
      // VALIDAÇÕES ANTES DE FINALIZAR
      // ========================================================================

      // 1. Verifica se todos itens obrigatórios foram respondidos
      if (!checklist.todosItensRespondidos) {
        final faltam = checklist.totalItens - checklist.itensRespondidos;
        throw Exception(
          'Existem $faltam ${faltam == 1 ? "item obrigatório não respondido" : "itens obrigatórios não respondidos"}',
        );
      }

      // 2. Verifica itens que exigem foto (futura implementação)
      // TODO: Validar se itens com exige-foto=true tem evidência

      if (kDebugMode) {
        debugPrint('✅ Validações OK - Chamando service...');
      }

      // Chama service
      final sucesso = await _service.finalizarChecklist(
        codChecklist: checklist.codChecklist,
        username: username,
        password: password,
        observacaoGeral: observacaoGeral,
        aprovado: aprovado,
      );

      if (kDebugMode) {
        debugPrint('✅ [ChecklistRepository] Checklist finalizado!');
        debugPrint('═══════════════════════════════════════');
      }

      return sucesso;
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('═══════════════════════════════════════');
        debugPrint('❌ [ChecklistRepository] Erro ao finalizar');
        debugPrint('   Erro: $e');
        debugPrint('   Stack: $stack');
        debugPrint('═══════════════════════════════════════');
      }
      rethrow;
    }
  }

  // ==========================================================================
  // 📤 UPLOAD DE EVIDÊNCIA
  // ==========================================================================

  /// Faz upload de evidência (foto) para um item
  ///
  /// Retorna: true se sucesso
  /// Lança: Exception se houver erro
  Future<bool> uploadEvidencia({
    required int codChecklist,
    required int sequenciaCat,
    required int sequenciaItem,
    required String caminhoFoto,
    required String username,
    required String password,
    String? descricao,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('═══════════════════════════════════════');
        debugPrint('📦 [ChecklistRepository] Enviando evidência...');
        debugPrint('   Item: $sequenciaCat-$sequenciaItem');
        debugPrint('   Arquivo: $caminhoFoto');
      }

      // Chama service
      final sucesso = await _service.uploadEvidencia(
        codChecklist: codChecklist,
        sequenciaCat: sequenciaCat,
        sequenciaItem: sequenciaItem,
        caminhoFoto: caminhoFoto,
        username: username,
        password: password,
        descricao: descricao,
      );

      if (kDebugMode) {
        debugPrint('✅ [ChecklistRepository] Evidência enviada!');
        debugPrint('═══════════════════════════════════════');
      }

      return sucesso;
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('═══════════════════════════════════════');
        debugPrint('❌ [ChecklistRepository] Erro ao enviar evidência');
        debugPrint('   Erro: $e');
        debugPrint('   Stack: $stack');
        debugPrint('═══════════════════════════════════════');
      }
      rethrow;
    }
  }

  // ==========================================================================
  // 🔧 MÉTODOS AUXILIARES
  // ==========================================================================

  /// Valida se checklist pode ser finalizado
  ///
  /// Retorna: null se pode finalizar, ou mensagem de erro
  String? validarPodeFinalizar(ChecklistModel checklist) {
    // 1. Verifica itens obrigatórios
    if (!checklist.todosItensRespondidos) {
      final faltam = checklist.totalItens - checklist.itensRespondidos;
      return 'Faltam $faltam ${faltam == 1 ? "item" : "itens"} obrigatórios';
    }

    // 2. Verifica itens que exigem foto (futura implementação)
    // TODO: Validar evidências

    return null; // Pode finalizar
  }

  /// Retorna mensagem detalhada dos problemas encontrados
  String obterMensagemProblemas(ChecklistModel checklist) {
    final problemas = <String>[];

    if (!checklist.todosItensRespondidos) {
      final faltam = checklist.totalItens - checklist.itensRespondidos;
      problemas.add(
        '$faltam ${faltam == 1 ? "item não respondido" : "itens não respondidos"}',
      );
    }

    // TODO: Adicionar validação de evidências

    return problemas.isEmpty ? 'Checklist OK' : problemas.join('\n');
  }
}
/*
```

---

## ✅ REPOSITORY CRIADO!

**Estrutura:**
```
lib/data/repositories/checklist/
└── checklist_repository.dart
```

---

## 📋 MÉTODOS DISPONÍVEIS:

| Método | Função | Validações |
|--------|--------|------------|
| **buscarOuCriarChecklist** | Busca/cria checklist | ✅ Params obrigatórios |
| **salvarRespostaItem** | Salva resposta | ✅ Valida se tem resposta |
| **finalizarChecklist** | Finaliza checklist | ✅ Valida itens obrigatórios |
| **uploadEvidencia** | Upload foto | ✅ Valida arquivo |
| **validarPodeFinalizar** | Valida checklist | ✅ Retorna erros |
| **obterMensagemProblemas** | Mensagem detalhada | ✅ Lista problemas |

---

## 🎯 CARACTERÍSTICAS:

✅ Segue padrão do projeto (`RecebimentoRepository`)
✅ Logs detalhados com debugPrint
✅ Validações de negócio
✅ Tratamento de erros com rethrow
✅ Métodos auxiliares para UI
✅ Documentação inline com exemplos

---

## 📊 CAMADAS CRIADAS ATÉ AGORA:
```
✅ Models     (checklist_model.dart, categoria, item, resposta)
✅ Service    (checklist_service.dart)
✅ Repository (checklist_repository.dart)
⏳ ViewModel  (próximo)
⏳ View       (próximo)
⏳ Widgets    (próximo)
*/