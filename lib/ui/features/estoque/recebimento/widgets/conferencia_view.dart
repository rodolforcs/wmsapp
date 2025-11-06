// lib/ui/features/estoque/recebimento/conferencia_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wmsapp/data/models/estoque/recebimento/docto_fisico_model.dart';
import 'package:wmsapp/data/models/estoque/recebimento/it_doc_fisico_model.dart';
import 'package:wmsapp/ui/features/estoque/recebimento/viewmodel/recebimento_view_model.dart';
import 'package:wmsapp/ui/features/estoque/recebimento/widgets/documento_info_card.dart';
import 'package:wmsapp/ui/features/estoque/recebimento/widgets/conferencia_progress_indicator.dart';
import 'package:wmsapp/ui/features/estoque/recebimento/widgets/itens_filter_toggle.dart';
import 'package:wmsapp/ui/features/estoque/recebimento/widgets/itens_conferencia_list.dart';
import 'package:wmsapp/ui/features/estoque/recebimento/widgets/divergencia_alert_banner.dart';
import 'package:wmsapp/ui/features/estoque/recebimento/widgets/conferencia_action_bar.dart';
import 'package:wmsapp/shared/widgets/empty_state_widget.dart';

class ConferenciaView extends StatefulWidget {
  final bool isTablet;

  const ConferenciaView({
    super.key,
    required this.isTablet,
  });

  @override
  State<ConferenciaView> createState() => _ConferenciaViewState();
}

class _ConferenciaViewState extends State<ConferenciaView> {
  bool _mostrarApenasNaoConferidos = true;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RecebimentoViewModel>();
    final documento = viewModel.documentoSelecionado;

    if (documento == null) {
      return _buildDocumentoNaoSelecionado();
    }

    return _buildConferenciaScreen(context, viewModel, documento);
  }

  Widget _buildConferenciaScreen(
    BuildContext context,
    RecebimentoViewModel viewModel,
    DoctoFisicoModel documento,
  ) {
    final itensExibidos = _getItensFiltrados(documento);
    final totalItens = documento.itensDoc.length;
    final itensNaoConferidos = documento.itensDoc
        .where((item) => !item.foiConferido)
        .length;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(documento, viewModel),
      body: Column(
        children: [
          DocumentoInfoCard(documento: documento),
          ConferenciaProgressIndicator(documento: documento),
          ItensFilterToggle(
            mostrarApenasNaoConferidos: _mostrarApenasNaoConferidos,
            totalItens: totalItens,
            itensNaoConferidos: itensNaoConferidos,
            onToggle: _toggleFiltro,
          ),
          DivergenciaAlertBanner(documento: documento),
          Expanded(
            child: ItensConferenciaList(
              itens: itensExibidos,
              isLoading: viewModel.isLoadingItens,
              showEmptyForFilter:
                  _mostrarApenasNaoConferidos &&
                  itensExibidos.isEmpty &&
                  totalItens > 0,
              onQuantidadeChanged: (sequencia, qtd) =>
                  viewModel.atualizarQuantidadeItem(sequencia, qtd),
              onRateioQuantidadeChanged: (sequencia, rateioIndex, qtd) =>
                  viewModel.atualizarQuantidadeRateioPorIndice(
                    sequencia,
                    rateioIndex,
                    qtd,
                  ),
              onAdicionarRateio: (sequencia, rateio) =>
                  viewModel.adicionarRateio(sequencia, rateio),
              onRemoverRateio: (sequencia, rateioIndex) =>
                  viewModel.removerRateioPorIndice(sequencia, rateioIndex),
            ),
          ),
          ConferenciaActionBar(
            isTablet: widget.isTablet,
            todosConferidos: documento.todosItensConferidos,
            todosRateiosCorretos: documento.todosRateiosCorretos,
            onVoltar: widget.isTablet
                ? null
                : () => viewModel.voltarParaLista(),
            onFinalizar: () => _handleFinalizar(context, viewModel, documento),
          ),
        ],
      ),
    );
  }

  AppBar? _buildAppBar(
    DoctoFisicoModel documento,
    RecebimentoViewModel viewModel,
  ) {
    if (widget.isTablet) return null;

    return AppBar(
      title: Text('NF ${documento.nroDocto}'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => viewModel.voltarParaLista(),
      ),
    );
  }

  Widget _buildDocumentoNaoSelecionado() {
    return EmptyStateWidget(
      icon: Icons.inventory_2_outlined,
      title: 'Selecione um documento',
      subtitle: 'Escolha um documento na lista para iniciar a conferência',
      iconColor: Colors.grey[400],
    );
  }

  List<ItDocFisicoModel> _getItensFiltrados(DoctoFisicoModel documento) {
    if (_mostrarApenasNaoConferidos) {
      return documento.itensDoc.where((item) => !item.foiConferido).toList();
    }
    return documento.itensDoc.toList();
  }

  void _toggleFiltro() {
    setState(() {
      _mostrarApenasNaoConferidos = !_mostrarApenasNaoConferidos;
    });
  }

  Future<void> _handleFinalizar(
    BuildContext context,
    RecebimentoViewModel viewModel,
    DoctoFisicoModel documento,
  ) async {
    // Mostra dialog de confirmação
    final confirmar = await _mostrarDialogConfirmacao(context, documento);

    if (confirmar == true && context.mounted) {
      await _executarFinalizacao(context, viewModel);
    }
  }

  Widget _buildDivergenciaItem(ItDocFisicoModel item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline,
            size: 16,
            color: Colors.orange,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.descrItem,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  item.mensagemDivergencia,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _mostrarDialogConfirmacao(
    BuildContext context,
    DoctoFisicoModel documento,
  ) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 28,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Finalizar Conferência?',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tudo conferido!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Todos os itens foram conferidos e os rateios estão corretos.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Esta ação irá:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 12),
              _buildCheckItem('Atualizar o documento como "Finalizado"'),
              _buildCheckItem('Gerar movimentação de estoque no ERP'),
              _buildCheckItem('Registrar a conferência no sistema'),
              _buildCheckItem('Atualizar saldos de estoque'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade300),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Esta ação não poderá ser desfeita',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            child: const Text(
              'Confirmar Finalização',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _executarFinalizacao(
    BuildContext context,
    RecebimentoViewModel viewModel,
  ) async {
    // Mostra loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  const Text(
                    'Finalizando conferência...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Atualizando sistema e gerando movimentação',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    try {
      // ✅ Só chama finalizarConferencia (sem divergência)
      final sucesso = await viewModel.finalizarConferencia();

      if (context.mounted) {
        // Fecha loading
        Navigator.of(context).pop();

        if (sucesso) {
          // Mostra mensagem de sucesso
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('Conferência finalizada com sucesso!'),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );

          // Volta para lista se não for tablet
          if (!widget.isTablet) {
            Navigator.of(context).pop();
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        // Fecha loading
        Navigator.of(context).pop();

        // Mostra erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Erro ao finalizar: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
