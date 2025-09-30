import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wmsapp/data/models/app_permissions_model.dart';

class AppUser {
  final String codUsuario;
  final String username;

  // --- ADICIONE ESTE CAMPO ---
  final String password; // Senha em texto plano para o Basic Auth

  final List<String> estabelecimentos;
  final String? selectedEstabelecimento;
  final AppPermissionsModel permissionsModules;

  AppUser({
    required this.codUsuario,
    required this.username,

    // --- E ADICIONE ESTE PARÂMETRO AO CONSTRUTOR ---
    required this.password,

    required this.estabelecimentos,
    this.selectedEstabelecimento,
    required this.permissionsModules,
  });

  /// Helper para obter o username no formato do Basic Auth.
  String get usernameForAuth {
    final domain = dotenv.env['DOMAIN'];
    if (domain == null || domain.isEmpty) {
      throw Exception(
        "A variável 'DOMAIN' não está configurada no arquivo .env",
      );
    }
    return '$username@$domain';
  }

  @override
  String toString() {
    return 'AppUser(codUsuario: $codUsuario, username: $username)';
  }
}
