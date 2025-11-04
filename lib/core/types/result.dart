/// Classe para encapsular resultado de operações (sucesso ou erro)
///
/// Usado em repositories e services para retornar resultados
/// de operações que podem falhar.
///
/// Exemplo:
/// ```dart
/// Future<Result<User>> login() async {
///   try {
///     final user = await api.login();
///     return Result.success(user);
///   } catch (e) {
///     return Result.failure('Erro ao fazer login: $e');
///   }
/// }
/// ```
class Result<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  Result._({
    this.data,
    this.error,
    required this.isSuccess,
  });

  /// Cria um resultado de sucesso
  factory Result.success(T? data) {
    return Result._(
      data: data,
      isSuccess: true,
    );
  }

  /// Cria um resultado de falha
  factory Result.failure(String error) {
    return Result._(
      error: error,
      isSuccess: false,
    );
  }

  /// Verifica se houve falha
  bool get isFailure => !isSuccess;
}
