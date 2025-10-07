import 'package:flutter/material.dart';

void main() {
  runApp(const WMSApp());
}

class WMSApp extends StatelessWidget {
  const WMSApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WMS Sistema',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 1,
        ),
      ),
      home:
          const MainScreen(), // A tela inicial agora é a tela principal com a BottomNav
    );
  }
}

// -------------------------------------------------------------------
// TELA PRINCIPAL (COM A BOTTOMNAVIGATORBAR)
// -------------------------------------------------------------------
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Lista de telas para a BottomNavigationBar
  static const List<Widget> _screens = <Widget>[
    MainMenuScreen(), // Aba 0: Tela de Início com os cards dos módulos
    PlaceholderScreen(title: 'Relatórios'), // Aba 1: Tela de Relatórios
    PlaceholderScreen(title: 'Histórico'), // Aba 2: Tela de Histórico
    PlaceholderScreen(title: 'Configurações'), // Aba 3: Tela de Configurações
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WMS - Sistema de Armazém'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(icon: const Icon(Icons.account_circle), onPressed: () {}),
        ],
      ),
      // O corpo agora muda de acordo com a aba selecionada na BottomNav
      body: _screens[_selectedIndex],
      // A BottomNavigationBar está de volta
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType
            .fixed, // Garante que todos os labels apareçam
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Relatórios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Histórico',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Config'),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------------
// TELA DE INÍCIO (Aba 0, com os cards dos módulos)
// -------------------------------------------------------------------
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> mainModules = [
      {
        'title': 'Estoque',
        'icon': Icons.inventory_2,
        'color': Colors.blue,
        'description': 'Operações de estoque',
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EstoqueModuleScreen(),
            ),
          );
        },
      },
      {
        'title': 'Expedição',
        'icon': Icons.local_shipping,
        'color': Colors.orange,
        'description': 'Saída de mercadorias',
        'onTap': () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Módulo de Expedição em desenvolvimento.'),
            ),
          );
        },
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0,
          ),
          itemCount: mainModules.length,
          itemBuilder: (context, index) {
            return _buildModuleCard(
              module: mainModules[index],
              onTap: mainModules[index]['onTap'],
            );
          },
        );
      },
    );
  }
}

// -------------------------------------------------------------------
// TELA DO MÓDULO DE ESTOQUE (com as sub-opções)
// -------------------------------------------------------------------
class EstoqueModuleScreen extends StatelessWidget {
  const EstoqueModuleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> stockOptions = [
      {
        'title': 'Recebimento',
        'icon': Icons.move_to_inbox,
        'color': Colors.green,
        'description': 'Entrada de materiais',
      },
      {
        'title': 'Endereçamento',
        'icon': Icons.forklift,
        'color': Colors.deepPurple,
        'description': 'Alocação de paletes',
      },
      {
        'title': 'Separação',
        'icon': Icons.checklist_rtl,
        'color': Colors.teal,
        'description': 'Picking de requisições',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Módulo de Estoque'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0,
            ),
            itemCount: stockOptions.length,
            itemBuilder: (context, index) {
              return _buildModuleCard(
                module: stockOptions[index],
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Acessando: ${stockOptions[index]['title']}',
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// -------------------------------------------------------------------
// WIDGETS REUTILIZÁVEIS
// -------------------------------------------------------------------

// Card de Módulo (reutilizado em ambas as telas de grid)
Widget _buildModuleCard({
  required Map<String, dynamic> module,
  required VoidCallback onTap,
}) {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [(module['color'] as Color).withOpacity(0.1), Colors.white],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (module['color'] as Color).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                module['icon'] as IconData,
                size: 32,
                color: module['color'] as Color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              module['title'] as String,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              module['description'] as String,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    ),
  );
}

// Tela genérica para as outras abas da BottomNav
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.build, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Em desenvolvimento',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
