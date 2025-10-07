import 'package:flutter/material.dart';

// ============================================================================
// STATUS BADGE - Badge colorido de status
// ============================================================================

/// Badge que mostra o status do documento (Pendente, Urgente, etc)
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    // Define cor baseado no status
    final config = _getStatusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        config.label,
        style: TextStyle(
          color: config.textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Retorna configuração de cores baseado no status
  _StatusConfig _getStatusConfig(String status) {
    final statusLower = status.toLowerCase();

    if (statusLower.contains('urgente')) {
      return _StatusConfig(
        backgroundColor: Colors.red[100]!,
        textColor: Colors.red[700]!,
        label: 'Urgente',
      );
    } else if (statusLower.contains('pendente')) {
      return _StatusConfig(
        backgroundColor: Colors.blue[100]!,
        textColor: Colors.blue[700]!,
        label: 'Pendente',
      );
    } else if (statusLower.contains('conferido')) {
      return _StatusConfig(
        backgroundColor: Colors.green[100]!,
        textColor: Colors.green[700]!,
        label: 'Conferido',
      );
    } else {
      // Status desconhecido - usa cinza
      return _StatusConfig(
        backgroundColor: Colors.grey[200]!,
        textColor: Colors.grey[700]!,
        label: status,
      );
    }
  }
}

/// Classe auxiliar para configuração do badge
class _StatusConfig {
  final Color backgroundColor;
  final Color textColor;
  final String label;

  _StatusConfig({
    required this.backgroundColor,
    required this.textColor,
    required this.label,
  });
}
