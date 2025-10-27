import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wmsapp/data/models/estoque/recebimento/it_doc_fisico_model.dart';
import 'package:wmsapp/data/models/estoque/recebimento/rat_lote_model.dart';
import 'package:wmsapp/ui/features/estoque/recebimento/viewmodel/recebimento_view_model.dart';
import 'package:wmsapp/ui/features/estoque/recebimento/widgets/rateio_tile.dart';
import 'package:wmsapp/ui/features/estoque/recebimento/widgets/rateio/rateio_data_table.dart';
//import 'package:wmsapp/ui/features/estoque/recebimento/widgets/rateios_data_table.dart';

// ============================================================================
// ITEM CONFERENCIA CARD - Card para conferir um item
// ============================================================================

class ItemConferenciaCard extends StatefulWidget {
  final ItDocFisicoModel item;
  final Function(double) onQuantidadeChanged;
  final Function(String, double) onRateioQuantidadeChanged;
  final Function(RatLoteModel)? onAdicionarRateio;
  final Function(String)? onRemoverRateio;

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
      text: widget.item.qtdeConferida > 0
          ? widget.item.qtdeConferida.toStringAsFixed(2)
          : '',
    );
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant ItemConferenciaCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.qtdeConferida != oldWidget.item.qtdeConferida) {
      _controller.text = widget.item.qtdeConferida > 0
          ? widget.item.qtdeConferida.toStringAsFixed(2)
          : '';
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
      final value = _controller.text.isEmpty
          ? 0.0
          : double.tryParse(_controller.text) ?? 0.0;
      widget.onQuantidadeChanged(value);

      print('Leave-sync disparado');

      // ✅ NOVO: Sincroniza imediatamente
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

    print('ReadOnly value => $isReadOnlyConferida');

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
                      const SizedBox(height: 4),

                      Text(
                        'Quantidade esperada: ${widget.item.qtdeItem.toStringAsFixed(2)} ${widget.item.unidMedida}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
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
                    readOnly: isReadOnlyConferida,
                    focusNode: _focusNode,
                    controller: _controller,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    onEditingComplete: () => FocusScope.of(context).nextFocus(),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
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
                if (widget.item.temDivergenciaRateio)
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 20,
                  ),
              ],
            ),
            subtitle: Text(
              'Total rateado: ${widget.item.somaTotalRateios.toStringAsFixed(2)} de ${widget.item.qtdeConferida.toStringAsFixed(2)}',
            ),
            onExpansionChanged: (expanded) {
              setState(() => _isExpanded = expanded);
            },
            children: [
              // TABLET: Usa DataTable
              if (isTablet) ...[
                RateioDataTable(
                  rateios: widget.item.rateios ?? [],
                  controlaLote: widget.item.controlaLote, // ← ADICIONE
                  onRateioChanged: (index, rateioAtualizado) {
                    // Atualiza o rateio completo
                    final rateios = List<RatLoteModel>.from(
                      widget.item.rateios!,
                    );
                    rateios[index] = rateioAtualizado;

                    // Notifica mudança de quantidade
                    widget.onRateioQuantidadeChanged(
                      rateioAtualizado.chaveRateio,
                      rateioAtualizado.qtdeLote,
                    );
                  },
                  onRemover: widget.onRemoverRateio != null
                      ? (index) {
                          final rateio = widget.item.rateios![index];
                          widget.onRemoverRateio!(rateio.chaveRateio);
                        }
                      : null,
                  onAdicionar: widget.onAdicionarRateio != null
                      ? () => _mostrarDialogNovoRateio(context)
                      : null,
                ),
              ]
              // MOBILE: Usa Cards
              else ...[
                if (widget.item.hasRateios && widget.item.rateios != null)
                  ...widget.item.rateios!.map((rateio) {
                    return RateioTile(
                      key: ValueKey(rateio.chaveRateio),
                      rateio: rateio,
                      onQuantidadeChanged: (valor) {
                        widget.onRateioQuantidadeChanged(
                          rateio.chaveRateio,
                          valor,
                        );
                      },
                      onRemover: widget.onRemoverRateio != null
                          ? () => widget.onRemoverRateio!(rateio.chaveRateio)
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
              ],
            ],
          ),
        ],
      ),
    );
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

  void _mostrarDialogNovoRateio(BuildContext context) {
    final seqController = TextEditingController();
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
              children: [
                TextField(
                  controller: seqController,
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Seq',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: depositoController,
                  decoration: const InputDecoration(
                    labelText: 'Depósito',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: localizController,
                  decoration: const InputDecoration(
                    labelText: 'Localização',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 12),

                if (widget.item.controlaLote) ...[
                  TextField(
                    controller: loteController,
                    decoration: const InputDecoration(
                      labelText: 'Lote *',
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
                        labelText: 'Validade',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        dataValidade != null
                            ? '${dataValidade!.day.toString().padLeft(2, '0')}/'
                                  '${dataValidade!.month.toString().padLeft(2, '0')}/'
                                  '${dataValidade!.year}'
                            : 'Selecione a data',
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
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Quantidade *',
                    border: const OutlineInputBorder(),
                    helperText:
                        'Restante: ${widget.item.qtdeNaoRateada.toStringAsFixed(2)}',
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
                final quantidade = double.tryParse(quantidadeController.text);

                if (quantidade == null || quantidade <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Informe uma quantidade válida'),
                    ),
                  );
                  return;
                }

                if (widget.item.controlaLote && loteController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Informe o lote'),
                    ),
                  );
                  return;
                }

                final novoRateio = RatLoteModel(
                  codDepos: depositoController.text,
                  codLocaliz: localizController.text,
                  codLote: loteController.text,
                  qtdeLote: quantidade,
                  dtValidade: dataValidade,
                  isEditavel: true,
                );

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
