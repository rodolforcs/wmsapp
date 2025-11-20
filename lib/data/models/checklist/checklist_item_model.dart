import 'checklist_resposta_model.dart';

class ChecklistItemModel {
  final int codChecklist;
  final int sequenciaCat;
  final int sequenciaItem;
  final String desItem;
  final String tipoResposta; // SELECT, BOOLEAN, TEXT, NUMBER, DATE
  final String opcoesSelect; // JSON array string: ["OK","NOK","N/A"]
  final bool obrigatorio;
  final bool permiteObs;
  final bool exigeFoto;
  final String tooltip;
  final int ordemExibicao;

  // Resposta (pode ser null se ainda não respondido)
  ChecklistRespostaModel? resposta;

  ChecklistItemModel({
    required this.codChecklist,
    required this.sequenciaCat,
    required this.sequenciaItem,
    required this.desItem,
    required this.tipoResposta,
    required this.opcoesSelect,
    required this.obrigatorio,
    required this.permiteObs,
    required this.exigeFoto,
    required this.tooltip,
    required this.ordemExibicao,
    this.resposta,
  });

  // ==========================================================================
  // FROM JSON
  // ==========================================================================

  factory ChecklistItemModel.fromJson(Map<String, dynamic> json) {
    // Parse da resposta (se existir)
    ChecklistRespostaModel? resposta;

    // Verifica se tem array de respostas
    final respostasJson = json['tt-item-resposta'] as List?;
    if (respostasJson != null && respostasJson.isNotEmpty) {
      resposta = ChecklistRespostaModel.fromJson(
        respostasJson[0] as Map<String, dynamic>,
      );
    }

    return ChecklistItemModel(
      codChecklist: json['cod-checklist'] as int? ?? 0,
      sequenciaCat: json['sequencia-cat'] as int? ?? 0,
      sequenciaItem: json['sequencia-item'] as int? ?? 0,
      desItem: json['des-item'] as String? ?? '',
      tipoResposta: json['tipo-resposta'] as String? ?? 'TEXT',
      opcoesSelect: json['opcoes-select'] as String? ?? '[]',
      obrigatorio: json['obrigatorio'] as bool? ?? false,
      permiteObs: json['permite-obs'] as bool? ?? false,
      exigeFoto: json['exige-foto'] as bool? ?? false,
      tooltip: json['tooltip'] as String? ?? '',
      ordemExibicao: json['ordem-exibicao'] as int? ?? 0,
      resposta: resposta,
    );
  }

  // ==========================================================================
  // TO JSON
  // ==========================================================================

  Map<String, dynamic> toJson() {
    return {
      'cod-checklist': codChecklist,
      'sequencia-cat': sequenciaCat,
      'sequencia-item': sequenciaItem,
      'des-item': desItem,
      'tipo-resposta': tipoResposta,
      'opcoes-select': opcoesSelect,
      'obrigatorio': obrigatorio,
      'permite-obs': permiteObs,
      'exige-foto': exigeFoto,
      'tooltip': tooltip,
      'ordem-exibicao': ordemExibicao,
      if (resposta != null) 'tt-item-resposta': [resposta!.toJson()],
    };
  }

  // ==========================================================================
  // GETTERS
  // ==========================================================================

  bool get isRespondido => resposta != null && resposta!.dtResposta != null;

  bool get isConforme => resposta?.conforme ?? false;

  bool get temObservacao => resposta?.observacao?.isNotEmpty ?? false;

  /// Parse das opções do SELECT (JSON string para List)
  List<String> get opcoes {
    try {
      // Remove aspas extras e faz split
      final cleaned = opcoesSelect
          .replaceAll('[', '')
          .replaceAll(']', '')
          .replaceAll('"', '')
          .replaceAll("'", '');

      return cleaned.split(',').map((e) => e.trim()).toList();
    } catch (e) {
      return ['OK', 'NOK', 'N/A']; // Fallback padrão
    }
  }

  /// Texto da resposta para exibição
  String get respostaTexto {
    if (resposta == null) return '';

    switch (tipoResposta) {
      case 'BOOLEAN':
        return resposta!.respostaBoolean == true ? 'Sim' : 'Não';
      case 'SELECT':
        return resposta!.respostaText ?? '';
      case 'TEXT':
        return resposta!.respostaText ?? '';
      case 'NUMBER':
        return resposta!.respostaNumber?.toString() ?? '';
      case 'DATE':
        return resposta!.respostaDate != null
            ? _formatarData(resposta!.respostaDate!)
            : '';
      default:
        return '';
    }
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  // ==========================================================================
  // COPY WITH
  // ==========================================================================

  ChecklistItemModel copyWith({
    int? codChecklist,
    int? sequenciaCat,
    int? sequenciaItem,
    String? desItem,
    String? tipoResposta,
    String? opcoesSelect,
    bool? obrigatorio,
    bool? permiteObs,
    bool? exigeFoto,
    String? tooltip,
    int? ordemExibicao,
    ChecklistRespostaModel? resposta,
  }) {
    return ChecklistItemModel(
      codChecklist: codChecklist ?? this.codChecklist,
      sequenciaCat: sequenciaCat ?? this.sequenciaCat,
      sequenciaItem: sequenciaItem ?? this.sequenciaItem,
      desItem: desItem ?? this.desItem,
      tipoResposta: tipoResposta ?? this.tipoResposta,
      opcoesSelect: opcoesSelect ?? this.opcoesSelect,
      obrigatorio: obrigatorio ?? this.obrigatorio,
      permiteObs: permiteObs ?? this.permiteObs,
      exigeFoto: exigeFoto ?? this.exigeFoto,
      tooltip: tooltip ?? this.tooltip,
      ordemExibicao: ordemExibicao ?? this.ordemExibicao,
      resposta: resposta ?? this.resposta,
    );
  }

  // ==========================================================================
  // MÉTODO PARA ATUALIZAR RESPOSTA
  // ==========================================================================

  /// Cria uma nova resposta para este item
  ChecklistItemModel comResposta({
    bool? respostaBoolean,
    String? respostaText,
    double? respostaNumber,
    DateTime? respostaDate,
    String? observacao,
    bool? conforme,
  }) {
    final novaResposta = ChecklistRespostaModel(
      codChecklist: codChecklist,
      sequenciaCat: sequenciaCat,
      sequenciaItem: sequenciaItem,
      respostaBoolean: respostaBoolean,
      respostaText: respostaText,
      respostaNumber: respostaNumber,
      respostaDate: respostaDate,
      observacao: observacao,
      dtResposta: DateTime.now(),
      conforme: conforme ?? true,
    );

    return copyWith(resposta: novaResposta);
  }
}
