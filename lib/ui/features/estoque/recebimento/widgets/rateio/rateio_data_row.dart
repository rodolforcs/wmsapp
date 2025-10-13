import 'package:flutter/material.dart';
import 'package:wmsapp/data/models/estoque/recebimento/rat_lote_model.dart';
import 'rateio_editable_cells.dart';

// ============================================================================
// RATEIO DATA ROW - Construtor de linha para DataTable
// ============================================================================

class RateioDataRow {
  final int index;
  final RatLoteModel rateio;
  final bool controlaLote;
  final Function(RatLoteModel) onChanged;
  final VoidCallback? onRemover;
  final BuildContext context;

  RateioDataRow({
    required this.index,
    required this.rateio,
    required this.controlaLote,
    required this.onChanged,
    this.onRemover,
    required this.context,
  });

  DataRow build() {
    return DataRow(
      cells: [
        // Sequência
        //DataCell(Text(rateio.sequencia.toString())),
        DataCell(
          ReadOnlyCell(
            value: rateio.sequencia.toString(),
          ),
        ),

        // Depósito (editável)
        DataCell(
          TextEditableCell(
            value: rateio.codDepos,
            onChanged: (valor) {
              final atualizado = rateio.copyWith(codDepos: valor);
              onChanged(atualizado);
            },
          ),
        ),

        // Localização (editável)
        DataCell(
          TextEditableCell(
            value: rateio.codLocaliz,
            onChanged: (valor) {
              final atualizado = rateio.copyWith(codLocalizacao: valor);
              onChanged(atualizado);
            },
          ),
        ),

        // Lote (editável só se controla lote)
        DataCell(
          controlaLote
              ? TextEditableCell(
                  value: rateio.codLote,
                  onChanged: (valor) {
                    final atualizado = rateio.copyWith(codLote: valor);
                    onChanged(atualizado);
                  },
                )
              : ReadOnlyCell(value: rateio.codLote),
        ),

        // Validade (editável só se controla lote)
        DataCell(
          controlaLote
              ? DateEditableCell(
                  value: rateio.dtValidade,
                  onChanged: (data) {
                    final atualizado = rateio.copyWith(dtValidade: data);
                    onChanged(atualizado);
                  },
                )
              : ReadOnlyCell(
                  value: rateio.dtValidade != null
                      ? _formatarData(rateio.dtValidade!)
                      : '-',
                ),
        ),

        // Quantidade (editável)
        DataCell(
          QuantidadeEditableCell(
            quantidade: rateio.qtdeLote,
            onChanged: (valor) {
              final atualizado = rateio.copyWith(qtdeLote: valor);
              onChanged(atualizado);
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
                  onPressed: () => _confirmarRemocao(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  void _confirmarRemocao() {
    if (onRemover == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover Rateio'),
        content: const Text('Tem certeza que deseja remover este rateio?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onRemover!();
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
