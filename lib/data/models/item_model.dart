// ============================================================================
// ITEM MODEL - Cadastro de itens (tabela item do Datasul)
// ============================================================================

/// Modelo que representa o cadastro de um item
///
/// Contém informações cadastrais do item que vêm da tabela "item" do Datasul.
/// Estes dados são separados do documento fiscal para manter normalização.
class ItemModel {
  /// Código único do item
  final String codItem;

  /// Descrição completa do item
  final String descrItem;

  /// Unidade de medida padrão
  final String unidMedida;

  /// Se o item tem controle de lote
  final bool controlaLote;

  /// Se o item tem controle de endereço/localização
  final bool controlaEndereco;

  ItemModel({
    required this.codItem,
    required this.descrItem,
    required this.unidMedida,
    this.controlaLote = false,
    this.controlaEndereco = false,
  });

  // ==========================================================================
  // CONSTRUTOR: From JSON
  // ==========================================================================

  /// Cria ItemModel a partir do JSON da API
  ///
  /// Exemplo de JSON esperado:
  /// ```json
  /// {
  ///   "cod-item": "PROD001",
  ///   "descr-item": "Parafuso M6x20",
  ///   "unid-medida": "UN",
  ///   "controla-lote": true,
  ///   "controla-endereco": true
  /// }
  /// ```
  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      codItem: json['cod-item'] as String? ?? '',
      descrItem: json['descr-item'] as String? ?? '',
      unidMedida: json['unid-medida'] as String? ?? 'UN',
      controlaLote: json['controla-lote'] as bool? ?? false,
      controlaEndereco: json['controla-endereco'] as bool? ?? false,
    );
  }

  // ==========================================================================
  // MÉTODO: To JSON
  // ==========================================================================

  Map<String, dynamic> toJson() {
    return {
      'cod-item': codItem,
      'descr-item': descrItem,
      'unid-medida': unidMedida,
      'controla-lote': controlaLote,
      'controla-endereco': controlaEndereco,
    };
  }

  // ==========================================================================
  // GETTERS
  // ==========================================================================

  /// Verifica se precisa de rateio (controla lote OU endereço)
  bool get precisaRateio => controlaLote || controlaEndereco;

  // ==========================================================================
  // MÉTODOS AUXILIARES
  // ==========================================================================

  @override
  String toString() {
    return 'ItemModel(codItem: $codItem, descrItem: $descrItem, '
        'unidMedida: $unidMedida, controlaLote: $controlaLote, '
        'controlaEndereco: $controlaEndereco)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ItemModel && other.codItem == codItem;
  }

  @override
  int get hashCode => codItem.hashCode;
}
