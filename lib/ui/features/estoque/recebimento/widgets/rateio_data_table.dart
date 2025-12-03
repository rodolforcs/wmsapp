import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wmsapp/data/models/estoque/recebimento/rat_lote_model.dart';
import 'package:wmsapp/shared/utils/format_number_utils.dart';

// ============================================================================
// RATEIOS DATA TABLE - Tabela de rateios para tablet/desktop
// ============================================================================

class RateioDataTable extends StatefulWidget {
  final int nrSequencia;
  final List<RatLoteModel> rateios;
  final Function(int index, RatLoteModel rateioAtualizado) onRateioChanged;
  final Function(int index)? onRemover;
  final VoidCallback? onAdicionar;
  final bool controlaLote;
  final Function(int index)? onSalvar; // ✅ NOVO

  const RateioDataTable({
    super.key,
    required this.nrSequencia,
    required this.rateios,
    required this.onRateioChanged,
    this.onRemover,
    this.onAdicionar,
    this.controlaLote = true,
    this.onSalvar, // ✅ NOVO
  });

  @override
  State<RateioDataTable> createState() => _RateioDataTableState();
}

class _RateioDataTableState extends State<RateioDataTable> {
  // ✅ Controla quais rateios foram editados
  final Set<int> _rateiosaEditados = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header com título e botão adicionar
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text(
                'Rateios de Estoque',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (widget.onAdicionar != null)
                ElevatedButton.icon(
                  onPressed: widget.onAdicionar,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Adicionar Rateio'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // DataTable
        if (widget.rateios.isEmpty)
          _buildEmptyState()
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(
                Colors.grey.shade100,
              ),
              border: TableBorder.all(
                color: Colors.grey.shade300,
                width: 1,
              ),
              columnSpacing: 20,
              horizontalMargin: 16,
              columns: const [
                DataColumn(
                  label: Text(
                    'Seq',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Depósito',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Localização',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Lote',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Validade',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Quantidade',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  numeric: true,
                ),
                DataColumn(
                  label: Text(
                    'Ações',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: widget.rateios.asMap().entries.map((entry) {
                final index = entry.key;
                final rateio = entry.value;
                return _buildDataRow(context, index, rateio);
              }).toList(),
            ),
          ),
      ],
    );
  }

  DataRow _buildDataRow(BuildContext context, int index, RatLoteModel rateio) {
    final foiEditado = _rateiosaEditados.contains(index);

    // ✅ LOG PARA DEBUG
    if (kDebugMode) {
      print(
        '🔍 Row $index: sequencia=${rateio.sequencia}, foiEditado=$foiEditado',
      );
    }

    // ✅ LOG PARA DEBUG
    if (kDebugMode) {
      print(
        '🔍 Row $index: foiEditado=$foiEditado, _rateiosaEditados=$_rateiosaEditados',
      );
    }

    return DataRow(
      cells: [
        // Sequência
        DataCell(Text('${rateio.sequencia}')),

        // Depósito (editável)
        DataCell(
          _TextEditableCell(
            value: rateio.codDepos,
            onChanged: (valor) {
              if (valor != rateio.codDepos) {
                // ✅ Marca como editado se mudou de valor
                setState(() => _rateiosaEditados.add(index));
                final atualizado = rateio.copyWith(codDepos: valor);
                widget.onRateioChanged(index, atualizado);
              }
            },
          ),
        ),
        // Localização (editável)
        DataCell(
          _TextEditableCell(
            value: rateio.codLocaliz,
            onChanged: (valor) {
              debugPrint('📝 Localização mudou: "$valor"');
              debugPrint('   Valor anterior: "${rateio.codLocaliz}"');

              if (valor != rateio.codLocaliz) {
                // ✅ Marca como editado
                setState(() => _rateiosaEditados.add(index));
                final atualizado = rateio.copyWith(codLocalizacao: valor);

                debugPrint('✅ Após copyWith:');
                debugPrint('   codLocaliz: "${atualizado.codLocaliz}"');

                widget.onRateioChanged(index, atualizado);
              }
            },
          ),
        ),

        // Lote (editável só se controla lote)
        DataCell(
          widget.controlaLote
              ? _TextEditableCell(
                  value: rateio.codLote,
                  onChanged: (valor) {
                    // ✅ Marca como editado
                    if (valor != rateio.codLote) {
                      setState(() => _rateiosaEditados.add(index));
                      final atualizado = rateio.copyWith(codLote: valor);
                      widget.onRateioChanged(index, atualizado);
                    }
                  },
                )
              : Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: Text(
                    rateio.codLote.isEmpty ? '-' : rateio.codLote,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
        ),
        // Validade (editável só se controla lote)
        DataCell(
          widget.controlaLote
              ? _DateEditableCell(
                  value: rateio.dtValidade,
                  onChanged: (data) {
                    if (data != rateio.dtValidade) {
                      // ✅ Marca como editado
                      setState(() {
                        _rateiosaEditados.add(index);
                      });

                      final atualizado = rateio.copyWith(dtValidade: data);
                      widget.onRateioChanged(index, atualizado);
                    }
                  },
                )
              : Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: Text(
                    rateio.dtValidade != null
                        ? _formatarData(rateio.dtValidade!)
                        : '-',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
        ),

        // Quantidade (editável)
        DataCell(
          _QuantidadeEditableCell(
            quantidade: rateio.qtdeLote,
            onChanged: (valor) {
              if (valor != rateio.qtdeLote) {
                // ✅ Marca como editado
                setState(() => _rateiosaEditados.add(index));
                final atualizado = rateio.copyWith(qtdeLote: valor);
                widget.onRateioChanged(index, atualizado);
              }
            },
          ),
        ),

        // ✅ Ações (Salvar + Deletar)
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              /*
              // ✅ LOG DO BOTÃO
              if (kDebugMode) ...[
                Text(
                  '[$index:${foiEditado ? "EDIT" : "OK"}]',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
                const SizedBox(width: 4),
              ],
            */
              // ✅ Botão Salvar (só aparece se foi editado)
              if (foiEditado && widget.onSalvar != null) ...[
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.check, size: 18),
                    color: Colors.green.shade700,
                    tooltip: 'Salvar alterações',
                    onPressed: () {
                      // ✅ DEBUG: Verifica se o botão foi clicado
                      debugPrint('═══════════════════════════════════════');
                      debugPrint('🖱️ [UI] Botão SALVAR clicado!');
                      debugPrint(
                        '   Item sequencia: ${widget.nrSequencia}',
                      );
                      debugPrint('   Rateio index: $index');
                      debugPrint('═══════════════════════════════════════');

                      if (widget.onSalvar != null) {
                        debugPrint(
                          '✅ [UI] Chamando callback onSalvarRateio...',
                        );
                        widget.onSalvar!(index);
                        // ✅ NOVO: Remove da lista de editados após callback completar
                        if (mounted) {
                          setState(() {
                            _rateiosaEditados.remove(index);
                          });

                          if (kDebugMode) {
                            debugPrint(
                              '✅ [UI] Rateio $index removido da lista de editados',
                            );
                            debugPrint('   Lista atual: $_rateiosaEditados');
                          }
                        }
                      } else {
                        debugPrint('❌ [UI] Callback onSalvarRateio é NULL!');
                      }
                      /*
                      widget.onSalvar!(index);
                      setState(() {
                        _rateiosaEditados.remove(index);
                      });
                      */
                    },
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                /*
                IconButton(
                  icon: const Icon(Icons.save, size: 20),
                  color: Colors.green,
                  tooltip: 'Salvar alterações',
                  onPressed: () {
                    widget.onSalvar!(index);
                    // Remove da lista de editados após salvar
                    setState(() {
                      _rateiosaEditados.remove(index);
                    });
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                */
              ],

              // Botão Deletar
              if (widget.onRemover != null)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    color: Colors.red.shade700,
                    tooltip: 'Remover',
                    onPressed: () {
                      _confirmarRemocao(context, index);
                    },
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              /*
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: Colors.red,
                  tooltip: 'Remover',
                  onPressed: () => _confirmarRemocao(context, index),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                */
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum rateio cadastrado',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            if (widget.onAdicionar != null) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: widget.onAdicionar,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar primeiro rateio'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  void _confirmarRemocao(BuildContext context, int index) {
    if (widget.onRemover == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Rateio'),
        content: const Text('Tem certeza que deseja remover este rateio?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onRemover!(index);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// CÉLULAS EDITÁVEIS (sem alterações - mantém seu código existente)
// ============================================================================

class _TextEditableCell extends StatefulWidget {
  final String value;
  final Function(String) onChanged;

  const _TextEditableCell({
    required this.value,
    required this.onChanged,
  });

  @override
  State<_TextEditableCell> createState() => _TextEditableCellState();
}

class _TextEditableCellState extends State<_TextEditableCell> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant _TextEditableCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _controller.text = widget.value;
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
      widget.onChanged(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        border: OutlineInputBorder(),
      ),
      style: const TextStyle(fontSize: 14),
      textCapitalization: TextCapitalization.characters,
    );
  }
}

class _DateEditableCell extends StatelessWidget {
  final DateTime? value;
  final Function(DateTime?) onChanged;

  const _DateEditableCell({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isVencido = value != null && value!.isBefore(DateTime.now());

    return InkWell(
      onTap: () => _selecionarData(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: value == null
                  ? Colors.grey
                  : (isVencido ? Colors.red : Colors.green),
            ),
            const SizedBox(width: 8),
            Text(
              value != null ? _formatarData(value!) : 'Selecionar',
              style: TextStyle(
                fontSize: 14,
                color: value == null
                    ? Colors.grey
                    : (isVencido ? Colors.red : Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selecionarData(BuildContext context) async {
    final data = await showDatePicker(
      context: context,
      initialDate: value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );

    if (data != null) {
      onChanged(data);
    }
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }
}

class _QuantidadeEditableCell extends StatefulWidget {
  final double quantidade;
  final Function(double) onChanged;

  const _QuantidadeEditableCell({
    required this.quantidade,
    required this.onChanged,
  });

  @override
  State<_QuantidadeEditableCell> createState() =>
      _QuantidadeEditableCellState();
}

class _QuantidadeEditableCellState extends State<_QuantidadeEditableCell> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: FormatNumeroUtils.formatarQuantidadeOrEmpty(widget.quantidade),
    );
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant _QuantidadeEditableCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.quantidade != oldWidget.quantidade && !_isEditing) {
      _controller.text = FormatNumeroUtils.formatarQuantidadeOrEmpty(
        widget.quantidade,
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
      setState(() => _isEditing = false);
      final value = FormatNumeroUtils.parseQuantidade(_controller.text) ?? 0.0;
      widget.onChanged(value);
      /*
      final value = _controller.text.isEmpty
          ? 0.0
          : double.tryParse(_controller.text) ?? 0.0;
      widget.onChanged(value);
      */
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      //width: 100,
      width: FormatNumeroUtils.quantidadeCellWidth,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(FormatNumeroUtils.quantidadeRegex),
        ],
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          border: OutlineInputBorder(),
          hintText: FormatNumeroUtils.quantidadeHint,
        ),
        style: const TextStyle(fontSize: 14),
        textAlign: TextAlign.right,
        onTap: () => setState(() => _isEditing = true),
      ),
    );
  }
}
