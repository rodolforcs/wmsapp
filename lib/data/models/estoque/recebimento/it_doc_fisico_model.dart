import 'package:flutter/foundation.dart';
import 'package:wmsapp/data/models/estoque/recebimento/rat_lote_model.dart';
import 'package:wmsapp/data/models/item_model.dart';
import 'package:wmsapp/shared/utils/format_number_utils.dart';

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

  int versao;

  DateTime? dataUltAlt;

  String usuarioUltAlt;

  /// Referência ao cadastro do item (para acessar descrição, etc)
  /// Será preenchido ao juntar com os dados de ItemModel
  ItemModel? itemCadastro;

  final String numPedido;
  final String numeroOrdem;
  //bool foiConferido;
  bool alteradoLocal;
  final String hashState;

  ItDocFisicoModel({
    required this.nrSequencia,
    required this.codItem,
    required this.qtdeItem,
    this.qtdeConferida = 0.0,
    this.rateios,
    this.itemCadastro,
    this.numPedido = '',
    this.numeroOrdem = '',
    this.alteradoLocal = false,
    this.hashState = '',
    required this.versao,
    this.dataUltAlt,
    this.usuarioUltAlt = '',
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
      versao: json['versao'] as int? ?? 0,
      alteradoLocal: false,
      hashState: json['hash-state'] ?? '',
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
      'versao': versao,
      'alterado-local': alteradoLocal,
      'hash-state': hashState,
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
    int? versao,
    bool? alteradoLocal,
    String? hashState,
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
      versao: versao ?? this.versao,
      alteradoLocal: alteradoLocal ?? this.alteradoLocal,
      hashState: hashState ?? this.hashState,
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

  bool get foiConferido => qtdeConferida > 0;

  String get qtdeConferidaFormat =>
      FormatNumeroUtils.formatarQuantidade(qtdeConferida);

  String get qtdItemFormat => FormatNumeroUtils.formatarQuantidade(qtdeItem);

  String get somaTotalRateiosFormat =>
      FormatNumeroUtils.formatarQuantidade(somaTotalRateios);

  String get qtdeNaoReateadaFomat =>
      FormatNumeroUtils.formatarQuantidade(qtdeNaoRateada);

  // ==========================================================================
  // VALIDAÇÃO 1: Quantidade Conferida vs Esperada
  // ==========================================================================

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

  /// Verifica se há divergência entre CONFERIDO e SOMA DOS RATEIOS
  ///
  /// ⚠️ REGRAS DE VALIDAÇÃO:
  /// 1. Se não conferiu ainda → não valida
  /// 2. Se não controla lote/endereço → não valida
  /// 3. Se conferiu ZERO → não precisa ratear
  /// 4. Se conferiu > 0 mas não tem rateios → DIVERGÊNCIA
  /// 5. Se tem rateios mas soma ≠ conferido → DIVERGÊNCIA
  bool get temDivergenciaRateio {
    if (kDebugMode) {
      debugPrint('═══════════════════════════════════════');
      debugPrint('🔍 [temDivergenciaRateio] Item: $codItem (seq=$nrSequencia)');
      debugPrint('   foiConferido: $foiConferido');
      debugPrint('   qtdeConferida: $qtdeConferida');
      debugPrint('   controlaLote: $controlaLote');
      debugPrint('   hasRateios: $hasRateios');
      debugPrint('   somaTotalRateios: $somaTotalRateios');
    }

    // ✅ REGRA 1: Se não conferiu ainda, não valida rateio
    if (!foiConferido) {
      if (kDebugMode) debugPrint('   ❌ Resultado: false (não conferiu)');
      return false;
    }

    // ✅ REGRA 2: Se conferiu ZERO, não precisa ratear
    if (qtdeConferida == 0) {
      if (kDebugMode) debugPrint('   ❌ Resultado: false (conferiu zero)');
      return false;
    }

    // ✅ REGRA 3: Se conferiu > 0 mas não tem rateios → SEMPRE DIVERGÊNCIA
    // (Rateio é obrigatório independente de controlar lote ou não)
    if (qtdeConferida > 0 && !hasRateios) {
      if (kDebugMode)
        debugPrint('   ⚠️ Resultado: true (conferiu > 0 mas sem rateios)');
      return true;
    }

    // ✅ REGRA 4: Valida se soma dos rateios bate com o conferido
    final resultado = (somaTotalRateios - qtdeConferida).abs() >= 0.0001;
    if (kDebugMode) {
      debugPrint(
        '   ${resultado ? "⚠️" : "❌"} Resultado: $resultado (diferença: ${(somaTotalRateios - qtdeConferida).abs()})',
      );
      debugPrint('═══════════════════════════════════════');
    }
    return resultado;
  }

  /// Retorna quantidade ainda não rateada
  double get qtdeNaoRateada {
    return qtdeConferida - somaTotalRateios;
  }

  /// Verifica se os rateios estão corretos (soma = conferido)
  /// ✅ OK quando soma dos rateios == quantidade conferida
  bool get rateiosCorretos {
    if (kDebugMode) {
      debugPrint('═══════════════════════════════════════');
      debugPrint('🔍 [rateiosCorretos] Item: $codItem (seq=$nrSequencia)');
      debugPrint('   foiConferido: $foiConferido');
      debugPrint('   qtdeConferida: $qtdeConferida');
      debugPrint('   controlaLote: $controlaLote');
      debugPrint('   hasRateios: $hasRateios');
      debugPrint('   somaTotalRateios: $somaTotalRateios');
    }

    // Se não conferiu, não pode estar "correto" ainda
    if (!foiConferido) {
      if (kDebugMode) debugPrint('   ❌ Resultado: false (não conferiu)');
      return false;
    }

    // Se conferiu ZERO, não precisa ratear → OK
    if (qtdeConferida == 0) {
      if (kDebugMode) debugPrint('   ✅ Resultado: true (conferiu zero)');
      return true;
    }

    // ✅ RATEIO É SEMPRE OBRIGATÓRIO: Se conferiu > 0, DEVE ter rateios
    if (qtdeConferida > 0 && !hasRateios) {
      if (kDebugMode)
        debugPrint('   ❌ Resultado: false (conferiu > 0 mas sem rateios)');
      return false;
    }

    // Validação: soma rateios deve bater com conferido (tolerância de 0.0001)
    final resultado = (somaTotalRateios - qtdeConferida).abs() < 0.0001;
    if (kDebugMode) {
      debugPrint(
        '   ${resultado ? "✅" : "❌"} Resultado: $resultado (diferença: ${(somaTotalRateios - qtdeConferida).abs()})',
      );
      debugPrint('═══════════════════════════════════════');
    }
    return resultado;
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

    if (kDebugMode) {
      print('[DEBUG] Item $codItem:');
      print('  qtdeItem=$qtdeItem');
      print('  qtdeConferida=$qtdeConferida');
      print('  somaTotalRateios=$somaTotalRateios');
      print('  quantidadeConferidaCorreta=$qtdOk');
      print('  rateiosCorretos=$ratOk');
      print('  conferidoCorreto=${qtdOk && ratOk}');
    }

    // Deve estar correto em AMBAS as validações
    return qtdOk && ratOk;
  }

  // ==========================================================================
  // MENSAGENS DE DIVERGÊNCIA
  // ==========================================================================

  /// Retorna mensagem de divergência de QUANTIDADE
  String get mensagemDivergenciaQuantidade {
    if (!temDivergenciaQuantidade) return '';
    return 'Esperado: ${qtdeItem.toStringAsFixed(4)} | '
        'Conferido: ${qtdeConferida.toStringAsFixed(4)}';
  }

  /// Retorna mensagem de divergência de RATEIO
  String get mensagemDivergenciaRateio {
    if (!temDivergenciaRateio) return '';

    // ✅ Mensagem específica se não tem rateios
    if (!hasRateios && qtdeConferida > 0) {
      return 'Falta ratear ${qtdeConferidaFormat}';
    }

    return 'Conferido: ${qtdeConferida.toStringAsFixed(4)} | '
        'Soma rateios: ${somaTotalRateios.toStringAsFixed(4)}';
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
  /*
  @override
  String toString() {
    return 'ItDocFisicoModel(nrSequencia: $nrSequencia, codItem: $codItem, '
        'qtdeItem: $qtdeItem, qtdeConferida: $qtdeConferida),versao: $versao, hashState: ${hashState.isEmpty} ? vazio';
  }
*/
  @override
  String toString() {
    return 'ItDocFisicoModel('
        'itCodigo: $codItem, '
        'sequencia: $nrSequencia, '
        'quantidade: $qtdeItem, '
        'qtdConferida: $qtdeConferida, '
        'versao: $versao, '
        'hashState: ${hashState.isEmpty ? "vazio" : hashState.substring(0, 8)}..., '
        'alteradoLocal: $alteradoLocal'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ItDocFisicoModel && other.nrSequencia == nrSequencia;
  }

  @override
  int get hashCode => nrSequencia.hashCode;

  // ==========================================================================
  // VALIDAÇÕES DE RATEIO - Regras de Negócio
  // ==========================================================================

  /// Verifica se já existe um rateio com a mesma chave (dep-loc-lote)
  ///
  /// Regra: Não pode ter rateios duplicados com mesma combinação de:
  /// - Depósito
  /// - Localização
  /// - Lote
  bool existeRateioComChave(
    String codDepos,
    String codLocaliz,
    String codLote,
  ) {
    if (!hasRateios) return false;

    // Para itens SEM controle de lote, compara apenas dep-loc
    if (!controlaLote) {
      final chaveNova = '$codDepos-$codLocaliz'.toUpperCase();
      return rateios!.any((rat) {
        final chaveExistente = '${rat.codDepos}-${rat.codLocaliz}'
            .toUpperCase();
        return chaveExistente == chaveNova;
      });
    }

    final chaveNova = '$codDepos-$codLocaliz-$codLote'.toUpperCase();

    return rateios!.any((rat) => rat.chaveRateio.toUpperCase() == chaveNova);
  }

  /// Verifica se pode adicionar quantidade ao rateio sem ultrapassar qtdeConferida
  ///
  /// Regra: somaTotalRateios não pode ser maior que qtdeConferida
  bool podeAdicionarQuantidade(double quantidade) {
    if (!foiConferido) return false;

    final novoTotal = somaTotalRateios + quantidade;
    return novoTotal <= qtdeConferida;
  }

  /// Retorna quanto ainda pode ser rateado
  double get quantidadeDisponivelParaRatear {
    return qtdeConferida - somaTotalRateios;
  }

  /// Valida se pode adicionar um novo rateio
  ///
  /// Retorna String com erro ou null se válido
  String? validarNovoRateio({
    required String codDepos,
    required String codLocaliz,
    required String codLote,
    required double quantidade,
  }) {
    // Validação 1: Item deve estar conferido
    if (!foiConferido) {
      return 'Item ainda não foi conferido';
    }

    // Validação 2: Quantidade deve ser maior que zero
    if (quantidade <= 0) {
      return 'Quantidade deve ser maior que zero';
    }

    // Validação 5: Lote é obrigatório SE item controla lote
    if (controlaLote && codLote.trim().isEmpty) {
      return 'Lote é obrigatório para este item';
    }

    // Validação 3: Não pode ter rateio duplicado
    if (existeRateioComChave(codDepos, codLocaliz, codLote)) {
      return controlaLote
          ? 'Já existe um rateio com este depósito, localização e lote'
          : 'Já existe um rateio com este depósito e localização';
    }

    // Validação 4: Soma não pode ultrapassar conferido
    if (!podeAdicionarQuantidade(quantidade)) {
      return 'Quantidade ultrapassa o disponível para ratear (${quantidadeDisponivelParaRatear.toStringAsFixed(4)})';
    }

    return null; // ✅ Válido
  }

  /// Valida se pode atualizar quantidade de um rateio existente
  ///
  /// Retorna String com erro ou null se válido
  String? validarAtualizacaoRateio({
    required int rateioIndex,
    required double novaQuantidade,
  }) {
    if (!hasRateios || rateioIndex >= rateios!.length) {
      return 'Rateio não encontrado';
    }

    // Validação 1: Quantidade deve ser maior que zero
    if (novaQuantidade <= 0) {
      return 'Quantidade deve ser maior que zero';
    }

    final rateioAtual = rateios![rateioIndex];
    final quantidadeAtual = rateioAtual.qtdeLote;
    final diferenca = novaQuantidade - quantidadeAtual;

    // Validação 2: Nova soma não pode ultrapassar conferido
    final novaSoma = somaTotalRateios + diferenca;
    if (novaSoma > qtdeConferida) {
      final disponivel = qtdeConferida - (somaTotalRateios - quantidadeAtual);
      return 'Quantidade ultrapassa o disponível (máximo: ${disponivel.toStringAsFixed(4)})';
    }

    return null; // ✅ Válido
  }
}
