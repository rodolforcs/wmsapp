import 'package:flutter/material.dart';
import 'package:wmsapp/data/models/estoque/recebimento/docto_fisico_model.dart';
import 'package:wmsapp/shared/enums/status_documento.dart';
import 'package:wmsapp/shared/widgets/status_badge.dart';

// ============================================================================
// DOCTO FISICO CARD - Card de documento fiscal na lista
// ============================================================================

class DoctoFisicoCard extends StatelessWidget {
  final DoctoFisicoModel documento;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onCheckListTap;

  const DoctoFisicoCard({
    super.key,
    required this.documento,
    required this.isSelected,
    required this.onTap,
    this.onCheckListTap,
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

                  if (onCheckListTap != null) ...[
                    const SizedBox(width: 8),
                    _buildChecklistButton(context),
                  ],

                  const SizedBox(width: 8),

                  // Badge de status
                  StatusBadge(
                    status: StatusDocumento.fromString(documento.status),
                  ),
                  //_buildStatusBadge(documento.status),
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
  // ✅ NOVO: BOTÃO DE CHECKLIST
  // ==========================================================================

  Widget _buildChecklistButton(BuildContext context) {
    // TODO: Futuramente, verificar se checklist está completo
    final checklistCompleto = false; // Placeholder

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onCheckListTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: checklistCompleto
                ? Colors.green.shade50
                : Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: checklistCompleto
                  ? Colors.green.shade300
                  : Colors.blue.shade200,
              width: 1.5,
            ),
          ),
          child: Icon(
            checklistCompleto ? Icons.check_circle : Icons.checklist,
            size: 20,
            color: checklistCompleto
                ? Colors.green.shade700
                : Colors.blue.shade700,
          ),
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
