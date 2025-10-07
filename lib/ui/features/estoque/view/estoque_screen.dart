import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wmsapp/core/viewmodel/session_view_model.dart';
import 'package:wmsapp/ui/features/estoque/viewmodel/estoque_view_model.dart';

// Importa os widgets que acabamos de separar.
import 'package:wmsapp/ui/features/estoque/widgets/estoque_operations_view.dart';
import 'package:wmsapp/ui/features/estoque/widgets/estoque_dashboard_view.dart';

class EstoqueScreen extends StatefulWidget {
  const EstoqueScreen({super.key});

  @override
  State<EstoqueScreen> createState() => _EstoqueScreenState();
}

class _EstoqueScreenState extends State<EstoqueScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Lê as permissões do SessionViewModel que já existe na árvore de widgets.
    final permissions = context.read<SessionViewModel>().permissionsModules;

    // 2. Fornece o EstoqueViewModel, passando as permissões que acabamos de ler.
    return ChangeNotifierProvider(
      create: (_) => EstoqueViewModel(permissions: permissions),
      child: Builder(
        builder: (BuildContext context) {
          // 'Context' enxerga o EstoqueViewModel
          // Agora, dentro deste builder, podemos usar 'newContext' para ler ou assistir.
          // No entanto, como o nosso widget filho (EstoqueOperationsView) já usa
          // context.watch, não precisamos fazer nada aqui. O simples fato de
          // existir um novo contexto já resolve o problema.
          return Scaffold(
            appBar: AppBar(
              title: Text(
                _selectedIndex == 0
                    ? 'Estoque - Operações'
                    : 'Estoque - Dashboard',
              ),
            ),
            body: IndexedStack(
              index: _selectedIndex,
              // Agora usamos as classes importadas.
              children: const [
                EstoqueOperationsView(),
                EstoqueDashboardView(),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              selectedItemColor: Colors.blue,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.grid_view_rounded),
                  label: 'Operações',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart_rounded),
                  label: 'Dashboard',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
