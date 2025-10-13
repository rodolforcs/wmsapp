// ============================================================================
// RAT LOTE MODEL - Modelo de rateio de lote (rat-lote do Datasul)
// ============================================================================

/// Modelo que representa o rateio de estoque de um item
///
/// Define onde o item será armazenado fisicamente:
/// - Depósito (cod-depos)
/// - Localização física (cod-localizacao)
/// - Lote (cod-lote)
/// - Quantidade a alocar (qtde-lote)
///
/// Corresponde à tabela rat-lote do Datasul
class RatLoteModel {
  final String codDepos;
  final String codLocaliz;
  final String codLote;
  double qtdeLote;
  final bool isEditavel;
  final DateTime? dtValidade;
  final int sequencia;

  RatLoteModel({
    this.codDepos = '',
    this.codLocaliz = '',
    this.codLote = '',
    this.qtdeLote = 0.0,
    this.isEditavel = false,
    this.dtValidade,
    this.sequencia = 0,
  });

  // ==========================================================================
  // CONSTRUTOR: From JSON (dados da API Progress)
  // ==========================================================================

  /// Cria RatLote a partir do JSON da API
  factory RatLoteModel.fromJson(Map<String, dynamic> json) {
    return RatLoteModel(
      codDepos: json['cod-depos']?.toString() ?? '',
      codLocaliz: json['cod-localiz']?.toString() ?? '',
      codLote: json['lote']?.toString() ?? '',
      qtdeLote: json['quantidade'] is double
          ? json['quantidade']
          : double.tryParse(json['quantidade']?.toString() ?? '') ?? 0.0,
      isEditavel: json['is-editavel'] as bool? ?? false,
      dtValidade: json['dt-vali-lote'] is String
          ? DateTime.tryParse(json['dt-vali-lote'])
          : null,
      sequencia: json['sequencia'] is int
          ? json['sequencia']
          : int.tryParse(json['sequencia']?.toString() ?? '') ?? 0,
    );
  }

  // ==========================================================================
  // MÉTODO: To JSON (para enviar à API)
  // ==========================================================================

  /// Converte o RatLote para JSON
  Map<String, dynamic> toJson() {
    return {
      'cod-depos': codDepos,
      'cod-localizacao': codLocaliz,
      'cod-lote': codLote,
      'qtde-lote': qtdeLote,
      if (dtValidade != null) 'dt-vali-lote': dtValidade!.toIso8601String(),
      'is-editavel': isEditavel,
      'sequencia': sequencia,
    };
  }

  // ==========================================================================
  // MÉTODO: Copy With
  // ==========================================================================

  /// Cria uma cópia do RatLote com valores alterados
  RatLoteModel copyWith({
    String? codDepos,
    String? codLocalizacao,
    String? codLote,
    double? qtdeLote,
    bool? isEditavel,
    DateTime? dtValidade,
    int? sequencia,
  }) {
    return RatLoteModel(
      codDepos: codDepos ?? this.codDepos,
      codLocaliz: codLocalizacao ?? this.codLocaliz,
      codLote: codLote ?? this.codLote,
      qtdeLote: qtdeLote ?? this.qtdeLote,
      isEditavel: isEditavel ?? this.isEditavel,
      dtValidade: dtValidade ?? this.dtValidade,
      sequencia: sequencia ?? this.sequencia,
    );
  }

  // ==========================================================================
  // GETTERS - Propriedades calculadas
  // ==========================================================================

  /// Chave única do rateio (para identificação)
  String get chaveRateio => '$codDepos-$codLocaliz-$codLote';

  /// Verifica se a quantidade é válida (maior que zero)
  bool get quantidadeValida => qtdeLote > 0;

  /// Verifica se pode ser removido (só rateios editáveis)
  bool get podeRemover => isEditavel;

  /// Verifica se pode alterar quantidade (só rateios editáveis)
  bool get podeAlterarQuantidade => isEditavel;

  // ==========================================================================
  // MÉTODOS AUXILIARES
  // ==========================================================================

  @override
  String toString() {
    return 'RatLote(codDepos: $codDepos, codLocalizacao: $codLocaliz, '
        'codLote: $codLote, qtdeLote: $qtdeLote, isEditavel: $isEditavel)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RatLoteModel && other.chaveRateio == chaveRateio;
  }

  @override
  int get hashCode => chaveRateio.hashCode;
}
