// lib/ui/features/estoque/recebimento/widgets/checklist_categoria_card.dart

import 'package:flutter/material.dart';
import 'package:wmsapp/data/models/checklist/checklist_categoria_model.dart';
import 'package:wmsapp/ui/features/estoque/recebimento/widgets/checklist_item_tile.dart';

/// Card expansível de categoria do checklist
class ChecklistCategoriaCard extends StatefulWidget {
  final ChecklistCategoriaModel categoria;
  final int codChecklist;

  const ChecklistCategoriaCard({
    super.key,
    required this.categoria,
    required this.codChecklist,
  });

  @override
  State<ChecklistCategoriaCard> createState() => _ChecklistCategoriaCardState();
}

class _ChecklistCategoriaCardState extends State<ChecklistCategoriaCard> {
  bool _isExpanded = true; // Inicia expandido

  @override
  Widget build(BuildContext context) {
    final categoria = widget.categoria;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getBorderColor(),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          // ==================================================================
          // HEADER: Título da Categoria
          // ==================================================================
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getHeaderColor(),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
              ),
              child: Row(
                children: [
                  // Ícone da categoria
                  _buildCategoriaIcon(),
                  const SizedBox(width: 12),

                  // Título
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          categoria.desCategoria,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${categoria.itensRespondidos}/${categoria.itens.length} itens',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Indicador de progresso
                  _buildProgressIndicator(),

                  const SizedBox(width: 12),

                  // Ícone de expandir/colapsar
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey.shade700,
                  ),
                ],
              ),
            ),
          ),

          // ==================================================================
          // BODY: Lista de Itens (Expansível)
          // ==================================================================
          if (_isExpanded)
            Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  ...categoria.itens.map((item) {
                    return ChecklistItemTile(
                      key: ValueKey(
                        'item-${categoria.sequenciaCat}-${item.sequenciaItem}',
                      ),
                      item: item,
                      codChecklist: widget.codChecklist,
                      sequenciaCat: categoria.sequenciaCat,
                    );
                  }).toList(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================================================
  // ÍCONE DA CATEGORIA
  // ==========================================================================

  Widget _buildCategoriaIcon() {
    IconData iconData;

    // Mapeia string do ícone para IconData
    switch (widget.categoria.icone.toLowerCase()) {
      case 'local_shipping':
        iconData = Icons.local_shipping;
        break;
      case 'inventory_2':
        iconData = Icons.inventory_2;
        break;
      case 'warehouse':
        iconData = Icons.warehouse;
        break;
      case 'check_circle':
        iconData = Icons.check_circle;
        break;
      case 'person':
        iconData = Icons.person;
        break;
      case 'widgets':
        iconData = Icons.widgets;
        break;
      case 'straighten':
        iconData = Icons.straighten;
        break;
      case 'content_cut':
        iconData = Icons.content_cut;
        break;
      case 'label':
        iconData = Icons.label;
        break;
      case 'science':
        iconData = Icons.science;
        break;
      default:
        iconData = Icons.checklist;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        iconData,
        color: _getIconColor(),
        size: 24,
      ),
    );
  }

  // ==========================================================================
  // INDICADOR DE PROGRESSO
  // ==========================================================================

  Widget _buildProgressIndicator() {
    final categoria = widget.categoria;
    final percentual = categoria.percentualConclusao;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            value: percentual / 100,
            strokeWidth: 4,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor()),
          ),
        ),
        Text(
          '${percentual.toStringAsFixed(0)}%',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // CORES
  // ==========================================================================

  Color _getBorderColor() {
    final percentual = widget.categoria.percentualConclusao;

    if (percentual >= 100) {
      return Colors.green;
    } else if (percentual > 0) {
      return Colors.orange;
    } else {
      return Colors.grey.shade300;
    }
  }

  Color _getHeaderColor() {
    final percentual = widget.categoria.percentualConclusao;

    if (percentual >= 100) {
      return Colors.green.withOpacity(0.1);
    } else if (percentual > 0) {
      return Colors.orange.withOpacity(0.05);
    } else {
      return Colors.grey.withOpacity(0.05);
    }
  }

  Color _getIconColor() {
    final percentual = widget.categoria.percentualConclusao;

    if (percentual >= 100) {
      return Colors.green;
    } else if (percentual > 0) {
      return Colors.orange;
    } else {
      return Colors.blue;
    }
  }

  Color _getProgressColor() {
    final percentual = widget.categoria.percentualConclusao;

    if (percentual >= 100) {
      return Colors.green;
    } else if (percentual >= 50) {
      return Colors.orange;
    } else {
      return Colors.blue;
    }
  }
}
