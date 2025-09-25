import 'package:flutter/material.dart';
import 'package:wmsapp/data/repositories/menu_repository.dart';
import 'package:wmsapp/navigation/app_router.dart';
import 'package:wmsapp/data/models/app_menu_model.dart';

/// MenuViewModel: Gerencia o estado da tela de menu.
///
/// Responsável por fornecer a lista de módulos (usando AppMenuModel) e, no futuro,
/// por buscar as permissões do usuário e atualizar o estado `isEnabled` de cada módulo.

class MenuViewModel extends ChangeNotifier {
  final MenuRepository _menuRepository; // Agora depende do MenuRepository

  //Estados da UI

  bool _isLoading = true; // Começa carregando
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // A lista agora é o tipo correto: AppMenuModel.
  List<AppMenuModel> _modulos = [];
  List<AppMenuModel> get modulos => _modulos;

  MenuViewModel({required MenuRepository menuRepository})
    : _menuRepository = menuRepository {
    // Inicializa a lista de módulos e busca as permissões.
    _initialize();
  }

  Future<void> _initialize() async {
    _loadModules(); // Carrega a estrutura dos módulos
    await _fetchPermissions();
  }

  /// _loadModules: Carrega a lista estática de todos os módulos possíveis.
  void _loadModules() {
    // A implementação usa a classe AppMenuModel importada.
    _modulos = [
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
  }

  /// Busca as permissões e atualiza os módulos.
  Future<void> _fetchPermissions() async {
    try {
      // Pede as permissões ao repositório.
      final userPermissions = await _menuRepository.getModulePermissions();

      // Itera sobre os módulos e atualiza o estado 'isEnabled'.
      for (var modulo in _modulos) {
        // Verifica se a lista de permissões contém o nome do módulo.
        if (userPermissions.contains(modulo.label)) {
          modulo.isEnabled = true;
        }
      }
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Erro ao carregar permissões: ${e.toString()}';
    } finally {
      // Finaliza o estado de carregamento e notifica a UI para se reconstruir.
      _isLoading = false;
      notifyListeners();
    }
  }
}
