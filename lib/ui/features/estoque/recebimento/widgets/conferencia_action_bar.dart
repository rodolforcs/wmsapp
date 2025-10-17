// lib/ui/features/estoque/recebimento/widgets/conferencia_action_bar.dart
import 'package:flutter/material.dart';

class ConferenciaActionBar extends StatelessWidget {
  final bool isTablet;
  final bool todosConferidos;
  final bool temDivergencias;
  final VoidCallback? onVoltar;
  final VoidCallback? onFinalizar;

  const ConferenciaActionBar({
    super.key,
    required this.isTablet,
    required this.todosConferidos,
    required this.temDivergencias,
    this.onVoltar,
    this.onFinalizar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (!isTablet && onVoltar != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onVoltar,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Voltar'),
                    ),
                  ),
                if (!isTablet && onVoltar != null) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: todosConferidos ? onFinalizar : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: temDivergencias
                          ? Colors.orange
                          : Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      temDivergencias
                          ? 'Finalizar com Divergência'
                          : 'Finalizar Conferência',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (!todosConferidos)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Confira todos os itens para finalizar',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
