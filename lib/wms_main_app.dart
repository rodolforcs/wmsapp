import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wmsapp/data/repositories/auth_repository.dart';
import 'package:wmsapp/data/services/http_api_service.dart';
import 'package:wmsapp/data/services/i_api_service.dart';
import 'package:wmsapp/navigation/app_router.dart';
import 'package:wmsapp/ui/features/menu/menu_wms_app.dart';
import 'package:wmsapp/core/services/messenger_service.dart';
import 'package:wmsapp/core/themes/theme.dart';
import 'package:wmsapp/core/viewmodel/session_view_model.dart';
import 'package:wmsapp/ui/features/login/view/login_screen.dart';
import 'package:wmsapp/ui/features/login/viewmodel/login_view_model.dart';

class WmsMainApp extends StatefulWidget {
  const WmsMainApp({super.key});

  @override
  State<WmsMainApp> createState() => _WmsMainAppState();
}

class _WmsMainAppState extends State<WmsMainApp> {
  @override
  Widget build(BuildContext context) {
    //final session = context.watch<SessionViewModel>();

    // 1. Pega a instância do SessionViewModel (que foi criada no main.dart).
    // Usamos `context.read` porque só precisamos do valor uma vez para a configuração
    // e não queremos que este widget reconstrua se o SessionViewModel mudar.
    final sessionViewModel = context.read<SessionViewModel>();

    // 2. Cria a instância do AppRouter, passando o ViewModel de sessão.
    // O AppRouter agora tem acesso ao estado de login.
    final appRouter = AppRouter(sessionViewModel);

    // 3. Usa MaterialApp.router e entrega TODO o controle de navegação para o GoRouter.
    // A propriedade home foi removida. routerconfig é quem manda agora.

    return MaterialApp.router(
      title: 'wmsapp',
      theme: AppTheme.theme,
      scaffoldMessengerKey: MessengerService.messengerKey,

      routerConfig: appRouter.router,
    );

    /*
    return MaterialApp(
      title: 'wmsApp',
      theme: AppTheme.theme,
      scaffoldMessengerKey: MessengerService.messengerKey,
      home: sessionViewModel.isLoggedIn
          ? const MenuWmsApp()
          : ChangeNotifierProvider(
              create: (context) {
                // A cadeia de dependências que montamos
                IApiService apiService = HttpApiService();
                AuthRepository authRepository = AuthRepository(
                  apiService: apiService,
                );
                return LoginViewModel(
                  sessionViewModel: context.read<SessionViewModel>(),
                  authRepository: authRepository,
                );
              },
              child: const LoginWms(),
            ),
    );
    */
  }
}
