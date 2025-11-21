// lib/ui/features/estoque/recebimento/view/checklist_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wmsapp/ui/features/estoque/recebimento/viewmodel/checklist_view_model.dart';
import 'package:wmsapp/ui/features/estoque/recebimento/widgets/checklist_app_bar.dart';
import 'package:wmsapp/ui/features/estoque/recebimento/widgets/checklist_categoria_card.dart';
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
            return _buildLoading();
          }

          // ERRO
          if (viewModel.hasError) {
            return _buildError(
              context: context,
              mensagem: viewModel.errorMessage ?? 'Erro desconhecido',
              onRetry: _carregarChecklist,
            );
          }

          // SEM CHECKLIST
          if (!viewModel.hasChecklist) {
            return _buildEmpty(context);
          }

          // ✅ CHECKLIST CARREGADO - TELA INTEIRA (sem ResponsiveCenterLayout)
          return _buildChecklistContent(context, viewModel);
        },
      ),
    );
  }

  Widget _buildLoading() {
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

  Widget _buildError({
    required BuildContext context,
    required String mensagem,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar checklist',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
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
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Não foi possível carregar o checklist para este documento.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
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
        // ✅ BARRA DE PROGRESSO (tela inteira, sem padding lateral)
        Container(
          width: double.infinity, // ✅ Largura total
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          color: Colors.white,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${checklist.itensRespondidos} de ${checklist.totalItens} itens',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${checklist.percentualConclusao.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getProgressColor(checklist.percentualConclusao),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: checklist.percentualConclusao / 100,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getProgressColor(checklist.percentualConclusao),
                  ),
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // ✅ LISTA DE CATEGORIAS (tela inteira)
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ), // ✅ Padding controlado
            itemCount: checklist.categorias.length,
            itemBuilder: (context, index) {
              final categoria = checklist.categorias[index];
              return ChecklistCategoriaCard(
                key: ValueKey('cat-${categoria.sequenciaCat}'),
                categoria: categoria,
                codChecklist: checklist.codChecklist,
              );
            },
          ),
        ),

        // ✅ FOOTER (tela inteira)
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

  Color _getProgressColor(double percentual) {
    if (percentual >= 100) return Colors.green;
    if (percentual >= 50) return Colors.orange;
    return Colors.blue;
  }

  void _mostrarInformacoes(BuildContext context) {
    // TODO: Implementar dialog de informações
  }

  void _confirmarFinalizacao(
    BuildContext context,
    ChecklistViewModel viewModel,
  ) {
    // TODO: Implementar dialog de confirmação
  }
}
