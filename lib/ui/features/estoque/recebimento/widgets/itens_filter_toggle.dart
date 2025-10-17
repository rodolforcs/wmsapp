// lib/ui/features/estoque/recebimento/widgets/itens_filter_toggle.dart
import 'package:flutter/material.dart';
import 'package:wmsapp/shared/widgets/filter_toggle_button.dart';

class ItensFilterToggle extends StatelessWidget {
  final bool mostrarApenasNaoConferidos;
  final int totalItens;
  final int itensNaoConferidos;
  final VoidCallback onToggle;

  const ItensFilterToggle({
    super.key,
    required this.mostrarApenasNaoConferidos,
    required this.totalItens,
    required this.itensNaoConferidos,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(
            'Exibir:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 12),
          FilterToggleButton(
            label: mostrarApenasNaoConferidos
                ? 'Pendentes ($itensNaoConferidos)'
                : 'Todos ($totalItens)',
            isSelected: mostrarApenasNaoConferidos,
            onTap: onToggle,
            icon: mostrarApenasNaoConferidos ? Icons.filter_list : Icons.list,
            selectedColor: Colors.blue,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
        ],
      ),
    );
  }
}
