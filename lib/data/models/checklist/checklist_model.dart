import 'checklist_categoria_model.dart';

class ChecklistModel {
  final int codChecklist;
  final int codTemplate;
  final String desTemplate;
  final String tipoChecklist;
  final int situacao;
  final double percentualConclusao;
  final DateTime dtInicio; // agora opcional
  final String usuarioInicio; // agora opcional
  final bool criadoAgora;
  final List<ChecklistCategoriaModel> categorias;

  ChecklistModel({
    required this.codChecklist,
    required this.codTemplate,
    required this.desTemplate,
    required this.tipoChecklist,
    required this.situacao,
    required this.percentualConclusao,
    required this.dtInicio,
    required this.usuarioInicio,
    required this.criadoAgora,
    required this.categorias,
  });

  // ==========================================================================
  // FROM JSON
  // ==========================================================================

  factory ChecklistModel.fromJson(Map<String, dynamic> json) {
    final categoriasJson = json['tt-categoria'] as List? ?? [];

    return ChecklistModel(
      codChecklist: json['cod-checklist'] is int
          ? json['cod-checklist']
          : int.tryParse(json['cod-checklist']?.toString() ?? '') ?? 0,
      codTemplate: json['cod-template'] is int
          ? json['cod-template']
          : int.tryParse(json['cod-template']?.toString() ?? '') ?? 0,
      desTemplate: json['des-template']?.toString() ?? '',
      tipoChecklist: json['tipo-checklist']?.toString() ?? '',
      situacao: json['situacao'] is int
          ? json['situacao']
          : int.tryParse(json['situacao']?.toString() ?? '') ?? 0,
      percentualConclusao: (json['percentual-conclusao'] is num)
          ? (json['percentual-conclusao'] as num).toDouble()
          : double.tryParse(json['percentual-conclusao']?.toString() ?? '') ??
                0.0,
      dtInicio: (json['dt-inicio'] is String && json['dt-inicio'] != '')
          ? DateTime.tryParse(json['dt-inicio'] as String) ?? DateTime.now()
          : DateTime.now(),
      usuarioInicio:
          (json['usuario-inicio'] != null &&
              json['usuario-inicio'].toString().isNotEmpty)
          ? json['usuario-inicio'].toString()
          : 'Não informado',
      criadoAgora: json['criado-agora'] is bool
          ? json['criado-agora']
          : (json['criado-agora']?.toString().toLowerCase() == 'true'),
      categorias: categoriasJson
          .map(
            (cat) =>
                ChecklistCategoriaModel.fromJson(cat as Map<String, dynamic>),
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
      'cod-template': codTemplate,
      'des-template': desTemplate,
      'tipo-checklist': tipoChecklist,
      'situacao': situacao,
      'percentual-conclusao': percentualConclusao,
      if (dtInicio != null) 'dt-inicio': dtInicio!.toIso8601String(),
      if (usuarioInicio != null) 'usuario-inicio': usuarioInicio,
      'criado-agora': criadoAgora,
      'tt-categoria': categorias.map((cat) => cat.toJson()).toList(),
    };
  }

  // ==========================================================================
  // GETTERS
  // ==========================================================================

  String get situacaoDescricao {
    switch (situacao) {
      case 0:
        return 'Pendente';
      case 1:
        return 'Em Andamento';
      case 2:
        return 'Concluído';
      case 3:
        return 'Aprovado';
      case 9:
        return 'Reprovado';
      default:
        return 'Desconhecido';
    }
  }

  bool get isPendente => situacao == 0;
  bool get isEmAndamento => situacao == 1;
  bool get isConcluido => situacao == 2 || situacao == 3;
  bool get isReprovado => situacao == 9;

  int get totalItens =>
      categorias.fold<int>(0, (sum, cat) => sum + cat.itens.length);

  int get itensRespondidos =>
      categorias.fold<int>(0, (sum, cat) => sum + cat.itensRespondidos);

  bool get todosItensRespondidos => itensRespondidos == totalItens;

  // ==========================================================================
  // COPY WITH
  // ==========================================================================

  ChecklistModel copyWith({
    int? codChecklist,
    int? codTemplate,
    String? desTemplate,
    String? tipoChecklist,
    int? situacao,
    double? percentualConclusao,
    DateTime? dtInicio,
    String? usuarioInicio,
    bool? criadoAgora,
    List<ChecklistCategoriaModel>? categorias,
  }) {
    return ChecklistModel(
      codChecklist: codChecklist ?? this.codChecklist,
      codTemplate: codTemplate ?? this.codTemplate,
      desTemplate: desTemplate ?? this.desTemplate,
      tipoChecklist: tipoChecklist ?? this.tipoChecklist,
      situacao: situacao ?? this.situacao,
      percentualConclusao: percentualConclusao ?? this.percentualConclusao,
      dtInicio: dtInicio ?? this.dtInicio,
      usuarioInicio: usuarioInicio ?? this.usuarioInicio,
      criadoAgora: criadoAgora ?? this.criadoAgora,
      categorias: categorias ?? this.categorias,
    );
  }
}
