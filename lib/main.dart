import 'package:flutter/material.dart';
import 'package:wmsapp/core/viewmodel/session_view_model.dart';
import 'package:wmsapp/data/repositories/auth_repository.dart';
import 'package:wmsapp/data/repositories/menu_repository.dart';
import 'package:wmsapp/data/services/http_api_service.dart';
import 'package:wmsapp/data/services/i_api_service.dart';
import 'package:wmsapp/ui/features/login/viewmodel/login_view_model.dart';
import 'package:wmsapp/ui/features/menu/viewmodel/menu_view_model.dart';
import 'package:wmsapp/wms_main_app.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  // Garente que os bindings do flutter sejam inicializados antes do código assícrono.
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega as variáveis de ambiente do arquivo .env
  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        // --- Camada de Dados ---
        // Provider 1: Fornece a implementeação concreta do serviço de API.
        // Ele não depende de ninguém.
        Provider<IApiService>(
          create: (_) => HttpApiService(),
        ),

        // Provider 2: Fornece o repositório. Ele depende de IApiService.
        // Usamos o ProxyProvider para injetar a dependência.
        ProxyProvider<IApiService, AuthRepository>(
          update: (context, apiService, previousRepository) =>
              AuthRepository(apiService: apiService),
        ),

        // 3. NOVO Provider para o MenuRepository. Ele também depende do IApiService.
        ProxyProvider<IApiService, MenuRepository>(
          update: (_, apiService, __) => MenuRepository(apiService: apiService),
        ),

        // 4. Provider : Fornece a ViewModel de sessão global.
        // Ele não depende de ninguém.
        ChangeNotifierProvider(
          create: (context) => SessionViewModel(),
        ),

        // Provider 5: Fornece o LoginViewModel. Ele depende do AuthRepository.
        // Usamos ChangeNotifierProxyProvider porque LoginViewModel é um ChangeNotifier.
        ChangeNotifierProxyProvider2<
          AuthRepository,
          MenuRepository,
          LoginViewModel
        >(
          create: (context) => LoginViewModel(
            // context.read pega a dependência (AuthRepository) que foi criada logo acima.
            authRepository: context.read<AuthRepository>(),
            menuRepository: context.read<MenuRepository>(),
          ),
          // o update é necessário, mas neste caso simples, apenas retornamos o ViewMOdel já criado.update:,
          update: (context, authRepo, menuRepo, previousViewModel) =>
              previousViewModel!,
        ),
        // 6. NOVO Provider para o MenuViewModel. Ele depende do SessionViewModel.
        // Ele será recriado sempre que a sessão mudar (login/logout).
        ChangeNotifierProxyProvider<SessionViewModel, MenuViewModel>(
          // `create` é chamado apenas uma vez. Pode retornar um estado inicial vazio.
          create: (context) => MenuViewModel(userPermissions: []),

          // `update` é a parte importante. Ele é chamado quando o SessionViewModel (a dependência) notifica uma mudança.
          // Ele pega as novas permissões da sessão e cria uma nova instância do MenuViewModel com elas.
          update: (context, session, previousMenuViewModel) => MenuViewModel(
            userPermissions: session.permissionsModule,
          ),
        ),
      ],
      // O filho de toda essa árvode de providers é o seu App.
      child: const WmsMainApp(),
    ),
  );
}
