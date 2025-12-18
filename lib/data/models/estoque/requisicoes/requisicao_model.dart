// lib/data/models/estoque/requisicoes/requisicao_model.dart

import 'item_requisicao_model.dart';

/// 📦 Modelo de Requisição de Estoque
///
/// Baseado na tabela: requisicao
/// Representa uma requisição de materiais/produtos do estoque
class RequisicaoModel {
  // Campos da tabela requisicao
  final int nrRequisicao; // nr-requisicao
  final String nomeAbrev; // nome-abrev (usuário solicitante)
  final DateTime dtRequisicao; // dt-requisicao
  final int
  situacao; // situacao (1=Aberta, 2=Atendida parcial, 3=Atendida total, 4=Cancelada)
  final DateTime? dtAtend; // dt-atend (data atendimento)
  final String? locEntrega; // loc-entrega
  final DateTime? dtDevol; // dt-devol
  final String? narrativa; // narrativa
  final int estado; // estado (1=Aprovada, 2=Reprovada, etc)
  final String? nomeAprov; // nome-aprov (aprovador)
  final int impressa; // impressa (0=Não, 1=Sim)
  final String codEstabel; // cod-estabel
  final int tpRequis; // tp-requis (1=Normal, 2=Transferência, etc)
  // Lista de itens da requisição
  final List<ItemRequisicaoModel>? itens;

  // Campos de controle (não existem no ERP)
  final int versao; // Versão para controle de concorrência
  final String? hashState; // Hash MD5 para detectar mudanças
  final bool alteradoLocal; // Flag de alteração local (não persistida)
  final DateTime? dhUltAlter; // Data/hora última alteração

  RequisicaoModel({
    required this.nrRequisicao,
    required this.nomeAbrev,
    required this.dtRequisicao,
    required this.situacao,
    this.dtAtend,
    this.locEntrega,
    this.dtDevol,
    this.narrativa,
    this.estado = 1,
    this.nomeAprov,
    this.impressa = 0,
    required this.codEstabel,
    this.tpRequis = 1,
    this.itens,
    this.versao = 1,
    this.hashState,
    this.alteradoLocal = false,
    this.dhUltAlter,
  });

  // Getters úteis
  bool get isAberta => situacao == 1;
  bool get isAtendidaParcial => situacao == 2;
  bool get isAtendidaTotal => situacao == 3;
  bool get isCancelada => situacao == 4;
  bool get isAprovada => estado == 1;
  bool get isReprovada => estado == 2;

  bool get hasItens => itens != null && itens!.isNotEmpty;
  int get qtdeItens => itens?.length ?? 0;
  int get qtdeItensAtendidos => itens?.where((i) => i.foiAtendido).length ?? 0;
  int get qtdeItensPendentes => qtdeItens - qtdeItensAtendidos;

  bool get isAtendimentoParcial =>
      qtdeItensAtendidos > 0 && qtdeItensAtendidos < qtdeItens;
  bool get isAtendimentoCompleto =>
      qtdeItens > 0 && qtdeItensAtendidos == qtdeItens;

  String get situacaoDescricao {
    switch (situacao) {
      case 1:
        return 'Aberta';
      case 2:
        return 'Atendida Parcial';
      case 3:
        return 'Atendida Total';
      case 4:
        return 'Cancelada';
      default:
        return 'Desconhecida';
    }
  }

  String get estadoDescricao {
    switch (estado) {
      case 1:
        return 'Aprovada';
      case 2:
        return 'Reprovada';
      case 3:
        return 'Pendente';
      default:
        return 'Desconhecido';
    }
  }

  String get tipoRequisicaoDescricao {
    switch (tpRequis) {
      case 1:
        return 'Normal';
      case 2:
        return 'Transferência';
      case 3:
        return 'Devolução';
      default:
        return 'Outros';
    }
  }

  // Progresso do atendimento (0.0 a 1.0)
  double get progressoAtendimento {
    if (qtdeItens == 0) return 0.0;
    return qtdeItensAtendidos / qtdeItens;
  }

  // ✅ fromJson
  factory RequisicaoModel.fromJson(Map<String, dynamic> json) {
    return RequisicaoModel(
      nrRequisicao: json['nr-requisicao'] ?? json['nrRequisicao'] ?? 0,
      nomeAbrev: json['nome-abrev'] ?? json['nomeAbrev'] ?? '',
      dtRequisicao: json['dt-requisicao'] != null
          ? DateTime.parse(json['dt-requisicao'])
          : json['dtRequisicao'] != null
          ? DateTime.parse(json['dtRequisicao'])
          : DateTime.now(),
      situacao: json['situacao'] ?? 1,
      dtAtend: json['dt-atend'] != null
          ? DateTime.parse(json['dt-atend'])
          : json['dtAtend'] != null
          ? DateTime.parse(json['dtAtend'])
          : null,
      locEntrega: json['loc-entrega'] ?? json['locEntrega'],
      dtDevol: json['dt-devol'] != null
          ? DateTime.parse(json['dt-devol'])
          : json['dtDevol'] != null
          ? DateTime.parse(json['dtDevol'])
          : null,
      narrativa: json['narrativa'],
      estado: json['estado'] ?? 1,
      nomeAprov: json['nome-aprov'] ?? json['nomeAprov'],
      impressa: json['impressa'] ?? 0,
      codEstabel: json['cod-estabel'] ?? json['codEstabel'] ?? '',
      tpRequis: json['tp-requis'] ?? json['tpRequis'] ?? 1,
      itens: json['tt-it-requisicao'] != null
          ? (json['tt-it-requisicao'] as List)
                .map((item) => ItemRequisicaoModel.fromJson(item))
                .toList()
          : json['itens'] != null
          ? (json['itens'] as List)
                .map((item) => ItemRequisicaoModel.fromJson(item))
                .toList()
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

  // ✅ toJson
  Map<String, dynamic> toJson() {
    return {
      'nr-requisicao': nrRequisicao,
      'nome-abrev': nomeAbrev,
      'dt-requisicao': dtRequisicao.toIso8601String(),
      'situacao': situacao,
      if (dtAtend != null) 'dt-atend': dtAtend!.toIso8601String(),
      if (locEntrega != null) 'loc-entrega': locEntrega,
      if (dtDevol != null) 'dt-devol': dtDevol!.toIso8601String(),
      if (narrativa != null) 'narrativa': narrativa,
      'estado': estado,
      if (nomeAprov != null) 'nome-aprov': nomeAprov,
      'impressa': impressa,
      'cod-estabel': codEstabel,
      'tp-requis': tpRequis,
      if (itens != null)
        'tt-it-requisicao': itens!.map((i) => i.toJson()).toList(),
      'versao': versao,
      if (hashState != null) 'hash-state': hashState,
      if (dhUltAlter != null) 'dh-ult-alter': dhUltAlter!.toIso8601String(),
    };
  }

  // ✅ copyWith
  RequisicaoModel copyWith({
    int? nrRequisicao,
    String? nomeAbrev,
    DateTime? dtRequisicao,
    String? ctCodigo,
    String? scCodigo,
    int? situacao,
    DateTime? dtAtend,
    String? locEntrega,
    DateTime? dtDevol,
    String? narrativa,
    int? estado,
    String? nomeAprov,
    int? impressa,
    String? codEstabel,
    int? tpRequis,
    List<ItemRequisicaoModel>? itens,
    int? versao,
    String? hashState,
    bool? alteradoLocal,
    DateTime? dhUltAlter,
  }) {
    return RequisicaoModel(
      nrRequisicao: nrRequisicao ?? this.nrRequisicao,
      nomeAbrev: nomeAbrev ?? this.nomeAbrev,
      dtRequisicao: dtRequisicao ?? this.dtRequisicao,
      situacao: situacao ?? this.situacao,
      dtAtend: dtAtend ?? this.dtAtend,
      locEntrega: locEntrega ?? this.locEntrega,
      dtDevol: dtDevol ?? this.dtDevol,
      narrativa: narrativa ?? this.narrativa,
      estado: estado ?? this.estado,
      nomeAprov: nomeAprov ?? this.nomeAprov,
      impressa: impressa ?? this.impressa,
      codEstabel: codEstabel ?? this.codEstabel,
      tpRequis: tpRequis ?? this.tpRequis,
      itens: itens ?? this.itens,
      versao: versao ?? this.versao,
      hashState: hashState ?? this.hashState,
      alteradoLocal: alteradoLocal ?? this.alteradoLocal,
      dhUltAlter: dhUltAlter ?? this.dhUltAlter,
    );
  }

  @override
  String toString() {
    return 'RequisicaoModel(nr: $nrRequisicao, situacao: $situacaoDescricao, '
        'itens: $qtdeItensAtendidos/$qtdeItens)';
  }
}
