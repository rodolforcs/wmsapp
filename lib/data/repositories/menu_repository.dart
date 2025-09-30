import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wmsapp/data/models/app_permissions_model.dart';
import 'package:wmsapp/data/services/i_api_service.dart';

/// Modelo para encapsular os dados retornados após o login.
class UserDataModel {
  final String codUsuario;
  final AppPermissionsModel permissions;

  UserDataModel({required this.codUsuario, required this.permissions});
}

class MenuRepository {
  final IApiService _apiService;
  MenuRepository({required IApiService apiService}) : _apiService = apiService;

  /// Busca os dados do usuário (código e permissões) após a autenticação.
  Future<UserDataModel> getUserData({
    required String username,
    required String password,
  }) async {
    final userForAuth = '$username@${dotenv.env['DOMAIN']}';
    const String endpoint =
        'sec/v1/api_get_user_modules/'; // Endpoint que retorna permissões e cod_usuario

    try {
      final responseBody = await _apiService.get(
        endpoint,
        queryParams: {"dominio": dotenv.env['DOMAIN']!, "usuario": username},
        username: userForAuth,
        password: password,
      );

      final List<dynamic> items = responseBody['items'];
      if (items.isEmpty) {
        throw Exception('Resposta da API de dados do usuário está vazia.');
      }
      final firstItem = items[0];

      // Validação robusta para o cod_usuario
      if (firstItem['cod_usuario'] == null ||
          (firstItem['cod_usuario'] as String).isEmpty) {
        throw Exception(
          "'cod_usuario' não encontrado ou está vazio na resposta da API.",
        );
      }

      // Cria os dois modelos a partir da mesma resposta
      final String codUsuario = firstItem['cod_usuario'];
      final AppPermissionsModel permissions = AppPermissionsModel.fromJson(
        firstItem,
      );

      print(
        '[MenuRepository] Dados do usuário e permissões obtidos com sucesso.',
      );

      // Retorna o objeto combinado
      return UserDataModel(codUsuario: codUsuario, permissions: permissions);
    } catch (e) {
      print('[MenuRepository] Erro ao buscar dados do usuário: $e');
      rethrow;
    }
  }
}
