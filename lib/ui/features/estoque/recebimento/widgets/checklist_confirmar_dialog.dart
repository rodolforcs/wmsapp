// lib/ui/features/estoque/recebimento/widgets/checklist_confirmar_dialog.dart

import 'package:flutter/material.dart';

/// Dialog de confirmação para finalizar checklist
class ChecklistConfirmarDialog extends StatelessWidget {
  final int itensRespondidos;
  final int totalItens;
  final VoidCallback onConfirmar;

  const ChecklistConfirmarDialog({
    super.key,
    required this.itensRespondidos,
    required this.totalItens,
    required this.onConfirmar,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.orange),
          SizedBox(width: 8),
          Text('Finalizar Checklist'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Deseja finalizar este checklist?',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          _buildStatusCard(),
          const SizedBox(height: 20),
          _buildWarning(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton.icon(
          onPressed: onConfirmar,
          icon: const Icon(Icons.check),
          label: const Text('Confirmar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Checklist Completo',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$itensRespondidos de $totalItens itens respondidos',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.orange, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Esta ação não poderá ser desfeita.',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
