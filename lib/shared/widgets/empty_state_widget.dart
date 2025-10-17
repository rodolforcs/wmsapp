// lib/shared/widgets/empty_state_widget.dart
import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onActionPressed;
  final Color? iconColor;
  final double iconSize;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onActionPressed,
    this.iconColor,
    this.iconSize = 80,
  });

  factory EmptyStateWidget.list({
    required String entityName,
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    return EmptyStateWidget(
      icon: Icons.inbox_outlined,
      title: 'Nenhum $entityName encontrado',
      subtitle: actionLabel != null
          ? 'Comece adicionando um novo $entityName'
          : null,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
      iconColor: Colors.grey[400],
    );
  }

  factory EmptyStateWidget.search({
    String query = '',
  }) {
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: 'Nenhum resultado encontrado',
      subtitle: query.isEmpty
          ? 'Tente usar outros termos de busca'
          : 'Não encontramos resultados para "$query"',
      iconColor: Colors.grey[400],
    );
  }

  factory EmptyStateWidget.error({
    String? message,
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    return EmptyStateWidget(
      icon: Icons.error_outline,
      title: 'Ops! Algo deu errado',
      subtitle: message ?? 'Tente novamente mais tarde',
      actionLabel: actionLabel ?? 'Tentar novamente',
      onActionPressed: onActionPressed,
      iconColor: Colors.red[400],
    );
  }

  factory EmptyStateWidget.noConnection({
    VoidCallback? onRetry,
  }) {
    return EmptyStateWidget(
      icon: Icons.wifi_off,
      title: 'Sem conexão',
      subtitle: 'Verifique sua conexão com a internet',
      actionLabel: 'Tentar novamente',
      onActionPressed: onRetry,
      iconColor: Colors.orange[400],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: iconColor ?? Colors.grey[400],
            ),
            SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            if (subtitle != null) ...[
              SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ],
            if (actionLabel != null && onActionPressed != null) ...[
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onActionPressed,
                icon: Icon(Icons.add),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
