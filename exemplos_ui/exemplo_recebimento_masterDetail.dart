import 'package:flutter/material.dart';

void main() {
  runApp(const WMSApp());
}

// --- Modelo de Dados Mockado ---
class MockDocumento {
  final String numero;
  final String fornecedor;
  final DateTime data;
  final List<MockItem> itens;

  MockDocumento({
    required this.numero,
    required this.fornecedor,
    required this.data,
    required this.itens,
  });
}

class MockItem {
  final String sku;
  final String descricao;
  final int quantidadeEsperada;

  MockItem({
    required this.sku,
    required this.descricao,
    required this.quantidadeEsperada,
  });
}

// --- Dados Mockados ---
final List<MockDocumento> mockDocumentos = List.generate(
  20,
  (i) => MockDocumento(
    numero: (12345 + i).toString(),
    fornecedor: 'FORNECEDOR ${(i % 5) + 1} SA',
    data: DateTime.now().subtract(Duration(days: i)),
    itens: List.generate(
      5 + i,
      (itemIndex) => MockItem(
        sku: 'SKU-${(100 + itemIndex * (i + 1))}',
        descricao: 'Produto Exemplo ${itemIndex + 1}',
        quantidadeEsperada: (itemIndex + 1) * 10,
      ),
    ),
  ),
);

// --- App Principal ---
class WMSApp extends StatelessWidget {
  const WMSApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recebimento WMS (Híbrido)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: RecebimentoMasterScreen(),
    );
  }
}

// --- Tela Principal (Master) ---
class RecebimentoMasterScreen extends StatefulWidget {
  const RecebimentoMasterScreen({Key? key}) : super(key: key);

  @override
  State<RecebimentoMasterScreen> createState() =>
      _RecebimentoMasterScreenState();
}

class _RecebimentoMasterScreenState extends State<RecebimentoMasterScreen> {
  MockDocumento? _selectedDocumento;

  @override
  void initState() {
    super.initState();
    if (mockDocumentos.isNotEmpty) {
      _selectedDocumento = mockDocumentos.first;
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
      appBar: AppBar(title: const Text('Documentos para Receber')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bool isTablet = constraints.maxWidth > 700;

          if (isTablet) {
            return Row(
              children: [
                SizedBox(
                  width: 320,
                  child: DocumentoListPanel(
                    documentos: mockDocumentos,
                    selectedDocumento: _selectedDocumento,
                    onSelected: _onDocumentoSelected,
                  ),
                ),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(
                  child: DocumentoDetailPanel(
                    key: ValueKey(
                      _selectedDocumento?.numero,
                    ), // Garante que o widget reconstrua ao trocar de doc
                    documento: _selectedDocumento,
                  ),
                ),
              ],
            );
          } else {
            return DocumentoListPanel(
              documentos: mockDocumentos,
              onSelected: (doc) {
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

// --- Widgets Componentizados ---

// Painel da Lista (Master)
class DocumentoListPanel extends StatelessWidget {
  final List<MockDocumento> documentos;
  final MockDocumento? selectedDocumento;
  final ValueChanged<MockDocumento> onSelected;

  const DocumentoListPanel({
    Key? key,
    required this.documentos,
    this.selectedDocumento,
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
          onTap: () => onSelected(doc),
          selected: isSelected,
          selectedTileColor: Colors.indigo.withOpacity(0.1),
        );
      },
    );
  }
}

// Painel de Detalhes (Somente Leitura)
class DocumentoDetailPanel extends StatelessWidget {
  final MockDocumento? documento;

  const DocumentoDetailPanel({Key? key, this.documento}) : super(key: key);

  void _navigateToConferencia(BuildContext context, MockDocumento doc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConferenciaScreen(documento: doc),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (documento == null) {
      return const Center(child: Text('Selecione um documento'));
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
          Text('Fornecedor: ${documento!.fornecedor}'),
          Text(
            'Emissão: ${documento!.data.day}/${documento!.data.month}/${documento!.data.year}',
          ),
          Text('Total de Itens: ${documento!.itens.length}'),
          const Spacer(), // Empurra o botão para baixo
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.playlist_add_check),
              label: const Text('Iniciar Conferência'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: () => _navigateToConferencia(context, documento!),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

// Tela de Detalhes para Celular
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

// --- TELA DE TRABALHO (CONFERÊNCIA) ---
class ConferenciaScreen extends StatefulWidget {
  final MockDocumento documento;
  const ConferenciaScreen({Key? key, required this.documento})
    : super(key: key);

  @override
  State<ConferenciaScreen> createState() => _ConferenciaScreenState();
}

class _ConferenciaScreenState extends State<ConferenciaScreen> {
  // Mapa para guardar o estado de "conferido" de cada item
  late Map<String, bool> _conferenciaState;

  @override
  void initState() {
    super.initState();
    // Inicializa o estado de conferência (todos como 'false')
    _conferenciaState = {
      for (var item in widget.documento.itens) item.sku: false,
    };
  }

  void _toggleItemConferido(String sku) {
    setState(() {
      _conferenciaState[sku] = !_conferenciaState[sku]!;
    });
  }

  void _finalizarConferencia() {
    // Lógica para finalizar
    final totalConferido = _conferenciaState.values
        .where((conferido) => conferido)
        .length;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Conferência Finalizada! $totalConferido de ${widget.documento.itens.length} itens conferidos.',
        ),
      ),
    );
    Navigator.pop(context); // Volta para a tela anterior
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conferência NF: ${widget.documento.numero}'),
      ),
      body: ListView.builder(
        itemCount: widget.documento.itens.length,
        itemBuilder: (context, index) {
          final item = widget.documento.itens[index];
          final isConferido = _conferenciaState[item.sku] ?? false;

          return Card(
            color: isConferido ? Colors.green[50] : null,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: CircleAvatar(child: Text('${item.quantidadeEsperada}')),
              title: Text(item.descricao),
              subtitle: Text('SKU: ${item.sku}'),
              trailing: Checkbox(
                value: isConferido,
                onChanged: (value) => _toggleItemConferido(item.sku),
              ),
              onTap: () => _toggleItemConferido(item.sku),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: _finalizarConferencia,
          child: const Text(
            'Finalizar Conferência',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
