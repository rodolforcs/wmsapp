import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wmsapp/data/models/estoque/recebimento/rat_lote_model.dart';

// ============================================================================
// LOTE CONFERENCIA TILE - Tile para conferir um lote
// ============================================================================

/// Tile que permite conferir a quantidade de um lote específico
class LoteConferenciaTile extends StatefulWidget {
  final RatLoteModel lote;
  final Function(int) onQuantidadeChanged;
  final VoidCallback onFocusNext;

  const LoteConferenciaTile({
    super.key,
    required this.lote,
    required this.onQuantidadeChanged,
    required this.onFocusNext,
  });

  @override
  State<LoteConferenciaTile> createState() => _LoteConferenciaTileState();
}

class _LoteConferenciaTileState extends State<LoteConferenciaTile> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _loteDivergente = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.lote.qtdeLote > 0 ? widget.lote.qtdeLote.toString() : '',
    );
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);

    //_loteDivergente = widget.lote.temDivergencia;
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
      final value = _controller.text.isEmpty ? 0 : int.parse(_controller.text);
      widget.onQuantidadeChanged(value);
      setState(() {
        _loteDivergente = value > 0 && value != widget.lote.qtdeLote;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: _loteDivergente ? Colors.orange[50] : Colors.grey[100],
      child: Row(
        children: [
          // Informações do lote
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.lote.codLote,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Esperado: ${widget.lote.qtdeLote}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Campo de quantidade
          Expanded(
            flex: 2,
            child: TextField(
              focusNode: _focusNode,
              controller: _controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              onEditingComplete: widget.onFocusNext,
              decoration: const InputDecoration(
                hintText: 'Qtd',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                isDense: true,
              ),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
