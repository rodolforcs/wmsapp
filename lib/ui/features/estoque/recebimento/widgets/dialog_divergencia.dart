import 'package:flutter/material.dart';
import 'package:wmsapp/data/models/estoque/recebimento/docto_fisico_model.dart';

// ============================================================================
// DIALOG DIVERGENCIAS - Dialog para confirmar divergências
// ============================================================================

/// Dialog que mostra as divergências encontradas e pede confirmação
class DialogDivergencias extends StatelessWidget {
  final DoctoFisicoModel documento;

  const DialogDivergencias({
    super.key,
    required this.documento,
  });

  @override
  Widget build(BuildContext context) {
    final itensComDivergencia = documento.itensComDivergencia;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.warning_amber,
            color: Colors.orange[700],
            size: 28,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Divergências Detectadas',
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Foram encontradas divergências em ${itensComDivergencia.length} '
              '${itensComDivergencia.length == 1 ? 'item' : 'itens'}:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Lista de itens com divergência
            ...itensComDivergencia.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.codItem,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(item.descrItem),
                      const SizedBox(height: 4),
                      Text(
                        item.mensagemDivergencia,
                        style: TextStyle(
                          color: Colors.orange[900],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 8),
            const Text(
              'Deseja finalizar mesmo assim? Isso irá gerar uma ocorrência de divergência.',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
      actions: [
        // Botão Cancelar
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),

        // Botão Corrigir
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
            // Usuário volta para corrigir
          },
          child: const Text('Corrigir'),
        ),

        // Botão Finalizar com Divergência
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          child: const Text('Finalizar com Divergência'),
        ),
      ],
    );
  }
}
