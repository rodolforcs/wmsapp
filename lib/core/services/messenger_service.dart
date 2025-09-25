import 'package:flutter/material.dart';

class MessengerService {
  // A GlobalKey nos dá acesso ao BuildContext do MaterialApp,
  // permitindo mostrar o SnackBar de qualquer lugar, sem precisar
  // passar o 'context' como parâmetro.
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  // Método para mostrar uma mensagem de erro
  static void showError(String message) {
    // Pega o estado atual do ScaffoldMessenger
    final currentState = messengerKey.currentState;
    if (currentState == null) return;

    //Se já existir uma mensagem aberta limpa a snack da tela atual
    currentState.clearSnackBars();

    //Cria a snackBar com a aparência de erro
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.red[700],
      behavior: SnackBarBehavior.floating, // Estilo flutuante
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(10),
    );
    // Usa a GlobalKey para encontrar o ScaffoldMessenger e mostrar o SnackBar
    messengerKey.currentState?.showSnackBar(snackBar);
  }

  // Você pode adicionar outros métodos aqui no futuro (showSuccess, showInfo, etc.)
  static void showSuccess(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: Colors.green[700], // Cor verde para sucesso
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(10),
    );
    messengerKey.currentState?.showSnackBar(snackBar);
  }
}
