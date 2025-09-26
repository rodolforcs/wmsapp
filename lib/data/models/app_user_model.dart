class AppUser {
  const AppUser({
    required this.username,
    required this.estabelecimentos,
    this.selectedEstabelecimento,
    this.token,
    this.permissionsModules = const [],
  });
  final String username;
  final List<String> estabelecimentos;
  final String? token;
  final String? selectedEstabelecimento;
  final List<String> permissionsModules;
}
