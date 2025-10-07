import 'package:flutter/material.dart';
import 'package:wmsapp/data/models/app_permissions_model.dart';
import 'package:wmsapp/data/models/estoque_module_model.dart';

/// Gerencia o estado e a lógica da tela do Módulo de Estoque.
class EstoqueViewModel extends ChangeNotifier {
  List<EstoqueModuleOptionModel> _subModulos = [];
  List<EstoqueModuleOptionModel> get subModulos => _subModulos;

  EstoqueViewModel({required AppPermissionsModel permissions}) {
    _loadSubModules(permissions);
  }

  /// Carrega a lista de sub-módulos.
  /// No futuro, aqui entrará a lógica para buscar as permissões de cada sub-módulo.
  void _loadSubModules(AppPermissionsModel permissions) {
    // Por enquanto, vamos definir os dados e habilitar todos para fins de UI.
    _subModulos = [
      EstoqueModuleOptionModel(
        label: 'Recebimento',
        icon: Icons.move_to_inbox,
        route: '/estoque/recebimento',
        isEnabled: permissions.podeReceber,
      ),
      EstoqueModuleOptionModel(
        label: 'Endereçamento',
        icon: Icons.forklift,
        route: '/estoque/enderecamento',
        isEnabled: permissions.podeTransferir, // Mock: Habilitado
      ),
      EstoqueModuleOptionModel(
        label: 'Separação',
        icon: Icons.checklist_rtl,
        route: '/estoque/separacao',
        isEnabled: permissions.podeSeparar, // Mock: Habilitado
      ),
      EstoqueModuleOptionModel(
        label: 'Transferência',
        icon: Icons.swap_horiz,
        route: '/estoque/transferencia',
        isEnabled:
            permissions.podeTransferir, // Mock: Desabilitado para teste de UI
      ),
    ];
    // Não é necessário notifyListeners() aqui, pois é chamado no construtor.
  }
}
