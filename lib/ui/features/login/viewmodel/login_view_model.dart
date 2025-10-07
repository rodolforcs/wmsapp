import 'package:flutter/foundation.dart';
import 'package:wmsapp/core/services/messenger_service.dart';
import 'package:wmsapp/core/viewmodel/base_view_model.dart';
import 'package:wmsapp/core/viewmodel/session_view_model.dart';
import 'package:wmsapp/data/models/app_user_model.dart';
import 'package:wmsapp/data/repositories/auth_repository.dart';
import 'package:wmsapp/data/repositories/menu_repository.dart';

// ============================================================================
// ENUMS
// ============================================================================

enum UserValidationState { idle, loading, success, error }

// ============================================================================
// LOGIN VIEW MODEL (com BaseViewModel)
// ============================================================================

/// ViewModel responsável pela lógica de negócio da tela de Login
///
/// Herda de BaseViewModel e ganha automaticamente:
/// - isLoading (bool)
/// - errorMessage (String?)
/// - runAsync() (método helper)
/// - setLoading(), setError(), clearError()
class LoginViewModel extends BaseViewModel {
  // ==========================================================================
  // DEPENDÊNCIAS
  // ==========================================================================

  final AuthRepository _authRepository;
  final MenuRepository _menuRepository;
  final SessionViewModel _sessionViewModel;

  LoginViewModel({
    required AuthRepository authRepository,
    required MenuRepository menuRepository,
    required SessionViewModel sessionViewModel,
  }) : _authRepository = authRepository,
       _menuRepository = menuRepository,
       _sessionViewModel = sessionViewModel;

  // ==========================================================================
  // ESTADO LOCAL (específico do Login)
  // ==========================================================================

  // Validação de usuário
  UserValidationState _userValidationState = UserValidationState.idle;
  String? _userValidationError;
  List<String> _estabelecimentos = [];
  String? _selectedEstabelecimento;

  // Configurações da tela
  bool _utilizarDominio = true;
  bool _isPasswordObscured = true;

  // 🎉 NÃO PRECISA MAIS DE:
  // bool _isLoggingIn = false;  ← Substituído por isLoading (herdado)
  // String? _errorMessage;      ← Substituído por errorMessage (herdado)

  // ==========================================================================
  // GETTERS
  // ==========================================================================

  UserValidationState get userValidationState => _userValidationState;
  String? get userValidationError => _userValidationError;
  List<String> get estabelecimentos => _estabelecimentos;
  String? get selectedEstabelecimento => _selectedEstabelecimento;
  bool get utilizarDominio => _utilizarDominio;
  bool get isPasswordObscured => _isPasswordObscured;

  // Helpers
  bool get hasEstabelecimentos => _estabelecimentos.isNotEmpty;
  bool get isValidatingUser =>
      _userValidationState == UserValidationState.loading;

  // 🎉 isLoading já vem do BaseViewModel!
  // Não precisa declarar novamente

  // ==========================================================================
  // MÉTODOS PÚBLICOS
  // ==========================================================================

  void toggleDominio(bool value) {
    _utilizarDominio = value;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _isPasswordObscured = !_isPasswordObscured;
    notifyListeners();
  }

  void selectEstabelecimento(String? estabelecimento) {
    if (kDebugMode) {
      debugPrint(
        '[LoginViewModel] Estabelecimento selecionado: $estabelecimento',
      );
    }
    _selectedEstabelecimento = estabelecimento;
    notifyListeners();
  }

  // ==========================================================================
  // VALIDAÇÃO DE USUÁRIO
  // ==========================================================================

  Future<void> validateUserOnLeave(String username) async {
    if (username.trim().isEmpty) {
      _resetValidationState();
      return;
    }

    _setValidationLoading();

    // 🎉 ANTES: try-catch manual com loading
    // 🎉 AGORA: runAsync faz tudo automaticamente!
    final result = await runAsync(
      () async {
        return await _authRepository.validateUserAndGetEstabelecimentos(
          username.trim(),
        );
      },
      showLoading: false, // Não usa o isLoading global, usa estado específico
    );

    if (result != null) {
      // Sucesso
      _estabelecimentos = result;
      _userValidationState = UserValidationState.success;
      _userValidationError = null;

      if (kDebugMode) {
        debugPrint(
          '[LoginViewModel] Usuário válido. ${result.length} estabelecimentos.',
        );
      }
    } else {
      // Erro (errorMessage já foi setado pelo runAsync)
      _handleValidationError(errorMessage);
    }

    notifyListeners();
  }

  void _resetValidationState() {
    _userValidationState = UserValidationState.idle;
    _userValidationError = null;
    _selectedEstabelecimento = null;
    _estabelecimentos = [];
    notifyListeners();
  }

  void _setValidationLoading() {
    _userValidationState = UserValidationState.loading;
    _userValidationError = null;
    _estabelecimentos.clear();
    _selectedEstabelecimento = null;
    notifyListeners();
  }

  void _handleValidationError(String? error) {
    final errorMsg = error ?? 'Erro ao validar usuário';

    _userValidationState = UserValidationState.error;
    _userValidationError = errorMsg;
    _estabelecimentos = [];
    _selectedEstabelecimento = null;

    MessengerService.showError(errorMsg);

    if (kDebugMode) {
      debugPrint('[LoginViewModel] Erro na validação: $errorMsg');
    }
  }

  // ==========================================================================
  // LOGIN PRINCIPAL
  // ==========================================================================

  Future<String?> performLogin({
    required String domain,
    required String username,
    required String password,
  }) async {
    if (kDebugMode) {
      debugPrint('[LoginViewModel] Iniciando processo de login...');
    }

    // Validações básicas
    final validationError = _validateLoginFields(username, password);
    if (validationError != null) {
      MessengerService.showError(validationError);
      return validationError;
    }

    // 🎉 ANTES:
    // _isLoggingIn = true;
    // notifyListeners();
    // try { ... } catch { ... } finally { _isLoggingIn = false; }

    // 🎉 AGORA:
    // runAsync cuida de TUDO (loading, erro, notify)!
    final success = await runAsync(() async {
      // ETAPA 1: Autenticar
      final loginResponse = await _authRepository.login(
        domain,
        username.trim(),
        password,
      );

      if (kDebugMode) {
        debugPrint(
          '[LoginViewModel] Autenticação bem-sucedida: $loginResponse',
        );
      }

      // ETAPA 2: Buscar dados do usuário
      final userData = await _menuRepository.getUserData(
        username: username.trim(),
        password: password,
      );

      if (kDebugMode) {
        debugPrint('[LoginViewModel] Dados do usuário: ${userData.codUsuario}');
      }

      // ETAPA 3: Criar AppUser
      final user = AppUser(
        codUsuario: userData.codUsuario,
        username: username.trim(),
        password: password,
        estabelecimentos: _estabelecimentos,
        selectedEstabelecimento: _selectedEstabelecimento,
        permissionsModules: userData.permissions,
      );

      // ETAPA 4: Iniciar sessão
      _sessionViewModel.loginSuccess(user);

      if (kDebugMode) {
        debugPrint('[LoginViewModel] Login concluído com sucesso!');
      }

      return true; // Sucesso
    });

    // Se deu erro, errorMessage já foi setado pelo runAsync
    if (success == null && errorMessage != null) {
      MessengerService.showError(errorMessage!);
      return errorMessage;
    }

    return null; // Sucesso (sem erro)
  }

  String? _validateLoginFields(String username, String password) {
    if (username.trim().isEmpty || password.isEmpty) {
      return 'Usuário e senha são obrigatórios.';
    }

    if (_estabelecimentos.isNotEmpty && _selectedEstabelecimento == null) {
      return 'Por favor, selecione um estabelecimento.';
    }

    return null;
  }
}

// ============================================================================
// COMPARAÇÃO: ANTES vs DEPOIS
// ============================================================================

/*

📊 REDUÇÃO DE CÓDIGO:

ANTES (sem BaseViewModel):
- 180 linhas
- bool _isLoggingIn + getters
- String? _error + getters
- try-catch manual em cada método
- setLoading() manual
- notifyListeners() em vários lugares

DEPOIS (com BaseViewModel):
- 150 linhas (-30 linhas = 17% menor!)
- isLoading herdado
- errorMessage herdado
- runAsync() cuida de tudo
- Código mais limpo e legível


🎯 BENEFÍCIOS PRÁTICOS:

1. MENOS CÓDIGO REPETITIVO
   ❌ _isLoading = true; notifyListeners();
   ✅ Feito automaticamente por runAsync()

2. TRATAMENTO DE ERRO CONSISTENTE
   ❌ Precisa lembrar de capturar e formatar erro
   ✅ BaseViewModel já faz isso

3. MAIS FÁCIL DE TESTAR
   ❌ Precisa testar loading/error em cada método
   ✅ Testa BaseViewModel uma vez

4. MANUTENÇÃO SIMPLES
   ❌ Mudar comportamento: editar 10 ViewModels
   ✅ Mudar comportamento: editar BaseViewModel

*/
