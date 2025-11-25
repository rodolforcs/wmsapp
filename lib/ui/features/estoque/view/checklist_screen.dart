// lib/ui/features/estoque/recebimento/view/checklist_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wmsapp/ui/features/estoque/recebimento/viewmodel/checklist_view_model.dart';
import 'package:wmsapp/ui/features/estoque/recebimento/widgets/checklist_app_bar.dart';
import 'package:wmsapp/ui/features/estoque/recebimento/widgets/checklist_item_tile.dart';
import 'package:wmsapp/ui/features/estoque/recebimento/widgets/checklist_footer.dart';

class ChecklistScreen extends StatefulWidget {
  final String codEstabel;
  final int codEmitente;
  final String nroDocto;
  final String serieDocto;

  const ChecklistScreen({
    super.key,
    required this.codEstabel,
    required this.codEmitente,
    required this.nroDocto,
    required this.serieDocto,
  });

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  bool _expanded = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarChecklist();
    });
  }

  void _carregarChecklist() {
    final viewModel = context.read<ChecklistViewModel>();
    viewModel.carregarChecklist(
      codEstabel: widget.codEstabel,
      codEmitente: widget.codEmitente,
      nroDocto: widget.nroDocto,
      serieDocto: widget.serieDocto,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ChecklistAppBar(
        nroDocto: widget.nroDocto,
        serieDocto: widget.serieDocto,
        codEmitente: widget.codEmitente,
        onInfoPressed: () => _mostrarInformacoes(context),
      ),
      body: Consumer<ChecklistViewModel>(
        builder: (context, viewModel, child) {
          // LOADING
          if (viewModel.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Carregando checklist...'),
                ],
              ),
            );
          }

          // ERRO
          if (viewModel.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erro ao carregar checklist',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      viewModel.errorMessage ?? 'Erro desconhecido',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _carregarChecklist,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar Novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          // SEM CHECKLIST
          if (!viewModel.hasChecklist) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.checklist, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum checklist disponível',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            );
          }

          const SizedBox(height: 8);

          // CHECKLIST CARREGADO
          return _buildChecklistContent(context, viewModel);
        },
      ),
    );
  }

  Widget _buildChecklistContent(
    BuildContext context,
    ChecklistViewModel viewModel,
  ) {
    final checklist = viewModel.checklist!;

    return Column(
      children: [
        // ================================================================
        // BARRA DE PROGRESSO (sem padding lateral)
        // ================================================================
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    // ✅ USA OS GETTERS CORRETOS QUE EXCLUEM INFORMATIVOS
                    '${checklist.itensRespondidos} de ${checklist.totalItens} itens',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    // ✅ USA O GETTER CALCULADO QUE EXCLUI INFORMATIVOS
                    '${checklist.percentualConclusaoCalculado.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getProgressColor(
                        checklist.percentualConclusaoCalculado,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  // ✅ USA O GETTER CALCULADO QUE EXCLUI INFORMATIVOS
                  value: checklist.percentualConclusaoCalculado / 100,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getProgressColor(checklist.percentualConclusaoCalculado),
                  ),
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // ================================================================
        // LISTA DE CATEGORIAS (sem padding lateral no ListView)
        // ================================================================
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero, // ✅ Remove padding padrão
            itemCount: checklist.categorias.length,
            itemBuilder: (context, index) {
              final categoria = checklist.categorias[index];

              return ExpansionTile(
                key: ValueKey('cat-${categoria.sequenciaCat}'),
                initiallyExpanded: _expanded,
                onExpansionChanged: (expanded) {
                  setState(() {
                    _expanded = expanded;
                  });
                },

                // ✅ Remove padding lateral
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                childrenPadding: EdgeInsets.zero, // ✅ Remove padding dos filhos
                // ✅ Ícone da categoria
                leading: Icon(
                  _mapIcon(categoria.icone),
                  color: _getCategoriaColor(categoria.percentualConclusao),
                  size: 28,
                ),

                // Título
                title: Text(
                  categoria.desCategoria,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                // ✅ Subtítulo - USA OS GETTERS CORRETOS
                subtitle: Text(
                  '${categoria.itensRespondidos}/${categoria.totalItens} itens',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),

                // ✅ Customizar trailing (percentual + ícone expand)
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ✅ Badge de progresso - USA O GETTER CORRETO
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoriaColor(
                          categoria.percentualConclusao,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getCategoriaColor(
                            categoria.percentualConclusao,
                          ),
                        ),
                      ),
                      child: Text(
                        '${categoria.percentualConclusao.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getCategoriaColor(
                            categoria.percentualConclusao,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                    ),
                  ],
                ),

                // ✅ Customizar ícone de expand/collapse
                collapsedShape: const Border(),
                shape: const Border(),
                iconColor: Colors.grey.shade700,
                collapsedIconColor: Colors.grey.shade700,

                // ITENS DA CATEGORIA
                children: categoria.itens.map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ), // ✅ Padding só nos itens
                    child: ChecklistItemTile(
                      key: ValueKey(
                        'item-${categoria.sequenciaCat}-${item.sequenciaItem}',
                      ),
                      item: item,
                      codChecklist: checklist.codChecklist,
                      sequenciaCat: categoria.sequenciaCat,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),

        // ================================================================
        // FOOTER
        // ================================================================
        ChecklistFooter(
          podeFinalizar: viewModel.podeFinalizar,
          todosItensRespondidos: viewModel.todosItensRespondidos,
          isFinalizing: viewModel.isFinalizing,
          onSalvarRascunho: () => Navigator.of(context).pop(),
          onFinalizar: () => _confirmarFinalizacao(context, viewModel),
        ),
      ],
    );
  }

  // ==========================================================================
  // MAPEAR ÍCONES
  // ==========================================================================

  IconData _mapIcon(String icone) {
    switch (icone.toLowerCase()) {
      case 'info':
        return Icons.info;
      case 'local_shipping':
        return Icons.local_shipping;
      case 'inventory_2':
        return Icons.inventory_2;
      case 'warehouse':
        return Icons.warehouse;
      case 'science':
        return Icons.science;
      case 'check_circle':
        return Icons.check_circle;
      case 'person':
        return Icons.person;
      default:
        return Icons.checklist;
    }
  }

  // ==========================================================================
  // CORES
  // ==========================================================================

  Color _getProgressColor(double percentual) {
    if (percentual >= 100) return Colors.green;
    if (percentual >= 50) return Colors.orange;
    return Colors.blue;
  }

  Color _getCategoriaColor(double percentual) {
    if (percentual >= 100) return Colors.green;
    if (percentual > 0) return Colors.orange;
    return Colors.blue;
  }

  // ==========================================================================
  // DIALOGS
  // ==========================================================================

  void _mostrarInformacoes(BuildContext context) {
    // TODO: Implementar
  }

  void _confirmarFinalizacao(
    BuildContext context,
    ChecklistViewModel viewModel,
  ) async {
    final checklist = viewModel.checklist;
    if (checklist == null) return;

    // ✅ Validação: Verifica se pode finalizar
    if (!viewModel.podeFinalizar) {
      final motivo = viewModel.motivoNaoPodeFinalizar;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(motivo),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // ✅ Dialog de confirmação
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 12),
            const Text('Finalizar Checklist'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deseja finalizar o checklist?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✅ Checklist: ${checklist.desTemplate}',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '✅ Progresso: ${checklist.percentualConclusaoCalculado.toStringAsFixed(0)}%',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '✅ Itens respondidos: ${checklist.itensRespondidos}/${checklist.totalItens}',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Esta ação não poderá ser desfeita.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );

    // ✅ Se confirmou, finaliza
    if (confirmar == true && context.mounted) {
      final sucesso = await viewModel.finalizarChecklist(aprovado: true);

      if (sucesso && context.mounted) {
        // ✅ Volta para tela anterior
        Navigator.of(context).pop();
      }
    }
  }
}
