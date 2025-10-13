import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ============================================================================
// CÉLULA EDITÁVEL DE TEXTO
// ============================================================================

class TextEditableCell extends StatefulWidget {
  final String value;
  final Function(String) onChanged;

  const TextEditableCell({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<TextEditableCell> createState() => _TextEditableCellState();
}

class _TextEditableCellState extends State<TextEditableCell> {
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
  void didUpdateWidget(covariant TextEditableCell oldWidget) {
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

class DateEditableCell extends StatelessWidget {
  final DateTime? value;
  final Function(DateTime?) onChanged;

  const DateEditableCell({
    super.key,
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

class QuantidadeEditableCell extends StatefulWidget {
  final double quantidade;
  final Function(double) onChanged;

  const QuantidadeEditableCell({
    super.key,
    required this.quantidade,
    required this.onChanged,
  });

  @override
  State<QuantidadeEditableCell> createState() => _QuantidadeEditableCellState();
}

class _QuantidadeEditableCellState extends State<QuantidadeEditableCell> {
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
  void didUpdateWidget(covariant QuantidadeEditableCell oldWidget) {
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

// ============================================================================
// CÉLULA SOMENTE LEITURA (ReadOnly)
// ============================================================================

class ReadOnlyCell extends StatelessWidget {
  final String value;
  final TextStyle? style;

  const ReadOnlyCell({
    super.key,
    required this.value,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Text(
        value.isEmpty ? '-' : value,
        style:
            style ??
            const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
      ),
    );
  }
}
