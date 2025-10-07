import 'package:flutter/material.dart';

/// Representa uma única opção dentro de um módulo do WMS.
class EstoqueModuleOptionModel {
  final String label;
  final IconData icon;
  final String route;
  bool isEnabled; // Para controlar a permissão da sub-opção

  EstoqueModuleOptionModel({
    required this.label,
    required this.icon,
    required this.route,
    this.isEnabled = false, // Começa desabilitado por padrão
  });
}
