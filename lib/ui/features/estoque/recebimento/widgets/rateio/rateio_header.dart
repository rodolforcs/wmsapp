import 'package:flutter/material.dart';

// ============================================================================
// RATEIO HEADER - Cabeçalho com título e botão adicionar
// ============================================================================

class RateioHeader extends StatelessWidget {
  final VoidCallback? onAdicionar;
  final String titulo;

  const RateioHeader({
    super.key,
    this.onAdicionar,
    this.titulo = 'Rateios de Estoque',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (onAdicionar != null)
            ElevatedButton.icon(
              onPressed: onAdicionar,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Adicionar Rateio'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
