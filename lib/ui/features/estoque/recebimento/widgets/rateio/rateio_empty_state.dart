import 'package:flutter/material.dart';

// ============================================================================
// EMPTY STATE - Exibido quando não há rateios cadastrados
// ============================================================================

class RateioEmptyState extends StatelessWidget {
  final VoidCallback? onAdicionar;

  const RateioEmptyState({
    super.key,
    this.onAdicionar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum rateio cadastrado',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            if (onAdicionar != null) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: onAdicionar,
                icon: const Icon(Icons.add),
                label: const Text('Adicionar primeiro rateio'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
