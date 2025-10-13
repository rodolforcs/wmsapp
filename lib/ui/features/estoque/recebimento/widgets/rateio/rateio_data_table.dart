import 'package:flutter/material.dart';
import 'package:wmsapp/data/models/estoque/recebimento/rat_lote_model.dart';
import 'rateio_header.dart';
import 'rateio_empty_state.dart';
import 'rateio_data_row.dart';

// ============================================================================
// RATEIOS DATA TABLE - Tabela de rateios para tablet/desktop (REFATORADO)
// ============================================================================

class RateioDataTable extends StatelessWidget {
  final List<RatLoteModel> rateios;
  final Function(int index, RatLoteModel rateioAtualizado) onRateioChanged;
  final Function(int index)? onRemover;
  final VoidCallback? onAdicionar;
  final bool controlaLote;

  const RateioDataTable({
    super.key,
    required this.rateios,
    required this.onRateioChanged,
    this.onRemover,
    this.onAdicionar,
    this.controlaLote = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        RateioHeader(onAdicionar: onAdicionar),

        // Conteúdo: Tabela ou Empty State
        if (rateios.isEmpty)
          RateioEmptyState(onAdicionar: onAdicionar)
        else
          _buildDataTable(context),
      ],
    );
  }

  Widget _buildDataTable(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
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
        rows: _buildRows(context),
      ),
    );
  }

  List<DataRow> _buildRows(BuildContext context) {
    return rateios.asMap().entries.map((entry) {
      final index = entry.key;
      final rateio = entry.value;
      return RateioDataRow(
        context: context,
        index: index,
        rateio: rateio,
        controlaLote: controlaLote,
        onChanged: (rateioAtualizado) {
          onRateioChanged(index, rateioAtualizado);
        },
        onRemover: onRemover != null ? () => onRemover!(index) : null,
      ).build();
    }).toList();
  }
}
