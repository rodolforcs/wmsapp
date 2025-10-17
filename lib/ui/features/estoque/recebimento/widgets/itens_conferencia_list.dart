// lib/ui/features/estoque/recebimento/widgets/itens_conferencia_list.dart
import 'package:flutter/material.dart';
import 'package:wmsapp/data/models/estoque/recebimento/it_doc_fisico_model.dart';
import 'package:wmsapp/shared/widgets/empty_state_widget.dart';
import 'package:wmsapp/ui/features/estoque/recebimento/widgets/item_conferencia_card.dart';

class ItensConferenciaList extends StatelessWidget {
  final List<ItDocFisicoModel> itens;
  final bool isLoading;
  final bool showEmptyForFilter;
  final void Function(int, double) onQuantidadeChanged;
  final void Function(int, String, double) onRateioQuantidadeChanged;
  final void Function(int, dynamic) onAdicionarRateio;
  final void Function(int, String) onRemoverRateio;

  const ItensConferenciaList({
    super.key,
    required this.itens,
    required this.isLoading,
    this.showEmptyForFilter = false,
    required this.onQuantidadeChanged,
    required this.onRateioQuantidadeChanged,
    required this.onAdicionarRateio,
    required this.onRemoverRateio,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando itens do documento...'),
          ],
        ),
      );
    }

    if (itens.isEmpty && !showEmptyForFilter) {
      return EmptyStateWidget(
        icon: Icons.inventory_2_outlined,
        title: 'Nenhum item encontrado',
        subtitle: 'Este documento não possui itens para conferir',
        iconColor: Colors.grey[400],
      );
    }

    if (itens.isEmpty && showEmptyForFilter) {
      return EmptyStateWidget(
        icon: Icons.check_circle_outline,
        title: 'Todos os itens conferidos!',
        subtitle: 'Parabéns! Você completou a conferência 🎉',
        iconColor: Colors.green[400],
      );
    }

    return FocusTraversalGroup(
      policy: OrderedTraversalPolicy(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: itens.length,
        itemBuilder: (context, index) {
          final item = itens[index];

          return ItemConferenciaCard(
            key: ValueKey(item.nrSequencia),
            item: item,
            onQuantidadeChanged: (qtd) {
              onQuantidadeChanged(item.nrSequencia, qtd);
            },
            onRateioQuantidadeChanged: (chave, qtd) {
              onRateioQuantidadeChanged(item.nrSequencia, chave, qtd);
            },
            onAdicionarRateio: (rateio) {
              onAdicionarRateio(item.nrSequencia, rateio);
            },
            onRemoverRateio: (chave) {
              onRemoverRateio(item.nrSequencia, chave);
            },
          );
        },
      ),
    );
  }
}
