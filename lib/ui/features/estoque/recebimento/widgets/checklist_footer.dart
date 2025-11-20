// lib/ui/features/estoque/recebimento/widgets/checklist_footer.dart

import 'package:flutter/material.dart';

/// Footer com botões de ação do checklist
class ChecklistFooter extends StatelessWidget {
  final bool podeFinalizar;
  final bool todosItensRespondidos;
  final bool isFinalizing;
  final VoidCallback onSalvarRascunho;
  final VoidCallback onFinalizar;

  const ChecklistFooter({
    super.key,
    required this.podeFinalizar,
    required this.todosItensRespondidos,
    required this.isFinalizing,
    required this.onSalvarRascunho,
    required this.onFinalizar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // ✅ Layout responsivo: Column em celular, Row em tablet
            final isWide = constraints.maxWidth > 600;

            if (isWide) {
              return _buildWideLayout(context);
            } else {
              return _buildNarrowLayout(context);
            }
          },
        ),
      ),
    );
  }

  // ==========================================================================
  // LAYOUT LARGO (TABLET)
  // ==========================================================================

  Widget _buildWideLayout(BuildContext context) {
    return Row(
      children: [
        // Botão Salvar Rascunho (se não completou)
        if (!todosItensRespondidos) ...[
          Expanded(
            child: _buildBotaoRascunho(context),
          ),
          const SizedBox(width: 16),
        ],

        // Botão Finalizar
        Expanded(
          flex: todosItensRespondidos ? 1 : 2,
          child: _buildBotaoFinalizar(context),
        ),
      ],
    );
  }

  // ==========================================================================
  // LAYOUT ESTREITO (CELULAR)
  // ==========================================================================

  Widget _buildNarrowLayout(BuildContext context) {
    if (todosItensRespondidos) {
      // Se completou: só botão finalizar (full width)
      return _buildBotaoFinalizar(context);
    }

    // Se não completou: column com 2 botões
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildBotaoRascunho(context),
        const SizedBox(height: 12),
        _buildBotaoFinalizar(context),
      ],
    );
  }

  // ==========================================================================
  // BOTÕES
  // ==========================================================================

  Widget _buildBotaoRascunho(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onSalvarRascunho,
      icon: const Icon(Icons.save_outlined),
      label: const Text('Salvar Rascunho'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildBotaoFinalizar(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: podeFinalizar && !isFinalizing ? onFinalizar : null,
      icon: isFinalizing
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.check_circle),
      label: Text(isFinalizing ? 'Finalizando...' : 'Finalizar'),
      style: ElevatedButton.styleFrom(
        backgroundColor: podeFinalizar ? Colors.green : Colors.grey,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}
