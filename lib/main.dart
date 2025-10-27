import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:wmsapp/core/viewmodel/session_view_model.dart';
import 'package:wmsapp/data/models/app_permissions_model.dart';
import 'package:wmsapp/data/repositories/auth_repository.dart';
import 'package:wmsapp/data/repositories/estoque/recebimento/recebimento_repository.dart';
import 'package:wmsapp/data/repositories/menu_repository.dart';
import 'package:wmsapp/data/services/conferencia_sync_service.dart';
import 'package:wmsapp/data/services/http_api_service.dart';
import 'package:wmsapp/data/services/i_api_service.dart';
import 'package:wmsapp/ui/features/login/viewmodel/login_view_model.dart';
import 'package:wmsapp/ui/features/menu/viewmodel/menu_view_model.dart';
import 'package:wmsapp/wms_main_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        // ====================================================================
        // CAMADA DE SERVIÇOS
        // ====================================================================
        Provider<IApiService>(
          create: (_) => HttpApiService(),
        ),

        // ✅ ADICIONAR: Service de sincronização de conferência
        ProxyProvider<IApiService, ConferenciaSyncService>(
          update: (context, apiService, _) => ConferenciaSyncService(
            apiService,
          ),
        ),
        // ====================================================================
        // CAMADA DE REPOSITORIES
        // ====================================================================
        ProxyProvider<IApiService, AuthRepository>(
          update: (context, apiService, _) => AuthRepository(
            apiService: apiService,
          ),
        ),

        ProxyProvider<IApiService, MenuRepository>(
          update: (context, apiService, _) => MenuRepository(
            apiService: apiService,
          ),
        ),

        ProxyProvider<IApiService, RecebimentoRepository>(
          update: (context, apiService, _) => RecebimentoRepository(
            apiService: apiService,
          ),
        ),

        // Repository de Recebimento (depende de IApiService)
        ProxyProvider<IApiService, RecebimentoRepository>(
          update: (_, apiService, __) => RecebimentoRepository(
            apiService: apiService,
          ),
        ),
        // ====================================================================
        // CAMADA DE VIEWMODELS GLOBAIS
        // ====================================================================

        /// SessionViewModel - DEVE vir ANTES dos ViewModels que dependem dele
        ChangeNotifierProvider(
          create: (_) => SessionViewModel(),
        ),

        /// LoginViewModel - Depende de 3 providers
        /// IMPORTANTE: Usar ChangeNotifierProxyProvider3 pois são 3 dependências
        ChangeNotifierProxyProvider3<
          AuthRepository,
          MenuRepository,
          SessionViewModel,
          LoginViewModel
        >(
          // create: Instância inicial (será recriada no update se necessário)
          create: (context) => LoginViewModel(
            authRepository: context.read<AuthRepository>(),
            menuRepository: context.read<MenuRepository>(),
            sessionViewModel: context.read<SessionViewModel>(),
          ),

          // update: Chamado quando qualquer dependência muda
          // Neste caso, sempre retorna a mesma instância pois não queremos recriar
          // o LoginViewModel (ele tem estado local da tela)
          update:
              (
                context,
                authRepository,
                menuRepository,
                sessionViewModel,
                previousLoginViewModel,
              ) {
                // Se já existe, retorna a mesma instância
                if (previousLoginViewModel != null) {
                  return previousLoginViewModel;
                }

                // Se não existe (primeira vez), cria uma nova
                return LoginViewModel(
                  authRepository: authRepository,
                  menuRepository: menuRepository,
                  sessionViewModel: sessionViewModel,
                );
              },
        ),

        /// MenuViewModel - Depende de SessionViewModel
        ChangeNotifierProxyProvider<SessionViewModel, MenuViewModel>(
          create: (_) => MenuViewModel(
            permissionsModules: AppPermissionsModel(),
          ),

          update: (context, sessionViewModel, previousMenuViewModel) {
            debugPrint(
              '[main.dart] Recriando MenuViewModel para usuário: '
              '${sessionViewModel.currentUser?.codUsuario ?? "nenhum"}',
            );

            return MenuViewModel(
              permissionsModules: sessionViewModel.permissionsModules,
            );
          },
        ),
      ],

      child: const WmsMainApp(),
    ),
  );
}

// ============================================================================
// ⚠️ IMPORTANTE - LoginViewModel Global vs Local
// ============================================================================

/*

OPÇÃO ATUAL (Global):
- LoginViewModel existe durante toda execução do app
- Ocupa memória mesmo quando não está na tela de login
- Útil se você precisa acessar dados do login em outras telas

❌ DESVANTAGENS:
- Desperdício de memória
- Estado pode ficar "sujo" entre logins
- Mais complexo de gerenciar

✅ VANTAGENS:
- Pode compartilhar estado entre telas
- Mais fácil de acessar de qualquer lugar

---

OPÇÃO RECOMENDADA (Local - main_refactored.dart):
- LoginViewModel criado apenas na LoginScreen
- Destruído quando sai da tela
- Estado sempre limpo

✅ VANTAGENS:
- Eficiente em memória
- Estado sempre limpo
- Mais fácil de testar
- Segue melhor as práticas do Flutter

❌ DESVANTAGENS:
- Precisa passar dados via argumentos ou SessionViewModel
- Um pouco mais de código inicial

---

RECOMENDAÇÃO:
Use a OPÇÃO 1 (main_refactored.dart) a menos que você tenha
um motivo muito específico para ter LoginViewModel global.

*/
