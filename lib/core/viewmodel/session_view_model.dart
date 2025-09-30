import 'package:flutter/material.dart';
import 'package:wmsapp/data/models/app_permissions_model.dart';
import 'package:wmsapp/data/models/app_user_model.dart';

class SessionViewModel extends ChangeNotifier {
  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  String? get selectedEstabelecimento => _currentUser?.selectedEstabelecimento;

  AppPermissionsModel get permissionsModules =>
      _currentUser?.permissionsModules ?? AppPermissionsModel();

  //Método chamada pela LoginViewModel para iniciar a sessão
  void loginSuccess(AppUser user) {
    print('[SessionViewModel] loginSuccess foi chamado!');
    if (_currentUser?.username != user.username) {
      _currentUser = user;
      print(
        '[SessionViewModel] Usuário atualizado. Chamando notifyListeners...',
      );
      // Notifica os ouvintes que o estado do Login mudou.
      notifyListeners();
    } else {
      print('[SessionViewModel] Mesmo usuário, não vai notificar.');
    }
  }

  //Método para encerrar a sessão
  void logout() {
    if (_currentUser != null) {
      _currentUser = null;
      notifyListeners();
    }
  }
}
