import 'package:flutter/material.dart';

/// AppMenuModel: Representa a estrutura de dados de um único módulo do menu.
///
/// Este modelo vive na camada de dados, pois define a "forma" dos dados
/// que podem, eventualmente, vir de uma fonte externa (como uma API que
/// retorna os módulos e permissões).

class AppMenuModel {
  AppMenuModel({
    required this.label,
    required this.icon,
    required this.route,
    this.isEnabled = false,
  });
  final String label;
  final IconData icon;
  final String route;
  bool isEnabled;
}
