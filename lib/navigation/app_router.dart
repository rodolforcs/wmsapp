import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wmsapp/core/viewmodel/session_view_model.dart';
import 'package:wmsapp/ui/features/estoque/recebimento/view/recebimento_screen.dart';
import 'package:wmsapp/ui/features/estoque/view/estoque_screen.dart';
import 'package:wmsapp/ui/features/login/view/login_screen.dart';
import 'package:wmsapp/ui/features/menu/view/menu_screen.dart';

class AppRouter {
  AppRouter(this._sessionViewModel);
  final SessionViewModel _sessionViewModel;

  static final login = '/login';
  static final home = '/';
  static final menu = '/menu';
  static final estoque = '/estoque';
  static final recebimento = '/recebimento';

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
      GoRoute(
        path: AppRouter.estoque,
        name: AppRouter.estoque,
        builder: (context, state) => const EstoqueScreen(),
      ),
      GoRoute(
        path: AppRouter.recebimento,
        name: AppRouter.recebimento,
        builder: (context, state) => const RecebimentoScreen(),
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      // Usando exatamente as suas variáveis
      final bool isLoggedIn = _sessionViewModel.isLoggedIn;
      final String currentLocation = state.matchedLocation;

      print(
        '[GoRouter] Avaliando redirect. Logado: $isLoggedIn, Tentando ir para: $currentLocation',
      );

      // --- LÓGICA CORRIGIDA ---

      // Caso 1: Usuário NÃO está logado.
      if (!isLoggedIn) {
        // Se ele não estiver tentando ir para a tela de login, force-o para lá.
        // Se ele JÁ estiver indo para o login, não faça nada (retorne null).
        if (currentLocation != AppRouter.login) {
          print('[GoRouter] Usuário deslogado. Forçando para /login.');
          return AppRouter.login;
        }
      }
      // Caso 2: Usuário ESTÁ logado.
      else {
        // Se ele estiver tentando acessar a tela de login, impeça e mande-o para o menu.
        if (currentLocation == AppRouter.login) {
          print(
            '[GoRouter] Usuário logado tentando acessar /login. Redirecionando para /menu.',
          );
          return AppRouter.menu;
        }
      }

      // Se nenhuma das condições de redirecionamento acima foi atendida,
      // significa que a navegação é permitida.
      // Ex: Usuário logado indo para /estoque.
      // Ex: Usuário deslogado indo para /login.
      print('[GoRouter] Navegação permitida para $currentLocation.');
      return null;
    },
  );
}
