import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wmsapp/ui/features/estoque/recebimento/viewmodel/recebimento_view_model.dart';
import 'package:wmsapp/ui/features/estoque/recebimento/widgets/docto_fisico_card.dart';

// ============================================================================
// LISTA DOCUMENTOS VIEW - Lista de documentos pendentes
// ============================================================================

/// Widget que exibe a lista de documentos pendentes com busca
class ListaDocumentosView extends StatefulWidget {
  final bool isTablet;

  const ListaDocumentosView({
    super.key,
    required this.isTablet,
  });

  @override
  State<ListaDocumentosView> createState() => _ListaDocumentosViewState();
}

class _ListaDocumentosViewState extends State<ListaDocumentosView> {
  @override
  Widget build(BuildContext context) {
    // ✅ Usa watch APENAS para pegar os dados
    // Mas separa em widgets menores para evitar rebuild de tudo
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: widget.isTablet
          ? null
          : AppBar(
              title: const Text('RECEBIMENTO'),
              centerTitle: true,
            ),
      body: Column(
        children: [
          // Header com título e busca
          const _HeaderWidget(),

          // Lista de documentos
          Expanded(
            child: _ContentWidget(isTablet: widget.isTablet),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// HEADER WIDGET - Separado para não rebuildar junto com a lista
// ============================================================================

class _HeaderWidget extends StatelessWidget {
  const _HeaderWidget();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RecebimentoViewModel>();

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
}

// ============================================================================
// CONTENT WIDGET - Lista de documentos
// ============================================================================

class _ContentWidget extends StatelessWidget {
  final bool isTablet;

  const _ContentWidget({required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RecebimentoViewModel>();

    // ✅ DEBUG: Ver os estados
    print(
      '📊 Lista - isLoading: ${viewModel.isLoading}, isLoadingItens: ${viewModel.isLoadingItens}',
    );

    // ✅ CORREÇÃO: Usa isLoading apenas para a lista de documentos
    // (não mostra loading quando está buscando itens da nota)
    if (viewModel.isLoading && !viewModel.isLoadingItens) {
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
