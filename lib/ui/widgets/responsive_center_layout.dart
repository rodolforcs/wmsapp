import 'package:flutter/material.dart';

class ResponsiveCenterLayout extends StatelessWidget {
  const ResponsiveCenterLayout({
    super.key,
    required this.child,
    this.maxWidth = 500.0, // Um bom valor padrão para formulários
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
