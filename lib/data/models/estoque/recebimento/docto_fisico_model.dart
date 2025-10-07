import 'package:wmsapp/data/models/estoque/recebimento/it_doc_fisico_model.dart';

// ============================================================================
// DOCTO FISICO MODEL - Representa um documento físico (nota fiscal)
// ============================================================================

class DoctoFisicoModel {
  final String codEstabel;
  final int codEmitente;
  final String nomeAbreviado;
  final String nroDocto;
  final String serieDocto;
  final DateTime dtEmissao;
  final String tipoNota;
  final String situacao;
  final String status;
  final int totalItems;
  final List<ItDocFisicoModel> itensDoc;

  DoctoFisicoModel({
    required this.codEstabel,
    required this.codEmitente,
    required this.nomeAbreviado,
    required this.nroDocto,
    required this.serieDocto,
    required this.dtEmissao,
    required this.tipoNota,
    required this.situacao,
    required this.status,
    required this.totalItems,
    required this.itensDoc,
  });

  // ==========================================================================
  // CONSTRUTOR: From JSON
  // ==========================================================================
  factory DoctoFisicoModel.fromJson(Map<String, dynamic> json) {
    final itensJson = json['itensDoc'] as List? ?? [];

    return DoctoFisicoModel(
      codEstabel: json['cod-estabel']?.toString() ?? '',
      codEmitente: json['cod-emitente'] is int
          ? json['cod-emitente']
          : int.tryParse(json['cod-emitente']?.toString() ?? '') ?? 0,
      nomeAbreviado: json['nome-abrev']?.toString() ?? '',
      nroDocto: json['nro-docto']?.toString() ?? '',
      serieDocto: json['serie-docto']?.toString() ?? '',
      dtEmissao: (json['dt-emissao'] is String && json['dt-emissao'] != '')
          ? DateTime.tryParse(json['dt-emissao']) ?? DateTime.now()
          : DateTime.now(),
      tipoNota: _convertTipoNota(json['tipo-nota']),
      situacao: _convertSituacao(json['situacao']),
      status: _convertStatus(json['status-atual']),
      totalItems: json['total-items'] is int
          ? json['total-items']
          : int.tryParse(json['total-items']?.toString() ?? '') ?? 0,
      itensDoc: itensJson
          .map((item) => ItDocFisicoModel.fromJson(item))
          .toList(),
    );
  }
  /*
  factory DoctoFisicoModel.fromJson(Map<String, dynamic> json) {
    final itensJson = json['itensDoc'] as List? ?? [];

    return DoctoFisicoModel(
      codEstabel: json['cod-estabel']?.toString() ?? '',
      codEmitente: json['cod-emitente'] as int? ?? 0,
      nomeAbreviado: json['nome-abrev'] is String ? json['nome-abrev'] : '',
      nroDocto: json['nro-docto'] is String ? json['nro-docto'] : '',
      serieDocto: json['serie-docto'] is String ? json['serie-docto'] : '',
      dtEmissao: (json['dt-emissao'] is String && json['dt-emissao'] != '')
          ? DateTime.parse(json['dt-emissao'])
          : DateTime.now(),
      tipoNota: _convertTipoNota(json['tipo-nota']),
      situacao: _convertSituacao(json['situacao']),
      status: _convertStatus(json['status-atual']),
      totalItems: json['total-items'] as int? ?? 0,
      itensDoc: itensJson
          .map((item) => ItDocFisicoModel.fromJson(item))
          .toList(),
    );
  }
  */
  // ==========================================================================
  // CONVERSORES DE TIPOS
  // ==========================================================================

  static String _convertTipoNota(dynamic value) {
    if (value == null) return 'Normal';
    if (value is String) return value;

    switch (value) {
      case 1:
        return 'Entrada';
      case 2:
        return 'Saída';
      case 3:
        return 'Devolução';
      default:
        return value.toString();
    }
  }

  static String _convertSituacao(dynamic value) {
    if (value == null) return 'Normal';
    if (value is String) return value;

    switch (value) {
      case 0:
        return 'Cancelada';
      case 1:
        return 'Normal';
      case 2:
        return 'Complementar';
      case 3:
        return 'Devolução';
      default:
        return value.toString();
    }
  }

  static String _convertStatus(dynamic value) {
    if (value == null) return 'Pendente';
    if (value is String) return value.trim();

    switch (value) {
      case 0:
        return 'Pendente';
      case 1:
        return 'Em Conferência';
      case 2:
        return 'Conferido';
      case 3:
        return 'Finalizado';
      default:
        return value.toString();
    }
  }
  // ==========================================================================
  // MÉTODO: To JSON
  // ==========================================================================

  Map<String, dynamic> toJson() {
    return {
      'cod-estabel': codEstabel,
      'cod-emitente': codEmitente,
      'nro-docto': nroDocto,
      'serie-docto': serieDocto,
      'dt-emissao': dtEmissao.toIso8601String(),
      'tipo-nota': tipoNota,
      'situacao': situacao,
      'status-atual': status,
      'total-items': totalItems,
      'itensDoc': itensDoc.map((item) => item.toJson()).toList(),
    };
  }

  // ==========================================================================
  // MÉTODO: Copy With
  // ==========================================================================

  DoctoFisicoModel copyWith({
    String? codEstabel,
    int? codEmitente,
    String? nomeAbreviado,
    String? nroDocto,
    String? serieDocto,
    DateTime? dtEmissao,
    String? tipoNota,
    String? situacao,
    String? status,
    int? totalItems,
    List<ItDocFisicoModel>? itensDoc,
  }) {
    return DoctoFisicoModel(
      codEstabel: codEstabel ?? this.codEstabel,
      codEmitente: codEmitente ?? this.codEmitente,
      nomeAbreviado: nomeAbreviado ?? this.nomeAbreviado,
      nroDocto: nroDocto ?? this.nroDocto,
      serieDocto: serieDocto ?? this.serieDocto,
      dtEmissao: dtEmissao ?? this.dtEmissao,
      tipoNota: tipoNota ?? this.tipoNota,
      situacao: situacao ?? this.situacao,
      status: status ?? this.status,
      totalItems: totalItems ?? this.totalItems,
      itensDoc: itensDoc ?? this.itensDoc,
    );
  }

  // ==========================================================================
  // GETTERS - Validações e Cálculos
  // ==========================================================================

  List<ItDocFisicoModel> get itensComDivergencia {
    return itensDoc.where((item) => item.temDivergencia).toList();
  }

  bool get temDivergencias {
    return itensComDivergencia.isNotEmpty;
  }

  bool get todosItensConferidos {
    return itensDoc.every((item) {
      // Se controla lote/endereço, precisa ter rateios válidos
      if (item.controlaLote || item.controlaEndereco) {
        if (!item.hasRateios) return false;
        return item.rateios?.every((rat) => rat.qtdeLote > 0) ?? false;
      }
      // Se não controla, só verifica se foi conferido
      return item.qtdeConferida > 0;
    });
  }

  bool get conferenciaOk {
    return todosItensConferidos && !temDivergencias;
  }

  bool get podeFinalizar {
    return todosItensConferidos;
  }

  int get quantidadeItensConferidos {
    return itensDoc.where((item) => item.foiConferido).length;
  }

  double get porcentagemConferida {
    if (itensDoc.isEmpty) return 0.0;
    return (quantidadeItensConferidos / itensDoc.length) * 100;
  }

  bool get isUrgente {
    return status.toLowerCase().contains('urgente');
  }

  bool get isPendente {
    return status.toLowerCase().contains('pendente');
  }

  String get dtEmissaoFormatada {
    return '${dtEmissao.day.toString().padLeft(2, '0')}/'
        '${dtEmissao.month.toString().padLeft(2, '0')}/'
        '${dtEmissao.year}';
  }

  String get chaveDocumento {
    return '$codEstabel-$codEmitente-$nroDocto-$serieDocto';
  }

  // ==========================================================================
  // MÉTODOS AUXILIARES
  // ==========================================================================

  @override
  String toString() {
    return 'DoctoFisicoModel(nroDocto: $nroDocto, codEstabel: $codEstabel, totalItems: $totalItems)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DoctoFisicoModel && other.chaveDocumento == chaveDocumento;
  }

  @override
  int get hashCode => chaveDocumento.hashCode;
}
