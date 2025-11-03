abstract class IApiService {
  //Adicionamos os métodos
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
    String? username,
    String? password,
  });

  Future<Map<String, dynamic>> post(
    String endpoint, {
    required Map<String, dynamic> body,
    String? username,
    String? password,
  });

  /// Deleta dados ✅
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? queryParams, // Alguns DELETE precisam de body
    String? username,
    String? password,
  });
}
