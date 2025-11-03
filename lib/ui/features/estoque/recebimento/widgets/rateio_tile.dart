import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wmsapp/data/models/estoque/recebimento/rat_lote_model.dart';
import 'package:wmsapp/shared/utils/format_number_utils.dart';

// ============================================================================
// RATEIO TILE - Linha de um rateio dentro do item
// ============================================================================

class RateioTile extends StatefulWidget {
  final RatLoteModel rateio;
  final Function(double) onQuantidadeChanged;
  final VoidCallback? onRemover;
  final VoidCallback? onFocusNext;

  const RateioTile({
    super.key,
    required this.rateio,
    required this.onQuantidadeChanged,
    this.onRemover,
    this.onFocusNext,
  });

  @override
  State<RateioTile> createState() => _RateioTileState();
}

class _RateioTileState extends State<RateioTile> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: FormatNumeroUtils.formatarQuantidadeOrEmpty(widget.rateio.qtdeLote),
    );
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant RateioTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rateio.qtdeLote != oldWidget.rateio.qtdeLote) {
      _controller.text = FormatNumeroUtils.formatarQuantidade(
        widget.rateio.qtdeLote,
      );
      /*
      _controller.text = widget.rateio.qtdeLote > 0
          ? widget.rateio.qtdeLote.toStringAsFixed(2)
          : '';
          */
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
    // DEBUG - Adicione estes prints
    print('🔍 RateioTile #${widget.rateio.codLote}');
    print('🔍 Depósito: "${widget.rateio.codDepos}"');
    print('🔍 Localização: "${widget.rateio.codLocaliz}"');
    print('🔍 Lote: "${widget.rateio.codLote}"');
    print('🔍 Validade: ${widget.rateio.dtValidade}');
    print('🔍 Quantidade: ${widget.rateio.qtdeLote}');
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com ações
          Row(
            children: [
              Expanded(
                child: Text(
                  'Rateio #${widget.rateio.codLote}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              if (widget.onRemover != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: Colors.red,
                  onPressed: () => _confirmarRemocao(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),

          const SizedBox(height: 8),

          // Informações do rateio
          if (widget.rateio.codDepos.isNotEmpty)
            _buildInfoRow(
              icon: Icons.warehouse,
              label: 'Depósito',
              value: widget.rateio.codDepos,
            ),

          if (widget.rateio.codLocaliz.isNotEmpty)
            _buildInfoRow(
              icon: Icons.location_on,
              label: 'Localização',
              value: widget.rateio.codLocaliz,
            ),

          if (widget.rateio.codLote.isNotEmpty)
            _buildInfoRow(
              icon: Icons.qr_code_2,
              label: 'Lote',
              value: widget.rateio.codLote,
            ),

          if (widget.rateio.dtValidade != null)
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'Validade',
              value:
                  '${widget.rateio.dtValidade!.day.toString().padLeft(2, '0')}/'
                  '${widget.rateio.dtValidade!.month.toString().padLeft(2, '0')}/'
                  '${widget.rateio.dtValidade!.year}',
            ),

          const SizedBox(height: 8),

          // Campo de quantidade
          Row(
            children: [
              const Icon(Icons.inventory_2, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              const Text(
                'Quantidade:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
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
                  onEditingComplete: () {
                    if (widget.onFocusNext != null) {
                      widget.onFocusNext!();
                    } else {
                      FocusScope.of(context).nextFocus();
                    }
                  },
                  decoration: InputDecoration(
                    hintText: '0.00',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
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
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmarRemocao(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Rateio'),
        content: const Text(
          'Tem certeza que deseja remover este rateio?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onRemover!();
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
