import 'package:wmsapp/data/services/i_api_service.dart';

/// MenuRepository: Responsável por toda a lógica de negócio relacionada ao menu.
///
/// Abstrai a fonte de dados para as permissões dos módulos. O ViewModel
/// usará este repositório sem saber se os dados vêm de uma API, cache, etc.
///

class MenuRepository {
  MenuRepository({required IApiService apiService}) : _apiService = apiService;

  final IApiService _apiService;

  /// Busca a lista de nomes de módulos que o usuário atual tem permissão para acessar.
  ///
  /// No futuro, pode receber um `userId` ou usar um token de autenticação
  /// armazenado no `_apiService`.
  ///

  Future<List<String>> getModulePermissions() async {
    // Delega a chamada para o serviço de API.
    // O repositório pode, no futuro, adicionar lógica de cache aqui.
    try {
      final permissions = await _apiService.getModulePermissions();
      return permissions;
    } catch (e) {
      // Propaga o erro para o ViewModel tratar.
      print('Erro ao buscar permissões no MenuRepository: $e');
      rethrow;
    }
  }
}
