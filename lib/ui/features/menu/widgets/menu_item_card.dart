import 'package:flutter/material.dart';

/// MenuItemCard: Um widget reutilizável que representa um único item(módulo)
/// no GridView da tela de menu.
///
/// Recebe um [icon], um [label] e uma função [onTap] para lidar com o clique.
/// Agora incluir uma propriedade [isEnable] para controlar a aparência e o
/// comportamento de clique do card.

class MenuItemCard extends StatelessWidget {
  const MenuItemCard({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.isEnabled = true, // Por padrão, o card é habilitado.
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    // Usamos um InkWell para dar o efeito visual de "splash" ao tocar.
    // Um GestureDetector também funcionaria, mas o InkWell é visualmente responsivo.
    return Opacity(
      // Se o card não estiver habilitado, sua opacidade será reduzida para 40%.
      // Se estiver habilitado, a opacidade é 100% (totalmente visível).
      opacity: isEnabled ? 1.0 : 0.4,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Card(
          elevation: 4.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(12),
          ),

          // Para evitar o overflow, vamos garantir que o conteúdo se ajuste
          // ao espaço que o Card recebe do GridView.
          child: Padding(
            // Usamos o padding para dar um respiro para o conteúdo.
            padding: const EdgeInsets.all(8.0),
            child: Column(
              // Centraliza o conteúdo verticalmente e horizonalmente.
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //Ícone do módulo.
                Flexible(
                  flex: 3,
                  child: Icon(
                    icon,
                    size: 48.0,
                    color: Theme.of(
                      context,
                    ).primaryColor, // Usar a cor primária do tema.
                  ),
                ),
                const SizedBox(
                  height: 16,
                ), // Espaçamento entre o ícone e o texto
                // Rótulo do módulo.
                Flexible(
                  flex: 2,
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
