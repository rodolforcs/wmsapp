// lib/data/models/estoque/recebimento/checklist_categoria_model.dart

import 'checklist_item_model.dart';

class ChecklistCategoriaModel {
  final int codChecklist;
  final int sequenciaCat;
  final String desCategoria;
  final int ordemExibicao;
  final bool obrigatorio;
  final String icone;
  final List<ChecklistItemModel> itens;

  ChecklistCategoriaModel({
    required this.codChecklist,
    required this.sequenciaCat,
    required this.desCategoria,
    required this.ordemExibicao,
    required this.obrigatorio,
    required this.icone,
    required this.itens,
  });

  // ==========================================================================
  // FROM JSON
  // ==========================================================================

  factory ChecklistCategoriaModel.fromJson(Map<String, dynamic> json) {
    final itensJson = json['tt-item-template'] as List? ?? [];

    return ChecklistCategoriaModel(
      codChecklist: json['cod-checklist'] as int? ?? 0,
      sequenciaCat: json['sequencia-cat'] as int? ?? 0,
      desCategoria: json['des-categoria'] as String? ?? '',
      ordemExibicao: json['ordem-exibicao'] as int? ?? 0,
      obrigatorio: json['obrigatorio'] as bool? ?? false,
      icone: json['icone'] as String? ?? '',
      itens: itensJson
          .map(
            (item) => ChecklistItemModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  // ==========================================================================
  // TO JSON
  // ==========================================================================

  Map<String, dynamic> toJson() {
    return {
      'cod-checklist': codChecklist,
      'sequencia-cat': sequenciaCat,
      'des-categoria': desCategoria,
      'ordem-exibicao': ordemExibicao,
      'obrigatorio': obrigatorio,
      'icone': icone,
      'tt-item-template': itens.map((item) => item.toJson()).toList(),
    };
  }

  // ==========================================================================
  // GETTERS
  // ==========================================================================

  int get itensRespondidos {
    return itens.where((item) => item.isRespondido).length;
  }

  double get percentualConclusao {
    if (itens.isEmpty) return 0.0;
    return (itensRespondidos / itens.length) * 100;
  }

  bool get todosItensRespondidos => itensRespondidos == itens.length;

  // ==========================================================================
  // COPY WITH
  // ==========================================================================

  ChecklistCategoriaModel copyWith({
    int? codChecklist,
    int? sequenciaCat,
    String? desCategoria,
    int? ordemExibicao,
    bool? obrigatorio,
    String? icone,
    List<ChecklistItemModel>? itens,
  }) {
    return ChecklistCategoriaModel(
      codChecklist: codChecklist ?? this.codChecklist,
      sequenciaCat: sequenciaCat ?? this.sequenciaCat,
      desCategoria: desCategoria ?? this.desCategoria,
      ordemExibicao: ordemExibicao ?? this.ordemExibicao,
      obrigatorio: obrigatorio ?? this.obrigatorio,
      icone: icone ?? this.icone,
      itens: itens ?? this.itens,
    );
  }
}
