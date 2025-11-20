// lib/ui/features/estoque/recebimento/widgets/checklist_progress_bar.dart

import 'package:flutter/material.dart';

/// Barra de progresso do checklist
class ChecklistProgressBar extends StatelessWidget {
  final double percentual;
  final int itensRespondidos;
  final int totalItens;
  final String situacao;

  const ChecklistProgressBar({
    super.key,
    required this.percentual,
    required this.itensRespondidos,
    required this.totalItens,
    required this.situacao,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: _getBackgroundColor(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ====================================================================
          // LINHA 1: Situação e Percentual
          // ====================================================================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildStatusIcon(),
                  const SizedBox(width: 8),
                  Text(
                    situacao,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                '${percentual.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _getProgressColor(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ====================================================================
          // LINHA 2: Barra de Progresso
          // ====================================================================
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentual / 100,
              minHeight: 8,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor()),
            ),
          ),

          const SizedBox(height: 8),

          // ====================================================================
          // LINHA 3: Contador de Itens
          // ====================================================================
          Text(
            '$itensRespondidos de $totalItens itens respondidos',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // HELPERS
  // ==========================================================================

  Widget _buildStatusIcon() {
    if (percentual >= 100) {
      return const Icon(Icons.check_circle, color: Colors.green);
    } else if (percentual > 0) {
      return const Icon(Icons.timelapse, color: Colors.orange);
    } else {
      return const Icon(Icons.radio_button_unchecked, color: Colors.grey);
    }
  }

  Color _getProgressColor() {
    if (percentual >= 100) {
      return Colors.green;
    } else if (percentual >= 50) {
      return Colors.orange;
    } else {
      return Colors.blue;
    }
  }

  Color _getBackgroundColor() {
    if (percentual >= 100) {
      return Colors.green.withOpacity(0.1);
    } else if (percentual > 0) {
      return Colors.orange.withOpacity(0.05);
    } else {
      return Colors.grey.withOpacity(0.05);
    }
  }
}
