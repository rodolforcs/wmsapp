import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wmsapp/data/models/estoque/recebimento/rat_lote_model.dart';

// ============================================================================
// RATEIOS DATA TABLE - Tabela de rateios para tablet/desktop
// ============================================================================

class RateiosDataTable extends StatelessWidget {
  final List<RatLoteModel> rateios;
  final Function(int index, RatLoteModel rateioAtualizado) onRateioChanged;
  final Function(int index)? onRemover;
  final VoidCallback? onAdicionar;
  final bool controlaLote; // ← ADICIONE

  const RateiosDataTable({
    super.key,
    required this.rateios,
    required this.onRateioChanged,
    this.onRemover,
    this.onAdicionar,
    this.controlaLote = true, // ← ADICIONE com valor padrão
  });

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
              if (onAdicionar != null)
                ElevatedButton.icon(
                  onPressed: onAdicionar,
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
        if (rateios.isEmpty)
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
              rows: rateios.asMap().entries.map((entry) {
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
    return DataRow(
      cells: [
        // Sequência
        DataCell(Text('${index + 1}')),

        // Depósito (editável)
        DataCell(
          _TextEditableCell(
            value: rateio.codDepos,
            onChanged: (valor) {
              final atualizado = rateio.copyWith(codDepos: valor);
              onRateioChanged(index, atualizado);
            },
          ),
        ),

        // Localização (editável)
        DataCell(
          _TextEditableCell(
            value: rateio.codLocaliz,
            onChanged: (valor) {
              final atualizado = rateio.copyWith(codLocalizacao: valor);
              onRateioChanged(index, atualizado);
            },
          ),
        ),

        // Lote (editável só se controla lote)
        DataCell(
          controlaLote
              ? _TextEditableCell(
                  value: rateio.codLote,
                  onChanged: (valor) {
                    final atualizado = rateio.copyWith(codLote: valor);
                    onRateioChanged(index, atualizado);
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
          controlaLote
              ? _DateEditableCell(
                  value: rateio.dtValidade,
                  onChanged: (data) {
                    final atualizado = rateio.copyWith(dtValidade: data);
                    onRateioChanged(index, atualizado);
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
              final atualizado = rateio.copyWith(qtdeLote: valor);
              onRateioChanged(index, atualizado);
            },
          ),
        ),

        // Ações
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onRemover != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: Colors.red,
                  tooltip: 'Remover',
                  onPressed: () => _confirmarRemocao(context, index),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
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
            if (onAdicionar != null) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: onAdicionar,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar primeiro rateio'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _isVencido(DateTime validade) {
    return validade.isBefore(DateTime.now());
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  void _confirmarRemocao(BuildContext context, int index) {
    if (onRemover == null) return;

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
              onRemover!(index);
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
// CÉLULA EDITÁVEL DE TEXTO
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

// ============================================================================
// CÉLULA EDITÁVEL DE DATA
// ============================================================================

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

// ============================================================================
// CÉLULA EDITÁVEL DE QUANTIDADE
// ============================================================================

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
      text: widget.quantidade > 0 ? widget.quantidade.toStringAsFixed(2) : '',
    );
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant _QuantidadeEditableCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.quantidade != oldWidget.quantidade && !_isEditing) {
      _controller.text = widget.quantidade > 0
          ? widget.quantidade.toStringAsFixed(2)
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
      setState(() => _isEditing = false);
      final value = _controller.text.isEmpty
          ? 0.0
          : double.tryParse(_controller.text) ?? 0.0;
      widget.onChanged(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ],
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          border: OutlineInputBorder(),
        ),
        style: const TextStyle(fontSize: 14),
        textAlign: TextAlign.right,
        onTap: () => setState(() => _isEditing = true),
      ),
    );
  }
}
