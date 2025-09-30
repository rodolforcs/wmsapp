import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wmsapp/data/models/app_user_model.dart'; // Importe o modelo de usuário
import 'package:wmsapp/core/services/messenger_service.dart';
import 'package:wmsapp/core/viewmodel/session_view_model.dart'; // Importe a SessionViewModel
import 'package:wmsapp/data/repositories/auth_repository.dart';
import 'package:wmsapp/data/repositories/menu_repository.dart';

// Enum para os estados de validação, para um código mais limpo
enum UserValidationState { idle, loading, success, error }

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;
  final MenuRepository _menuRepository;

  LoginViewModel({
    required AuthRepository authRepository,
    required MenuRepository menuRepository,
  }) : _authRepository = authRepository,
       _menuRepository = menuRepository;

  // --- ESTADO LOCAL DA TELA DE LOGIN ---

  // Estado da validação do usuário no "leave" do campo
  UserValidationState _userValidationState = UserValidationState.idle;
  UserValidationState get userValidationState => _userValidationState;

  String _validationErrorError = '';
  String get validationErrorMessage => _validationErrorError;

  List<String> _estabelecimentos = [];
  List<String> get estabelecimentos => _estabelecimentos;

  // Estado para o switch "Utilizar Domínio"
  bool _utilizarDominio = true;
  bool get utilizarDominio => _utilizarDominio;

  // Estado para a visibilidade da senha
  bool _isPasswordObscured = true;
  bool get isPasswordObscured => _isPasswordObscured;

  // Estado de loading para o botão de login principal
  bool _isLoggingIn = false;
  bool get isLoggingIn => _isLoggingIn;

  // Variável para armazenar o estabelecimento selecionado
  String? _selectedEstabelecimento;
  String? get selectedEstabelecimento => _selectedEstabelecimento;

  // Adicione um campo para a mensagem de erro
  String? _userValidationError;
  String? get userValidationError => _userValidationError;

  // --- AÇÕES DA VIEW ---

  void toggleDominio(bool value) {
    _utilizarDominio = value;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _isPasswordObscured = !_isPasswordObscured;
    notifyListeners();
  }

  void selectEstabelecimento(String? estabelecimento) {
    print(
      '[LOGIN VM] Estabelecimento selecionado: $estabelecimento',
    ); // Adicione um print para depurar
    _selectedEstabelecimento = estabelecimento;
    notifyListeners();
  }

  // Ação para validar o usuário quando ele sai do campo
  Future<void> validateUserOnLeave(String username) async {
    if (username.isEmpty) {
      _userValidationState = UserValidationState.idle;
      _userValidationError = null;
      _selectedEstabelecimento = null;
      _estabelecimentos = [];
      notifyListeners();
      return;
    }

    _userValidationState = UserValidationState.loading;
    _userValidationError = null;
    _estabelecimentos.clear();
    notifyListeners();

    try {
      final result = await _authRepository.validateUserAndGetEstabelecimentos(
        username,
      );

      _estabelecimentos = result;
      _userValidationState = UserValidationState.success;
    } catch (e) {
      final errorMessage = e.toString().replaceFirst(
        'Exception: ',
        '',
      );
      /*
      _userValidationError = e.toString().replaceFirst(
        'Exception: ',
        '',
      );
      */
      MessengerService.showError(errorMessage);

      //Ainda guardamos o erro para o errorText do TextFormField
      _validationErrorError = errorMessage;
      _userValidationState = UserValidationState.error;
      _estabelecimentos = [];
      _selectedEstabelecimento = null;
    } finally {
      notifyListeners();
    }
  }

  // Ação para o botão de login principal
  Future<String?> performLogin({
    required BuildContext context,
    required String domain,
    required String username,
    required String password,
    String? selectedEstabelecimento,
  }) async {
    print('[LOGIN VM] performLogin chamado.');
    // Validação simples de entrada
    if (username.isEmpty || password.isEmpty) {
      MessengerService.showError('Usuário e senha são obrigatórios.');
      return null;
    }
    if (_estabelecimentos.isNotEmpty && _selectedEstabelecimento == null) {
      print('$_estabelecimentos.isNotEmpty $selectedEstabelecimento');
      MessengerService.showError('Por favor, selecione um estabelecimento.');
      return null;
    }

    _isLoggingIn = true;
    notifyListeners();

    String? errorMessage;
    try {
      // ETAPA 1: Autenticar e obter os dados do usuário.
      final loginResponse = await _authRepository.login(
        domain,
        username,
        password,
      );
      print(
        '[LoginViewModel] Resposta do Login: $loginResponse',
      ); // DEBUG: Veja a resposta completa

      // ETAPA 3: Buscar as permissões para este usuário.
      final userData = await _menuRepository.getUserData(
        username: username,
        password: password,
      );

      // ETAPA 4: Criar o objeto AppUser completo.
      final user = AppUser(
        codUsuario: userData.codUsuario,
        username: username,
        password:
            password, // Armazena a senha para futuras chamadas autenticadas
        estabelecimentos: _estabelecimentos,
        selectedEstabelecimento: _selectedEstabelecimento,
        permissionsModules: userData.permissions,
      );

      // ETAPA 5: Iniciar a sessão.
      Provider.of<SessionViewModel>(context, listen: false).loginSuccess(user);
      print('[LoginViewModel] Processo de login concluído com sucesso.');
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      print(
        '[LoginViewModel] ERRO no processo de login: $errorMessage',
      ); // DEBUG
      MessengerService.showError(errorMessage);
    } finally {
      _isLoggingIn = false;
      notifyListeners();
    }
  }
}
