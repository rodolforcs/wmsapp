import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Importa a biblioteca de gráficos

void main() {
  runApp(const WMSApp());
}

class WMSApp extends StatelessWidget {
  const WMSApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WMS Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[100],
        fontFamily: 'Roboto', // Uma fonte limpa e legível
      ),
      home: const DashboardMenuScreen(),
    );
  }
}

class DashboardMenuScreen extends StatelessWidget {
  const DashboardMenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dados mockados para os módulos
    final List<Map<String, dynamic>> modules = [
      {'title': 'Estoque', 'icon': Icons.inventory_2, 'color': Colors.blue},
      {
        'title': 'Expedição',
        'icon': Icons.local_shipping,
        'color': Colors.orange,
      },
      {
        'title': 'Produção',
        'icon': Icons.precision_manufacturing,
        'color': Colors.purple,
      },
      {'title': 'Qualidade', 'icon': Icons.high_quality, 'color': Colors.green},
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Painel de Controle WMS',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.black54,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.account_circle_outlined,
              color: Colors.black54,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SEÇÃO DE INDICADORES (KPIs) ---
            const Text(
              'Visão Geral do Armazém',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildKpiCard(
                    'Requisições Abertas',
                    '12',
                    Icons.checklist_rtl,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildKpiCard(
                    'Notas Pendentes',
                    '3',
                    Icons.receipt_long,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- SEÇÃO DO GRÁFICO ---
            const Text(
              'Status das Requisições',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildPieChart(),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- SEÇÃO DOS MÓDULOS (SEU GRIDVIEW) ---
            const Text(
              'Acessar Módulos',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Fixo em 2 para simplicidade no exemplo
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2, // Ajuste para caber o conteúdo
              ),
              itemCount: modules.length,
              itemBuilder: (context, index) {
                return _buildModuleCard(modules[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget para os cards de indicadores (KPIs)
  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para o gráfico de pizza
  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sectionsSpace: 4, // Espaço entre as fatias
        centerSpaceRadius: 40, // Raio do buraco no centro (gráfico de rosca)
        sections: [
          PieChartSectionData(
            color: Colors.blue,
            value: 40,
            title: '40%',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            color: Colors.green,
            value: 30,
            title: '30%',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            color: Colors.amber,
            value: 15,
            title: '15%',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          PieChartSectionData(
            color: Colors.red,
            value: 15,
            title: '15%',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Widget para os cards dos módulos
  Widget _buildModuleCard(Map<String, dynamic> module) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(module['icon'], size: 40, color: module['color']),
            const SizedBox(height: 12),
            Text(
              module['title'],
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
