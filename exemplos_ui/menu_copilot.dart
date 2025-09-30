import 'package:flutter/material.dart';

void main() => runApp(const WmsApp());

class WmsApp extends StatelessWidget {
  const WmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WMS',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF0A84FF),
        brightness: Brightness.light,
      ),
      home: const WmsShell(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Shell com AppBar, navegação adaptativa (BottomNavigation/NavigationRail)
/// e Home em cards. Sem go_router — apenas para visualizar a UI.
class WmsShell extends StatefulWidget {
  const WmsShell({super.key});
  @override
  State<WmsShell> createState() => _WmsShellState();
}

class _WmsShellState extends State<WmsShell> {
  int _index = 0;

  // Metadados das “abas”
  final List<_TabMeta> _tabs = const [
    _TabMeta('Início', Icons.dashboard_rounded),
    _TabMeta('Receb.', Icons.move_to_inbox_rounded),
    _TabMeta('Picking', Icons.shopping_basket_rounded),
    _TabMeta('Putaway', Icons.unarchive_rounded),
    _TabMeta('Inventário', Icons.inventory_2_rounded),
  ];

  late final List<Widget> _pages = const <Widget>[
    HomeDashboard(),
    ReceivePage(),
    PickPage(),
    PutawayPage(),
    InventoryPage(),
  ];

  void _onSelect(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final useRail =
        width >= 900; // breakpoint simples: >=900 usa NavigationRail

    return Scaffold(
      appBar: AppBar(
        title: const Text('WMS'),
        actions: [
          IconButton(
            tooltip: 'Sincronizar',
            icon: const Icon(Icons.cloud_sync_rounded),
            onPressed: () {}, // placeholder
          ),
          IconButton(
            tooltip: 'Configurações',
            icon: const Icon(Icons.settings),
            onPressed: () => _openSettings(context),
          ),
        ],
      ),
      // Drawer apenas para itens secundários (não essenciais)
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              const ListTile(title: Text('Opções')),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Perfil'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('Ajuda'),
                onTap: () {},
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sair'),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
      body: Row(
        children: [
          if (useRail)
            NavigationRail(
              selectedIndex: _index,
              labelType: NavigationRailLabelType.selected,
              leading: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: CircleAvatar(
                  radius: 18,
                  child: const Icon(Icons.person),
                ),
              ),
              destinations: _tabs
                  .map(
                    (t) => NavigationRailDestination(
                      icon: Icon(t.icon),
                      selectedIcon: Icon(
                        t.icon,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      label: Text(t.label),
                    ),
                  )
                  .toList(),
              onDestinationSelected: _onSelect,
            ),
          Expanded(
            child: IndexedStack(
              index: _index,
              children: _pages,
            ),
          ),
        ],
      ),
      bottomNavigationBar: useRail
          ? null
          : NavigationBar(
              selectedIndex: _index,
              destinations: _tabs
                  .map(
                    (t) => NavigationDestination(
                      icon: Icon(t.icon),
                      label: t.label,
                    ),
                  )
                  .toList(),
              onDestinationSelected: _onSelect,
            ),
      floatingActionButton: _index == 0
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.qr_code_scanner_rounded),
              label: const Text('Scan'),
              onPressed: () {
                // TODO: abrir fluxo de scanner (mobile_scanner ou integração com leitor)
              },
            )
          : null,
    );
  }

  void _openSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(leading: Icon(Icons.wifi_off), title: Text('Modo Offline')),
          ListTile(leading: Icon(Icons.palette_rounded), title: Text('Tema')),
          ListTile(
            leading: Icon(Icons.language_rounded),
            title: Text('Idioma'),
          ),
        ],
      ),
    );
  }
}

class _TabMeta {
  final String label;
  final IconData icon;
  const _TabMeta(this.label, this.icon);
}

/* ====================== HOME (cards) ====================== */

class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _DashItem('Recebimento', Icons.move_to_inbox_rounded, Colors.indigo, 3),
      _DashItem('Putaway', Icons.unarchive_rounded, Colors.teal, 2),
      _DashItem('Picking', Icons.shopping_basket_rounded, Colors.orange, 5),
      _DashItem('Inventário', Icons.inventory_2_rounded, Colors.purple, null),
    ];

    return LayoutBuilder(
      builder: (ctx, c) {
        final width = c.maxWidth;
        final crossAxisCount = width >= 1200
            ? 4
            : width >= 900
            ? 3
            : 2;
        const spacing = 16.0;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: spacing,
              crossAxisSpacing: spacing,
              children: cards.map((i) => _WmsCard(item: i)).toList(),
            ),
          ),
        );
      },
    );
  }
}

class _WmsCard extends StatelessWidget {
  final _DashItem item;
  const _WmsCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      child: InkWell(
        onTap: () {
          // Apenas visual: poderia trocar de aba aqui via estado global se quisesse
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Abrir ${item.title}')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: item.color.withOpacity(.12),
                child: Icon(item.icon, color: item.color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (item.counter != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${item.counter}',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashItem {
  final String title;
  final IconData icon;
  final Color color;
  final int? counter;
  _DashItem(this.title, this.icon, this.color, this.counter);
}

/* ====================== TELAS “stub” ====================== */

class ReceivePage extends StatelessWidget {
  const ReceivePage({super.key});
  @override
  Widget build(BuildContext context) => const _Stub('Recebimento');
}

class PickPage extends StatelessWidget {
  const PickPage({super.key});
  @override
  Widget build(BuildContext context) => const _Stub('Picking');
}

class PutawayPage extends StatelessWidget {
  const PutawayPage({super.key});
  @override
  Widget build(BuildContext context) => const _Stub('Putaway');
}

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});
  @override
  Widget build(BuildContext context) => const _Stub('Inventário');
}

class _Stub extends StatelessWidget {
  final String title;
  const _Stub(this.title, {super.key});
  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      title,
      style: Theme.of(context).textTheme.headlineMedium,
      textAlign: TextAlign.center,
    ),
  );
}
