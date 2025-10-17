// lib/shared/widgets/status_badge.dart
import 'package:flutter/material.dart';

/// Badge genérico de status com cor personalizável
/// Pode ser usado em qualquer tela do app para mostrar status
///
/// Exemplos:
/// ```dart
/// StatusBadge(label: 'Pendente', color: Colors.orange)
/// StatusBadge.success('Concluído')
/// StatusBadge.warning('Aguardando')
/// StatusBadge.error('Cancelado')
/// StatusBadge.info('Em Andamento')
/// ```
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final double fontSize;
  final EdgeInsets padding;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.fontSize = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  });

  /// Factory para status comum - Sucesso
  factory StatusBadge.success(String label, {IconData? icon}) {
    return StatusBadge(
      label: label,
      color: Colors.green,
      icon: icon ?? Icons.check_circle_outline,
    );
  }

  /// Factory para status comum - Aviso
  factory StatusBadge.warning(String label, {IconData? icon}) {
    return StatusBadge(
      label: label,
      color: Colors.orange,
      icon: icon ?? Icons.warning_amber_outlined,
    );
  }

  /// Factory para status comum - Erro
  factory StatusBadge.error(String label, {IconData? icon}) {
    return StatusBadge(
      label: label,
      color: Colors.red,
      icon: icon ?? Icons.error_outline,
    );
  }

  /// Factory para status comum - Info
  factory StatusBadge.info(String label, {IconData? icon}) {
    return StatusBadge(
      label: label,
      color: Colors.blue,
      icon: icon ?? Icons.info_outline,
    );
  }

  /// Factory para status comum - Neutro
  factory StatusBadge.neutral(String label, {IconData? icon}) {
    return StatusBadge(
      label: label,
      color: Colors.grey,
      icon: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: fontSize + 2,
              color: color,
            ),
            SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }
}
