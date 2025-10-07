import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wmsapp/data/models/estoque/recebimento/docto_fisico_model.dart';
import 'package:wmsapp/data/services/i_api_service.dart';

// ============================================================================
// RECEBIMENTO REPOSITORY - Acesso aos dados de recebimento
// ============================================================================

/// Repository responsável por acessar dados de recebimento via API Progress
class RecebimentoRepository {
  final IApiService _apiService;

  RecebimentoRepository({required IApiService apiService})
    : _apiService = apiService;

  // ==========================================================================
  // BUSCAR DOCUMENTOS FÍSICOS PENDENTES
  // ==========================================================================

  /// Busca lista de documentos físicos pendentes de conferência
  ///
  /// Endpoint Progress esperado: rep/v1/api_get_docto_fisico/
  ///
  /// Parâmetros:
  /// - [username]: Usuário autenticado (sem @DOMAIN)
  /// - [password]: Senha do usuário
  /// - [codEstabel]: Código do estabelecimento selecionado
  /// - [searchTerm]: Termo de busca (opcional)
  Future<List<DoctoFisicoModel>> buscarDoctosPendentes({
    required String username,
    required String password,
    required String codEstabel,
    String? searchTerm,
  }) async {
    try {
      // ⚠️ IMPORTANTE: Adiciona @DOMAIN ao username (igual ao MenuRepository)
      final userForAuth = '$username@${dotenv.env['DOMAIN']}';

      // Monta query params
      final queryParams = <String, String>{
        'cod-estabel': codEstabel,
        'status': 'Pendente',
      };

      if (searchTerm != null && searchTerm.isNotEmpty) {
        queryParams['search'] = searchTerm;
      }

      // Chama API Progress
      final response = await _apiService.get(
        'rep/v1/api_get_docto_fisico/',
        queryParams: queryParams,
        username: userForAuth, // ← CORRIGIDO: com @DOMAIN
        password: password,
      );

      // A API retorna 'items' ao invés de 'data'
      final List<dynamic> doctosJson = response['items'] as List? ?? [];

      if (doctosJson.isEmpty) {
        print('[RecebimentoRepository] Nenhum documento encontrado');
        return [];
      }
      return doctosJson.map((json) => DoctoFisicoModel.fromJson(json)).toList();
    } catch (e) {
      print('[RecebimentoRepository] ERRO: $e');
      throw Exception('Erro ao buscar documentos pendentes: ${e.toString()}');
    }
  }

  // ==========================================================================
  // BUSCAR DETALHES DE UM DOCUMENTO ESPECÍFICO
  // ==========================================================================

  /// Busca detalhes completos de um documento físico (com itens e lotes)
  Future<DoctoFisicoModel> buscarDetalhesDocto({
    required String codEstabel,
    required int codEmitente,
    required String nroDocto,
    required String serieDocto,
    required String username,
    required String password,
  }) async {
    try {
      // ⚠️ IMPORTANTE: Adiciona @DOMAIN ao username
      final userForAuth = '$username@${dotenv.env['DOMAIN']}';

      final queryParams = <String, String>{
        'cod-estabel': codEstabel,
        'cod-emitente': codEmitente.toString(),
        'nro-docto': nroDocto,
        'serie-docto': serieDocto,
      };

      print('[RecebimentoRepository] Buscando detalhes do documento...');

      final response = await _apiService.get(
        'rep/v1/api_get_docto_detalhes/',
        queryParams: queryParams,
        username: userForAuth, // ← CORRIGIDO: com @DOMAIN
        password: password,
      );

      // Navega até o documento dentro da estrutura do dataset
      final items = response['items'] as List;
      if (items.isEmpty) {
        throw Exception('Documento não encontrado');
      }

      final dataset = items[0]['dsDoctoDetalhes'];
      final doctos = dataset['tt-doc-fisico'] as List;

      if (doctos.isEmpty) {
        throw Exception('Documento não encontrado');
      }

      //final docJson = doctos[0] as Map<String, dynamic>;
      final docJson = Map<String, dynamic>.from(doctos[0]);

      // Extrai os itens e renomeia para o campo que o model espera
      final itensJson = docJson['tt-it-doc-fisico'] as List? ?? [];
      docJson['itensDoc'] = itensJson;
      docJson.remove('tt-it-doc-fisico');

      return DoctoFisicoModel.fromJson(docJson);
    } catch (e) {
      print('[RecebimentoRepository] ERRO: $e');
      throw Exception('Erro ao buscar detalhes: ${e.toString()}');
    }
  }

  // ==========================================================================
  // FINALIZAR CONFERÊNCIA
  // ==========================================================================

  /// Finaliza a conferência de um documento físico
  ///
  /// IMPORTANTE: Requer método POST no IApiService
  Future<bool> finalizarConferencia({
    required DoctoFisicoModel docto,
    required String username,
    required String password,
    bool comDivergencia = false,
  }) async {
    try {
      // ⚠️ IMPORTANTE: Adiciona @DOMAIN ao username
      final userForAuth = '$username@${dotenv.env['DOMAIN']}';

      // ═════════════════════════════════════════════════════════════════
      // QUANDO IMPLEMENTAR POST, USE ESTE CÓDIGO:
      // ═════════════════════════════════════════════════════════════════
      /*
      final response = await _apiService.post(
        'rep/v1/api_finalizar_conferencia/',
        body: {
          'cod-estabel': docto.codEstabel,
          'cod-emitente': docto.codEmitente,
          'nro-docto': docto.nroDocto,
          'serie-docto': docto.serieDocto,
          'itensDoc': docto.itensDoc.map((item) => item.toJson()).toList(),
          'com-divergencia': comDivergencia,
          'dt-conferencia': DateTime.now().toIso8601String(),
        },
        username: userForAuth,  // ← CORRIGIDO: com @DOMAIN
        password: password,
      );

      if (response['success'] != true) {
        throw Exception(
          response['message'] ?? 'Erro ao finalizar conferência',
        );
      }

      return true;
      */

      // ═════════════════════════════════════════════════════════════════
      // TEMPORÁRIO: Simula sucesso
      // ═════════════════════════════════════════════════════════════════
      await Future.delayed(const Duration(seconds: 1));
      return true;
    } catch (e) {
      throw Exception('Erro ao finalizar conferência: ${e.toString()}');
    }
  }

  // ==========================================================================
  // REGISTRAR DIVERGÊNCIA
  // ==========================================================================

  /// Registra uma divergência específica
  Future<bool> registrarDivergencia({
    required String codEstabel,
    required int codEmitente,
    required String nroDocto,
    required String serieDocto,
    required int nrSequencia,
    required String tipoDivergencia,
    required String observacao,
    required String username,
    required String password,
  }) async {
    try {
      // ⚠️ IMPORTANTE: Adiciona @DOMAIN ao username
      final userForAuth = '$username@${dotenv.env['DOMAIN']}';

      // ═════════════════════════════════════════════════════════════════
      // QUANDO IMPLEMENTAR POST, USE ESTE CÓDIGO:
      // ═════════════════════════════════════════════════════════════════
      /*
      final response = await _apiService.post(
        'rep/v1/api_registrar_divergencia/',
        body: {
          'cod-estabel': codEstabel,
          'cod-emitente': codEmitente,
          'nro-docto': nroDocto,
          'serie-docto': serieDocto,
          'nr-sequencia': nrSequencia,
          'tipo-divergencia': tipoDivergencia,
          'observacao': observacao,
          'dt-registro': DateTime.now().toIso8601String(),
        },
        username: userForAuth,  // ← CORRIGIDO: com @DOMAIN
        password: password,
      );

      if (response['success'] != true) {
        throw Exception(
          response['message'] ?? 'Erro ao registrar divergência',
        );
      }

      return true;
      */

      // TEMPORÁRIO: Simula sucesso
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    } catch (e) {
      throw Exception('Erro ao registrar divergência: ${e.toString()}');
    }
  }
}
