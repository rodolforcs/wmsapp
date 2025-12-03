import 'package:http/http.dart' as http;
import 'package:wmsapp/data/services/i_api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class HttpApiService implements IApiService {
  final String _apiBaseUrl = dotenv.env['API_BASE_URL_PRD']!;

  // Função helper para criar o header do basic auth
  Map<String, String> _createHeaders({String? username, String? password}) {
    final headers = {'content-type': 'application/json; charset=UTF-8'};

    if (username != null && password != null) {
      // 1. junta usuário e senha
      final credentials = '$username:$password';
      // 2. transforma em base64
      final encodeCredentials = base64.encode(utf8.encode(credentials));
      // 3. Adiciona o Header de autorização
      headers['Authorization'] = 'Basic $encodeCredentials';
    }
    return headers;
  }

  @override
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
    String? username,
    String? password,
  }) async {
    final url = Uri.parse(
      '$_apiBaseUrl$endpoint',
    ).replace(queryParameters: queryParams);
    print('GET -> $url'); // ESSENCIAL PARA DEBUG

    final headers = _createHeaders(username: username, password: password);
    final response = await http.get(url, headers: headers);

    // Log sempre
    print('↩ Status: ${response.statusCode}');
    print('↩ Body: ${response.body}');

    try {
      //Cria headers com credenciais fornecidas
      final headers = _createHeaders(username: username, password: password);

      final response = await http.get(url, headers: headers);

      //print('Status da resposta: ${response.statusCode}');
      //print('Corpo da resposta: ${response.body}');
      //print('Header: ${headers}');

      // Tenta decodificar o corpo da resposta em todos os casos.
      // Se o corpo estiver vazio, retorna um objeto vazio para evitar erros de parsing.
      final responseBody = response.body.isNotEmpty
          ? json.decode(response.body)
          : {};

      // Se a requisição foi um sucesso (2xx), retorna o corpo.
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseBody;
      } else {
        /******************************************************************
         * CORREÇÃO PRINCIPAL AQUI
         * Se for um erro (4xx, 5xx), tentamos extrair a mensagem de erro
         * específica do backend Progress.
         ******************************************************************/
        String errorMessage = 'Erro desconhecido (${response.statusCode})';

        // Estrutura de erro do JsonAPIResponseBuilder:BadRequest
        if (responseBody is Map &&
            responseBody.containsKey('RowErrors') &&
            responseBody['RowErrors'] is List &&
            (responseBody['RowErrors'] as List).isNotEmpty) {
          final firstError = (responseBody['RowErrors'] as List).first;
          if (firstError is Map && firstError.containsKey('ErrorDescription')) {
            errorMessage = firstError['ErrorDescription'];
          }
        }
        // Estrutura de erro do JsonAPIError (caso você use no futuro)
        else if (responseBody is Map && responseBody.containsKey('message')) {
          errorMessage = responseBody['message'];
        }

        // Lança uma exceção com a mensagem de erro específica.
        throw Exception(errorMessage);
      }
    } catch (e) {
      // Se o erro já for uma exceção com a mensagem certa, apenas re-lança.
      // Se for um erro de parsing ou de rede, a mensagem será genérica.
      print('Erro na camada de rede (HttpApiService): $e');
      rethrow; // Re-lança a exceção para ser tratada pela camada do repositório/viewModel.
    }
  }

  @override
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    String? username,
    String? password,
  }) async {
    final url = Uri.parse('$_apiBaseUrl$endpoint');
    print('POST -> $url'); // ESSENCIAL PARA DEBUG

    try {
      // Cria headers com credenciais fornecidas
      final headers = _createHeaders(username: username, password: password);

      // Converte o body para JSON
      final jsonBody = body != null ? json.encode(body) : null;

      final response = await http.post(
        url,
        headers: headers,
        body: jsonBody,
      );

      // Tenta decodificar o corpo da resposta em todos os casos.
      // Se o corpo estiver vazio, retorna um objeto vazio para evitar erros de parsing.
      final responseBody = response.body.isNotEmpty
          ? json.decode(response.body)
          : {};

      // Se a requisição foi um sucesso (2xx), retorna o corpo.
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseBody;
      } else {
        /******************************************************************
         * CORREÇÃO PRINCIPAL AQUI
         * Se for um erro (4xx, 5xx), tentamos extrair a mensagem de erro
         * específica do backend Progress.
         ******************************************************************/
        String errorMessage = 'Erro desconhecido (${response.statusCode})';

        // Estrutura de erro do JsonAPIResponseBuilder:BadRequest
        if (responseBody is Map &&
            responseBody.containsKey('RowErrors') &&
            responseBody['RowErrors'] is List &&
            (responseBody['RowErrors'] as List).isNotEmpty) {
          final firstError = (responseBody['RowErrors'] as List).first;
          if (firstError is Map && firstError.containsKey('ErrorDescription')) {
            errorMessage = firstError['ErrorDescription'];
          }
        }
        // Estrutura de erro do JsonAPIError (caso você use no futuro)
        else if (responseBody is Map && responseBody.containsKey('message')) {
          errorMessage = responseBody['message'];
        }

        // Lança uma exceção com a mensagem de erro específica.
        throw Exception(errorMessage);
      }
    } catch (e) {
      // Se o erro já for uma exceção com a mensagem certa, apenas re-lança.
      // Se for um erro de parsing ou de rede, a mensagem será genérica.
      print('Erro na camada de rede (HttpApiService): $e');
      rethrow; // Re-lança a exceção para ser tratada pela camada do repositório/viewModel.
    }
  }

  @override
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? queryParams,
    String? username,
    String? password,
  }) async {
    final url = Uri.parse(
      '$_apiBaseUrl$endpoint',
    ).replace(queryParameters: queryParams);

    print('DELETE -> $url');

    // ✅ ADICIONE: Debug dos query params
    if (queryParams != null && queryParams.isNotEmpty) {
      print('📋 Query Params:');
      queryParams.forEach((key, value) {
        print('   $key: $value');
      });
    }

    try {
      final headers = _createHeaders(username: username, password: password);

      final response = await http.delete(
        url,
        headers: headers,
      );

      // ✅ ADICIONE: Debug da resposta
      print('📥 Response Status: ${response.statusCode}');
      if (response.body.isNotEmpty) {
        print('📥 Response Body: ${response.body}');
      }

      final responseBody = response.body.isNotEmpty
          ? json.decode(response.body)
          : {};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseBody;
      } else {
        String errorMessage = 'Erro desconhecido (${response.statusCode})';

        if (responseBody is Map &&
            responseBody.containsKey('RowErrors') &&
            responseBody['RowErrors'] is List &&
            (responseBody['RowErrors'] as List).isNotEmpty) {
          final firstError = (responseBody['RowErrors'] as List).first;
          if (firstError is Map && firstError.containsKey('ErrorDescription')) {
            errorMessage = firstError['ErrorDescription'];
          }
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Erro na camada de rede (HttpApiService): $e');
      rethrow;
    }
  }
}
