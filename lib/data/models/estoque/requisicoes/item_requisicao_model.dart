// lib/data/models/estoque/requisicoes/item_requisicao_model.dart

/// 📦 Modelo de Item da Requisição de Estoque
///
/// Baseado na tabela: it-requisicao
/// Representa um item (produto) dentro de uma requisição
class ItemRequisicaoModel {
  // Campos da tabela it-requisicao
  final int nrRequisicao; // nr-requisicao
  final int sequencia; // sequencia
  final String itCodigo; // it-codigo
  final double qtRequisitada; // qt-requisitada
  final double qtAtendida; // qt-atendida
  final double qtAAtender; // qt-a-atender
  final String? ctCodigo; // ct-codigo
  final String? scCodigo; // sc-codigo
  final String? narrativa; // narrativa
  final DateTime? dtEntrega; // dt-entrega
  final int situacao; // situacao
  final String codEstabel; // cod-estabel
  final String? codDepos; // cod-depos
  final String? lote; // lote
  final double qtDevolvida; // qt-devolvida
  final double qtADevolver; // qt-a-devolver
  final String nomeAbrev; // nome-abrev
  final String? codRefer; // cod-refer
  final DateTime? dtAtend; // dt-atend
  final String? epCodigo; // ep-codigo
  final double? valItem; // val-item
  final String? un; // un (unidade)
  final double? precoUnit; // preco-unit
  final String? codLocaliz; // cod-localiz
  final String? contaContabil; // conta-contabil
  final String? nomeAprov; // nome-aprov
  final int? prioridadeAprov; // prioridade-aprov
  final int estado; // estado
  final String? codUnidNegoc; // cod-unid-negoc
  final String? hraEntrega; // hra-entrega
  final int tpRequis; // tp-requis
  final String? respRetirada; // resp-retirada

  // Campos adicionais (podem vir do backend)
  final String? descItem; // Descrição do item
  final bool? controlaLote; // Se controla lote
  final bool? controlaLocaliz; // Se controla localização
  final DateTime? dtValidade; // Data validade do lote

  // Campos de controle (não existem no ERP)
  final int versao; // Versão para controle de concorrência
  final String? hashState; // Hash MD5 para detectar mudanças
  final bool alteradoLocal; // Flag de alteração local
  final DateTime? dhUltAlter; // Data/hora última alteração

  ItemRequisicaoModel({
    required this.nrRequisicao,
    required this.sequencia,
    required this.itCodigo,
    required this.qtRequisitada,
    this.qtAtendida = 0.0,
    double? qtAAtender,
    this.ctCodigo,
    this.scCodigo,
    this.narrativa,
    this.dtEntrega,
    this.situacao = 1,
    required this.codEstabel,
    this.codDepos,
    this.lote,
    this.qtDevolvida = 0.0,
    this.qtADevolver = 0.0,
    this.nomeAbrev = '',
    this.codRefer,
    this.dtAtend,
    this.epCodigo,
    this.valItem,
    this.un,
    this.precoUnit,
    this.codLocaliz,
    this.contaContabil,
    this.nomeAprov,
    this.prioridadeAprov,
    this.estado = 1,
    this.codUnidNegoc,
    this.hraEntrega,
    this.tpRequis = 1,
    this.respRetirada,
    this.descItem,
    this.controlaLote,
    this.controlaLocaliz,
    this.dtValidade,
    this.versao = 1,
    this.hashState,
    this.alteradoLocal = false,
    this.dhUltAlter,
  }) : qtAAtender = qtAAtender ?? (qtRequisitada - qtAtendida);

  // Getters úteis
  bool get foiAtendido => qtAtendida > 0;
  bool get isAtendimentoParcial => qtAtendida > 0 && qtAtendida < qtRequisitada;
  bool get isAtendimentoCompleto => qtAtendida >= qtRequisitada;
  bool get isPendente => qtAAtender > 0;

  // Progresso do atendimento (0.0 a 1.0)
  double get progressoAtendimento {
    if (qtRequisitada == 0) return 0.0;
    return qtAtendida / qtRequisitada;
  }

  // Valida se pode atender (tem quantidade pendente)
  bool get podeAtender => qtAAtender > 0;

  // Valida se precisa de lote
  bool get precisaLote => controlaLote == true;

  // Valida se precisa de localização
  bool get precisaLocaliz => controlaLocaliz == true;

  // ✅ fromJson
  factory ItemRequisicaoModel.fromJson(Map<String, dynamic> json) {
    return ItemRequisicaoModel(
      nrRequisicao: json['nr-requisicao'] ?? json['nrRequisicao'] ?? 0,
      sequencia: json['sequencia'] ?? 0,
      itCodigo: json['it-codigo'] ?? json['itCodigo'] ?? '',
      qtRequisitada: (json['qt-requisitada'] ?? json['qtRequisitada'] ?? 0.0)
          .toDouble(),
      qtAtendida: (json['qt-atendida'] ?? json['qtAtendida'] ?? 0.0).toDouble(),
      qtAAtender: (json['qt-a-atender'] ?? json['qtAAtender'])?.toDouble(),
      ctCodigo: json['ct-codigo'] ?? json['ctCodigo'],
      scCodigo: json['sc-codigo'] ?? json['scCodigo'],
      narrativa: json['narrativa'],
      dtEntrega: json['dt-entrega'] != null
          ? DateTime.parse(json['dt-entrega'])
          : json['dtEntrega'] != null
          ? DateTime.parse(json['dtEntrega'])
          : null,
      situacao: json['situacao'] ?? 1,
      codEstabel: json['cod-estabel'] ?? json['codEstabel'] ?? '',
      codDepos: json['cod-depos'] ?? json['codDepos'],
      lote: json['lote'],
      qtDevolvida: (json['qt-devolvida'] ?? json['qtDevolvida'] ?? 0.0)
          .toDouble(),
      qtADevolver: (json['qt-a-devolver'] ?? json['qtADevolver'] ?? 0.0)
          .toDouble(),
      nomeAbrev: json['nome-abrev'] ?? json['nomeAbrev'] ?? '',
      codRefer: json['cod-refer'] ?? json['codRefer'],
      dtAtend: json['dt-atend'] != null
          ? DateTime.parse(json['dt-atend'])
          : json['dtAtend'] != null
          ? DateTime.parse(json['dtAtend'])
          : null,
      epCodigo: json['ep-codigo'] ?? json['epCodigo'],
      valItem: (json['val-item'] ?? json['valItem'])?.toDouble(),
      un: json['un'] ?? 'UN',
      precoUnit: (json['preco-unit'] ?? json['precoUnit'])?.toDouble(),
      codLocaliz: json['cod-localiz'] ?? json['codLocaliz'],
      contaContabil: json['conta-contabil'] ?? json['contaContabil'],
      nomeAprov: json['nome-aprov'] ?? json['nomeAprov'],
      prioridadeAprov: json['prioridade-aprov'] ?? json['prioridadeAprov'],
      estado: json['estado'] ?? 1,
      codUnidNegoc: json['cod-unid-negoc'] ?? json['codUnidNegoc'],
      hraEntrega: json['hra-entrega'] ?? json['hraEntrega'],
      tpRequis: json['tp-requis'] ?? json['tpRequis'] ?? 1,
      respRetirada: json['resp-retirada'] ?? json['respRetirada'],
      descItem: json['desc-item'] ?? json['descItem'],
      controlaLote: json['controla-lote'] ?? json['controlaLote'],
      controlaLocaliz: json['controla-localiz'] ?? json['controlaLocaliz'],
      dtValidade: json['dt-validade'] != null
          ? DateTime.parse(json['dt-validade'])
          : json['dtValidade'] != null
          ? DateTime.parse(json['dtValidade'])
          : null,
      versao: json['versao'] ?? 1,
      hashState: json['hash-state'] ?? json['hashState'],
      alteradoLocal: false,
      dhUltAlter: json['dh-ult-alter'] != null
          ? DateTime.parse(json['dh-ult-alter'])
          : json['dhUltAlter'] != null
          ? DateTime.parse(json['dhUltAlter'])
          : null,
    );
  }

  // ✅ toJson (campos principais)
  Map<String, dynamic> toJson() {
    return {
      'nr-requisicao': nrRequisicao,
      'sequencia': sequencia,
      'it-codigo': itCodigo,
      'qt-requisitada': qtRequisitada,
      'qt-atendida': qtAtendida,
      'qt-a-atender': qtAAtender,
      'cod-estabel': codEstabel,
      if (codDepos != null) 'cod-depos': codDepos,
      if (lote != null) 'lote': lote,
      if (codLocaliz != null) 'cod-localiz': codLocaliz,
      'un': un,
      'situacao': situacao,
      'versao': versao,
      if (hashState != null) 'hash-state': hashState,
    };
  }

  // ✅ copyWith (campos principais)
  ItemRequisicaoModel copyWith({
    int? nrRequisicao,
    int? sequencia,
    String? itCodigo,
    double? qtRequisitada,
    double? qtAtendida,
    double? qtAAtender,
    String? ctCodigo,
    String? scCodigo,
    String? narrativa,
    DateTime? dtEntrega,
    int? situacao,
    String? codEstabel,
    String? codDepos,
    String? lote,
    double? qtDevolvida,
    double? qtADevolver,
    DateTime? dtAtend,
    String? codLocaliz,
    int? prioridadeAprov,
    int? estado,
    String? codUnidNegoc,
    String? hraEntrega,
    int? tpRequis,
    DateTime? dtValidade,
    String? descItem,
    bool? controlaLote,
    bool? controlaLocaliz,
    int? versao,
    String? hashState,
    bool? alteradoLocal,
    DateTime? dhUltAlter,
  }) {
    return ItemRequisicaoModel(
      nrRequisicao: nrRequisicao ?? this.nrRequisicao,
      sequencia: sequencia ?? this.sequencia,
      itCodigo: itCodigo ?? this.itCodigo,
      qtRequisitada: qtRequisitada ?? this.qtRequisitada,
      qtAtendida: qtAtendida ?? this.qtAtendida,
      qtAAtender: qtAAtender ?? this.qtAAtender,
      ctCodigo: this.ctCodigo,
      scCodigo: this.scCodigo,
      narrativa: this.narrativa,
      dtEntrega: this.dtEntrega,
      situacao: this.situacao,
      codEstabel: codEstabel ?? this.codEstabel,
      codDepos: codDepos ?? this.codDepos,
      lote: lote ?? this.lote,
      qtDevolvida: this.qtDevolvida,
      qtADevolver: this.qtADevolver,
      dtAtend: this.dtAtend,
      codLocaliz: codLocaliz ?? this.codLocaliz,
      prioridadeAprov: this.prioridadeAprov,
      estado: this.estado,
      codUnidNegoc: this.codUnidNegoc,
      hraEntrega: this.hraEntrega,
      tpRequis: this.tpRequis,
      descItem: descItem ?? this.descItem,
      controlaLote: controlaLote ?? this.controlaLote,
      controlaLocaliz: controlaLocaliz ?? this.controlaLocaliz,
      dtValidade: dtValidade ?? this.dtValidade,
      versao: versao ?? this.versao,
      hashState: hashState ?? this.hashState,
      alteradoLocal: alteradoLocal ?? this.alteradoLocal,
      dhUltAlter: this.dhUltAlter,
    );
  }

  @override
  String toString() {
    return 'ItemRequisicaoModel(seq: $sequencia, item: $itCodigo, '
        'atendida: $qtAtendida/$qtRequisitada $un)';
  }
}
