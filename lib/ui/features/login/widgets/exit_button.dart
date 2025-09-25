import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ExitButton extends StatelessWidget {
  const ExitButton({super.key});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {},
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 20,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Icon(Icons.exit_to_app),
          ),
          const SizedBox(
            width: 10,
          ),
          Text(
            'Sair',
          ),
        ],
      ),
    );
  }
}
