import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wmsapp/core/viewmodel/session_view_model.dart';
import 'package:wmsapp/navigation/app_router.dart';
import 'package:wmsapp/ui/features/menu/widgets/menu_item_card.dart';
import 'package:go_router/go_router.dart';

/// MenuScreen: A tela principal após o login, exibindo os módulos disponíveis
/// em um formato de grade responsiva.
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Acessa a SessionViewModel para obetar a informações do usuário, se necessário.
    final user = context.watch<SessionViewModel>().currentUser;

    // Lista de módulos. No futuro, isso virá do MenuViewModel,
    // possivelmente filtrado pelas permissões do usuário.
    // Por enquanto, vamos definir os dados diretamente na UI.
    final List<Map<String, dynamic>> modulos = [
      {
        'label': 'Estoque',
        'icon': Icons.inventory_2,
        'route': AppRouter.estoque,
      },
      {
        'label': 'Expedição',
        'icon': Icons.local_shipping,
        'route': '/expedicao',
      }, // Exemplo de rota
      {
        'label': 'Produção',
        'icon': Icons.precision_manufacturing,
        'route': '/producao',
      }, // Exemplo de rota
      {
        'label': 'Qualidade',
        'icon': Icons.high_quality,
        'route': '/qualidade',
      }, // Exemplo de rota
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Bem-vindo, ${user?.username.toUpperCase()}'),
        centerTitle: true,
        // Futuramente, aqui entrará o botão de Logout.
        actions: [
          // IconButton(icon: Icon(Icons.logout), onPressed: () { /* Lógica de logout */ }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          // SliverGridDelegateWithMaxCrossAxisExtent é ótimo para responsividade.
          // Ele cria o máximo de colunas possível, onde cada coluna tem no mínimo 180 pixels de largura.
          // - Em um celular, isso geralmente resulta em 2 colunas.
          // - Em um tablet, pode resultar em 3, 4 ou mais colunas.
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200, // Largura máxima de cada item da grade.
            crossAxisSpacing: 16, // Espaçamento horizontal entre os itens.
            childAspectRatio:
                1.0, // Proporção (1.0 significa que os itens serão quadrado)
          ),
          itemCount: modulos.length, // O número de itens da grade.
          itemBuilder: (context, index) {
            final modulo = modulos[index];

            return MenuItemCard(
              label: modulo['label'],
              icon: modulo['icon'],
              onTap: () {
                // Ação ao clicar: Navega para a rota definida para o módulo.
                // Usamos context.push para empilhar a nova tela sobre o menu.
                print(
                  'Navegando para ${modulo['route']}',
                ); // Log para depuração
                context.push(modulo['route']);
              },
            );
          },
        ),
      ),
    );
  }
}
