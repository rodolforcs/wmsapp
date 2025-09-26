import 'package:flutter/material.dart';
import 'package:wmsapp/navigation/app_router.dart';
import 'package:wmsapp/data/models/app_menu_model.dart';

/// MenuViewModel: Gerencia o estado da tela de menu.
///
/// Responsável por fornecer a lista de módulos (usando AppMenuModel) e, no futuro,
/// por buscar as permissões do usuário e atualizar o estado `isEnabled` de cada módulo.

class MenuViewModel extends ChangeNotifier {
  //Estados da UI
  // A lista agora é o tipo correto: AppMenuModel.
  List<AppMenuModel> _modulos = [];
  List<AppMenuModel> get modulos => _modulos;

  /// O construtor agora recebe APENAS a lista de permissões.
  /// Ele não precisa mais do MenuRepository.
  MenuViewModel({required List<String> userPermissions}) {
    _loadModules(userPermissions);
  }

  /// _loadModules: Carrega a lista estática de todos os módulos possíveis.
  void _loadModules(List<String> permissions) {
    // A implementação usa a classe AppMenuModel importada.
    final allModulos = [
      AppMenuModel(
        label: 'Estoque',
        icon: Icons.inventory_2,
        route: AppRouter.estoque,
      ),
      AppMenuModel(
        label: 'Expedição',
        icon: Icons.local_shipping,
        route: '/expedicao',
      ),
      AppMenuModel(
        label: 'Produção',
        icon: Icons.precision_manufacturing,
        route: '/producao',
      ),
      AppMenuModel(
        label: 'Qualidade',
        icon: Icons.high_quality,
        route: '/qualidade',
      ),
    ];

    // Itera e habilita apenas os módulos permitidos
    for (var modulo in allModulos) {
      if (permissions.contains(modulo.label)) {
        modulo.isEnabled = true;
      }
    }
    // 5. Atribui a lista, agora com os estados de `isEnabled` corretos,
    //    à variável de estado do ViewModel.
    _modulos = allModulos;
    // Nota: Não é necessário chamar `notifyListeners()` aqui porque o ViewModel
    // está sendo construído. A UI que o "assiste" (`watch`) será construída
    // com este estado inicial automaticamente.
  }
}
