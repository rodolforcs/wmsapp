class AppUser {
  const AppUser({
    required this.username,
    required this.estabelecimentos,
    this.selectedEstabelecimento,
    this.token,
  });
  final String username;
  final List<String> estabelecimentos;
  final String? token;
  final String? selectedEstabelecimento;
}
