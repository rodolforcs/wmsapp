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
            temDivergencias: documento.temDivergencias,
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
    final temDivergencias = documento.temDivergencias;

    final success = temDivergencias
        ? await _confirmarFinalizacaoComDivergencia(
            context,
            viewModel,
            documento,
          )
        : await viewModel.finalizarConferencia();

    if (success && context.mounted && !widget.isTablet) {
      Navigator.of(context).pop();
    }
  }

  Future<bool> _confirmarFinalizacaoComDivergencia(
    BuildContext context,
    RecebimentoViewModel viewModel,
    DoctoFisicoModel documento,
  ) async {
    final divergencias = documento.itensComDivergencia;

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange.shade700,
            ),
            const SizedBox(width: 12),
            const Text('Confirmar Divergências'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Foram encontradas divergências nos seguintes itens:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...divergencias.map((item) => _buildDivergenciaItem(item)),
              const SizedBox(height: 16),
              const Text(
                'Deseja finalizar a conferência registrando estas divergências?',
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
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      return await viewModel.finalizarComDivergencia();
    }

    return false;
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
}
