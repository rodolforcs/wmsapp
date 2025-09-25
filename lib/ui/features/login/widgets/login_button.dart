import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({
    super.key,
    this.isLoading = false, // Padrão é não estar carregando
    this.onPressed, // A função a ser executada no clique
  });

  // Declare as variáveis como final
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 20,
        ),
        backgroundColor: Colors.indigo,
      ),
      child: isLoading
          // Se estiver carregando, mostrar o indicador
          ? const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )
          : const Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Icon(Icons.login),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'Login',
                ),
              ],
            ),
    );
  }
}
