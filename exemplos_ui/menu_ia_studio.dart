import 'package:flutter/material.dart';

void main() {
  runApp(const WmsApp());
}

class WmsApp extends StatelessWidget {
  const WmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simulador WMS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const OperationalMenuScreen(),
    );
  }
}

class OperationalMenuScreen extends StatelessWidget {
  const OperationalMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lista de módulos operacionais
    final List<Map<String, dynamic>> operationalModules = [
      {'icon': Icons.inventory_2_outlined, 'title': 'Recebimento'},
      {'icon': Icons.warehouse_outlined, 'title': 'Endereçamento'},
      {'icon': Icons.shopping_cart_checkout_outlined, 'title': 'Separação'},
      {'icon': Icons.sync_alt_outlined, 'title': 'Transferência'},
      {'icon': Icons.checklist_rtl_outlined, 'title': 'Inventário'},
      {'icon': Icons.local_shipping_outlined, 'title': 'Expedição'},
      {'icon': Icons.undo_outlined, 'title': 'Devolução'},
      {'icon': Icons.settings_outlined, 'title': 'Configurações'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Operacional'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 colunas
            crossAxisSpacing: 10, // Espaçamento horizontal
            mainAxisSpacing: 10, // Espaçamento vertical
            childAspectRatio: 1.2, // Proporção dos cards
          ),
          itemCount: operationalModules.length,
          itemBuilder: (context, index) {
            final module = operationalModules[index];
            return InkWell(
              onTap: () {
                // Simula a navegação para a tela do módulo
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Navegando para ${module['title']}...'),
                    duration: const Duration(seconds: 1),
                  ),
                );
                // Em um app real, use:
                // Navigator.push(context, MaterialPageRoute(builder: (context) => SuaTelaDeModulo()));
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      module['icon'],
                      size: 50,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 15),
                    Text(
                      module['title'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
