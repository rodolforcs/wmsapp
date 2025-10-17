// lib/ui/features/estoque/recebimento/widgets/documento_info_card.dart
import 'package:flutter/material.dart';
import 'package:wmsapp/data/models/estoque/recebimento/docto_fisico_model.dart';
import 'package:wmsapp/shared/widgets/status_badge.dart';

/// Widget que exibe informações do documento fiscal
///
/// Mostra:
/// - Número da NF e série
/// - Nome do fornecedor
/// - Badge de status
class DocumentoInfoCard extends StatelessWidget {
  final DoctoFisicoModel documento;

  const DocumentoInfoCard({
    super.key,
    required this.documento,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NF ${documento.nroDocto} - Série ${documento.serieDocto}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    documento.nomeAbreviado,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            _buildStatusBadge(documento.status),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    switch (status.toLowerCase()) {
      case 'pendente':
        return StatusBadge.warning(status);
      case 'em conferência':
        return StatusBadge.info(status);
      case 'concluído':
      case 'concluida':
        return StatusBadge.success(status);
      default:
        return StatusBadge.neutral(status);
    }
  }
}
