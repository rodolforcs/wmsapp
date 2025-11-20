class ChecklistRespostaModel {
  final int codChecklist;
  final int sequenciaCat;
  final int sequenciaItem;
  final bool? respostaBoolean;
  final String? respostaText;
  final double? respostaNumber;
  final DateTime? respostaDate;
  final String? observacao;
  final DateTime? dtResposta;
  final bool conforme;

  ChecklistRespostaModel({
    required this.codChecklist,
    required this.sequenciaCat,
    required this.sequenciaItem,
    this.respostaBoolean,
    this.respostaText,
    this.respostaNumber,
    this.respostaDate,
    this.observacao,
    this.dtResposta,
    this.conforme = true,
  });

  // ==========================================================================
  // FROM JSON
  // ==========================================================================

  factory ChecklistRespostaModel.fromJson(Map<String, dynamic> json) {
    return ChecklistRespostaModel(
      codChecklist: json['cod-checklist'] as int? ?? 0,
      sequenciaCat: json['sequencia-cat'] as int? ?? 0,
      sequenciaItem: json['sequencia-item'] as int? ?? 0,
      respostaBoolean: json['resposta-boolean'] as bool?,
      respostaText: json['resposta-text'] as String?,
      respostaNumber: (json['resposta-number'] as num?)?.toDouble(),
      respostaDate: json['resposta-date'] != null
          ? DateTime.parse(json['resposta-date'] as String)
          : null,
      observacao: json['observacao'] as String?,
      dtResposta: json['dt-resposta'] != null
          ? DateTime.parse(json['dt-resposta'] as String)
          : null,
      conforme: json['conforme'] as bool? ?? true,
    );
  }

  // ==========================================================================
  // TO JSON (para enviar ao backend)
  // ==========================================================================

  Map<String, dynamic> toJson() {
    return {
      'cod-checklist': codChecklist,
      'sequencia-cat': sequenciaCat,
      'sequencia-item': sequenciaItem,
      if (respostaBoolean != null) 'resposta-boolean': respostaBoolean,
      if (respostaText != null) 'resposta-text': respostaText,
      if (respostaNumber != null) 'resposta-number': respostaNumber,
      if (respostaDate != null)
        'resposta-date': respostaDate!.toIso8601String(),
      if (observacao != null && observacao!.isNotEmpty)
        'observacao': observacao,
      if (dtResposta != null) 'dt-resposta': dtResposta!.toIso8601String(),
      'conforme': conforme,
    };
  }

  // ==========================================================================
  // COPY WITH
  // ==========================================================================

  ChecklistRespostaModel copyWith({
    int? codChecklist,
    int? sequenciaCat,
    int? sequenciaItem,
    bool? respostaBoolean,
    String? respostaText,
    double? respostaNumber,
    DateTime? respostaDate,
    String? observacao,
    DateTime? dtResposta,
    bool? conforme,
  }) {
    return ChecklistRespostaModel(
      codChecklist: codChecklist ?? this.codChecklist,
      sequenciaCat: sequenciaCat ?? this.sequenciaCat,
      sequenciaItem: sequenciaItem ?? this.sequenciaItem,
      respostaBoolean: respostaBoolean ?? this.respostaBoolean,
      respostaText: respostaText ?? this.respostaText,
      respostaNumber: respostaNumber ?? this.respostaNumber,
      respostaDate: respostaDate ?? this.respostaDate,
      observacao: observacao ?? this.observacao,
      dtResposta: dtResposta ?? this.dtResposta,
      conforme: conforme ?? this.conforme,
    );
  }
}
