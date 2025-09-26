import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wmsapp/core/viewmodel/session_view_model.dart';
import 'package:wmsapp/ui/features/login/view/login_screen.dart';
import 'package:wmsapp/ui/features/menu/view/menu_screen.dart';

class AppRouter {
  AppRouter(this._sessionViewModel);
  final SessionViewModel _sessionViewModel;

  static final login = '/login';
  static final home = '/';
  static final menu = '/menu';
  static final estoque = '/estoque';

  late final router = GoRouter(
    // O refreshListenable faz o router "ouvir" as mudanças na SessionViewModel.
    // Sempre que a SessionViewModel chamar notifyListeners(), o redirect será reavaliado.
    refreshListenable: _sessionViewModel,
    initialLocation: AppRouter.login,
    routes: [
      GoRoute(
        path: AppRouter.login,
        name: AppRouter.login,
        builder: (context, state) => LoginWms(),
      ),
      GoRoute(
        path: AppRouter.menu,
        name: AppRouter.menu,
        builder: (context, state) => MenuScreen(),
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      // Usando exatamente o getter 'isLoggedIn' do seu ViewModel.
      final bool isLoggedIn = _sessionViewModel.isLoggedIn;
      final String currentLocation = state.matchedLocation;

      //Caso 1: Usuário está logado.
      if (isLoggedIn) {
        // Se ele tentar acessar a tela de login, recirecione-o para o menu.
        return AppRouter.menu;
      }
      // Caso 2: Usuário não está logado.
      else {
        // Se ele tentar acessar QUALQUER rota que NÃO seja a de login,
        // force-o a ir para a tela de login.
        if (currentLocation != AppRouter.login) {
          // CORREÇÃO: Retorne a STRING do caminho, não o Widget.
          return AppRouter.login;
        } // Se ele t
      }
      // Se nenhuma das condições acima for verdadeira, o usuário pode prosseguir.
      // Ex: (usuário logado acessando /menu) ou (usuário deslogado acessando /login).
      return null;
    },
  );
}
