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

  final String numPedido;
  final String numeroOrdem;
  bool foiConferido;

  ItDocFisicoModel({
    required this.nrSequencia,
    required this.codItem,
    required this.qtdeItem,
    this.qtdeConferida = 0.0,
    this.rateios,
    this.itemCadastro,
    this.numPedido = '',
    this.numeroOrdem = '',
    this.foiConferido = false,
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
      numPedido: json['num-pedido']?.toString() ?? '',
      numeroOrdem: json['numero-ordem']?.toString() ?? '',
    );
  }

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
    String? numPedido,
    String? numeroOrdem,
    bool? foiConferido,
  }) {
    return ItDocFisicoModel(
      nrSequencia: nrSequencia ?? this.nrSequencia,
      codItem: codItem ?? this.codItem,
      qtdeItem: qtdeItem ?? this.qtdeItem,
      qtdeConferida: qtdeConferida ?? this.qtdeConferida,
      rateios: rateios ?? this.rateios,
      itemCadastro: itemCadastro ?? this.itemCadastro,
      numPedido: numPedido ?? this.numPedido,
      numeroOrdem: numeroOrdem ?? this.numeroOrdem,
      foiConferido: foiConferido ?? this.foiConferido,
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
  // VALIDAÇÃO 1: Quantidade Conferida vs Esperada
  // ==========================================================================

  /*
  /// Verifica se o item foi conferido
  bool get foiConferido {
    return qtdeConferida > 0;
  }
  */

  /// Verifica se há divergência entre quantidade ESPERADA e CONFERIDA
  /// Esta validação é independente dos rateios
  bool get temDivergenciaQuantidade {
    if (!foiConferido) return false;
    return qtdeConferida != qtdeItem;
  }

  /// Verifica se a quantidade conferida está correta (igual ao esperado)
  /// ✅ Check verde quando conferido == esperado
  bool get quantidadeConferidaCorreta {
    if (!foiConferido) return false;
    return qtdeConferida == qtdeItem;
  }

  // ==========================================================================
  // VALIDAÇÃO 2: Soma dos Rateios vs Quantidade Conferida
  // ==========================================================================

  /// Verifica se tem rateios cadastrados
  bool get hasRateios => rateios != null && rateios!.isNotEmpty;

  /// Retorna soma total dos rateios
  double get somaTotalRateios {
    if (!hasRateios) return 0.0;
    return rateios!.fold<double>(0.0, (sum, rat) => sum + rat.qtdeLote);
  }

  /// Retorna quantidade ainda não rateada
  double get qtdeNaoRateada {
    return qtdeConferida - somaTotalRateios;
  }

  /// Verifica se há divergência entre CONFERIDO e SOMA DOS RATEIOS
  /// ⚠️ Só valida se qtdeConferida > 0
  /// ⚠️ Só aplica se item controla lote ou endereço
  bool get temDivergenciaRateio {
    // Se não conferiu ainda, não tem divergência de rateio
    if (!foiConferido) return false;

    // Se não controla lote/endereço, não precisa validar rateio
    if (!controlaLote && !controlaEndereco) return false;

    // Se conferiu mas não tem rateios, está divergente
    if (!hasRateios) return true;

    // Valida se soma dos rateios bate com o conferido
    return somaTotalRateios != qtdeConferida;
  }

  /// Verifica se os rateios estão corretos (soma = conferido)
  /// ✅ OK quando soma dos rateios == quantidade conferida
  bool get rateiosCorretos {
    // Se não conferiu, não tem como validar
    if (!foiConferido) return false;

    // Se não controla lote/endereço, rateio é opcional
    if (!controlaLote && !controlaEndereco) return true;

    // Validação: soma rateios == conferido
    return !temDivergenciaRateio;
  }

  // ==========================================================================
  // VALIDAÇÃO COMBINADA: Combina as duas validações
  // ==========================================================================

  /// Verifica se tem QUALQUER divergência (quantidade OU rateio)
  bool get temDivergencia {
    return temDivergenciaQuantidade || temDivergenciaRateio;
  }

  /// Verifica se está TUDO correto (quantidade E rateios)
  /// ✅ Check verde principal do card
  bool get conferidoCorreto {
    if (!foiConferido) {
      print('[DEBUG] conferidoCorreto = false (não conferido)');
      return false;
    }

    final qtdOk = quantidadeConferidaCorreta;
    final ratOk = rateiosCorretos;

    print(
      '[DEBUG] Item $codItem: qtdeItem=$qtdeItem, qtdeConferida=$qtdeConferida',
    );
    print('[DEBUG] quantidadeConferidaCorreta=$qtdOk, rateiosCorretos=$ratOk');
    print('[DEBUG] conferidoCorreto=${qtdOk && ratOk}');

    // Deve estar correto em AMBAS as validações
    return qtdOk && ratOk;
  }

  // ==========================================================================
  // MENSAGENS DE DIVERGÊNCIA
  // ==========================================================================

  /// Retorna mensagem de divergência de QUANTIDADE
  String get mensagemDivergenciaQuantidade {
    if (!temDivergenciaQuantidade) return '';
    return 'Esperado: ${qtdeItem.toStringAsFixed(2)} | '
        'Conferido: ${qtdeConferida.toStringAsFixed(2)}';
  }

  /// Retorna mensagem de divergência de RATEIO
  String get mensagemDivergenciaRateio {
    if (!temDivergenciaRateio) return '';
    return 'Conferido: ${qtdeConferida.toStringAsFixed(2)} | '
        'Soma rateios: ${somaTotalRateios.toStringAsFixed(2)}';
  }

  /// Retorna mensagem de divergência combinada (se houver)
  String get mensagemDivergencia {
    final mensagens = <String>[];

    if (temDivergenciaQuantidade) {
      mensagens.add(mensagemDivergenciaQuantidade);
    }

    if (temDivergenciaRateio) {
      mensagens.add(mensagemDivergenciaRateio);
    }

    return mensagens.join('\n');
  }

  // ==========================================================================
  // GETTERS LEGADOS (compatibilidade com código antigo)
  // ==========================================================================

  /// @deprecated Use temDivergenciaQuantidade
  bool get temDivergenciaEsperadoVsRecebido => temDivergenciaQuantidade;

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
