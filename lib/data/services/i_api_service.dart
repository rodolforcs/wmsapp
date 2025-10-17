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
}
