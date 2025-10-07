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
    this.podeReceber = false,
    this.podeSeparar = false,
    this.podeTransferir = false,
    this.podeEmitirFicha = false,
    this.podeBaixarReq = false,
    this.podeEmitirChecklist = false,
  });
  final bool estoque;
  final bool expedicao;
  final bool producao;
  final bool qualidade;
  final bool recebimento;
  final bool portaria;
  // Ex: final bool lRegEnt;

  // --- ADICIONE AS PERMISSÕES DAS SUB-OPÇÕES AQUI ---
  final bool podeReceber; // Ex: "l-est-rec": true
  final bool podeSeparar; // Ex: "l-est-picking": true
  final bool podeTransferir; // Ex: "l-est-transf": true
  final bool podeEmitirFicha; // Ex: l-emis-ficha: true
  final bool podeBaixarReq; //Ex: l-est-baixa-req: true
  final bool podeEmitirChecklist; // Ex: l-est-checklist

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
      podeReceber: json['l-est-rec'] ?? false,
      podeSeparar: json['l-est-picking'] ?? false,
      podeTransferir: json['l-est-transf'] ?? false,
      podeEmitirFicha: json['l-emis-ficha'] ?? false,
      podeBaixarReq: json['l-est-baixa-req'] ?? false,
      podeEmitirChecklist: json['podeEmitirChecklist'] ?? false,
    );
  }
}
