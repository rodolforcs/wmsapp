// lib/ui/features/estoque/recebimento/widgets/checklist_info_dialog.dart

import 'package:flutter/material.dart';
import 'package:wmsapp/data/models/checklist/checklist_model.dart';

/// Dialog com informações detalhadas do checklist
class ChecklistInfoDialog extends StatelessWidget {
  final ChecklistModel checklist;

  const ChecklistInfoDialog({
    super.key,
    required this.checklist,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue),
          SizedBox(width: 8),
          Text('Informações do Checklist'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSection(
              title: 'Identificação',
              items: [
                _InfoItem('Código', checklist.codChecklist.toString()),
                _InfoItem('Template', checklist.desTemplate),
                _InfoItem('Tipo', checklist.tipoChecklist),
                _InfoItem('Situação', checklist.situacaoDescricao),
              ],
            ),
            const Divider(height: 24),
            _buildSection(
              title: 'Progresso',
              items: [
                _InfoItem('Total de Itens', checklist.totalItens.toString()),
                _InfoItem(
                  'Itens Respondidos',
                  checklist.itensRespondidos.toString(),
                ),
                _InfoItem(
                  'Percentual',
                  '${checklist.percentualConclusao.toStringAsFixed(1)}%',
                ),
              ],
            ),
            const Divider(height: 24),
            _buildSection(
              title: 'Informações Adicionais',
              items: [
                _InfoItem(
                  'Iniciado em',
                  _formatarDataHora(checklist.dtInicio),
                ),
                _InfoItem('Usuário', checklist.usuarioInicio),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<_InfoItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => _buildInfoRow(item.label, item.value)),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatarDataHora(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year} '
        '${data.hour.toString().padLeft(2, '0')}:'
        '${data.minute.toString().padLeft(2, '0')}';
  }
}

/// Classe auxiliar para info items
class _InfoItem {
  final String label;
  final String value;

  _InfoItem(this.label, this.value);
}
