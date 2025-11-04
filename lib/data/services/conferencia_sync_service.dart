// lib/data/services/conferencia_sync_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wmsapp/data/models/estoque/recebimento/rat_lote_model.dart';

import '../models/estoque/recebimento/docto_fisico_model.dart';
import '../models/estoque/recebimento/it_doc_fisico_model.dart';
import 'i_api_service.dart';

/// 🔄 Service responsável pela SINCRONIZAÇÃO da conferência
///
/// Segue o mesmo padrão do RecebimentoRepository:
/// - Métodos retornam dados diretamente (Map, bool, models)
/// - Exceções são lançadas em caso de erro
/// - Sem classes de resultado customizadas
class ConferenciaSyncService {
  final IApiService _apiService;
  Timer? _syncTimer;

  ConferenciaSyncService(this._apiService);

  // ==========================================================================
  // 🔄 SINCRONIZAR DOCUMENTO
  // ==========================================================================

  /// Sincroniza o documento com o backend
  ///
  /// Retorna: Map com as novas versões dos itens
  /// Lança: Exception se houver erro ou conflito
  ///
  /// Exemplo de retorno:
  /// ```dart
  /// {
  ///   'versoes': {1: 2, 2: 3},
  ///   'conflito': false
  /// }
  /// ```
  Future<Map<String, dynamic>> sincronizarDocumento({
    required DoctoFisicoModel documento,
    required List<ItDocFisicoModel> itensAlterados,
    required String username,
    required String password,
  }) async {
    try {
      print('📤 Enviando ${itensAlterados.length} itens para sync...');

      // ⚠️ IMPORTANTE: Adiciona @DOMAIN ao username (igual ao MenuRepository)
      final userForAuth = '$username@${dotenv.env['DOMAIN']}';

      // Monta payload
      final payload = _montarPayloadDataset(documento, itensAlterados);

      // ✅ Log do JSON real (com aspas)
      if (kDebugMode) {
        print('📦 Payload JSON:');
        print(jsonEncode(payload));
      }
      // Chama API
      final response = await _apiService.post(
        'rep/v1/api_post_sync_recebimento/',
        body: payload,
        username: userForAuth,
        password: password,
      );

      final result = _parseRespostaDataset(response);

      // ⚠️ Se backend retornar conflito, lança exceção
      if (result['conflito'] == true) {
        print('⚠️ CONFLITO detectado!');
        throw ConflictException('Dados alterados por outro usuário');
      }

      print('✅ Sync OK!');
      return result;
    } catch (e) {
      print('❌ Erro no sync: $e');

      // ✅ CORREÇÃO: Detecta erro de versão divergente e trata como conflito
      final errorMsg = e.toString().toLowerCase();
      if (errorMsg.contains('versão') &&
          (errorMsg.contains('divergente') ||
              errorMsg.contains('atualização'))) {
        print('⚠️ Erro de versão detectado - tratando como conflito');
        throw ConflictException(
          'Dados foram alterados no servidor. Recarregando documento...',
        );
      }

      rethrow; // Propaga erro para o ViewModel tratar
    }
  }

  Map<String, dynamic> _montarPayloadDataset(
    DoctoFisicoModel documento,
    List<ItDocFisicoModel> itensAlterados,
  ) {
    // Monta lista de itens (tt-it-doc-fisico)
    final ttItDocFisico = itensAlterados.map((item) {
      if (kDebugMode) {
        print(
          '📤 Enviando item seq=${item.nrSequencia} com versao=${item.versao}',
        );
      }

      // Monta lista de rateios DESTE item (tt-rat-lote)
      final ttRatLote = <Map<String, dynamic>>[];

      if (item.rateios != null && item.rateios!.isNotEmpty) {
        for (final rateio in item.rateios!) {
          final ratJson = <String, dynamic>{
            'cod-depos': rateio.codDepos,
            'cod-localiz': rateio.codLocaliz,
            'quantidade': rateio.qtdeLote,
          };

          // Só adiciona se não for vazio
          if (rateio.codLote != null && rateio.codLote.isNotEmpty) {
            ratJson['lote'] = rateio.codLote;
          }

          if (rateio.dtValidade != null) {
            ratJson['dt-vali-lote'] = rateio.dtValidade!.toIso8601String();
          }

          ttRatLote.add(ratJson);
        }
      }

      // ✅ Rateios DENTRO do item
      return {
        'it-codigo': item.codItem,
        'sequencia': item.nrSequencia,
        'quantidade': item.qtdeItem,
        'qtde-conferida': item.qtdeConferida,
        'versao': item.versao,
        'tt-rat-lote': ttRatLote, // ✅ ANINHADO
      };
    }).toList();

    // ✅ Itens DENTRO do documento
    final ttDocFisico = {
      'cod-emitente': documento.codEmitente,
      'nro-docto': documento.nroDocto,
      'serie-docto': documento.serieDocto,
      'tt-it-doc-fisico': ttItDocFisico, // ✅ ANINHADO
    };

    // ✅ Formato Dataset NESTED completo
    return {
      'dsDocto': {
        'tt-doc-fisico': [ttDocFisico],
      },
    };
  }

  // ==========================================================================
  // 🔧 PARSE RESPOSTA DATASET
  // ==========================================================================

  Map<String, dynamic> _parseRespostaDataset(Map<String, dynamic> response) {
    try {
      // Resposta vem em formato Dataset
      final items = response['items'] as List?;

      if (items == null || items.isEmpty) {
        throw Exception('Resposta vazia do servidor');
      }

      if (kDebugMode) {
        print('📥 Response completo do backend:');
        print(jsonEncode(response));
      }

      // ✅ CORREÇÃO: Usa Map.from ao invés de cast direto
      final dsDocto = items[0]['dsDocto'] != null
          ? Map<String, dynamic>.from(items[0]['dsDocto'] as Map)
          : null;

      if (dsDocto == null) {
        throw Exception('Dataset dsDocto não encontrado na resposta');
      }

      // Verifica conflito
      if (dsDocto['conflito'] == true) {
        return {'conflito': true};
      }

      final ttDocFisico = dsDocto['tt-doc-fisico'] as List?;

      if (ttDocFisico == null || ttDocFisico.isEmpty) {
        print('⚠️ tt-doc-fisico vazio ou null');
        return {'versoes': {}};
      }

      final documento = ttDocFisico[0] as Map<String, dynamic>;
      final ttItDocFisico = documento['tt-it-doc-fisico'] as List?;

      // Extrai versões das tt-it-doc-fisico retornadas
      //final ttItDocFisico = dsDocto['tt-it-doc-fisico'] as List?;

      if (ttItDocFisico == null || ttItDocFisico.isEmpty) {
        print('⚠️ tt-it-doc-fisico vazio ou null');
        return {'versoes': {}};
      }

      if (kDebugMode) {
        print('📦 tt-it-doc-fisico recebido: ${ttItDocFisico.length} itens');
      }

      // Monta map de versões: sequencia -> versao
      final versoes = <int, int>{};
      for (final item in ttItDocFisico) {
        final sequencia = item['sequencia'] as int?;
        final versao = item['versao'] as int?;

        if (sequencia != null && versao != null) {
          versoes[sequencia] = versao;
          print('✅ Versão extraída: sequencia=$sequencia, versao=$versao');
        }
      }
      if (kDebugMode) {
        print('✅ Map de versões montado: $versoes');
      }
      print('📋 Total de versões extraídas: ${versoes.length}');
      return {'versoes': versoes};
    } catch (e) {
      print('❌ Erro ao fazer parse da resposta: $e');
      throw Exception('Erro ao processar resposta do servidor: $e');
    }
  }

  // ==========================================================================
  // 🔁 AUTO-SYNC
  // ==========================================================================

  /// Inicia auto-sync periódico (a cada 30s)
  ///
  /// O callback [onSyncNeeded] será chamado a cada intervalo
  void iniciarAutoSync({
    required Function() onSyncNeeded,
    Duration intervalo = const Duration(seconds: 30),
  }) {
    pararAutoSync();

    print('🔁 Auto-sync iniciado (${intervalo.inSeconds}s)');

    _syncTimer = Timer.periodic(intervalo, (_) {
      print('⏰ Auto-sync disparado');
      onSyncNeeded();
    });
  }

  /// Para o auto-sync
  void pararAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
    print('⏹️ Auto-sync parado');
  }

  // ==========================================================================
  // 🏁 FINALIZAR CONFERÊNCIA
  // ==========================================================================

  /// Finaliza a conferência do documento
  ///
  /// Retorna: true se sucesso, lança exceção em caso de erro
  Future<bool> finalizarConferencia({
    required DoctoFisicoModel documento,
    required String username,
    required String password,
    bool comDivergencia = false,
  }) async {
    try {
      print('🏁 Finalizando conferência...');

      final response = await _apiService.post(
        'rep/v1/api_post_sync_recebimento/',
        body: {
          'cod-estabel': documento.codEstabel,
          'cod-emitente': documento.codEmitente,
          'nro-docto': documento.nroDocto,
          'serie-docto': documento.serieDocto,
          'itensDoc': documento.itensDoc.map((item) => item.toJson()).toList(),
          'com-divergencia': comDivergencia,
          'dt-conferencia': DateTime.now().toIso8601String(),
        },
        username: username,
        password: password,
      );

      if (response['success'] != true) {
        throw Exception(
          response['message'] ?? 'Erro ao finalizar conferência',
        );
      }

      print('✅ Conferência finalizada!');
      return true;
    } catch (e) {
      print('❌ Erro ao finalizar: $e');
      throw Exception('Erro ao finalizar conferência: ${e.toString()}');
    }
  }

  // ==========================================================================
  // 🧹 CLEANUP
  // ==========================================================================

  void dispose() {
    pararAutoSync();
  }

  /// Salva um rateio individual no backend
  Future<void> salvarRateio({
    required String codEstabel,
    required int codEmitente,
    required String nroDocto,
    required String serieDocto,
    required int sequencia,
    required RatLoteModel rateio,
    required String username,
    required String password,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('═══════════════════════════════════════');
        debugPrint('📡 [SyncService] Salvando rateio:');
        debugPrint('   Estabelecimento: $codEstabel');
        debugPrint('   Emitente: $codEmitente');
        debugPrint('   Documento: $nroDocto-$serieDocto');
        debugPrint('   Sequência: $sequencia');
        debugPrint('   Depósito: ${rateio.codDepos}');
        debugPrint('   Localização: ${rateio.codLocaliz}');
        debugPrint('   Lote: ${rateio.codLote}');
        debugPrint('   Quantidade: ${rateio.qtdeLote}');
        debugPrint('═══════════════════════════════════════');
      }

      // ⚠️ IMPORTANTE: Adiciona @DOMAIN ao username (igual ao sincronizarDocumento)
      final userForAuth = '$username@${dotenv.env['DOMAIN']}';

      final payload = {
        'cod-estabel': codEstabel,
        'cod-emitente': codEmitente,
        'nro-docto': nroDocto,
        'serie-docto': serieDocto,
        'sequencia': sequencia,
        'rateio': {
          'cod-depos': rateio.codDepos,
          'cod-localiz': rateio.codLocaliz,
          'cod-lote': rateio.codLote,
          'qtde-lote': rateio.qtdeLote,
          if (rateio.dtValidade != null)
            'dt-vali-lote': rateio.dtValidade!.toIso8601String(),
        },
      };

      // ✅ HttpApiService já valida statusCode e lança exceção se erro
      await _apiService.post(
        'rep/v1/api_update_rateio/',
        body: payload,
        username: userForAuth,
        password: password,
      );

      if (kDebugMode) {
        debugPrint('✅ [SyncService] Rateio salvo com sucesso');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('❌ [SyncService] Erro ao salvar rateio: $e');
        debugPrint('Stack: $stack');
      }
      // ✅ Re-lança exceção para ser tratada no ViewModel
      rethrow;
    }
  }

  /// Remove um rateio do backend
  Future<void> removerRateio({
    required String codEstabel,
    required int codEmitente,
    required String nroDocto,
    required String serieDocto,
    required int sequencia,
    required String codDepos,
    required String codLocaliz,
    required String codLote,
    required String username,
    required String password,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('═══════════════════════════════════════');
        debugPrint('📡 [SyncService] Removendo rateio:');
        debugPrint('   Documento: $nroDocto-$serieDocto');
        debugPrint('   Sequência: $sequencia');
        debugPrint('   Chave: $codDepos-$codLocaliz-$codLote');
        debugPrint('═══════════════════════════════════════');
      }

      // ⚠️ IMPORTANTE: Adiciona @DOMAIN ao username
      final userForAuth = '$username@${dotenv.env['DOMAIN']}';

      // Monta payload para deletar
      final queryParams = <String, String>{
        'cod-estabel': codEstabel,
        'cod-emitente': codEmitente.toString(),
        'nro-docto': nroDocto,
        'serie-docto': serieDocto,
        'sequencia': sequencia.toString(),
        'cod-depos': codDepos,
        'cod-localiz': codLocaliz,
        if (codLote.isNotEmpty) 'cod-lote': codLote,
      };

      // ✅ ADICIONE: Debug dos query params ANTES de enviar
      if (kDebugMode) {
        debugPrint('📦 Query Params sendo enviados:');
        queryParams.forEach((key, value) {
          debugPrint('   $key = $value');
        });
      }

      // ✅ HttpApiService já valida statusCode e lança exceção se erro
      await _apiService.delete(
        'rep/v1/api_delete_rateio/',
        queryParams: queryParams,
        username: userForAuth,
        password: password,
      );

      if (kDebugMode) {
        debugPrint('✅ [SyncService] Rateio removido com sucesso');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('❌ [SyncService] Erro ao remover rateio: $e');
        debugPrint('Stack: $stack');
      }
      // ✅ Re-lança exceção para ser tratada no ViewModel
      rethrow;
    }
  }

  /// Atualiza um rateio existente (permite alterar chave e quantidade)
  Future<void> atualizarRateio({
    required String codEstabel,
    required int codEmitente,
    required String nroDocto,
    required String serieDocto,
    required int sequencia,
    required RatLoteModel rateio,
    required String username,
    required String password,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('═══════════════════════════════════════');
        debugPrint('📡 [SyncService] Atualizando rateio:');
        debugPrint('   Documento: $nroDocto-$serieDocto');
        debugPrint('   Sequência: $sequencia');

        if (rateio.chaveMudou) {
          debugPrint('   🔑 CHAVE ALTERADA:');
          debugPrint('      OLD: ${rateio.chaveRateioOriginal}');
          debugPrint('      NEW: ${rateio.chaveRateio}');
        } else {
          debugPrint('   📝 Chave mantida: ${rateio.chaveRateio}');
        }

        debugPrint('   Quantidade: ${rateio.qtdeLote}');
        debugPrint('═══════════════════════════════════════');
      }

      final userForAuth = '$username@${dotenv.env['DOMAIN']}';

      // ✅ Monta payload com chave-busca e dados-novos
      final payload = {
        'cod-estabel': codEstabel,
        'cod-emitente': codEmitente,
        'nro-docto': nroDocto,
        'serie-docto': serieDocto,
        'sequencia': sequencia,

        // ✅ Chave de busca (valores originais)
        'chave-busca': {
          'cod-depos': rateio.codDeposOriginal,
          'cod-localiz': rateio.codLocalizOriginal,
          if (rateio.codLoteOriginal.isNotEmpty) 'lote': rateio.codLoteOriginal,
        },

        // ✅ Dados novos (valores atuais)
        'dados-novos': {
          'cod-depos': rateio.codDepos,
          'cod-localiz': rateio.codLocaliz,
          if (rateio.codLote.isNotEmpty) 'lote': rateio.codLote,
          'quantidade': rateio.qtdeLote,
          if (rateio.dtValidade != null)
            'dt-vali-lote': rateio.dtValidade!.toIso8601String(),
        },
      };

      if (kDebugMode) {
        debugPrint('📦 Payload:');
        debugPrint('   ${json.encode(payload)}');
      }

      await _apiService.post(
        'rep/v1/api_update_rateio',
        body: payload,
        username: userForAuth,
        password: password,
      );

      if (kDebugMode) {
        debugPrint('✅ [SyncService] Rateio atualizado com sucesso');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('❌ [SyncService] Erro ao atualizar rateio: $e');
        debugPrint('Stack: $stack');
      }
      rethrow;
    }
  }
}

// ==========================================================================
// 🚨 EXCEÇÃO CUSTOMIZADA PARA CONFLITOS
// ==========================================================================

/// Exceção lançada quando há conflito de versão durante o sync
class ConflictException implements Exception {
  final String message;

  ConflictException(this.message);

  @override
  String toString() => 'ConflictException: $message';
}
