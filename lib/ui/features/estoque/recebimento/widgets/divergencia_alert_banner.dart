// lib/ui/features/estoque/recebimento/widgets/divergencia_alert_banner.dart
import 'package:flutter/material.dart';
import 'package:wmsapp/data/models/estoque/recebimento/docto_fisico_model.dart';

/// Widget que exibe um banner de alerta quando há divergências
///
/// Auto-oculta se não houver divergências
/// Mostra contador de itens com divergência
class DivergenciaAlertBanner extends StatelessWidget {
  final DoctoFisicoModel documento;

  const DivergenciaAlertBanner({
    super.key,
    required this.documento,
  });

  @override
  Widget build(BuildContext context) {
    // Não mostra nada se não houver divergências
    if (!documento.temDivergencias) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange.shade700,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Divergências encontradas',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade900,
                  ),
                ),
                Text(
                  '${documento.itensComDivergencia.length} item(ns) com divergência',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
