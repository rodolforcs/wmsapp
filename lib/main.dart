import 'package:flutter/material.dart';
import 'package:wmsapp/core/viewmodel/session_view_model.dart';
import 'package:wmsapp/data/repositories/auth_repository.dart';
import 'package:wmsapp/data/services/http_api_service.dart';
import 'package:wmsapp/data/services/i_api_service.dart';
import 'package:wmsapp/ui/features/login/viewmodel/login_view_model.dart';
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

        // Provider 3: Fornece a ViewModel de sessão global.
        // Ele não depende de ninguém.
        ChangeNotifierProvider(
          create: (context) => SessionViewModel(),
        ),

        // Provider 4: Fornece o LoginViewModel. Ele depende do AuthRepository.
        // Usamos ChangeNotifierProxyProvider porque LoginViewModel é um ChangeNotifier.
        ChangeNotifierProxyProvider<AuthRepository, LoginViewModel>(
          create: (context) => LoginViewModel(
            // context.read pega a dependência (AuthRepository) que foi criada logo acima.
            authRepository: context.read<AuthRepository>(),
          ),
          // o update é necessário, mas neste caso simples, apenas retornamos o ViewMOdel já criado.update:,
          update: (context, authRepo, previousLoginViewModel) =>
              previousLoginViewModel!,
        ),
      ],
      // O filho de toda essa árvode de providers é o seu App.
      child: const WmsMainApp(),
    ),
  );
}
