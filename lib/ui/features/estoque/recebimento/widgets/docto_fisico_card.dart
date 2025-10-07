import 'package:flutter/material.dart';
import 'package:wmsapp/data/models/estoque/recebimento/docto_fisico_model.dart';

// ============================================================================
// DOCTO FISICO CARD - Card de documento fiscal na lista
// ============================================================================

class DoctoFisicoCard extends StatelessWidget {
  final DoctoFisicoModel documento;
  final bool isSelected;
  final VoidCallback onTap;

  const DoctoFisicoCard({
    super.key,
    required this.documento,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Linha 1: Número NF + Série + Status
              Row(
                children: [
                  // Número da NF
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 20,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'NF ${documento.nroDocto}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Série
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: Colors.blue.shade200,
                            ),
                          ),
                          child: Text(
                            'Série ${documento.serieDocto}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Badge de status
                  _buildStatusBadge(),
                ],
              ),

              const SizedBox(height: 12),

              // Linha 2: Fornecedor
              Row(
                children: [
                  Icon(
                    Icons.business_outlined,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          documento.nomeAbreviado.isNotEmpty
                              ? documento.nomeAbreviado
                              : 'Fornecedor não informado',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (documento.codEmitente > 0)
                          Text(
                            'Cód: ${documento.codEmitente}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Linha 3: Detalhes (Data, Estabelecimento, Itens)
              Row(
                children: [
                  // Data de emissão
                  Expanded(
                    child: _buildInfoChip(
                      icon: Icons.calendar_today_outlined,
                      label: documento.dtEmissaoFormatada,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Estabelecimento
                  Expanded(
                    child: _buildInfoChip(
                      icon: Icons.store_outlined,
                      label: 'Est. ${documento.codEstabel}',
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Total de itens
                  Expanded(
                    child: _buildInfoChip(
                      icon: Icons.inventory_2_outlined,
                      label: '${documento.totalItems} itens',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // STATUS BADGE
  // ==========================================================================

  Widget _buildStatusBadge() {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (documento.status.toLowerCase()) {
      case 'pendente':
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        text = 'Pendente';
        break;
      case 'em conferência':
        backgroundColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        text = 'Em andamento';
        break;
      case 'conferido':
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        text = 'Conferido';
        break;
      default:
        backgroundColor = Colors.grey.shade50;
        textColor = Colors.grey.shade700;
        text = documento.status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  // ==========================================================================
  // INFO CHIP
  // ==========================================================================

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
