import 'package:flutter/material.dart';

class EstoqueDashboardView extends StatelessWidget {
  const EstoqueDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_rounded, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Dashboard do Estoque',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          Text(
            'Gráficos e KPIs em desenvolvimento.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
