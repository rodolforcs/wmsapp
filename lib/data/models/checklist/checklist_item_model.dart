// lib/data/models/checklist/checklist_item_model.dart

import 'dart:convert';
import 'checklist_resposta_model.dart';

class ChecklistItemModel {
  final int codChecklist;
  final int sequenciaCat;
  final int sequenciaItem;
  final String desItem;
  final String
  tipoResposta; // SELECT, BOOLEAN, TEXT, NUMBER, DATE, '' (vazio = informativo)
  final String opcoesSelect; // JSON array string: ["OK","NOK","N/A"]
  final bool obrigatorio;
  final bool permiteObs;
  final bool exigeFoto;
  final String tooltip;
  final int ordemExibicao;

  // Resposta (pode ser null se ainda não respondido)
  final ChecklistRespostaModel? resposta;

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
  // GETTERS DE VALIDAÇÃO
  // ==========================================================================

  /// ✅ Verifica se é um item INFORMATIVO (não requer resposta)
  bool get isInformativo {
    final tipo = tipoResposta.toUpperCase();

    // Tipos explicitamente informativos
    if (tipo.isEmpty || tipo == 'INFO' || tipo == 'INFORMATIVO') {
      return true;
    }

    // ✅ TEXT + não obrigatório = informativo
    if (tipo == 'TEXT' && !obrigatorio) {
      return true;
    }

    return false;
  }

  /// ✅ Verifica se o item foi respondido
  bool get isRespondido {
    // ✅ Item informativo sempre retorna true
    if (isInformativo) return true;

    // Verifica se tem resposta
    if (resposta == null) return false;

    // Valida se a resposta está preenchida
    return resposta!.respostaText != null &&
            resposta!.respostaText!.isNotEmpty ||
        resposta!.respostaBoolean != null ||
        resposta!.respostaNumber != null ||
        resposta!.respostaDate != null;
  }

  /// ✅ Alias para compatibilidade
  bool get foiRespondido => isRespondido;

  /// ✅ Verifica se precisa resposta
  bool get precisaResposta => !isInformativo;

  bool get isConforme => resposta?.conforme ?? false;

  bool get temObservacao => resposta?.observacao?.isNotEmpty ?? false;

  // ==========================================================================
  // OPÇÕES DO SELECT
  // ==========================================================================

  List<String> get opcoes {
    try {
      final decoded = jsonDecode(opcoesSelect);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList();
      }
      return [];
    } catch (e) {
      return ['OK', 'NOK', 'N/A']; // fallback
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
      opcoesSelect: json['opcoes-select']?.toString() ?? '[]',
      obrigatorio: json['obrigatorio'] as bool? ?? false,
      permiteObs: json['permite-obs'] as bool? ?? false,
      exigeFoto: json['exige-foto'] as bool? ?? false,
      tooltip: json['toolti'] as String? ?? '',
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
      'toolti': tooltip,
      'ordem-exibicao': ordemExibicao,
      if (resposta != null) 'tt-item-resposta': [resposta!.toJson()],
    };
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
