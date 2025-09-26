import 'package:flutter/material.dart';
import 'package:wmsapp/data/models/app_user_model.dart';

class SessionViewModel extends ChangeNotifier {
  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  String? get selectedEstabelecimento => _currentUser?.selectedEstabelecimento;
  List<String> get permissionsModule => _currentUser?.permissionsModules ?? [];

  //Método chamada pela LoginViewModel para iniciar a sessão
  void loginSuccess(AppUser user) {
    if (_currentUser?.username != user.username) {
      _currentUser = user;
      // Notifica os ouvintes que o estado do Login mudou.
      notifyListeners();
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
