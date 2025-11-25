// lib/data/services/checklist_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wmsapp/data/models/checklist/checklist_model.dart';
//import 'package:wmsapp/data/models/checklist/checklist_item_model.dart';
import 'package:wmsapp/data/services/i_api_service.dart';

/// 📋 Service responsável pela comunicação com APIs de Checklist
///
/// Segue o mesmo padrão dos outros services:
/// - Métodos retornam dados diretamente (models)
/// - Exceções são lançadas em caso de erro
/// - Sem classes de resultado customizadas
class ChecklistService {
  final IApiService _apiService;

  ChecklistService(this._apiService);

  // ==========================================================================
  // 🔍 BUSCAR/CRIAR CHECKLIST DO DOCUMENTO
  // ==========================================================================

  /// Busca checklist existente ou cria novo
  ///
  /// Retorna: ChecklistModel completo com categorias e itens
  /// Lança: Exception se houver erro
  ///
  /// Fluxo:
  /// 1. Backend verifica se já existe checklist para o documento
  /// 2. Se existe: retorna checklist com respostas salvas
  /// 3. Se não existe: cria novo e retorna template vazio
  Future<ChecklistModel> buscarOuCriarChecklist({
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
        debugPrint('📋 [ChecklistService] Buscando checklist...');
        debugPrint('   Estabelecimento: $codEstabel');
        debugPrint('   Emitente: $codEmitente');
        debugPrint('   Documento: $nroDocto-$serieDocto');
        debugPrint('═══════════════════════════════════════');
      }

      // ⚠️ IMPORTANTE: Adiciona @DOMAIN ao username
      final userForAuth = '$username@${dotenv.env['DOMAIN']}';

      // Monta query params
      final queryParams = {
        'cod-estabel': codEstabel,
        'cod-emitente': codEmitente.toString(),
        'nro-docto': nroDocto,
        'serie-docto': serieDocto,
      };

      if (kDebugMode) {
        debugPrint('📦 Query Params:');
        queryParams.forEach((key, value) {
          debugPrint('   $key = $value');
        });
      }

      // Chama API GET
      final response = await _apiService.get(
        'rep/v1/api_checklist_get_documento/',
        queryParams: queryParams,
        username: userForAuth,
        password: password,
      );

      if (kDebugMode) {
        debugPrint('📥 Response recebido:');
        debugPrint(jsonEncode(response));
      }

      // Parse da resposta
      final checklist = _parseChecklistResponse(response);

      if (kDebugMode) {
        debugPrint('✅ Checklist carregado:');
        debugPrint('   Código: ${checklist.codChecklist}');
        debugPrint('   Template: ${checklist.desTemplate}');
        debugPrint('   Categorias: ${checklist.categorias.length}');
        debugPrint('   Total itens: ${checklist.totalItens}');
        debugPrint('   Criado agora: ${checklist.criadoAgora}');
        debugPrint('═══════════════════════════════════════');
      }

      return checklist;
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('═══════════════════════════════════════');
        debugPrint('❌ [ChecklistService] Erro ao buscar checklist');
        debugPrint('   Mensagem do backend: $e');
        debugPrint('   Stack: $stack');
        debugPrint('═══════════════════════════════════════');
      }
      throw Exception(
        e.toString().contains('Template não encontrado')
            ? 'Checklist não encontrado para o fornecedor informado'
            : 'Falha ao carregar checklist: $e',
      );
    }
  }

  // ==========================================================================
  // 💾 SALVAR RESPOSTA DE ITEM
  // ==========================================================================

  /// Salva resposta de um item do checklist
  ///
  /// Retorna: true se sucesso
  /// Lança: Exception se houver erro
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
        debugPrint('💾 [ChecklistService] Salvando resposta...');
        debugPrint('   Checklist: $codChecklist');
        debugPrint('   Categoria: $sequenciaCat');
        debugPrint('   Item: $sequenciaItem');
        if (respostaBoolean != null) {
          debugPrint('   Resposta Boolean: $respostaBoolean');
        }
        if (respostaText != null) {
          debugPrint('   Resposta Text: $respostaText');
        }
        if (respostaNumber != null) {
          debugPrint('   Resposta Number: $respostaNumber');
        }
        if (observacao != null && observacao.isNotEmpty) {
          debugPrint('   Observação: $observacao');
        }
        debugPrint('═══════════════════════════════════════');
      }

      final userForAuth = '$username@${dotenv.env['DOMAIN']}';

      // ✅ Monta payload com HÍFENS (padrão Progress)
      final payload = {
        'cod-checklist': codChecklist,
        'sequencia-cat': sequenciaCat,
        'sequencia-item': sequenciaItem,
        if (respostaBoolean != null) 'resposta-boolean': respostaBoolean,
        if (respostaText != null) 'resposta-text': respostaText,
        if (respostaNumber != null) 'resposta-number': respostaNumber,
        if (respostaDate != null)
          'resposta-date': respostaDate.toIso8601String(),
        if (observacao != null && observacao.isNotEmpty)
          'observacao': observacao,
        if (conforme != null) 'conforme': conforme,
      };

      if (kDebugMode) {
        debugPrint('📦 Payload:');
        debugPrint(jsonEncode(payload));
      }

      // Chama API POST
      final response = await _apiService.post(
        'rep/v1/api_checklist_post_item/',
        body: payload,
        username: userForAuth,
        password: password,
      );

      if (kDebugMode) {
        debugPrint('✅ Resposta salva com sucesso!');
        debugPrint('═══════════════════════════════════════');
      }

      return true;
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('═══════════════════════════════════════');
        debugPrint('❌ [ChecklistService] Erro ao salvar resposta');
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
  Future<bool> finalizarChecklist({
    required int codChecklist,
    required String username,
    required String password,
    String? observacaoGeral,
    bool aprovado = true,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('═══════════════════════════════════════');
        debugPrint('🏁 [ChecklistService] Finalizando checklist...');
        debugPrint('   Código: $codChecklist');
        debugPrint('   Aprovado: $aprovado');
        if (observacaoGeral != null && observacaoGeral.isNotEmpty) {
          debugPrint('   Observação: $observacaoGeral');
        }
        debugPrint('═══════════════════════════════════════');
      }

      final userForAuth = '$username@${dotenv.env['DOMAIN']}';

      // ✅ Monta payload com HÍFENS (padrão Progress)
      final payload = {
        'cod-checklist': codChecklist, // ✅ CORRIGIDO: era 'codChecklist'
        'aprovado': aprovado,
        if (observacaoGeral != null && observacaoGeral.isNotEmpty)
          'observacao-geral':
              observacaoGeral, // ✅ CORRIGIDO: era 'observacaoGeral'
        'dt-finalizacao': DateTime.now()
            .toIso8601String(), // ✅ CORRIGIDO: era 'dtFinalizacao'
      };

      if (kDebugMode) {
        debugPrint('📦 Payload:');
        debugPrint(jsonEncode(payload));
      }

      // Chama API POST
      final response = await _apiService.post(
        'rep/v1/api_checklist_post_finalizar/',
        body: payload,
        username: userForAuth,
        password: password,
      );

      if (kDebugMode) {
        debugPrint('✅ Checklist finalizado com sucesso!');
        debugPrint('═══════════════════════════════════════');
      }

      return true;
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('═══════════════════════════════════════');
        debugPrint('❌ [ChecklistService] Erro ao finalizar checklist');
        debugPrint('   Erro: $e');
        debugPrint('   Stack: $stack');
        debugPrint('═══════════════════════════════════════');
      }
      rethrow;
    }
  }

  // ==========================================================================
  // 📤 UPLOAD DE EVIDÊNCIA (FOTO)
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
        debugPrint('📤 [ChecklistService] Enviando evidência...');
        debugPrint('   Checklist: $codChecklist');
        debugPrint('   Categoria: $sequenciaCat');
        debugPrint('   Item: $sequenciaItem');
        debugPrint('   Arquivo: $caminhoFoto');
        debugPrint('═══════════════════════════════════════');
      }

      final userForAuth = '$username@${dotenv.env['DOMAIN']}';

      // TODO: Implementar upload multipart quando necessário
      // Por enquanto, lança exceção
      throw UnimplementedError(
        'Upload de evidência ainda não implementado',
      );

      // Código de exemplo para quando implementar:
      /*
      final response = await _apiService.uploadFile(
        'rep/v1/checklist_post_evidencia/',
        filePath: caminhoFoto,
        fields: {
          'cod-checklist': codChecklist.toString(),
          'sequencia-cat': sequenciaCat.toString(),
          'sequencia-item': sequenciaItem.toString(),
          if (descricao != null) 'descricao': descricao,
        },
        username: userForAuth,
        password: password,
      );

      if (kDebugMode) {
        debugPrint('✅ Evidência enviada com sucesso!');
        debugPrint('═══════════════════════════════════════');
      }

      return true;
      */
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('═══════════════════════════════════════');
        debugPrint('❌ [ChecklistService] Erro ao enviar evidência');
        debugPrint('   Erro: $e');
        debugPrint('   Stack: $stack');
        debugPrint('═══════════════════════════════════════');
      }
      rethrow;
    }
  }

  // ==========================================================================
  // 🔧 PARSE DA RESPOSTA DO BACKEND
  // ==========================================================================

  /// Faz parse da resposta da API de buscar checklist
  ChecklistModel _parseChecklistResponse(Map<String, dynamic> response) {
    try {
      // A resposta vem no formato padrão da API
      final dsChecklist = response['dsChecklist'] as Map<String, dynamic>?;

      if (dsChecklist == null) {
        throw Exception('Dataset dsChecklist não encontrado na resposta');
      }

      // Pega tt-checklist-response (array com 1 elemento)
      final ttChecklistResponse = dsChecklist['tt-checklist-response'] as List?;

      if (ttChecklistResponse == null || ttChecklistResponse.isEmpty) {
        throw Exception('tt-checklist-response não encontrado');
      }

      // Parse do checklist
      final checklistJson = ttChecklistResponse[0] as Map<String, dynamic>;

      // Cria o model
      return ChecklistModel.fromJson(checklistJson);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erro ao fazer parse da resposta: $e');
        debugPrint('Response completo:');
        debugPrint(jsonEncode(response));
      }
      throw Exception('Erro ao processar resposta do servidor: $e');
    }
  }
}
