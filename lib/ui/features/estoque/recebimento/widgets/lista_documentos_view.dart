import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wmsapp/ui/features/estoque/recebimento/viewmodel/recebimento_view_model.dart';
import 'package:wmsapp/ui/features/estoque/recebimento/widgets/docto_fisico_card.dart';

// ============================================================================
// LISTA DOCUMENTOS VIEW - Lista de documentos pendentes
// ============================================================================

/// Widget que exibe a lista de documentos pendentes com busca
class ListaDocumentosView extends StatelessWidget {
  final bool isTablet;

  const ListaDocumentosView({
    super.key,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RecebimentoViewModel>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: isTablet
          ? null
          : AppBar(
              title: const Text('RECEBIMENTO'),
              centerTitle: true,
            ),
      body: Column(
        children: [
          // Header com título e busca
          _buildHeader(context, viewModel),

          // Lista de documentos
          Expanded(
            child: _buildContent(context, viewModel),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // HEADER (Título + Busca)
  // ==========================================================================

  Widget _buildHeader(BuildContext context, RecebimentoViewModel viewModel) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Documentos Pendentes',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Campo de busca
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por número ou estabelecimento...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: viewModel.searchTerm.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          context.read<RecebimentoViewModel>().clearSearch();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              onChanged: (value) {
                context.read<RecebimentoViewModel>().updateSearchTerm(value);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // CONTENT (Loading / Lista / Vazio / Erro)
  // ==========================================================================

  Widget _buildContent(BuildContext context, RecebimentoViewModel viewModel) {
    // ESTADO 1: Loading
    if (viewModel.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Carregando documentos...'),
          ],
        ),
      );
    }

    // ESTADO 2: Erro
    if (viewModel.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
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
                viewModel.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  context
                      .read<RecebimentoViewModel>()
                      .fetchDocumentosPendentes();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }

    // ESTADO 3: Lista vazia
    final documentosFiltrados = viewModel.documentosFiltrados;
    if (documentosFiltrados.isEmpty) {
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
              viewModel.searchTerm.isNotEmpty
                  ? 'Nenhum documento encontrado'
                  : 'Nenhum documento pendente',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            if (viewModel.searchTerm.isNotEmpty) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  context.read<RecebimentoViewModel>().clearSearch();
                },
                icon: const Icon(Icons.clear),
                label: const Text('Limpar busca'),
              ),
            ],
          ],
        ),
      );
    }

    // ESTADO 4: Lista com documentos
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<RecebimentoViewModel>().fetchDocumentosPendentes();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: documentosFiltrados.length,
        itemBuilder: (context, index) {
          final documento = documentosFiltrados[index];
          final isSelected =
              isTablet &&
              viewModel.documentoSelecionado?.chaveDocumento ==
                  documento.chaveDocumento;

          return DoctoFisicoCard(
            documento: documento,
            isSelected: isSelected,
            onTap: () {
              context.read<RecebimentoViewModel>().selecionarDocumento(
                documento,
              );
            },
          );
        },
      ),
    );
  }
}
