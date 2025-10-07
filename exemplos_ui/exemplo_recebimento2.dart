import 'package:flutter/material.dart';

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
  final int totalItens;
  final List<String> itens;

  MockDocumento({
    required this.numero,
    required this.serie,
    required this.fornecedor,
    required this.data,
    required this.status,
    required this.totalItens,
    required this.itens,
  });
}

class WMSApp extends StatelessWidget {
  const WMSApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recebimento WMS (Master-Detail)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[100],
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
  final List<MockDocumento> _documentos = List.generate(
    20,
    (i) => MockDocumento(
      numero: (12345 + i).toString(),
      serie: 'A',
      fornecedor: 'FORNECEDOR ${(i % 5) + 1} SA',
      data: DateTime.now().subtract(Duration(days: i)),
      status: i % 3 == 0 ? 'Pendente' : 'Em Conferência',
      totalItens: 5 + i,
      itens: List.generate(
        5 + i,
        (itemIndex) => 'SKU-${(100 + itemIndex * (i + 1))}-XYZ',
      ),
    ),
  );

  MockDocumento? _selectedDocumento;

  @override
  void initState() {
    super.initState();
    // Pré-seleciona o primeiro documento se a lista não estiver vazia
    if (_documentos.isNotEmpty) {
      _selectedDocumento = _documentos.first;
    }
  }

  void _onDocumentoSelected(MockDocumento doc) {
    setState(() {
      _selectedDocumento = doc;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recebimento de Documentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              /* Lógica de filtro */
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Ponto de quebra: se a largura for maior que 600, consideramos um tablet.
          final bool isTablet = constraints.maxWidth > 600;

          if (isTablet) {
            // --- LAYOUT TABLET: Master-Detail ---
            return Row(
              children: [
                // Painel Master (Lista)
                SizedBox(
                  width: 300, // Largura fixa para a lista
                  child: DocumentoListPanel(
                    documentos: _documentos,
                    selectedDocumento: _selectedDocumento,
                    onSelected: _onDocumentoSelected,
                  ),
                ),
                const VerticalDivider(width: 1, thickness: 1),
                // Painel Detail (Detalhes)
                Expanded(
                  child: DocumentoDetailPanel(
                    documento: _selectedDocumento,
                  ),
                ),
              ],
            );
          } else {
            // --- LAYOUT CELULAR: Apenas a lista ---
            return DocumentoListPanel(
              documentos: _documentos,
              selectedDocumento: _selectedDocumento,
              onSelected: (doc) {
                // No celular, navegar para uma nova tela para mostrar os detalhes
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(documento: doc),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

// --- WIDGETS SEPARADOS ---

// Painel da Lista (Master)
class DocumentoListPanel extends StatelessWidget {
  final List<MockDocumento> documentos;
  final MockDocumento? selectedDocumento;
  final ValueChanged<MockDocumento> onSelected;

  const DocumentoListPanel({
    Key? key,
    required this.documentos,
    required this.selectedDocumento,
    required this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: documentos.length,
      itemBuilder: (context, index) {
        final doc = documentos[index];
        final isSelected = selectedDocumento?.numero == doc.numero;
        return ListTile(
          title: Text(
            'NF: ${doc.numero}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(doc.fornecedor),
          trailing: Text('${doc.data.day}/${doc.data.month}'),
          onTap: () => onSelected(doc),
          selected: isSelected,
          selectedTileColor: Colors.indigo.withOpacity(0.1),
        );
      },
    );
  }
}

// Painel de Detalhes (Detail)
class DocumentoDetailPanel extends StatelessWidget {
  final MockDocumento? documento;

  const DocumentoDetailPanel({Key? key, this.documento}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (documento == null) {
      return const Center(
        child: Text('Selecione um documento para ver os detalhes'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalhes da NF: ${documento!.numero}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            'Fornecedor: ${documento!.fornecedor}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            'Emissão: ${documento!.data.day}/${documento!.data.month}/${documento!.data.year}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            'Status: ${documento!.status}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            'Total de Itens: ${documento!.totalItens}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Divider(height: 40),
          Text('Itens da Nota', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: documento!.itens.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: Text(documento!.itens[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Tela de Detalhes separada para o layout de celular
class DetailScreen extends StatelessWidget {
  final MockDocumento documento;
  const DetailScreen({Key? key, required this.documento}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalhes da NF ${documento.numero}')),
      body: DocumentoDetailPanel(documento: documento),
    );
  }
}
