import 'package:flutter/material.dart';
import 'package:wmsapp/data/models/app_menu_model.dart';
import 'package:wmsapp/data/models/app_permissions_model.dart';

class MenuViewModel extends ChangeNotifier {
  List<AppMenuModel> _modulos = [];
  List<AppMenuModel> get modulos => _modulos;

  MenuViewModel({required AppPermissionsModel permissionsModules}) {
    _initializeModules(permissionsModules);
  }

  void _initializeModules(AppPermissionsModel permissions) {
    print(
      '[MenuViewModel CONSTRUCTOR] Recebeu permissões. Estoque: ${permissions.estoque}',
    );

    final allModules = [
      AppMenuModel(
        label: 'Estoque',
        icon: Icons.inventory_2,
        route: '/estoque',
        isEnabled: false,
      ),
      AppMenuModel(
        label: 'Expedição',
        icon: Icons.local_shipping,
        route: '/expedicao',
        isEnabled: false,
      ),
      AppMenuModel(
        label: 'Produção',
        icon: Icons.precision_manufacturing,
        route: '/producao',
        isEnabled: false,
      ),
      AppMenuModel(
        label: 'Qualidade',
        icon: Icons.high_quality,
        route: '/qualidade',
        isEnabled: false,
      ),
    ];

    for (var modulo in allModules) {
      switch (modulo.label) {
        case 'Estoque':
          modulo.isEnabled = permissions.estoque;
          break;
        case 'Expedição':
          modulo.isEnabled = permissions.expedicao;
          break;
        case 'Produção':
          modulo.isEnabled = permissions.producao;
          break;
        case 'Qualidade':
          modulo.isEnabled = permissions.qualidade;
          break;
      }
    }
    _modulos = allModules;
    print(
      '[MenuViewModel CONSTRUCTOR] Módulos inicializados. Estoque agora é: ${_modulos.first.isEnabled}',
    );
  }
}
