import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const WMSApp());
}

// --- Modelo de Dados Mockado ---
class MockDocumento {
  final String numero;
  final String serie;
  final String fornecedor;
  final DateTime data;
  final String status;

  MockDocumento({
    required this.numero,
    required this.serie,
    required this.fornecedor,
    required this.data,
    required this.status,
  });
}

class WMSApp extends StatelessWidget {
  const WMSApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recebimento WMS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[200],
      ),
      home: const RecebimentoScreen(),
    );
  }
}

class RecebimentoScreen extends StatefulWidget {
  const RecebimentoScreen({Key? key}) : super(key: key);

  @override
  State<RecebimentoScreen> createState() => _RecebimentoScreenState();
}

class _RecebimentoScreenState extends State<RecebimentoScreen> {
  bool _isLoading = true;
  List<MockDocumento> _documentos = [];

  @override
  void initState() {
    super.initState();
    _fetchDocumentos(); // Busca inicial
  }

  // Simula uma chamada de API para buscar os documentos
  Future<void> _fetchDocumentos({String? filtro}) async {
    setState(() {
      _isLoading = true;
    });
    // Simula a latência da rede
    await Future.delayed(const Duration(seconds: 2));

    // Cria dados mockados
    final List<MockDocumento> allDocs = [
      MockDocumento(
        numero: '12345',
        serie: '1',
        fornecedor: 'ACME LTDA',
        data: DateTime.now(),
        status: 'Pendente',
      ),
      MockDocumento(
        numero: '67890',
        serie: 'A',
        fornecedor: 'FORNECEDOR GERAL SA',
        data: DateTime.now().subtract(const Duration(days: 1)),
        status: 'Em Conferência',
      ),
      MockDocumento(
        numero: '11223',
        serie: '1',
        fornecedor: 'COMPONENTES XYZ',
        data: DateTime.now().subtract(const Duration(days: 2)),
        status: 'Pendente',
      ),
      MockDocumento(
        numero: '99887',
        serie: 'B',
        fornecedor: 'ACME LTDA',
        data: DateTime.now().subtract(const Duration(days: 3)),
        status: 'Pendente',
      ),
    ];

    setState(() {
      if (filtro != null && filtro.isNotEmpty) {
        _documentos = allDocs
            .where(
              (doc) =>
                  doc.numero.contains(filtro) ||
                  doc.fornecedor.toLowerCase().contains(filtro.toLowerCase()),
            )
            .toList();
      } else {
        _documentos = allDocs;
      }
      _isLoading = false;
    });
  }

  // Função para o "Puxar para Atualizar"
  Future<void> _onRefresh() async {
    await _fetchDocumentos();
  }

  // Função para mostrar o BottomSheet de Filtro
  void _showFilterSheet() {
    final filterController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permite que o sheet cresça
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Filtrar Documentos',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: filterController,
                decoration: const InputDecoration(
                  labelText: 'Nº da Nota ou Fornecedor',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  // Simula a chamada de API com filtro
                  _fetchDocumentos(filtro: filterController.text);
                  Navigator.pop(context); // Fecha o BottomSheet
                },
                child: const Text('Aplicar Filtro'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documentos para Receber'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_documentos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Nenhum documento pendente encontrado.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // O RefreshIndicator envolve a lista para habilitar o "puxar para atualizar"
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _documentos.length,
        itemBuilder: (context, index) {
          return _buildDocumentoCard(_documentos[index]);
        },
      ),
    );
  }

  Widget _buildDocumentoCard(MockDocumento doc) {
    final statusColor = doc.status == 'Pendente' ? Colors.orange : Colors.blue;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Ação ao clicar: Navegaria para a tela de detalhes da nota
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Abrindo detalhes da nota ${doc.numero}')),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nota Fiscal: ${doc.numero} (Série ${doc.serie})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      doc.status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                doc.fornecedor,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                'Emissão: ${doc.data.day}/${doc.data.month}/${doc.data.year}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
