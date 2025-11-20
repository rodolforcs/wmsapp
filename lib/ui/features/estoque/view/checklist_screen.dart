// lib/ui/features/estoque/recebimento/view/checklist_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wmsapp/ui/features/estoque/recebimento/viewmodel/checklist_view_model.dart';
import 'package:wmsapp/ui/features/estoque/recebimento/widgets/checklist_app_bar.dart';
import 'package:wmsapp/ui/features/estoque/recebimento/widgets/checklist_categoria_card.dart';
import 'package:wmsapp/ui/features/estoque/recebimento/widgets/checklist_progress_bar.dart';
import 'package:wmsapp/ui/features/estoque/recebimento/widgets/checklist_footer.dart';
import 'package:wmsapp/ui/features/estoque/recebimento/widgets/checklist_info_dialog.dart';
import 'package:wmsapp/ui/features/estoque/recebimento/widgets/checklist_confirmar_dialog.dart';
import 'package:wmsapp/ui/widgets/responsive_center_layout.dart';
import 'package:wmsapp/shared/widgets/empty_state_widget.dart';

/// 📋 Tela do Checklist
///
/// Exibe checklist completo com categorias e itens
/// Suporta tablet e celular com layout responsivo
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

    // Carrega checklist ao abrir tela
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
        onInfoPressed: () => _mostrarInformacoes(context),
      ),
      body: Consumer<ChecklistViewModel>(
        builder: (context, viewModel, child) {
          // ====================================================================
          // LOADING
          // ====================================================================
          if (viewModel.isLoading) {
            return _buildLoading();
          }

          // ====================================================================
          // ERRO
          // ====================================================================
          if (viewModel.hasError) {
            return _buildError(
              context: context,
              mensagem: viewModel.errorMessage ?? 'Erro desconhecido',
              onRetry: _carregarChecklist,
            );
          }

          // ====================================================================
          // SEM CHECKLIST
          // ====================================================================
          // ✅ CORRETO
          if (!viewModel.hasChecklist) {
            return const EmptyStateWidget(
              icon: Icons.checklist,
              title: 'Nenhum checklist disponível',
              /*
              message:
                  'Não foi possível carregar o checklist para este documento.',
                  */
            );
          }

          // ====================================================================
          // CHECKLIST CARREGADO - Layout Responsivo
          // ====================================================================
          return ResponsiveCenterLayout(
            maxWidth: 800, // Limita largura em tablets
            child: _buildChecklistContent(context, viewModel),
          );
        },
      ),
    );
  }

  // ==========================================================================
  // LOADING
  // ==========================================================================

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

  // ==========================================================================
  // ERRO
  // ==========================================================================

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

  // ==========================================================================
  // CONTEÚDO DO CHECKLIST
  // ==========================================================================

  Widget _buildChecklistContent(
    BuildContext context,
    ChecklistViewModel viewModel,
  ) {
    final checklist = viewModel.checklist!;

    return Column(
      children: [
        // ====================================================================
        // HEADER: Progresso
        // ====================================================================
        ChecklistProgressBar(
          percentual: checklist.percentualConclusao,
          itensRespondidos: checklist.itensRespondidos,
          totalItens: checklist.totalItens,
          situacao: checklist.situacaoDescricao,
        ),

        const Divider(height: 1),

        // ====================================================================
        // BODY: Lista de Categorias
        // ====================================================================
        Expanded(
          child: _buildCategoriasList(checklist),
        ),

        // ====================================================================
        // FOOTER: Botões de Ação
        // ====================================================================
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
  // LISTA DE CATEGORIAS
  // ==========================================================================

  Widget _buildCategoriasList(dynamic checklist) {
    // ✅ Usa LayoutBuilder para adaptar padding
    return LayoutBuilder(
      builder: (context, constraints) {
        // Tablet: padding maior
        final padding = constraints.maxWidth > 600
            ? const EdgeInsets.all(24)
            : const EdgeInsets.all(16);

        return ListView.builder(
          padding: padding,
          itemCount: checklist.categorias.length,
          itemBuilder: (context, index) {
            final categoria = checklist.categorias[index];

            return ChecklistCategoriaCard(
              key: ValueKey('cat-${categoria.sequenciaCat}'),
              categoria: categoria,
              codChecklist: checklist.codChecklist,
            );
          },
        );
      },
    );
  }

  // ==========================================================================
  // DIALOGS (MODULARIZADOS)
  // ==========================================================================

  void _mostrarInformacoes(BuildContext context) {
    final viewModel = context.read<ChecklistViewModel>();
    final checklist = viewModel.checklist;

    if (checklist == null) return;

    showDialog(
      context: context,
      builder: (context) => ChecklistInfoDialog(checklist: checklist),
    );
  }

  void _confirmarFinalizacao(
    BuildContext context,
    ChecklistViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) => ChecklistConfirmarDialog(
        itensRespondidos: viewModel.itensRespondidos,
        totalItens: viewModel.totalItens,
        onConfirmar: () async {
          Navigator.of(context).pop(); // Fecha dialog

          final sucesso = await viewModel.finalizarChecklist(
            aprovado: true,
          );

          if (sucesso && context.mounted) {
            Navigator.of(context).pop(); // Volta para tela anterior
          }
        },
      ),
    );
  }
}
