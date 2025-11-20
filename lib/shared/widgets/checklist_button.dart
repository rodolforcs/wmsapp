import 'package:flutter/material.dart';

// ============================================================================
// CHECKLIST BUTTON - Botão de checklist reutilizável
// ============================================================================

class ChecklistButton extends StatelessWidget {
  final bool isCompleto;
  final VoidCallback? onTap;

  const ChecklistButton({
    super.key,
    this.isCompleto = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isCompleto ? Colors.green.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isCompleto ? Colors.green.shade300 : Colors.blue.shade200,
        ),
      ),
      child: IconButton(
        icon: Icon(
          isCompleto ? Icons.check_circle : Icons.checklist,
          size: 18,
        ),
        color: isCompleto ? Colors.green.shade700 : Colors.blue.shade700,
        tooltip: isCompleto ? 'Checklist completo' : 'Abrir checklist',
        onPressed: onTap,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(
          minWidth: 32,
          minHeight: 32,
        ),
      ),
    );
  }
}
