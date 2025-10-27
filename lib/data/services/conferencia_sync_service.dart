// lib/data/services/conferencia_sync_service.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
      rethrow; // Propaga erro para o ViewModel tratar
    }
  }

  Map<String, dynamic> _montarPayloadDataset(
    DoctoFisicoModel documento,
    List<ItDocFisicoModel> itensAlterados,
  ) {
    // Monta lista de itens (tt-it-doc-fisico)
    final ttItDocFisico = itensAlterados.map((item) {
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

      // Extrai versões das tt-it-doc-fisico retornadas
      final ttItDocFisico = dsDocto['tt-it-doc-fisico'] as List?;

      if (ttItDocFisico == null) {
        return {'versoes': {}};
      }

      // Monta map de versões: sequencia -> versao
      final versoes = <int, int>{};
      for (final item in ttItDocFisico) {
        final sequencia = item['sequencia'] as int?;
        final versao = item['versao'] as int?;

        if (sequencia != null && versao != null) {
          versoes[sequencia] = versao;
        }
      }

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
