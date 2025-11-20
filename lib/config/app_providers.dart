// lib/config/app_providers.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:wmsapp/core/viewmodel/session_view_model.dart';
import 'package:wmsapp/data/models/app_permissions_model.dart';
import 'package:wmsapp/data/repositories/auth_repository.dart';
import 'package:wmsapp/data/repositories/checklist/checklist_repository.dart';
import 'package:wmsapp/data/repositories/estoque/recebimento/recebimento_repository.dart';
import 'package:wmsapp/data/repositories/menu_repository.dart';
import 'package:wmsapp/data/services/checklist_service.dart';
import 'package:wmsapp/data/services/conferencia_sync_service.dart';
import 'package:wmsapp/data/services/http_api_service.dart';
import 'package:wmsapp/data/services/i_api_service.dart';
import 'package:wmsapp/ui/features/estoque/recebimento/viewmodel/checklist_view_model.dart';
import 'package:wmsapp/ui/features/login/viewmodel/login_view_model.dart';
import 'package:wmsapp/ui/features/menu/viewmodel/menu_view_model.dart';

/// 🏗️ Configuração centralizada de Providers
class AppProviders {
  static List<SingleChildWidget> get providers => [
    ..._serviceProviders,
    ..._repositoryProviders,
    ..._viewModelProviders,
  ];

  // ==========================================================================
  // 🔧 SERVICES
  // ==========================================================================

  static final _serviceProviders = <SingleChildWidget>[
    Provider<IApiService>(
      create: (_) => HttpApiService(),
    ),
    ProxyProvider<IApiService, ConferenciaSyncService>(
      update: (_, apiService, __) => ConferenciaSyncService(apiService),
    ),
    ProxyProvider<IApiService, ChecklistService>(
      update: (_, apiService, __) => ChecklistService(apiService),
    ),
  ];

  // ==========================================================================
  // 📦 REPOSITORIES
  // ==========================================================================

  static final _repositoryProviders = <SingleChildWidget>[
    ProxyProvider<IApiService, AuthRepository>(
      update: (_, apiService, __) => AuthRepository(apiService: apiService),
    ),
    ProxyProvider<IApiService, MenuRepository>(
      update: (_, apiService, __) => MenuRepository(apiService: apiService),
    ),
    ProxyProvider<IApiService, RecebimentoRepository>(
      update: (_, apiService, __) =>
          RecebimentoRepository(apiService: apiService),
    ),
    ProxyProvider<ChecklistService, ChecklistRepository>(
      update: (_, checklistService, __) =>
          ChecklistRepository(checklistService),
    ),
  ];

  // ==========================================================================
  // 🎨 VIEWMODELS
  // ==========================================================================

  static final _viewModelProviders = <SingleChildWidget>[
    // SessionViewModel (base)
    ChangeNotifierProvider<SessionViewModel>(
      create: (_) => SessionViewModel(),
    ),

    // ✅ LoginViewModel - CORRIGIDO
    ChangeNotifierProxyProvider3<
      AuthRepository,
      MenuRepository,
      SessionViewModel,
      LoginViewModel
    >(
      create: (context) => LoginViewModel(
        authRepository: context.read<AuthRepository>(),
        menuRepository: context.read<MenuRepository>(),
        sessionViewModel: context.read<SessionViewModel>(),
      ),
      update: (_, auth, menu, session, previous) {
        return previous ??
            LoginViewModel(
              authRepository: auth,
              menuRepository: menu,
              sessionViewModel: session,
            );
      },
    ),

    // ✅ MenuViewModel - CORRIGIDO
    ChangeNotifierProxyProvider<SessionViewModel, MenuViewModel>(
      create: (_) => MenuViewModel(permissionsModules: AppPermissionsModel()),
      update: (_, session, __) {
        debugPrint(
          '[AppProviders] Recriando MenuViewModel para: ${session.currentUser?.codUsuario ?? "nenhum"}',
        );
        return MenuViewModel(permissionsModules: session.permissionsModules);
      },
    ),

    // ✅ ChecklistViewModel - CORRIGIDO
    ChangeNotifierProxyProvider2<
      ChecklistRepository,
      SessionViewModel,
      ChecklistViewModel
    >(
      create: (context) => ChecklistViewModel(
        repository: context.read<ChecklistRepository>(),
        session: context.read<SessionViewModel>(),
      ),
      update: (_, repository, session, previous) {
        return previous ??
            ChecklistViewModel(
              repository: repository,
              session: session,
            );
      },
    ),
  ];
}
