//import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wmsapp/data/services/i_api_service.dart'; // Pode ser útil para debug

class AuthRepository {
  final IApiService _apiService;
  AuthRepository({required IApiService apiService}) : _apiService = apiService;

  Future<List<String>> validateUserAndGetEstabelecimentos(
    String username,
  ) async {
    final queryParams = {
      "dominio": dotenv.env['DOMAIN']!,
      "usuario": username,
    };

    final apiUser = dotenv.env['USERAPI'];
    final pwUser = dotenv.env['PWAPI'];

    print('usuário: $apiUser Senha: $pwUser');

    try {
      // 1. A chamada à API não muda.
      final responseBody = await _apiService.get(
        'sec/v1/api_get_estab_user/',
        queryParams: queryParams,
        username: apiUser,
        password: pwUser,
      );

      /******************************************************************
       * CORREÇÃO PRINCIPAL AQUI
       * Verificamos a estrutura da resposta JSON.
       ******************************************************************/

      // 2. Verifique se a resposta contém a chave de erro.
      // O objeto de erro pode estar aninhado dentro de 'payload'.
      if (responseBody.containsKey('payload') &&
          responseBody['payload'] is Map &&
          responseBody['payload'].containsKey('RowErrors')) {
        // Extrai a lista de erros.
        final List<dynamic> errors = responseBody['payload']['RowErrors'];
        if (errors.isNotEmpty) {
          // Pega a descrição do primeiro erro e lança a exceção.
          final String errorMessage =
              errors[0]['ErrorDescription'] ?? 'Erro desconhecido do backend.';
          throw Exception(errorMessage);
        }
      }

      // 3. Se não for um erro, trate como sucesso. Verifique se a chave 'payload' existe.
      if (responseBody.containsKey('items') && responseBody['items'] is List) {
        // O array de resultado está DENTRO da chave 'payload'.
        final List<dynamic> retorno = responseBody['items'];

        if (retorno.isNotEmpty) {
          final List<String> estabelecimentos = retorno
              .map((item) => item['cod-estabel'].toString())
              .toList();
          return estabelecimentos;
        } else {
          // Se o payload está vazio, isso pode ser um caso de "usuário sem permissões".
          // A API Progress deveria ter retornado um erro 400, mas por segurança, tratamos aqui.
          throw Exception(
            'Usuário válido, mas sem estabelecimentos associados.',
          );
        }
      }

      // 4. Se a estrutura do JSON não for nem de sucesso nem de erro, é um formato inesperado.
      throw Exception('Formato de resposta inesperado da API.');
    } catch (e) {
      // Agora podemos dar uma mensagem de erro melhor para o 401
      if (e.toString().contains('Status code 401')) {
        throw Exception(
          'Credenciais genéricas inválidas. Verifique a configuração do app.',
        );
      }
      // Re-lança outras exceções
      rethrow;
    }
  }

  // NOVO MÉTODO PARA O LOGIN REAL (com as credenciais do usuário)
  Future<Map<String, dynamic>> login(
    String domain,
    String username,
    String password,
  ) async {
    // Este método pode chamar uma API de "login" ou apenas validar as credenciais
    // fazendo uma chamada simples para qualquer endpoint protegido.
    // Por exemplo, podemos chamar a mesma API de estabelecimentos. Se ela retornar 200 OK,
    // as credenciais são válidas.

    final queryParams = {
      "dominio": domain,
      "usuario": username,
    };
    final userWithDomain =
        '$username@${dotenv.env['DOMAIN']}'; // Formato usuario@dominio

    try {
      final responseBody = await _apiService.get(
        'sec/v1/api_get_user/',
        queryParams: queryParams,
        username: userWithDomain, // Passando o usuário REAL
        password: password, // Passando a senha REAL
      );

      // Retorna o corpo da resposta para quem chamou (o LoginViewModel)
      // RETORNA o corpo da resposta para o LoginViewModel.
      print(
        '[AuthRepository] Login bem-sucedido. Retornando dados do usuário.',
      );
      // A função agora retorna o corpo da resposta, como esperado.
      return responseBody;
      // Se a chamada acima não lançar uma exceção, o login é considerado um sucesso.
    } catch (e) {
      // Se a chamada falhar (ex: 401 Unauthorized), a autenticação falhou.
      throw Exception('Usuário ou senha inválidos.');
    }
  }
}
