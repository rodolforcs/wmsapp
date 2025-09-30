/// AppPermissionsModel: Representa o objeto de permissões retornado pela API.
///
/// Cada propriedade booleana corresponde a uma permissão de módulo.
/// O método `fromJson` é um "factory constructor" que sabe como criar
/// uma instância deste modelo a partir de um mapa de dados (o JSON decodificado).
///
class AppPermissionsModel {
  AppPermissionsModel({
    this.estoque = false,
    this.expedicao = false,
    this.portaria = false,
    this.producao = false,
    this.qualidade = false,
    this.recebimento = false,
  });
  final bool estoque;
  final bool expedicao;
  final bool producao;
  final bool qualidade;
  final bool recebimento;
  final bool portaria;
  // Adicione outras permissões granulares se precisar delas no futuro.
  // Ex: final bool lRegEnt;

  /// Factory constructor para criar uma instância a partir de um json.
  factory AppPermissionsModel.fromJson(Map<String, dynamic> json) {
    return AppPermissionsModel(
      // Acessa a chave do JSON e usa 'false' como padrão se a chave não existir.
      estoque: json['estoque'] ?? false,
      expedicao: json['expedicao'] ?? false,
      producao: json['producao'] ?? false,
      qualidade: json['qualidade'] ?? false,
      recebimento: json['recebimento'] ?? false,
      portaria: json['portaria'] ?? false,
    );
  }
}
