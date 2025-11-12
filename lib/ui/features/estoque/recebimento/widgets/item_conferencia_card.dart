import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wmsapp/data/models/estoque/recebimento/it_doc_fisico_model.dart';
import 'package:wmsapp/data/models/estoque/recebimento/rat_lote_model.dart';
import 'package:wmsapp/shared/utils/format_number_utils.dart';
import 'package:wmsapp/ui/features/estoque/recebimento/viewmodel/recebimento_view_model.dart';
import 'package:wmsapp/ui/features/estoque/recebimento/widgets/rateio_data_table.dart';
import 'package:wmsapp/ui/features/estoque/recebimento/widgets/rateio_tile.dart';

// ============================================================================
// ITEM CONFERENCIA CARD - Card para conferir um item
// ============================================================================

class ItemConferenciaCard extends StatefulWidget {
  final ItDocFisicoModel item;
  final Function(double) onQuantidadeChanged;
  final Function(int index, double quantidade) onRateioQuantidadeChanged;
  final Function(RatLoteModel)? onAdicionarRateio;
  final Function(int index)? onRemoverRateio;

  const ItemConferenciaCard({
    super.key,
    required this.item,
    required this.onQuantidadeChanged,
    required this.onRateioQuantidadeChanged,
    this.onAdicionarRateio,
    this.onRemoverRateio,
  });

  @override
  State<ItemConferenciaCard> createState() => _ItemConferenciaCardState();
}

class _ItemConferenciaCardState extends State<ItemConferenciaCard> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: FormatNumeroUtils.formatarQuantidadeOrEmpty(
        widget.item.qtdeConferida,
      ),
    );
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant ItemConferenciaCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.qtdeConferida != oldWidget.item.qtdeConferida) {
      _controller.text = FormatNumeroUtils.formatarQuantidadeOrEmpty(
        widget.item.qtdeConferida,
      );
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      final value = FormatNumeroUtils.parseQuantidade(_controller.text) ?? 0.0;
      widget.onQuantidadeChanged(value);

      final viewModel = context.read<RecebimentoViewModel>();
      viewModel.sincronizarAgora();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Detecta se é tablet
    final isTablet = MediaQuery.of(context).size.width > 768;

    final viewModel = context.watch<RecebimentoViewModel>();
    final isReadOnlyConferida = viewModel.isSyncing;

    Color borderColor = Colors.transparent;
    double borderWidth = 1;

    if (widget.item.temDivergencia) {
      borderColor = Colors.orange;
      borderWidth = 2;
    } else if (widget.item.conferidoCorreto) {
      borderColor = Colors.green;
      borderWidth = 2;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: borderColor,
          width: borderWidth,
        ),
      ),
      child: Column(
        children: [
          // Informações do item
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.codItem,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.item.descrItem,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      if (widget.item.temNarrativa) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.amber.shade200,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Colors.amber.shade700,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _limparNarrativa(widget.item.narrativa!),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade800,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 8),
                      // Linha com Pedido e Ordem
                      Row(
                        children: [
                          if (widget.item.numPedido.isNotEmpty) ...[
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Pedido: ${widget.item.numPedido}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                          if (widget.item.numeroOrdem.isNotEmpty) ...[
                            Icon(
                              Icons.receipt_outlined,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'OC: ${widget.item.numeroOrdem}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                      /*
                      const SizedBox(height: 4),

                      Text(
                        'Quantidade esperada: ${widget.item.qtdItemFormat} ${widget.item.unidMedida}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      */
                    ],
                  ),
                ),
                _buildStatusIcon(),
              ],
            ),
          ),

          // Campo de quantidade conferida
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Text(
                  'Qtd. conferida:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isReadOnlyConferida ? Colors.grey : Colors.black,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    enabled: !isReadOnlyConferida,
                    focusNode: _focusNode,
                    controller: _controller,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        FormatNumeroUtils.quantidadeRegex,
                      ),
                      /*
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*,?\d{0,4}'),
                        
                      )*/
                    ],
                    onEditingComplete: () => FocusScope.of(context).nextFocus(),
                    decoration: InputDecoration(
                      hintText: FormatNumeroUtils.quantidadeHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      suffixIcon: isReadOnlyConferida
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.blue,
                                ),
                              ),
                            )
                          : null,
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // ✅ NOVO: Indicador de validação da quantidade conferida
                if (widget.item.foiConferido) ...[
                  const SizedBox(width: 8),
                  Icon(
                    widget.item.quantidadeConferidaCorreta
                        ? Icons.check_circle
                        : Icons.warning_amber,
                    color: widget.item.quantidadeConferidaCorreta
                        ? Colors.green
                        : Colors.orange,
                    size: 24,
                  ),
                ],
              ],
            ),
          ),
          // Expansão de rateios
          ExpansionTile(
            title: Row(
              children: [
                const Text(
                  'Rateios de Estoque',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                // ✅ NOVO: Só valida rateios se JÁ conferiu
                if (widget.item.foiConferido &&
                    widget.item.temDivergenciaRateio)
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 20,
                  ),
                if (widget.item.foiConferido && widget.item.rateiosCorretos)
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
              ],
            ),
            subtitle: Text(
              widget.item.foiConferido
                  ? 'Total rateado: ${widget.item.somaTotalRateiosFormat} de ${widget.item.qtdeConferidaFormat}'
                  : 'Confira a quantidade primeiro para habilitar rateios',
              style: TextStyle(
                color: widget.item.foiConferido ? null : Colors.grey,
                fontStyle: widget.item.foiConferido ? null : FontStyle.italic,
                fontSize: 13,
              ),
            ),
            // ✅ NOVO: Desabilita expansão se não conferiu ainda
            enabled: widget.item.foiConferido,
            onExpansionChanged: widget.item.foiConferido
                ? (expanded) {
                    setState(() => _isExpanded = expanded);
                  }
                : null,
            children: [
              // TABLET: Usa DataTable
              if (isTablet) ...[
                RateioDataTable(
                  nrSequencia: widget.item.nrSequencia,
                  rateios: widget.item.rateios ?? [],
                  controlaLote: widget.item.controlaLote, // ← ADICIONE
                  onRateioChanged: (index, rateioAtualizado) {
                    widget.onRateioQuantidadeChanged(
                      index,
                      rateioAtualizado.qtdeLote,
                    );
                  },
                  onRemover: widget.onRemoverRateio != null
                      ? (index) {
                          widget.onRemoverRateio!(index);
                        }
                      : null,
                  onAdicionar: widget.onAdicionarRateio != null
                      ? () => _mostrarDialogNovoRateio(context)
                      : null,

                  // ✅ NOVO: Callback para salvar
                  onSalvar: (index) async {
                    final sucesso = await viewModel.atualizarRateioExistente(
                      widget.item.nrSequencia,
                      index,
                    );
                    if (sucesso) {
                      setState(() {});
                    }
                  },
                ),
              ]
              // MOBILE: Usa Cards
              else ...[
                if (widget.item.hasRateios && widget.item.rateios != null)
                  ...widget.item.rateios!.asMap().entries.map((entry) {
                    final index = entry.key;
                    final rateio = entry.value;

                    return RateioTile(
                      key: ValueKey(rateio.chaveRateio),
                      rateio: rateio,
                      onQuantidadeChanged: (valor) {
                        // ✅ MUDOU: Usa índice
                        widget.onRateioQuantidadeChanged(index, valor);
                        ;
                      },
                      onRemover: widget.onRemoverRateio != null
                          ? () => widget.onRemoverRateio!(index)
                          : null,
                      onFocusNext: () => FocusScope.of(context).nextFocus(),
                    );
                  }),

                if (!widget.item.hasRateios)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Nenhum rateio cadastrado',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                /*
                if (widget.onAdicionarRateio != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _mostrarDialogNovoRateio(context),
                        icon: const Icon(Icons.add),
                        label: const Text('Adicionar Rateio'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  */
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// Limpa a narrativa removendo espaços extras e quebras de linha
  String _limparNarrativa(String narrativa) {
    return narrativa
        .trim() // Remove espaços no início/fim
        .replaceAll(RegExp(r'\s+'), ' ') // Múltiplos espaços → 1 espaço
        .replaceAll(RegExp(r'\n+'), ' ') // Quebras de linha → espaço
        .replaceAll(RegExp(r'\r+'), ' ') // Carriage return → espaço
        .replaceAll(RegExp(r'\t+'), ' '); // Tabs → espaço
  }

  Widget _buildStatusIcon() {
    if (widget.item.conferidoCorreto) {
      return const Icon(
        Icons.check_circle,
        color: Colors.green,
        size: 28,
      );
    } else if (widget.item.temDivergencia) {
      return const Icon(
        Icons.warning_amber,
        color: Colors.orange,
        size: 28,
      );
    }
    return const SizedBox.shrink();
  }

  // ✅ NOVO: Método para salvar rateio individual
  Future<void> _salvarRateioIndividual(BuildContext context, int index) async {
    final viewModel = context.read<RecebimentoViewModel>();

    if (kDebugMode) {
      debugPrint(
        '💾 Salvando rateio index $index do item ${widget.item.codItem}',
      );
    }

    try {
      // TODO: Implementar método no ViewModel
      await viewModel.salvarRateioIndividual(widget.item.nrSequencia, index);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Rateio salvo com sucesso!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _mostrarDialogNovoRateio(BuildContext context) {
    final loteController = TextEditingController();
    final quantidadeController = TextEditingController();
    final localizController = TextEditingController();
    final depositoController = TextEditingController();
    DateTime? dataValidade;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Novo Rateio'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Informações do item (não editáveis)
                Card(
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Item: ${widget.item.codItem}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.item.descrItem,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Sequência: ${widget.item.nrSequencia}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              'Qtde conferida: ${widget.item.qtdeConferidaFormat}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Não rateado: ${widget.item.qtdeNaoRateada.toStringAsFixed(4)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: widget.item.qtdeNaoRateada > 0
                                ? Colors.orange[700]
                                : Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ✅ Campos editáveis do rateio
                TextField(
                  controller: depositoController,
                  decoration: const InputDecoration(
                    labelText: 'Depósito *',
                    hintText: 'Ex: ALM',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: localizController,
                  decoration: const InputDecoration(
                    labelText: 'Localização',
                    hintText: 'Ex: P01A1',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 12),

                // ✅ Campos de lote (apenas se controla lote)
                if (widget.item.controlaLote) ...[
                  TextField(
                    controller: loteController,
                    decoration: const InputDecoration(
                      labelText: 'Lote *',
                      hintText: 'Ex: L001',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                  const SizedBox(height: 12),

                  InkWell(
                    onTap: () async {
                      final data = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(
                          const Duration(days: 3650),
                        ),
                      );
                      if (data != null) {
                        setStateDialog(() => dataValidade = data);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Data de Validade',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        dataValidade != null
                            ? '${dataValidade!.day.toString().padLeft(2, '0')}/'
                                  '${dataValidade!.month.toString().padLeft(2, '0')}/'
                                  '${dataValidade!.year}'
                            : 'Selecione a data (opcional)',
                        style: TextStyle(
                          color: dataValidade != null
                              ? Colors.black
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                TextField(
                  controller: quantidadeController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      FormatNumeroUtils.quantidadeRegex,
                    ),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Quantidade *',
                    hintText: FormatNumeroUtils.quantidadeHint,
                    border: const OutlineInputBorder(),
                    helperText:
                        'Restante para ratear: ${widget.item.qtdeNaoReateadaFomat}',
                    helperMaxLines: 2,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                // ✅ Validações
                if (depositoController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Informe o depósito'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                if (widget.item.controlaLote &&
                    loteController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Item controla lote - informe o lote'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                final quantidade = FormatNumeroUtils.parseQuantidade(
                  quantidadeController.text,
                );

                if (quantidade == null || quantidade <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Informe uma quantidade válida (maior que zero)',
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                // ✅ Cria rateio - sequência será preenchida no ViewModel
                final novoRateio = RatLoteModel(
                  codDepos: depositoController.text.trim().toUpperCase(),
                  codLocaliz: localizController.text.trim().toUpperCase(),
                  codLote: loteController.text.trim().toUpperCase(),
                  qtdeLote: quantidade,
                  dtValidade: dataValidade,
                  isEditavel: true,
                  sequencia:
                      widget.item.nrSequencia, // ✅ Usa a sequência do item!
                );

                if (kDebugMode) {
                  debugPrint('📦 Criando rateio:');
                  debugPrint('  Item seq: ${widget.item.nrSequencia}');
                  debugPrint('  Rateio seq: ${novoRateio.sequencia}');
                  debugPrint('  Depósito: ${novoRateio.codDepos}');
                  debugPrint('  Localização: ${novoRateio.codLocaliz}');
                  debugPrint('  Lote: ${novoRateio.codLote}');
                  debugPrint('  Quantidade: ${novoRateio.qtdeLote}');
                }

                widget.onAdicionarRateio!(novoRateio);
                Navigator.of(context).pop();
              },
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }
}
