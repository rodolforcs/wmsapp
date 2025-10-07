import 'package:flutter/foundation.dart';

// ============================================================================
// BASE VIEW MODEL - Classe base para todos os ViewModels
// ============================================================================

/// Classe abstrata que fornece funcionalidades comuns a todos os ViewModels
///
/// Responsabilidades:
/// - Gerenciar estado de loading
/// - Gerenciar mensagens de erro
/// - Fornecer método helper para operações assíncronas
/// - Evitar código duplicado
///
/// Como usar:
/// ```dart
/// class LoginViewModel extends BaseViewModel {
///   Future<void> login() async {
///     await runAsync(() async {
///       // Seu código aqui
///       await authRepository.login();
///     });
///   }
/// }
/// ```
abstract class BaseViewModel extends ChangeNotifier {
  // ==========================================================================
  // ESTADO COMUM - Presente em TODOS os ViewModels
  // ==========================================================================

  /// Indica se alguma operação assíncrona está em andamento
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Mensagem de erro da última operação (null se não houver erro)
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Indica se existe um erro
  bool get hasError => _errorMessage != null;

  // ==========================================================================
  // MÉTODOS PROTEGIDOS - Usados apenas pelos ViewModels filhos
  // ==========================================================================

  /// Define o estado de loading e notifica os listeners
  @protected
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Define uma mensagem de erro e notifica os listeners
  @protected
  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Limpa a mensagem de erro
  @protected
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Limpa o estado (loading e erro)
  @protected
  void resetState() {
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  // ==========================================================================
  // HELPERS - Facilitam operações comuns
  // ==========================================================================

  /// Executa uma operação assíncrona com tratamento automático de loading e erro
  ///
  /// Benefícios:
  /// - Ativa loading automaticamente
  /// - Desativa loading ao finalizar
  /// - Captura e armazena erros
  /// - Sempre notifica listeners
  ///
  /// Exemplo:
  /// ```dart
  /// await runAsync(() async {
  ///   final data = await repository.fetchData();
  ///   _data = data;
  /// });
  /// ```
  @protected
  Future<T?> runAsync<T>(
    Future<T> Function() operation, {
    String? errorMessage,
    bool showLoading = true,
  }) async {
    if (showLoading) {
      setLoading(true);
    }
    clearError();

    try {
      final result = await operation();
      return result;
    } catch (e) {
      final error = errorMessage ?? _extractErrorMessage(e);
      setError(error);

      if (kDebugMode) {
        debugPrint('[${runtimeType}] Erro: $error');
      }

      return null;
    } finally {
      if (showLoading) {
        setLoading(false);
      }
    }
  }

  /// Executa múltiplas operações em paralelo
  ///
  /// Exemplo:
  /// ```dart
  /// await runParallel([
  ///   () => repository.fetchUsers(),
  ///   () => repository.fetchProducts(),
  /// ]);
  /// ```
  @protected
  Future<List<T?>> runParallel<T>(
    List<Future<T> Function()> operations,
  ) async {
    setLoading(true);
    clearError();

    try {
      final futures = operations.map((op) => op()).toList();
      final results = await Future.wait(futures);
      return results;
    } catch (e) {
      setError(_extractErrorMessage(e));
      return List.filled(operations.length, null);
    } finally {
      setLoading(false);
    }
  }

  // ==========================================================================
  // MÉTODOS PRIVADOS
  // ==========================================================================

  /// Extrai mensagem legível de exceções
  String _extractErrorMessage(Object error) {
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return error.toString();
  }

  // ==========================================================================
  // DISPOSE
  // ==========================================================================

  @override
  void dispose() {
    if (kDebugMode) {
      debugPrint('[${runtimeType}] Disposed');
    }
    super.dispose();
  }
}

// ============================================================================
// EXEMPLO DE USO
// ============================================================================

/*

// ANTES (sem BaseViewModel):
class LoginViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await authRepository.login(username, password);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// DEPOIS (com BaseViewModel):
class LoginViewModel extends BaseViewModel {
  Future<void> login(String username, String password) async {
    await runAsync(() async {
      await authRepository.login(username, password);
    });
  }
}

// Redução de 20+ linhas para 5 linhas! 🎉

*/

// ============================================================================
// BENEFÍCIOS DO BaseViewModel
// ============================================================================

/*

✅ MENOS CÓDIGO:
   - Elimina 15-20 linhas por ViewModel
   - Código mais limpo e legível

✅ CONSISTÊNCIA:
   - Todos os ViewModels funcionam igual
   - Mesmos nomes de variáveis (isLoading, errorMessage)
   - Mesmo comportamento

✅ MANUTENÇÃO:
   - Corrige bug em 1 lugar, afeta todos
   - Adiciona feature (ex: retry) em 1 lugar

✅ TESTABILIDADE:
   - Testa BaseViewModel uma vez
   - ViewModels filhos herdam testes

✅ ESCALABILIDADE:
   - Fácil adicionar novos ViewModels
   - Padrão claro para toda equipe

*/
