import 'package:wmsapp/data/models/estoque/recebimento/rat_lote_model.dart';
import 'package:wmsapp/data/models/item_model.dart';

// ============================================================================
// IT DOC FISICO MODEL - Item do documento físico
// ============================================================================

/// Modelo que representa um item do documento físico
///
/// Contém apenas os dados específicos do item na nota fiscal.
/// Dados cadastrais (descrição, unidade) vêm do ItemModel.
/// Rateios de estoque vêm da lista de RatLote.
class ItDocFisicoModel {
  /// Número sequencial do item no documento
  final int nrSequencia;

  /// Código do item (chave para buscar dados no ItemModel)
  final String codItem;

  /// Quantidade do item no documento
  final double qtdeItem;

  /// Quantidade conferida pelo usuário
  double qtdeConferida;

  /// Lista de rateios de estoque (depósito/localização/lote/quantidade)
  /// Null se o item não tiver rateios configurados
  List<RatLoteModel>? rateios;

  /// Referência ao cadastro do item (para acessar descrição, etc)
  /// Será preenchido ao juntar com os dados de ItemModel
  ItemModel? itemCadastro;

  ItDocFisicoModel({
    required this.nrSequencia,
    required this.codItem,
    required this.qtdeItem,
    this.qtdeConferida = 0.0,
    this.rateios,
    this.itemCadastro,
  });

  // ==========================================================================
  // CONSTRUTOR: From JSON
  // ==========================================================================

  /// Cria ItDocFisicoModel a partir do JSON da API
  ///
  /// Exemplo de JSON esperado:
  /// ```json
  /// {
  ///   "nr-sequencia": 1,
  ///   "cod-item": "PROD001",
  ///   "qtde-item": 100.5,
  ///   "qtde-conferida": 0,
  ///   "rateios": [...],
  ///   "item-cadastro": {...}
  /// }
  /// ```
  ///
  factory ItDocFisicoModel.fromJson(Map<String, dynamic> json) {
    print('[ItDocFisicoModel] Parseando item: ${json['it-codigo']}');

    // Converte lista de rateios (se existir)
    List<RatLoteModel>? rateios;
    if (json['tt-rat-lote'] != null && json['tt-rat-lote'] is List) {
      final rateiosJson = json['tt-rat-lote'] as List;
      print('[ItDocFisicoModel] Item tem ${rateiosJson.length} rateios');

      rateios = rateiosJson.asMap().entries.map((entry) {
        final index = entry.key;
        final ratJson = entry.value;

        print('[ItDocFisicoModel] Parseando rateio $index: $ratJson');

        try {
          return RatLoteModel.fromJson(ratJson);
        } catch (e, stack) {
          print('[ItDocFisicoModel] ERRO no rateio $index: $e');
          print('[ItDocFisicoModel] Stack: $stack');
          print('[ItDocFisicoModel] JSON do rateio: $ratJson');
          rethrow;
        }
      }).toList();
    }

    // Cria ItemModel com os dados do JSON Progress
    ItemModel itemCadastro = ItemModel(
      codItem: json['it-codigo']?.toString() ?? '',
      descrItem: json['desc-item']?.toString() ?? '',
      unidMedida: json['un']?.toString() ?? 'UN',
      controlaLote: json['controla-lote'] == true,
      controlaEndereco: json['controla-ender'] == true,
    );

    return ItDocFisicoModel(
      nrSequencia: json['sequencia'] as int? ?? 0,
      codItem: json['it-codigo']?.toString() ?? '',
      qtdeItem: (json['quantidade'] as num?)?.toDouble() ?? 0.0,
      qtdeConferida: (json['qtde-conferida'] as num?)?.toDouble() ?? 0.0,
      rateios: rateios,
      itemCadastro: itemCadastro,
    );
  }
  /*
  factory ItDocFisicoModel.fromJson(Map<String, dynamic> json) {
    // Converte lista de rateios (se existir)
    List<RatLoteModel>? rateios;
    if (json['tt-rat-lote'] != null && json['tt-rat-lote'] is List) {
      rateios = (json['tt-rat-lote'] as List)
          .map((ratJson) => RatLoteModel.fromJson(ratJson))
          .toList();
    }

    // Cria ItemModel com os dados do JSON Progress
    final itemCadastro = ItemModel(
      codItem: json['it-codigo']?.toString() ?? '',
      descrItem: json['desc-item']?.toString() ?? '',
      unidMedida: json['un']?.toString() ?? 'UN',
      controlaLote: json['controla-lote'] == true,
      controlaEndereco: json['controla-ender'] == true,
    );

    return ItDocFisicoModel(
      nrSequencia: json['sequencia'] ?? 0,
      codItem: json['it-codigo'] ?? '',
      qtdeItem: (json['quantidade'] ?? 0).toDouble(),
      qtdeConferida: (json['qtde-conferida'] ?? 0).toDouble(),
      rateios: rateios,
      itemCadastro: itemCadastro,
    );
  }
*/
  /*
  factory ItDocFisicoModel.fromJson(Map<String, dynamic> json) {
    // Converte lista de rateios (se existir)
    List<RatLoteModel>? rateios;
    if (json['tt-rat-lote'] != null && json['tt-rat-lote'] is List) {
      rateios = (json['tt-rat-lote'] as List)
          .map((ratJson) => RatLoteModel.fromJson(ratJson))
          .toList();
    }

    // Cria ItemModel com os dados do JSON Progress
    ItemModel itemCadastro = ItemModel(
      codItem: json['it-codigo']?.toString() ?? '',
      descrItem: json['desc-item']?.toString() ?? '',
      unidMedida: json['un']?.toString() ?? 'UN',
      controlaLote: json['controla-lote'] == true, // ← Converte corretamente
      controlaEndereco:
          json['controla-ender'] == true, // ← Converte corretamente
    );

    return ItDocFisicoModel(
      nrSequencia: json['sequencia'] as int? ?? 0,
      codItem: json['it-codigo']?.toString() ?? '',
      qtdeItem: (json['quantidade'] as num?)?.toDouble() ?? 0.0,
      qtdeConferida: (json['qtde-conferida'] as num?)?.toDouble() ?? 0.0,
      rateios: rateios,
      itemCadastro: itemCadastro,
    );
  }
  */
  // ==========================================================================
  // MÉTODO: To JSON
  // ==========================================================================

  /// Converte o ItDocFisicoModel para JSON
  Map<String, dynamic> toJson() {
    return {
      'nr-sequencia': nrSequencia,
      'cod-item': codItem,
      'qtde-item': qtdeItem,
      'qtde-conferida': qtdeConferida,
      'rateios': rateios?.map((rat) => rat.toJson()).toList(),
    };
  }

  // ==========================================================================
  // MÉTODO: Copy With
  // ==========================================================================

  /// Cria uma cópia do ItDocFisicoModel com valores alterados
  ItDocFisicoModel copyWith({
    int? nrSequencia,
    String? codItem,
    double? qtdeItem,
    double? qtdeConferida,
    List<RatLoteModel>? rateios,
    ItemModel? itemCadastro,
  }) {
    return ItDocFisicoModel(
      nrSequencia: nrSequencia ?? this.nrSequencia,
      codItem: codItem ?? this.codItem,
      qtdeItem: qtdeItem ?? this.qtdeItem,
      qtdeConferida: qtdeConferida ?? this.qtdeConferida,
      rateios: rateios ?? this.rateios,
      itemCadastro: itemCadastro ?? this.itemCadastro,
    );
  }

  // ==========================================================================
  // GETTERS - Acessa dados do ItemModel quando disponível
  // ==========================================================================

  /// Retorna descrição do item (do cadastro)
  String get descrItem => itemCadastro?.descrItem ?? 'Item $codItem';

  /// Retorna unidade de medida (do cadastro)
  String get unidMedida => itemCadastro?.unidMedida ?? 'UN';

  /// Verifica se item controla lote (do cadastro)
  bool get controlaLote => itemCadastro?.controlaLote ?? false;

  /// Verifica se item controla endereço (do cadastro)
  bool get controlaEndereco => itemCadastro?.controlaEndereco ?? false;

  // ==========================================================================
  // GETTERS - Validações de Rateio
  // ==========================================================================

  /// Verifica se tem rateios cadastrados
  bool get hasRateios => rateios != null && rateios!.isNotEmpty;

  /// Verifica se há divergência entre esperado e conferido
  bool get temDivergenciaEsperadoVsRecebido {
    return qtdeConferida > 0 && (qtdeConferida - qtdeItem).abs() > 0.0001;
  }

  /// Verifica se há divergência entre conferido e soma dos rateios
  ///
  /// IMPORTANTE: A soma dos rateios DEVE ser igual à quantidade conferida
  /// quando o item controla lote/endereço
  bool get temDivergenciaRateio {
    // Se não controla lote/endereço, não precisa validar rateio
    if (!controlaLote && !controlaEndereco) return false;

    // Se não tem rateios mas já conferiu, está divergente
    if (!hasRateios && qtdeConferida > 0) return true;

    // Se não tem rateios, não tem divergência
    if (rateios == null || rateios!.isEmpty) return false;

    // Valida se soma dos rateios bate com o conferido
    final somaRateios = rateios!.fold<double>(
      0.0,
      (sum, rat) => sum + rat.qtdeLote,
    );

    // Usa tolerância para comparação de doubles
    return qtdeConferida > 0 && (somaRateios - qtdeConferida).abs() > 0.0001;
  }

  /// Verifica se tem qualquer tipo de divergência
  bool get temDivergencia {
    return temDivergenciaEsperadoVsRecebido || temDivergenciaRateio;
  }

  /// Verifica se o item foi conferido
  bool get foiConferido {
    return qtdeConferida > 0;
  }

  /// Verifica se a conferência está correta (sem divergências)
  bool get conferidoCorreto {
    return foiConferido && !temDivergencia;
  }

  /// Retorna mensagem de divergência (se houver)
  String get mensagemDivergencia {
    if (temDivergenciaEsperadoVsRecebido) {
      return 'Esperado: ${qtdeItem.toStringAsFixed(2)} | '
          'Conferido: ${qtdeConferida.toStringAsFixed(2)}';
    }
    if (temDivergenciaRateio) {
      final somaRateios =
          rateios?.fold<double>(
            0.0,
            (sum, rat) => sum + rat.qtdeLote,
          ) ??
          0.0;
      return 'Conferido: ${qtdeConferida.toStringAsFixed(2)} | '
          'Soma rateios: ${somaRateios.toStringAsFixed(2)}';
    }
    return '';
  }

  /// Retorna soma total dos rateios
  double get somaTotalRateios {
    if (!hasRateios) return 0.0;
    return rateios!.fold<double>(0.0, (sum, rat) => sum + rat.qtdeLote);
  }

  /// Retorna quantidade ainda não rateada
  /// Útil para saber quanto ainda precisa ser alocado
  double get qtdeNaoRateada {
    return qtdeConferida - somaTotalRateios;
  }

  // ==========================================================================
  // MÉTODOS AUXILIARES
  // ==========================================================================

  @override
  String toString() {
    return 'ItDocFisicoModel(nrSequencia: $nrSequencia, codItem: $codItem, '
        'qtdeItem: $qtdeItem, qtdeConferida: $qtdeConferida)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ItDocFisicoModel && other.nrSequencia == nrSequencia;
  }

  @override
  int get hashCode => nrSequencia.hashCode;
}
