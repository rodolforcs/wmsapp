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
  /// Código do depósito
  final String codDepos;

  /// Código da localização/endereço físico
  final String codLocaliz;

  /// Código do lote
  final String codLote;

  /// Quantidade a ser alocada neste rateio
  double qtdeLote;

  /// Se o rateio pode ser editado/removido pelo usuário
  /// false = veio do backend (já existe no sistema)
  /// true = criado pelo usuário (ainda não foi salvo)
  final bool isEditavel;

  final DateTime? dtValidade;

  int versao;

  DateTime? dtUltAlter;

  RatLoteModel({
    required this.codDepos,
    required this.codLocaliz,
    required this.codLote,
    this.qtdeLote = 0.0,
    required this.isEditavel,
    required this.dtValidade,
    required this.versao,
    this.dtUltAlter,
  });

  // ==========================================================================
  // CONSTRUTOR: From JSON (dados da API Progress)
  // ==========================================================================

  /// Cria RatLote a partir do JSON da API
  ///
  /// Exemplo de JSON esperado:
  /// ```json
  /// {
  ///   "cod-depos": "01",
  ///   "cod-localizacao": "A1-P01",
  ///   "cod-lote": "LOTE-2025-001",
  ///   "qtde-lote": 50.5,
  ///   "is-editavel": false
  /// }
  /// ```
  ///
  factory RatLoteModel.fromJson(Map<String, dynamic> json) {
    return RatLoteModel(
      codLocaliz: json['cod-localiz']?.toString() ?? '',
      codLote: json['lote']?.toString() ?? '',
      dtValidade: json['dt-vali-lote'] is String
          ? DateTime.tryParse(json['dt-vali-lote']) ?? DateTime.now()
          : DateTime.now(),
      qtdeLote: json['quantidade'] is double
          ? json['quantidade']
          : double.tryParse(json['quantidade']?.toString() ?? '') ?? 0.0,
      codDepos: json['cod-depos']?.toString() ?? '',
      isEditavel: json['is-editavel'] as bool? ?? true,
      versao: json['versao'] as int? ?? 0,
    );
  }

  // ==========================================================================
  // MÉTODO: To JSON (para enviar à API)
  // ==========================================================================

  /// Converte o RatLote para JSON
  /// Usado ao finalizar conferência para enviar os rateios à API
  Map<String, dynamic> toJson() {
    return {
      'cod-depos': codDepos,
      'cod-localizacao': codLocaliz,
      'cod-lote': codLote,
      'qtde-lote': qtdeLote,
    };
  }

  // ==========================================================================
  // MÉTODO: Copy With
  // ==========================================================================

  /// Cria uma cópia do RatLote com valores alterados
  ///
  /// Útil para criar uma nova instância alterando apenas alguns campos:
  /// ```dart
  /// final novoRateio = rateioOriginal.copyWith(qtdeLote: 100.0);
  /// ```
  RatLoteModel copyWith({
    String? codDepos,
    String? codLocalizacao,
    String? codLote,
    double? qtdeLote,
    bool? isEditavel,
    int? versao,
  }) {
    return RatLoteModel(
      codDepos: codDepos ?? this.codDepos,
      codLocaliz: codLocalizacao ?? this.codLocaliz,
      codLote: codLote ?? this.codLote,
      qtdeLote: qtdeLote ?? this.qtdeLote,
      isEditavel: isEditavel ?? this.isEditavel,
      dtValidade: dtValidade ?? this.dtValidade,
      versao: versao ?? this.versao,
    );
  }

  // ==========================================================================
  // GETTERS - Propriedades calculadas
  // ==========================================================================

  /// Chave única do rateio (para identificação)
  /// Combinação de depósito + localização + lote
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
