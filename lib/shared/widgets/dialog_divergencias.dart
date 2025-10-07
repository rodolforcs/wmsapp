import 'package:flutter/material.dart';

class DialogDivergencias extends StatelessWidget {
  final dynamic documento;

  const DialogDivergencias({super.key, required this.documento});

  @override
  Widget build(BuildContext context) {
    // Lista de divergências mockada - ajuste conforme seu modelo de dados
    final List<Map<String, dynamic>> divergencias = _getDivergencias();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Divergências Encontradas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Documento: ${documento?.numero ?? "N/A"}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Lista de divergências
            Expanded(
              child: divergencias.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Nenhuma divergência encontrada',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: divergencias.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final divergencia = divergencias[index];
                        return _buildDivergenciaItem(divergencia);
                      },
                    ),
            ),

            // Footer com ações
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Fechar'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Implementar ação de resolver divergências
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Resolver'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivergenciaItem(Map<String, dynamic> divergencia) {
    return Card(
      elevation: 0,
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getSeverityColor(divergencia['severity']),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    divergencia['tipo'] ?? 'Divergência',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Item: ${divergencia['item'] ?? "-"}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              divergencia['descricao'] ?? '',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildInfoChip(
                  'Esperado',
                  divergencia['esperado']?.toString() ?? '-',
                  Colors.green,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  'Encontrado',
                  divergencia['encontrado']?.toString() ?? '-',
                  Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(String? severity) {
    switch (severity?.toLowerCase()) {
      case 'alta':
        return Colors.red.shade700;
      case 'media':
        return Colors.orange.shade700;
      case 'baixa':
        return Colors.yellow.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  List<Map<String, dynamic>> _getDivergencias() {
    // Exemplo de divergências - ajuste conforme sua estrutura de dados
    // Você deve pegar isso do documento.divergencias ou similar

    if (documento == null) return [];

    // Tente acessar as divergências do documento
    // Adapte conforme a estrutura real do seu modelo
    try {
      if (documento.divergencias != null) {
        return List<Map<String, dynamic>>.from(documento.divergencias);
      }
    } catch (e) {
      // Se der erro, retorna lista vazia ou exemplo
    }

    // Dados de exemplo para visualização
    return [
      {
        'tipo': 'Quantidade',
        'severity': 'alta',
        'item': '001',
        'descricao': 'Quantidade divergente do produto X',
        'esperado': 100,
        'encontrado': 95,
      },
      {
        'tipo': 'Localização',
        'severity': 'media',
        'item': '002',
        'descricao': 'Produto em endereço diferente do esperado',
        'esperado': 'A-01-01',
        'encontrado': 'A-01-02',
      },
      {
        'tipo': 'Validade',
        'severity': 'baixa',
        'item': '003',
        'descricao': 'Lote com validade próxima ao vencimento',
        'esperado': '2025-12-31',
        'encontrado': '2025-11-15',
      },
    ];
  }
}
