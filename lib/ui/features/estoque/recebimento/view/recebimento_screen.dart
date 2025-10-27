import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wmsapp/core/viewmodel/session_view_model.dart';
import 'package:wmsapp/data/repositories/estoque/recebimento/recebimento_repository.dart';
import 'package:wmsapp/data/services/conferencia_sync_service.dart';
import 'package:wmsapp/ui/features/estoque/recebimento/viewmodel/recebimento_view_model.dart';
import 'package:wmsapp/ui/features/estoque/recebimento/widgets/conferencia_view.dart';
import 'package:wmsapp/ui/features/estoque/recebimento/widgets/lista_documentos_view.dart';

// ============================================================================
// RECEBIMENTO SCREEN - Tela principal de recebimento (OTIMIZADA)
// ============================================================================

/// Tela de recebimento de notas fiscais
///
/// Cria o RecebimentoViewModel localmente (não global)
/// Responsivo: mobile (fullscreen) ou tablet (split-screen)
/// OTIMIZADO: Usa Selector para evitar rebuilds desnecessários
class RecebimentoScreen extends StatelessWidget {
  const RecebimentoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Cria o ViewModel LOCAL (só existe enquanto a tela está ativa)
    return ChangeNotifierProvider(
      create: (context) => RecebimentoViewModel(
        repository: context.read<RecebimentoRepository>(),
        session: context.read<SessionViewModel>(),
        syncService: context.read<ConferenciaSyncService>(),
      ),
      child: const _RecebimentoScreenContent(),
    );
  }
}

// ============================================================================
// CONTEÚDO DA TELA (separado para acessar o Provider)
// ============================================================================

class _RecebimentoScreenContent extends StatelessWidget {
  const _RecebimentoScreenContent();

  @override
  Widget build(BuildContext context) {
    // Detecta se é tablet (largura > 768px)
    final isTablet = MediaQuery.of(context).size.width > 768;

    // TABLET: Split-screen (lista à esquerda, conferência à direita)
    if (isTablet) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('RECEBIMENTO'),
          centerTitle: true,
        ),
        body: Row(
          children: [
            // Lista de documentos (40% da largura)
            // ✅ NÃO rebuilda quando seleciona documento
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: const ListaDocumentosView(isTablet: true),
            ),

            // Divisor vertical
            const VerticalDivider(width: 1, color: Colors.black12),

            // Conferência (60% da largura)
            // ✅ Só rebuilda quando documentoSelecionado muda
            Expanded(
              child: Selector<RecebimentoViewModel, String?>(
                selector: (_, viewModel) =>
                    viewModel.documentoSelecionado?.chaveDocumento,
                builder: (context, chaveDocumento, _) {
                  if (chaveDocumento == null) {
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
                            'Selecione um documento para começar',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }
                  return const ConferenciaView(isTablet: true);
                },
              ),
            ),
          ],
        ),
      );
    }

    // MOBILE: Fullscreen (alterna entre lista e conferência)
    // ✅ Só rebuilda quando documentoSelecionado muda
    return Selector<RecebimentoViewModel, bool>(
      selector: (_, viewModel) => viewModel.documentoSelecionado != null,
      builder: (context, temDocumentoSelecionado, _) {
        return temDocumentoSelecionado
            ? const ConferenciaView(isTablet: false)
            : const ListaDocumentosView(isTablet: false);
      },
    );
  }
}
