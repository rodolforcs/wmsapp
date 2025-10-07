import 'package:flutter/material.dart';

void main() {
  runApp(const WMSApp());
}

class WMSApp extends StatelessWidget {
  const WMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WMS System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade700),
      ),
      home: const OperationalMenuScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class OperationalMenuScreen extends StatefulWidget {
  const OperationalMenuScreen({super.key});

  @override
  State<OperationalMenuScreen> createState() => _OperationalMenuScreenState();
}

class _OperationalMenuScreenState extends State<OperationalMenuScreen> {
  int _selectedModuleIndex = 0;

  // Módulos principais do WMS
  final List<WMSModule> modules = [
    WMSModule(
      title: 'Recebimento',
      icon: Icons.inbox,
      color: Colors.green,
      operations: [
        Operation('Entrada de NF', Icons.receipt_long, Colors.green.shade600),
        Operation('Conferência', Icons.fact_check, Colors.green.shade500),
        Operation('Etiquetagem', Icons.qr_code_2, Colors.green.shade400),
        Operation('Armazenagem', Icons.inventory_2, Colors.green.shade700),
      ],
    ),
    WMSModule(
      title: 'Armazenagem',
      icon: Icons.warehouse,
      color: Colors.blue,
      operations: [
        Operation('Endereçamento', Icons.location_on, Colors.blue.shade600),
        Operation('Transferência', Icons.swap_horiz, Colors.blue.shade500),
        Operation('Inventário', Icons.inventory, Colors.blue.shade400),
        Operation('Reabastecimento', Icons.add_box, Colors.blue.shade700),
      ],
    ),
    WMSModule(
      title: 'Separação',
      icon: Icons.shopping_cart,
      color: Colors.orange,
      operations: [
        Operation('Picking', Icons.touch_app, Colors.orange.shade600),
        Operation('Conferência', Icons.checklist, Colors.orange.shade500),
        Operation('Embalagem', Icons.inventory_2, Colors.orange.shade400),
        Operation('Consolidação', Icons.merge, Colors.orange.shade700),
      ],
    ),
    WMSModule(
      title: 'Expedição',
      icon: Icons.local_shipping,
      color: Colors.purple,
      operations: [
        Operation('Romaneio', Icons.list_alt, Colors.purple.shade600),
        Operation('Carregamento', Icons.fork_left, Colors.purple.shade500),
        Operation('Conferência Final', Icons.done_all, Colors.purple.shade400),
        Operation('Liberação', Icons.check_circle, Colors.purple.shade700),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        final isLargeTablet = constraints.maxWidth > 900;

        if (isTablet) {
          return _buildTabletLayout(isLargeTablet);
        } else {
          return _buildMobileLayout();
        }
      },
    );
  }

  // Layout para Tablets
  Widget _buildTabletLayout(bool isLargeTablet) {
    return Scaffold(
      body: Row(
        children: [
          // Navigation Rail para tablets
          NavigationRail(
            extended: isLargeTablet,
            backgroundColor: Theme.of(context).colorScheme.surface,
            selectedIndex: _selectedModuleIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedModuleIndex = index;
              });
            },
            destinations: modules.map((module) {
              return NavigationRailDestination(
                icon: Icon(module.icon),
                label: Text(module.title),
              );
            }).toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // Conteúdo principal
          Expanded(
            child: _buildModuleContent(modules[_selectedModuleIndex], true),
          ),
        ],
      ),
    );
  }

  // Layout para Mobile
  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: Text(modules[_selectedModuleIndex].title),
        centerTitle: true,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // Menu drawer implementation
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: _buildModuleContent(modules[_selectedModuleIndex], false),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedModuleIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedModuleIndex = index;
          });
        },
        destinations: modules.map((module) {
          return NavigationDestination(
            icon: Icon(module.icon),
            label: module.title,
          );
        }).toList(),
      ),
    );
  }

  // Conteúdo do módulo selecionado
  Widget _buildModuleContent(WMSModule module, bool isTablet) {
    return Scaffold(
      appBar: isTablet
          ? AppBar(
              title: Text(module.title),
              centerTitle: false,
              elevation: 0,
              backgroundColor: Colors.transparent,
              foregroundColor: Theme.of(context).colorScheme.onBackground,
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {},
                ),
                const SizedBox(width: 8),
              ],
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com estatísticas
            _buildStatsHeader(module),
            const SizedBox(height: 24),

            // Título da seção
            Text(
              'Operações',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Grid de operações
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isTablet ? 3 : 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isTablet ? 1.5 : 1.2,
                ),
                itemCount: module.operations.length,
                itemBuilder: (context, index) {
                  return _buildOperationCard(module.operations[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Cards de estatísticas do módulo
  Widget _buildStatsHeader(WMSModule module) {
    return Container(
      height: 80,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildStatCard('Pendentes', '42', Colors.orange),
          const SizedBox(width: 12),
          _buildStatCard('Em Processo', '18', Colors.blue),
          const SizedBox(width: 12),
          _buildStatCard('Concluídos', '156', Colors.green),
          const SizedBox(width: 12),
          _buildStatCard('Urgentes', '3', Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              //color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Card de operação
  Widget _buildOperationCard(Operation operation) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          // Navegar para a operação específica
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Abrindo ${operation.name}'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: operation.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  operation.icon,
                  size: 32,
                  color: operation.color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                operation.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Ativo',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Modelo de dados
class WMSModule {
  final String title;
  final IconData icon;
  final Color color;
  final List<Operation> operations;

  WMSModule({
    required this.title,
    required this.icon,
    required this.color,
    required this.operations,
  });
}

class Operation {
  final String name;
  final IconData icon;
  final Color color;

  Operation(this.name, this.icon, this.color);
}
