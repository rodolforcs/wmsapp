import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const WMSApp());
}

class WMSApp extends StatelessWidget {
  const WMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WMS - Recebimento',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// Models
class NotaFiscal {
  final int id;
  final String numero;
  final String fornecedor;
  final String data;
  final int quantidadeItens;
  final double valorTotal;
  final String status;
  List<ItemNota> itens;

  NotaFiscal({
    required this.id,
    required this.numero,
    required this.fornecedor,
    required this.data,
    required this.quantidadeItens,
    required this.valorTotal,
    required this.status,
    required this.itens,
  });
}

class ItemNota {
  final int id;
  final String codigo;
  final String descricao;
  final int quantidade;
  int conferido;

  ItemNota({
    required this.id,
    required this.codigo,
    required this.descricao,
    required this.quantidade,
    this.conferido = 0,
  });
}

// Dados de exemplo
List<NotaFiscal> getNotasFiscaisExemplo() {
  return [
    NotaFiscal(
      id: 1,
      numero: '12345',
      fornecedor: 'Fornecedor ABC Ltda',
      data: '15/09/2025',
      quantidadeItens: 3,
      valorTotal: 5280.00,
      status: 'pendente',
      itens: [
        ItemNota(
          id: 1,
          codigo: 'PROD001',
          descricao: 'Parafuso M6x20',
          quantidade: 100,
        ),
        ItemNota(
          id: 2,
          codigo: 'PROD002',
          descricao: 'Porca M6',
          quantidade: 100,
        ),
        ItemNota(
          id: 3,
          codigo: 'PROD003',
          descricao: 'Arruela Lisa M6',
          quantidade: 200,
        ),
      ],
    ),
    NotaFiscal(
      id: 2,
      numero: '12346',
      fornecedor: 'Fornecedor XYZ S.A.',
      data: '14/09/2025',
      quantidadeItens: 2,
      valorTotal: 3450.00,
      status: 'pendente',
      itens: [
        ItemNota(
          id: 4,
          codigo: 'PROD004',
          descricao: 'Cabo de Rede Cat6',
          quantidade: 50,
        ),
        ItemNota(
          id: 5,
          codigo: 'PROD005',
          descricao: 'Conector RJ45',
          quantidade: 100,
        ),
      ],
    ),
    NotaFiscal(
      id: 3,
      numero: '12347',
      fornecedor: 'Distribuidora Tech',
      data: '13/09/2025',
      quantidadeItens: 2,
      valorTotal: 8920.00,
      status: 'urgente',
      itens: [
        ItemNota(
          id: 6,
          codigo: 'PROD006',
          descricao: 'Mouse USB',
          quantidade: 30,
        ),
        ItemNota(
          id: 7,
          codigo: 'PROD007',
          descricao: 'Teclado USB',
          quantidade: 30,
        ),
      ],
    ),
    NotaFiscal(
      id: 4,
      numero: '12348',
      fornecedor: 'Materiais Industrial',
      data: '12/09/2025',
      quantidadeItens: 1,
      valorTotal: 12500.00,
      status: 'pendente',
      itens: [
        ItemNota(
          id: 8,
          codigo: 'PROD008',
          descricao: 'Lubrificante Industrial 1L',
          quantidade: 24,
        ),
      ],
    ),
    NotaFiscal(
      id: 5,
      numero: '12349',
      fornecedor: 'Embalagens e Suprimentos',
      data: '11/09/2025',
      quantidadeItens: 1,
      valorTotal: 1890.00,
      status: 'pendente',
      itens: [
        ItemNota(
          id: 9,
          codigo: 'PROD009',
          descricao: 'Caixa de Papelão 30x30x30',
          quantidade: 100,
        ),
      ],
    ),
  ];
}

// Tela Principal
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<NotaFiscal> notasFiscais = getNotasFiscaisExemplo();
  NotaFiscal? notaSelecionada;
  String searchTerm = '';

  void _selecionarNota(NotaFiscal nota) {
    setState(() {
      notaSelecionada = nota;
    });
  }

  void _voltarParaLista() {
    setState(() {
      notaSelecionada = null;
    });
  }

  List<NotaFiscal> get notasFiltradas {
    if (searchTerm.isEmpty) return notasFiscais;
    return notasFiscais.where((nota) {
      return nota.numero.contains(searchTerm) ||
          nota.fornecedor.toLowerCase().contains(searchTerm.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 768;

    // Layout Master-Detail para Tablet
    if (isTablet && notaSelecionada != null) {
      return Scaffold(
        body: Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: _buildListaNotas(),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: _buildTelaConferencia(),
            ),
          ],
        ),
      );
    }

    // Layout Mobile
    return notaSelecionada == null
        ? _buildListaNotas()
        : _buildTelaConferencia();
  }

  Widget _buildListaNotas() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notas Pendentes de Conferência',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar por número ou fornecedor...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchTerm = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: notasFiltradas.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhuma nota fiscal encontrada',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notasFiltradas.length,
                    itemBuilder: (context, index) {
                      return NotaFiscalCard(
                        nota: notasFiltradas[index],
                        onTap: () => _selecionarNota(notasFiltradas[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTelaConferencia() {
    final nota = notaSelecionada!;
    final todosConferidos = nota.itens.every((item) => item.conferido > 0);
    final temDivergencia = nota.itens.any(
      (item) => item.conferido != item.quantidade && item.conferido > 0,
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: _voltarParaLista,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Voltar',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Conferência NF ${nota.numero}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              nota.fornecedor,
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              nota.data,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      StatusBadge(status: nota.status),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (temDivergencia)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      border: Border.all(color: Colors.orange[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber, color: Colors.orange[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Atenção: Divergência detectada',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[900],
                                ),
                              ),
                              Text(
                                'Alguns itens têm quantidade diferente do esperado.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ...nota.itens.map((item) {
                  final divergente =
                      item.conferido > 0 && item.conferido != item.quantidade;
                  return ItemConferenciaCard(
                    item: item,
                    divergente: divergente,
                    onQuantidadeChanged: (valor) {
                      setState(() {
                        item.conferido = valor;
                      });
                    },
                  );
                }),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _voltarParaLista,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: todosConferidos
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Conferência finalizada com sucesso!',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              _voltarParaLista();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        todosConferidos
                            ? 'Finalizar Conferência'
                            : 'Confira todos os itens',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Componentes
class NotaFiscalCard extends StatelessWidget {
  final NotaFiscal nota;
  final VoidCallback onTap;

  const NotaFiscalCard({
    super.key,
    required this.nota,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 768;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isTablet ? _buildTabletLayout() : _buildMobileLayout(),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.inventory_2, color: Colors.blue, size: 24),
                const SizedBox(width: 8),
                Text(
                  'NF ${nota.numero}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            StatusBadge(status: nota.status),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          nota.fornecedor,
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${nota.data} • ${nota.quantidadeItens} itens',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            Text(
              'R\$ ${nota.valorTotal.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        const Icon(Icons.inventory_2, color: Colors.blue, size: 32),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NF ${nota.numero}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                nota.fornecedor,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        Text(
          '${nota.quantidadeItens} itens',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(width: 16),
        Text(
          'R\$ ${nota.valorTotal.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(width: 16),
        StatusBadge(status: nota.status),
        const SizedBox(width: 8),
        const Icon(Icons.chevron_right, color: Colors.grey),
      ],
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case 'urgente':
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[700]!;
        label = 'Urgente';
        break;
      case 'conferido':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[700]!;
        label = 'Conferido';
        break;
      default:
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[700]!;
        label = 'Pendente';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class ItemConferenciaCard extends StatefulWidget {
  final ItemNota item;
  final bool divergente;
  final Function(int) onQuantidadeChanged;

  const ItemConferenciaCard({
    super.key,
    required this.item,
    required this.divergente,
    required this.onQuantidadeChanged,
  });

  @override
  State<ItemConferenciaCard> createState() => _ItemConferenciaCardState();
}

class _ItemConferenciaCardState extends State<ItemConferenciaCard> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.item.conferido > 0 ? widget.item.conferido.toString() : '',
    );
  }

  @override
  void didUpdateWidget(ItemConferenciaCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Atualiza o controller apenas se o valor mudou externamente
    if (oldWidget.item.conferido != widget.item.conferido) {
      final cursorPosition = _controller.selection.baseOffset;
      _controller.text = widget.item.conferido > 0
          ? widget.item.conferido.toString()
          : '';
      // Mantém o cursor na mesma posição se possível
      if (cursorPosition <= _controller.text.length) {
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: cursorPosition),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conferidoOk =
        widget.item.conferido == widget.item.quantidade &&
        widget.item.conferido > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: widget.divergente ? Colors.orange : Colors.grey[300]!,
          width: widget.divergente ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.codigo,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.item.descricao,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Quantidade esperada: ${widget.item.quantidade}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (conferidoOk)
                  const Icon(Icons.check_circle, color: Colors.green, size: 28)
                else if (widget.divergente)
                  const Icon(
                    Icons.warning_amber,
                    color: Colors.orange,
                    size: 28,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  'Quantidade conferida:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: 'Digite aqui',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    onChanged: (value) {
                      widget.onQuantidadeChanged(
                        value.isEmpty ? 0 : int.parse(value),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
