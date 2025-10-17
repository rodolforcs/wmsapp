// lib/shared/widgets/custom_progress_bar.dart
import 'package:flutter/material.dart';

/// Barra de progresso customizada e reutilizável
/// Pode mostrar percentual, label e cores personalizadas
///
/// Exemplos:
/// ```dart
/// CustomProgressBar(
///   value: 0.65,
///   label: 'Progresso',
///   showPercentage: true,
/// )
///
/// CustomProgressBar(
///   value: 0.80,
///   label: 'Carregando arquivos',
///   showPercentage: true,
///   height: 12,
///   progressColor: Colors.blue,
/// )
/// ```
class CustomProgressBar extends StatelessWidget {
  final double value; // 0.0 a 1.0
  final Color? backgroundColor;
  final Color? progressColor;
  final double height;
  final bool showPercentage;
  final String? label;
  final BorderRadius? borderRadius;

  const CustomProgressBar({
    super.key,
    required this.value,
    this.backgroundColor,
    this.progressColor,
    this.height = 8.0,
    this.showPercentage = false,
    this.label,
    this.borderRadius,
  });

  Color _getProgressColor(BuildContext context) {
    if (progressColor != null) return progressColor!;

    // Cor automática baseada no progresso
    if (value < 0.3) return Colors.red;
    if (value < 0.7) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Colors.grey[300]!;
    final fgColor = _getProgressColor(context);
    final radius = borderRadius ?? BorderRadius.circular(height / 2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              if (showPercentage)
                Text(
                  '${(value * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: fgColor,
                  ),
                ),
            ],
          ),
          SizedBox(height: 4),
        ],
        ClipRRect(
          borderRadius: radius,
          child: SizedBox(
            height: height,
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              backgroundColor: bgColor,
              valueColor: AlwaysStoppedAnimation<Color>(fgColor),
            ),
          ),
        ),
      ],
    );
  }
}

/// Versão circular da barra de progresso
///
/// Exemplos:
/// ```dart
/// CustomCircularProgressBar(
///   value: 0.75,
///   size: 100,
/// )
///
/// CustomCircularProgressBar(
///   value: 0.65,
///   size: 120,
///   strokeWidth: 10,
///   progressColor: Colors.blue,
///   showPercentage: false,
///   child: Icon(Icons.check, size: 40),
/// )
/// ```
class CustomCircularProgressBar extends StatelessWidget {
  final double value; // 0.0 a 1.0
  final double size;
  final double strokeWidth;
  final Color? backgroundColor;
  final Color? progressColor;
  final bool showPercentage;
  final Widget? child;

  const CustomCircularProgressBar({
    Key? key,
    required this.value,
    this.size = 100,
    this.strokeWidth = 8.0,
    this.backgroundColor,
    this.progressColor,
    this.showPercentage = true,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Colors.grey[300]!;
    final fgColor = progressColor ?? Theme.of(context).primaryColor;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: value.clamp(0.0, 1.0),
            strokeWidth: strokeWidth,
            backgroundColor: bgColor,
            valueColor: AlwaysStoppedAnimation<Color>(fgColor),
          ),
          if (showPercentage && child == null)
            Text(
              '${(value * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: size * 0.2,
                fontWeight: FontWeight.bold,
                color: fgColor,
              ),
            ),
          if (child != null) child!,
        ],
      ),
    );
  }
}
