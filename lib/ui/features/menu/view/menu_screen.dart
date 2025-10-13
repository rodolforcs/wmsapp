import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:wmsapp/core/viewmodel/session_view_model.dart';
import 'package:wmsapp/ui/features/menu/viewmodel/menu_view_model.dart';
import 'package:wmsapp/ui/features/menu/widgets/menu_item_card.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Ouve as mudanças no MenuViewModel.
    // Sempre que o MenuViewModel for recriado (após o login), esta tela será reconstruída.
    final menuViewModel = context.watch<MenuViewModel>();

    // 2. ✅ MUDANÇA AQUI: Usa READ ao invés de WATCH
    // read = "me dê o valor AGORA, mas não me avise de mudanças"
    // watch = "me avise SEMPRE que algo mudar"
    final user = context.read<SessionViewModel>().currentUser;

    print(
      '[MenuScreen BUILD] Reconstruindo tela. Permissão de Estoque: ${menuViewModel.modulos.isNotEmpty ? menuViewModel.modulos.first.isEnabled : 'lista vazia'}',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Bem-vindo, ${user?.username.toUpperCase() ?? ''}'),
        centerTitle: true,
        // Ações, como o botão de logout, virão aqui.
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () {
              // Chama o método de logout do SessionViewModel.
              // Usamos context.read() porque estamos dentro de um callback (onPressed)
              // e não precisamos que este widget específico reconstrua quando o estado mudar.
              // Apenas queremos disparar a ação.
              context.read<SessionViewModel>().logout();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16, // Adicionado para consistência
            childAspectRatio: 1.0,
          ),
          // 2. Usa a lista de módulos que vem do MenuViewModel.
          itemCount: menuViewModel.modulos.length,
          itemBuilder: (context, index) {
            // Pega o módulo específico da lista do ViewModel.
            final modulo = menuViewModel.modulos[index];

            // 3. Passa TODOS os dados do modelo para o card, incluindo 'isEnabled'.
            return MenuItemCard(
              label: modulo.label,
              icon: modulo.icon,
              isEnabled: modulo.isEnabled, // <-- A PEÇA FUNDAMENTAL
              onTap: () {
                // A lógica de onTap agora verifica se o card está habilitado.
                if (modulo.isEnabled) {
                  print('Navegando para ${modulo.route}');
                  context.push(modulo.route);
                } else {
                  print('Módulo ${modulo.label} está desabilitado.');
                }
              },
            );
          },
        ),
      ),
    );
  }
}
