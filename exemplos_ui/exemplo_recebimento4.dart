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
        dividerTheme: const DividerThemeData(color: Colors.transparent),
      ),
      home: const HomeScreen(),
    );
  }
}

// Models
class Lote {
  final int id;
  final String numero;
  final int quantidade;
  int conferido;

  Lote({
    required this.id,
    required this.numero,
    required this.quantidade,
    this.conferido = 0,
  });
}

class ItemNota {
  final int id;
  final String codigo;
  final String descricao;
  final int quantidade;
  int conferido;
  final List<Lote>? lotes;

  ItemNota({
    required this.id,
    required this.codigo,
    required this.descricao,
    required this.quantidade,
    this.conferido = 0,
    this.lotes,
  });
}

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
          descricao: 'Parafuso M6x20 (com 15 lotes)',
          quantidade: 750,
          lotes: List.generate(15, (index) {
            final loteNumero = 101 + index;
            return Lote(
              id: loteNumero,
              numero: 'LOTE-A${loteNumero}',
              quantidade: 50,
            );
          }),
        ),
        ItemNota(
          id: 2,
          codigo: 'PROD002',
          descricao: 'Porca M6 (sem lote)',
          quantidade: 100,
        ),
        ItemNota(
          id: 3,
          codigo: 'PROD003',
          descricao: 'Arruela Lisa M6 (sem lote)',
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isTablet = MediaQuery.of(context).size.width > 768;
      if (isTablet && notasFiscais.isNotEmpty) {
        setState(() {
          notaSelecionada = notasFiscais.first;
        });
      }
    });
  }

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

    if (isTablet) {
      return Scaffold(
        body: Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: _buildListaNotas(isTablet: true),
            ),
            const VerticalDivider(width: 1, color: Colors.black12),
            Expanded(
              child: notaSelecionada != null
                  ? _buildTelaConferencia(isTablet: true)
                  : const Center(
                      child: Text('Selecione uma nota para começar'),
                    ),
            ),
          ],
        ),
      );
    }

    return notaSelecionada == null
        ? _buildListaNotas(isTablet: false)
        : _buildTelaConferencia(isTablet: false);
  }

  Widget _buildListaNotas({required bool isTablet}) {
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
                    'Notas Pendentes',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                    onChanged: (value) => setState(() => searchTerm = value),
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
                        isSelected:
                            isTablet &&
                            notaSelecionada?.id == notasFiltradas[index].id,
                        onTap: () => _selecionarNota(notasFiltradas[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTelaConferencia({required bool isTablet}) {
    final nota = notaSelecionada!;
    final todosConferidos = nota.itens.every((item) {
      if (item.lotes != null && item.lotes!.isNotEmpty) {
        return item.lotes!.every((lote) => lote.conferido > 0);
      }
      return item.conferido > 0;
    });

    // Verifica se há divergências em qualquer item
    final temDivergencia = nota.itens.any((item) {
      final divergenciaEsperadoVsRecebido =
          item.conferido > 0 && item.conferido != item.quantidade;

      bool divergenciaRecebidoVsLotes = false;
      if (item.lotes != null && item.lotes!.isNotEmpty) {
        final somaConferida = item.lotes!.fold<int>(
          0,
          (sum, lote) => sum + lote.conferido,
        );
        if (item.conferido > 0 || somaConferida > 0) {
          divergenciaRecebidoVsLotes = item.conferido != somaConferida;
        }
      }

      return divergenciaEsperadoVsRecebido || divergenciaRecebidoVsLotes;
    });

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
                  if (!isTablet)
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
                  if (!isTablet) const SizedBox(height: 16),
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
                  return ItemConferenciaCard(
                    key: ValueKey(item.id),
                    item: item,
                    onQuantidadeChanged: (valor) {
                      setState(() => item.conferido = valor);
                    },
                    onLoteQuantidadeChanged: (loteId, valor) {
                      setState(() {
                        final lote = item.lotes?.firstWhere(
                          (l) => l.id == loteId,
                        );
                        if (lote != null) {
                          lote.conferido = valor;
                          item.conferido = item.lotes!.fold(
                            0,
                            (sum, l) => sum + l.conferido,
                          );
                        }
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
                  if (!isTablet)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _voltarParaLista,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                  if (!isTablet) const SizedBox(width: 12),
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
                              if (!isTablet) _voltarParaLista();
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
  final bool isSelected;
  final VoidCallback onTap;

  const NotaFiscalCard({
    super.key,
    required this.nota,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isSelected ? Colors.blue[50] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? const BorderSide(color: Colors.blue, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
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
                    Text(nota.fornecedor, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              Text(
                '${nota.quantidadeItens} itens',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(width: 16),
              StatusBadge(status: nota.status),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
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
  final Function(int) onQuantidadeChanged;
  final Function(int, int) onLoteQuantidadeChanged;

  const ItemConferenciaCard({
    super.key,
    required this.item,
    required this.onQuantidadeChanged,
    required this.onLoteQuantidadeChanged,
  });

  @override
  State<ItemConferenciaCard> createState() => _ItemConferenciaCardState();
}

class _ItemConferenciaCardState extends State<ItemConferenciaCard> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _validationExpectedVsReceived = false;
  bool _validationReceivedVsLots = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.item.conferido > 0 ? widget.item.conferido.toString() : '',
    );
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    _updateValidationStates();
  }

  @override
  void didUpdateWidget(covariant ItemConferenciaCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.item.conferido != oldWidget.item.conferido) {
      _updateValidationStates();
      _controller.text = widget.item.conferido > 0
          ? widget.item.conferido.toString()
          : '';
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _updateValidationStates() {
    bool newValidationExpectedVsReceived = false;
    bool newValidationReceivedVsLots = false;

    if (widget.item.conferido > 0) {
      newValidationExpectedVsReceived =
          widget.item.conferido != widget.item.quantidade;
    }

    if (widget.item.lotes != null && widget.item.lotes!.isNotEmpty) {
      final somaConferida = widget.item.lotes!.fold<int>(
        0,
        (sum, lote) => sum + lote.conferido,
      );
      if (widget.item.conferido > 0 || somaConferida > 0) {
        newValidationReceivedVsLots = widget.item.conferido != somaConferida;
      }
    }

    if (mounted &&
        (_validationExpectedVsReceived != newValidationExpectedVsReceived ||
            _validationReceivedVsLots != newValidationReceivedVsLots)) {
      setState(() {
        _validationExpectedVsReceived = newValidationExpectedVsReceived;
        _validationReceivedVsLots = newValidationReceivedVsLots;
      });
    }
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      final value = _controller.text.isEmpty ? 0 : int.parse(_controller.text);
      widget.onQuantidadeChanged(value);
      _updateValidationStates();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasLotes =
        widget.item.lotes != null && widget.item.lotes!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: (_validationExpectedVsReceived || _validationReceivedVsLots)
              ? Colors.orange
              : Colors.transparent,
          width: (_validationExpectedVsReceived || _validationReceivedVsLots)
              ? 2
              : 1,
        ),
      ),
      child: _buildCardContent(context, hasLotes),
    );
  }

  Widget _buildStatusIcon() {
    final bool hasValidationErrors =
        _validationExpectedVsReceived || _validationReceivedVsLots;
    final bool conferidoOk = !hasValidationErrors && widget.item.conferido > 0;

    if (conferidoOk) {
      return const Icon(Icons.check_circle, color: Colors.green, size: 28);
    } else if (hasValidationErrors) {
      return const Icon(Icons.warning_amber, color: Colors.orange, size: 28);
    }
    return const SizedBox.shrink();
  }

  Widget _buildCardContent(BuildContext context, bool hasLotes) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
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
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    if (_validationExpectedVsReceived)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Divergência: Qtd. Recebida (${widget.item.conferido}) diferente da Esperada (${widget.item.quantidade})',
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (_validationReceivedVsLots)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Divergência: Qtd. Recebida (${widget.item.conferido}) diferente da Soma dos Lotes',
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              _buildStatusIcon(),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            children: [
              const Text(
                'Qtd. conferida:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  focusNode: _focusNode,
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onEditingComplete: () => FocusScope.of(context).nextFocus(),
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
                ),
              ),
            ],
          ),
        ),
        if (hasLotes)
          ExpansionTile(
            title: Row(
              children: [
                const Text(
                  'Lotes',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                if (_validationReceivedVsLots || _validationExpectedVsReceived)
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 20,
                  ),
              ],
            ),
            subtitle: Text(
              'Total conferido: ${widget.item.conferido} de ${widget.item.quantidade}',
            ),
            children: widget.item.lotes!.map((lote) {
              return LoteConferenciaTile(
                key: ValueKey(lote.id),
                lote: lote,
                onQuantidadeChanged: (valor) {
                  widget.onLoteQuantidadeChanged(lote.id, valor);
                },
                onFocusNext: () => FocusScope.of(context).nextFocus(),
              );
            }).toList(),
          ),
      ],
    );
  }
}

class LoteConferenciaTile extends StatefulWidget {
  final Lote lote;
  final Function(int) onQuantidadeChanged;
  final VoidCallback onFocusNext;

  const LoteConferenciaTile({
    super.key,
    required this.lote,
    required this.onQuantidadeChanged,
    required this.onFocusNext,
  });

  @override
  State<LoteConferenciaTile> createState() => _LoteConferenciaTileState();
}

class _LoteConferenciaTileState extends State<LoteConferenciaTile> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _loteDivergente = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.lote.conferido > 0 ? widget.lote.conferido.toString() : '',
    );
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);

    _loteDivergente =
        widget.lote.conferido > 0 &&
        widget.lote.conferido != widget.lote.quantidade;
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      final value = _controller.text.isEmpty ? 0 : int.parse(_controller.text);
      widget.onQuantidadeChanged(value);
      setState(() {
        _loteDivergente = value > 0 && value != widget.lote.quantidade;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: _loteDivergente ? Colors.orange[50] : Colors.grey[100],
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.lote.numero,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Esperado: ${widget.lote.quantidade}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: TextField(
              focusNode: _focusNode,
              controller: _controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onEditingComplete: widget.onFocusNext,
              decoration: const InputDecoration(
                hintText: 'Qtd',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                isDense: true,
              ),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
