import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wmsapp/data/models/estoque/recebimento/it_doc_fisico_model.dart';
import 'package:wmsapp/data/models/estoque/recebimento/rat_lote_model.dart';
import 'package:wmsapp/ui/features/estoque/recebimento/widgets/rateio_tile.dart';

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
          ? widget.item.qtdeConferida.toStringAsFixed(4)
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
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      const SizedBox(height: 4),
                      Text(
                        'Quantidade esperada: ${widget.item.qtdeItem.toStringAsFixed(4)} ${widget.item.unidMedida}',
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
                const Text(
                  'Qtd. conferida:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
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
                      hintText: '0.0000',
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
              'Total rateado: ${widget.item.somaTotalRateios.toStringAsFixed(4)} de ${widget.item.qtdeConferida.toStringAsFixed(2)}',
            ),
            onExpansionChanged: (expanded) {
              setState(() => _isExpanded = expanded);
            },
            children: [
              // Dentro do ExpansionTile, antes do map:
              // Lista de rateios existentes
              if (widget.item.hasRateios)
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

              // Mensagem se não tiver rateios
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

              // Botão para adicionar novo rateio
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
    final depositoController = TextEditingController();
    final loteController = TextEditingController();
    final quantidadeController = TextEditingController();
    final localizController = TextEditingController();
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
                // Lote (se controla)
                if (widget.item.controlaLote)
                  TextField(
                    controller: loteController,
                    decoration: const InputDecoration(
                      labelText: 'Lote',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),

                if (widget.item.controlaLote) const SizedBox(height: 12),

                // Data de validade (se controla lote)
                if (widget.item.controlaLote)
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

                if (widget.item.controlaLote) const SizedBox(height: 12),

                // Localização (se controla)
                if (widget.item.controlaEndereco)
                  TextField(
                    controller: localizController,
                    decoration: const InputDecoration(
                      labelText: 'Localização',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),

                if (widget.item.controlaEndereco) const SizedBox(height: 12),

                // Quantidade
                TextField(
                  controller: quantidadeController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Quantidade',
                    border: const OutlineInputBorder(),
                    helperText:
                        'Restante: ${widget.item.qtdeNaoRateada.toStringAsFixed(4)}',
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

                final novoRateio = RatLoteModel(
                  codDepos: depositoController.text,
                  codLote: loteController.text,
                  //dtValidade: dataValidade,
                  codLocaliz: localizController.text,
                  qtdeLote: quantidade,
                  isEditavel: true,
                  dtValidade: DateTime.now(),
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
