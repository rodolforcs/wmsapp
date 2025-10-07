import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wmsapp/data/models/estoque/recebimento/docto_fisico_model.dart';
import 'package:wmsapp/ui/features/estoque/recebimento/viewmodel/recebimento_view_model.dart';
import 'package:wmsapp/ui/features/estoque/recebimento/widgets/item_conferencia_card.dart';

// ============================================================================
// CONFERENCIA VIEW - Tela de conferência de itens do documento
// ============================================================================

class ConferenciaView extends StatelessWidget {
  final bool isTablet;

  const ConferenciaView({
    super.key,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RecebimentoViewModel>();
    final documento = viewModel.documentoSelecionado;

    if (documento == null) {
      return _buildEmpty();
    }

    return _buildScaffold(context, viewModel, documento);
  }

  Widget _buildScaffold(
    BuildContext context,
    RecebimentoViewModel viewModel,
    DoctoFisicoModel documento,
  ) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: isTablet
          ? null
          : AppBar(
              title: Text('NF ${documento.nroDocto}'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  viewModel.voltarParaLista();
                },
              ),
            ),
      body: Column(
        children: [
          _buildHeader(context, documento),
          Expanded(
            child: _buildContent(context, viewModel, documento),
          ),
          _buildFooter(context, viewModel, documento),
        ],
      ),
    );
  }

  // ==========================================================================
  // HEADER - Informações do documento
  // ==========================================================================

  Widget _buildHeader(BuildContext context, documento) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NF ${documento.nroDocto} - Série ${documento.serieDocto}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        documento.nomeAbreviado,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(documento.status),
              ],
            ),
            const SizedBox(height: 12),
            // Progresso da conferência
            _buildProgressBar(documento),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'pendente':
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        break;
      case 'em conferência':
        backgroundColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        break;
      default:
        backgroundColor = Colors.grey.shade50;
        textColor = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildProgressBar(documento) {
    final total = documento.itensDoc.length;
    final conferidos = documento.quantidadeItensConferidos;
    final porcentagem = total > 0 ? (conferidos / total) * 100 : 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progresso da Conferência',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            Text(
              '$conferidos de $total itens',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: porcentagem / 100,
            minHeight: 8,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              porcentagem == 100 ? Colors.green : Colors.blue,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // CONTENT - Lista de itens
  // ==========================================================================

  Widget _buildContent(
    BuildContext context,
    RecebimentoViewModel viewModel,
    documento,
  ) {
    // Estado de loading ao buscar itens
    if (viewModel.isLoading) {
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

    // Lista vazia
    if (documento.itensDoc.isEmpty) {
      return Center(
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
              'Nenhum item encontrado neste documento',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    // Lista de itens
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: documento.itensDoc.length,
      itemBuilder: (context, index) {
        final item = documento.itensDoc[index];

        return ItemConferenciaCard(
          key: ValueKey(item.nrSequencia),
          item: item,
          onQuantidadeChanged: (qtd) {
            viewModel.atualizarQuantidadeItem(item.nrSequencia, qtd);
          },
          onRateioQuantidadeChanged: (chave, qtd) {
            viewModel.atualizarQuantidadeRateio(
              item.nrSequencia,
              chave,
              qtd,
            );
          },
          onAdicionarRateio: (rateio) {
            viewModel.adicionarRateio(item.nrSequencia, rateio);
          },
          onRemoverRateio: (chave) {
            viewModel.removerRateio(item.nrSequencia, chave);
          },
        );
      },
    );
  }

  // ==========================================================================
  // FOOTER - Botões de ação
  // ==========================================================================

  Widget _buildFooter(
    BuildContext context,
    RecebimentoViewModel viewModel,
    documento,
  ) {
    final temDivergencias = documento.temDivergencias;
    final todosConferidos = documento.todosItensConferidos;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Alerta de divergências
            if (temDivergencias)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Divergências encontradas',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade900,
                            ),
                          ),
                          Text(
                            '${documento.itensComDivergencia.length} item(ns) com divergência',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            // Botões de ação
            Row(
              children: [
                // Botão Voltar (apenas mobile)
                if (!isTablet)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        viewModel.voltarParaLista();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Voltar'),
                    ),
                  ),

                if (!isTablet) const SizedBox(width: 12),

                // Botão Finalizar
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: !todosConferidos
                        ? null
                        : () async {
                            final success = temDivergencias
                                ? await _confirmarFinalizacaoComDivergencia(
                                    context,
                                    viewModel,
                                    documento,
                                  )
                                : await viewModel.finalizarConferencia();

                            if (success && context.mounted) {
                              if (!isTablet) {
                                Navigator.of(context).pop();
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: temDivergencias
                          ? Colors.orange
                          : Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      temDivergencias
                          ? 'Finalizar com Divergência'
                          : 'Finalizar Conferência',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Dica
            if (!todosConferidos)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Confira todos os itens para finalizar',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // ESTADO VAZIO
  // ==========================================================================

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Selecione um documento para conferir',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // CONFIRMAÇÃO DE DIVERGÊNCIA
  // ==========================================================================

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
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
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
              ...divergencias.map(
                (item) => Padding(
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
                ),
              ),
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
}
