import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:wmsapp/core/viewmodel/session_view_model.dart';
import 'package:wmsapp/data/repositories/auth_repository.dart';
import 'package:wmsapp/data/repositories/menu_repository.dart';
import 'package:wmsapp/ui/features/login/viewmodel/login_view_model.dart';
import 'package:wmsapp/ui/features/login/widgets/exit_button.dart';
import 'package:wmsapp/ui/features/login/widgets/login_button.dart';
import 'package:wmsapp/ui/widgets/responsive_center_layout.dart';

// ============================================================================
// LOGIN SCREEN - Camada de Apresentação (View)
// ============================================================================

/// Tela de login do WMS
///
/// Responsabilidades:
/// - Renderizar UI (TextFields, Botões, etc)
/// - Capturar eventos do usuário (onPressed, onChanged)
/// - Delegar lógica para o LoginViewModel
/// - Reagir a mudanças de estado (via context.watch)
///
/// NÃO é responsável por:
/// - Lógica de negócio (validação, autenticação) → vai pro ViewModel
/// - Chamadas HTTP → vai pro Repository
/// - Navegação complexa → delega para ViewModel/Router
class LoginWms extends StatelessWidget {
  const LoginWms({super.key});

  @override
  Widget build(BuildContext context) {
    // ========================================================================
    // IMPORTANTE: ChangeNotifierProvider cria o ViewModel
    // ========================================================================
    // - create: instancia o ViewModel COM as dependências injetadas
    // - context.read<>(): busca dependências já registradas no Provider tree
    // - A tela filha (_LoginWmsContent) pode usar context.watch<LoginViewModel>()
    return ChangeNotifierProvider(
      create: (context) => LoginViewModel(
        authRepository: context.read<AuthRepository>(),
        menuRepository: context.read<MenuRepository>(),
        sessionViewModel: context.read<SessionViewModel>(),
      ),
      child: const _LoginWmsContent(),
    );
  }
}

// ============================================================================
// CONTEÚDO DA TELA (Stateful para gerenciar controllers)
// ============================================================================

class _LoginWmsContent extends StatefulWidget {
  const _LoginWmsContent();

  @override
  State<_LoginWmsContent> createState() => _LoginWmsContentState();
}

class _LoginWmsContentState extends State<_LoginWmsContent> {
  // ==========================================================================
  // CONTROLLERS E FOCUS NODES
  // ==========================================================================

  final _formKey = GlobalKey<FormState>();

  late TextEditingController _dominioController;
  late TextEditingController _userController;
  late TextEditingController _passwordController;
  late FocusNode _userFocusNode;

  // ==========================================================================
  // LIFECYCLE
  // ==========================================================================

  @override
  void initState() {
    super.initState();

    // Inicializa controllers
    _dominioController = TextEditingController(
      text: dotenv.env['DOMAIN'] ?? '',
    );
    _userController = TextEditingController();
    _passwordController = TextEditingController();

    // Configura FocusNode para detectar quando sai do campo de usuário
    _userFocusNode = FocusNode();
    _userFocusNode.addListener(_onUserFieldFocusChange);
  }

  @override
  void dispose() {
    // Limpa recursos para evitar memory leaks
    _userFocusNode.removeListener(_onUserFieldFocusChange);
    _userFocusNode.dispose();
    _dominioController.dispose();
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // EVENT HANDLERS
  // ==========================================================================

  /// Detecta quando o campo de usuário perde o foco
  /// Quando isso acontece, valida o usuário no backend
  void _onUserFieldFocusChange() {
    if (!_userFocusNode.hasFocus) {
      // context.read<>() não causa rebuild, é ideal para chamar métodos
      context.read<LoginViewModel>().validateUserOnLeave(
        _userController.text,
      );
    }
  }

  /// Executa o login quando o botão é pressionado
  Future<void> _handleLogin() async {
    // Valida o formulário (campos obrigatórios, etc)
    if (_formKey.currentState?.validate() ?? false) {
      // Chama o método do ViewModel (SEM passar context!)
      await context.read<LoginViewModel>().performLogin(
        domain: _dominioController.text,
        username: _userController.text,
        password: _passwordController.text,
      );
    }
  }

  // ==========================================================================
  // BUILD - Construção da UI
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    // ========================================================================
    // context.watch<>() - ESCUTA mudanças no ViewModel
    // ========================================================================
    // Quando o ViewModel chama notifyListeners(), este widget reconstrói
    final viewModel = context.watch<LoginViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ==================================================================
            // LOGO
            // ==================================================================
            Flexible(
              flex: 2,
              child: Container(
                alignment: Alignment.center,
                constraints: const BoxConstraints(minHeight: 80),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback se a imagem não existir
                    return const Icon(Icons.warehouse, size: 80);
                  },
                ),
              ),
            ),

            // ==================================================================
            // FORMULÁRIO
            // ==================================================================
            Expanded(
              flex: 4,
              child: SingleChildScrollView(
                child: ResponsiveCenterLayout(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ==========================================================
                        // SWITCH: Utilizar Domínio
                        // ==========================================================
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text(
                              'Utilizar Domínio',
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 8),
                            Switch(
                              value: viewModel.utilizarDominio,
                              activeColor: Colors.indigo,
                              onChanged: viewModel.toggleDominio,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // ==========================================================
                        // CAMPO: Domínio (condicional)
                        // ==========================================================
                        if (viewModel.utilizarDominio)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: TextFormField(
                              controller: _dominioController,
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: 'Domínio',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.business),
                              ),
                            ),
                          ),

                        // ==========================================================
                        // CAMPO: Usuário
                        // ==========================================================
                        TextFormField(
                          controller: _userController,
                          focusNode: _userFocusNode,
                          decoration: InputDecoration(
                            labelText: 'Usuário',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.person),
                            // Ícone dinâmico baseado no estado de validação
                            suffixIcon: _buildUserValidationIcon(viewModel),
                            // Mensagem de erro se houver
                            errorText:
                                viewModel.userValidationState ==
                                    UserValidationState.error
                                ? viewModel.userValidationError
                                : null,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Campo obrigatório';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // ==========================================================
                        // CAMPO: Senha
                        // ==========================================================
                        TextFormField(
                          controller: _passwordController,
                          obscureText: viewModel.isPasswordObscured,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(Icons.lock),
                            // Botão para mostrar/ocultar senha
                            suffixIcon: IconButton(
                              onPressed: viewModel.togglePasswordVisibility,
                              icon: Icon(
                                viewModel.isPasswordObscured
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Campo obrigatório';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // ==========================================================
                        // DROPDOWN: Estabelecimentos (condicional)
                        // ==========================================================
                        // Só aparece se:
                        // 1. Validação do usuário foi bem-sucedida
                        // 2. Há estabelecimentos disponíveis
                        if (viewModel.userValidationState ==
                                UserValidationState.success &&
                            viewModel.hasEstabelecimentos)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: DropdownButtonFormField<String>(
                              value: viewModel.selectedEstabelecimento,
                              decoration: const InputDecoration(
                                labelText: 'Estabelecimento',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.store),
                              ),
                              items: viewModel.estabelecimentos
                                  .map(
                                    (estabelecimento) => DropdownMenuItem(
                                      value: estabelecimento,
                                      child: Text(estabelecimento),
                                    ),
                                  )
                                  .toList(),
                              onChanged: viewModel.selectEstabelecimento,
                              validator: (value) {
                                if (viewModel.hasEstabelecimentos &&
                                    value == null) {
                                  return 'Selecione um estabelecimento';
                                }
                                return null;
                              },
                            ),
                          ),

                        const SizedBox(height: 24),

                        // ==========================================================
                        // BOTÃO: Login
                        // ==========================================================
                        LoginButton(
                          isLoading: viewModel.isLoading,
                          onPressed: viewModel.isLoading ? null : _handleLogin,
                        ),

                        const SizedBox(height: 16),

                        // ==========================================================
                        // BOTÃO: Sair
                        // ==========================================================
                        const ExitButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // HELPER METHODS - Widgets auxiliares
  // ==========================================================================

  /// Constrói o ícone do campo de usuário baseado no estado de validação
  ///
  /// Estados possíveis:
  /// - idle: sem ícone
  /// - loading: CircularProgressIndicator
  /// - error: ícone de erro vermelho com tooltip
  /// - success: ícone de check verde
  Widget? _buildUserValidationIcon(LoginViewModel viewModel) {
    switch (viewModel.userValidationState) {
      case UserValidationState.idle:
        return null;

      case UserValidationState.loading:
        return const Padding(
          padding: EdgeInsets.all(12.0),
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        );

      case UserValidationState.error:
        return Tooltip(
          message: viewModel.userValidationError ?? 'Erro na validação',
          child: const Icon(Icons.error, color: Colors.red),
        );

      case UserValidationState.success:
        return const Icon(Icons.check_circle, color: Colors.green);
    }
  }
}

// ============================================================================
// RESUMO DO FLUXO - Para entender o padrão
// ============================================================================

/*

1. INICIALIZAÇÃO
   └─> LoginWms (StatelessWidget)
       └─> ChangeNotifierProvider cria LoginViewModel
           └─> Injeta dependências (AuthRepository, MenuRepository, SessionViewModel)

2. USUÁRIO DIGITA NO CAMPO "USUÁRIO"
   └─> TextFormField.onChanged atualiza _userController
   
3. USUÁRIO SAI DO CAMPO "USUÁRIO" (perde foco)
   └─> _userFocusNode detecta perda de foco
       └─> _onUserFieldFocusChange() é chamado
           └─> context.read<LoginViewModel>().validateUserOnLeave()
               └─> ViewModel muda _userValidationState para .loading
                   └─> notifyListeners() ← 🔔
                       └─> context.watch<LoginViewModel>() reconstrói a View
                           └─> suffixIcon mostra CircularProgressIndicator

4. API RESPONDE (sucesso ou erro)
   └─> ViewModel atualiza _userValidationState e _estabelecimentos
       └─> notifyListeners() ← 🔔
           └─> View reconstrói
               └─> Mostra check verde OU erro vermelho
               └─> Se sucesso: DropdownButton aparece com estabelecimentos

5. USUÁRIO CLICA EM "ENTRAR"
   └─> LoginButton.onPressed() → _handleLogin()
       └─> Valida formulário
           └─> context.read<LoginViewModel>().performLogin()
               └─> ViewModel muda _isLoggingIn = true
                   └─> notifyListeners() ← 🔔
                       └─> Botão mostra loading
               └─> Chama AuthRepository.login()
               └─> Chama MenuRepository.getUserData()
               └─> Cria AppUser
               └─> SessionViewModel.loginSuccess(user)
                   └─> Navega para tela principal (Menu)

*/
