// lib/ui/features/estoque/recebimento/widgets/conferencia_progress_indicator.dart
import 'package:flutter/material.dart';
import 'package:wmsapp/data/models/estoque/recebimento/docto_fisico_model.dart';
import 'package:wmsapp/shared/widgets/custom_progress_bar.dart';

class ConferenciaProgressIndicator extends StatelessWidget {
  final DoctoFisicoModel documento;

  const ConferenciaProgressIndicator({
    super.key,
    required this.documento,
  });

  @override
  Widget build(BuildContext context) {
    final totalItens = documento.itensDoc.length;
    final conferidos = documento.quantidadeItensConferidos;
    final porcentagem = totalItens > 0 ? conferidos / totalItens : 0.0;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          CustomProgressBar(
            value: porcentagem,
            label: 'Progresso da Conferência',
            showPercentage: false,
            height: 8,
            progressColor: porcentagem == 1.0 ? Colors.green : Colors.blue,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$conferidos de $totalItens itens conferidos',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              if (porcentagem == 1.0)
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Concluído',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
