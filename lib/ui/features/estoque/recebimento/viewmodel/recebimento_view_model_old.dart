import 'package:flutter/foundation.dart';
import 'package:wmsapp/core/services/messenger_service.dart';
import 'package:wmsapp/core/viewmodel/base_view_model.dart';
import 'package:wmsapp/core/viewmodel/session_view_model.dart';
import 'package:wmsapp/data/models/estoque/recebimento/docto_fisico_model.dart';
import 'package:wmsapp/data/models/estoque/recebimento/rat_lote_model.dart';
import 'package:wmsapp/data/repositories/estoque/recebimento/recebimento_repository.dart';

class RecebimentoViewModel extends BaseViewModel {
  final RecebimentoRepository _repository;
  final SessionViewModel _session;

  RecebimentoViewModel({
    required RecebimentoRepository repository,
    required SessionViewModel session,
  }) : _repository = repository,
       _session = session {
    if (kDebugMode) {
      debugPrint(
        '[RecebimentoVM] 🏗️ ViewModel CRIADO (ID: ${identityHashCode(this)}) - Buscando documentos...',
      );
    }
    fetchDocumentosPendentes();
  }

  List<DoctoFisicoModel> _documentos = [];
  DoctoFisicoModel? _documentoSelecionado;
  String _searchTerm = '';
  bool _isInitialized = false; // ✅ NOVO: Flag para controlar inicialização
  bool _isLoadingItens = false;

  //Documentos

  List<DoctoFisicoModel> get documentos => _documentos;
  DoctoFisicoModel? get documentoSelecionado => _documentoSelecionado;
  String get searchTerm => _searchTerm;

  List<DoctoFisicoModel> get documentosFiltrados {
    if (_searchTerm.isEmpty) return _documentos;

    final termLower = _searchTerm.toLowerCase();
    return _documentos.where((doc) {
      return doc.nroDocto.toLowerCase().contains(termLower) ||
          doc.codEstabel.toLowerCase().contains(termLower) ||
          doc.situacao.toLowerCase().contains(termLower);
    }).toList();
  }

  bool get hasDocumentos => _documentos.isNotEmpty;
  bool get semResultados => !isLoading && _documentos.isEmpty;
  bool get isLoadingItens => _isLoadingItens; // ✅ ADICIONE AQUI

  Future<void> fetchDocumentosPendentes() async {
    // ✅ PROTEÇÃO: Não busca se já está inicializado e não é refresh
    if (_isInitialized && !isLoading) {
      if (kDebugMode) {
        debugPrint(
          '[RecebimentoVM] ⚠️ TENTOU buscar de novo, mas JÁ está inicializado. Pulando.',
        );
        debugPrint('[RecebimentoVM] Stack trace:');
        debugPrint(
          StackTrace.current.toString().split('\n').take(5).join('\n'),
        );
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('[RecebimentoVM] 🔄 FETCH: Buscando lista de documentos...');
    }

    final codEstabel = _session.selectedEstabelecimento;
    if (codEstabel == null || codEstabel.isEmpty) {
      setError('Nenhum estabelecimento selecionado.');
      notifyListeners();
      return;
    }

    final user = _session.currentUser;
    if (user == null) {
      setError('Usuário não autenticado.');
      notifyListeners();
      return;
    }

    if (kDebugMode) {
      debugPrint(
        '[RecebimentoVM] Buscando documentos para estabelecimento: $codEstabel',
      );
    }

    final result = await runAsync(() async {
      return await _repository.buscarDoctosPendentes(
        username: user.username,
        password: user.password,
        codEstabel: codEstabel,
        searchTerm: _searchTerm.isNotEmpty ? _searchTerm : null,
      );
    });

    if (result != null) {
      _documentos = result;
      _isInitialized = true; // ✅ Marca como inicializado

      if (_documentoSelecionado != null) {
        _documentoSelecionado = _documentos.firstWhere(
          (doc) => doc.chaveDocumento == _documentoSelecionado!.chaveDocumento,
          orElse: () => _documentos.isNotEmpty
              ? _documentos.first
              : _documentoSelecionado!,
        );
      }

      if (kDebugMode) {
        debugPrint('[RecebimentoVM] ${result.length} documentos carregados');
      }
    } else {
      _documentos = [];
      _documentoSelecionado = null;

      if (kDebugMode) {
        debugPrint('[RecebimentoVM] Erro ao buscar: $errorMessage');
      }
    }

    notifyListeners();
  }

  void updateSearchTerm(String term) {
    _searchTerm = term;
    notifyListeners();
  }

  void clearSearch() {
    _searchTerm = '';
    notifyListeners();
  }

  Future<void> selecionarDocumento(DoctoFisicoModel documento) async {
    // ✅ OTIMIZAÇÃO: Não notifica se já está selecionado
    if (_documentoSelecionado?.chaveDocumento == documento.chaveDocumento) {
      if (kDebugMode) {
        debugPrint(
          '[RecebimentoVM] Documento já selecionado: ${documento.nroDocto}',
        );
      }
      return;
    }

    _documentoSelecionado = documento;

    // ✅ MUDANÇA: Só notifica se já tem itens (não vai buscar)
    if (documento.itensDoc.isNotEmpty) {
      if (kDebugMode) {
        debugPrint(
          '[RecebimentoVM] Documento selecionado: ${documento.nroDocto} \n'
          '[RecebimentoVM] Documento já possui itens carregados',
        );
      }
      notifyListeners();
      return;
    }

    /// Busca detalhes complementos do documento
    if (kDebugMode) {
      debugPrint(
        '[RecebimentoVM] Buscando detalhes do documento: ${documento.nroDocto}',
      );
    }
    final user = _session.currentUser;
    if (user == null) return;

    // ✅ NOVO: Usa loading separado para itens (NÃO usa runAsync!)
    _isLoadingItens = true;
    notifyListeners();

    try {
      // ✅ IMPORTANTE: NÃO usa runAsync aqui!
      // runAsync mudaria o isLoading, queremos usar apenas isLoadingItens
      //final result = await _repository.buscarDetalhesDocto(
      final result = await _repository.iniciarConferencia(
        codEstabel: documento.codEstabel,
        codEmitente: documento.codEmitente,
        nroDocto: documento.nroDocto,
        serieDocto: documento.serieDocto,
        username: user.username,
        password: user.password,
      );

      if (result != null) {
        // Atualiza o documento na lista com os itens carregados
        final index = _documentos.indexWhere(
          (d) => d.chaveDocumento == documento.chaveDocumento,
        );

        if (index >= 0) {
          _documentos[index] = result;
        }

        _documentoSelecionado = result;

        if (kDebugMode) {
          debugPrint(
            '[RecebimentoVM] Detalhes carregados: ${result.itensDoc.length} itens',
          );
        }
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('[RecebimentoVM] Erro ao buscar detalhes: $e');
        debugPrint('[RecebimentoVM] Stack: $stack');
      }
      // Você pode adicionar tratamento de erro aqui se quiser
    } finally {
      // ✅ Sempre desliga o loading, mesmo se der erro
      _isLoadingItens = false;
    }

    // ✅ Notifica depois de carregar (ou dar erro)
    notifyListeners();
  }

  void voltarParaLista() {
    _documentoSelecionado = null;
    notifyListeners();
  }

  void atualizarQuantidadeItem(int nrSequencia, double quantidade) {
    if (_documentoSelecionado == null) return;

    final item = _documentoSelecionado!.itensDoc.firstWhere(
      (item) => item.nrSequencia == nrSequencia,
    );

    // Atualiza APENAS a quantidade conferida digitada pelo usuário
    item.qtdeConferida = quantidade;

    // 2. 🔥 LÓGICA ADICIONADA: Recalcula o status de conferência do item
    //    (Assumindo que seu modelo ItDocFisicoModel tem a propriedade 'quantidade' original)

    if (kDebugMode) {
      debugPrint(
        '[RecebimentoVM] Quantidade atualizada: Item ${item.codItem}, '
        'Qtde: $quantidade',
      );
    }

    notifyListeners();
  }

  void atualizarQuantidadeRateio(
    int nrSequencia,
    String chaveRateio,
    double quantidade,
  ) {
    if (_documentoSelecionado == null) return;

    final item = _documentoSelecionado!.itensDoc.firstWhere(
      (item) => item.nrSequencia == nrSequencia,
    );

    if (!item.hasRateios) return;

    final rateio = item.rateios!.firstWhere(
      (rat) => rat.chaveRateio == chaveRateio,
    );

    rateio.qtdeLote = quantidade;

    // AQUI SIM recalcula, pois mudou um rateio
    item.qtdeConferida = item.rateios!.fold<double>(
      0.0,
      (sum, rat) => sum + rat.qtdeLote,
    );

    if (kDebugMode) {
      debugPrint(
        '[RecebimentoVM] Rateio atualizado: ${rateio.chaveRateio}, '
        'Nova soma: ${item.qtdeConferida}',
      );
    }

    notifyListeners();
  }

  void adicionarRateio(int nrSequencia, RatLoteModel rateio) {
    if (_documentoSelecionado == null) return;

    final item = _documentoSelecionado!.itensDoc.firstWhere(
      (item) => item.nrSequencia == nrSequencia,
    );

    item.rateios ??= [];
    item.rateios!.add(rateio);

    // Recalcula quantidade conferida
    item.qtdeConferida = item.rateios!.fold<double>(
      0.0,
      (sum, rat) => sum + rat.qtdeLote,
    );

    notifyListeners();

    if (kDebugMode) {
      debugPrint('[RecebimentoVM] Rateio adicionado: ${rateio.chaveRateio}');
    }
  }

  void removerRateio(int nrSequencia, String chaveRateio) {
    if (_documentoSelecionado == null) return;

    final item = _documentoSelecionado!.itensDoc.firstWhere(
      (item) => item.nrSequencia == nrSequencia,
    );

    if (!item.hasRateios) return;

    item.rateios!.removeWhere((rat) => rat.chaveRateio == chaveRateio);

    // Recalcula quantidade conferida
    item.qtdeConferida = item.hasRateios
        ? item.rateios!.fold<double>(0.0, (sum, rat) => sum + rat.qtdeLote)
        : 0.0;

    notifyListeners();

    if (kDebugMode) {
      debugPrint('[RecebimentoVM] Rateio removido: $chaveRateio');
    }
  }

  // ==========================================================================
  // VALIDAÇÕES DE FINALIZAÇÃO
  // ==========================================================================

  /// Verifica se pode finalizar (para habilitar/desabilitar botão na UI)
  bool get podeFinalizar {
    if (_documentoSelecionado == null) return false;
    return _documentoSelecionado!.podeFinalizar;
  }

  /// Mensagem explicando por que não pode finalizar
  String get motivoNaoPodeFinalizar {
    if (_documentoSelecionado == null) return 'Nenhum documento selecionado';

    final doc = _documentoSelecionado!;

    if (!doc.todosItensConferidos) {
      final qtd = doc.itensNaoConferidos.length;
      return 'Existem $qtd ${qtd == 1 ? "item não conferido" : "itens não conferidos"}';
    }

    if (!doc.todosRateiosCorretos) {
      final qtd = doc.itensComRateiosIncorretos.length;
      return 'Existem $qtd ${qtd == 1 ? "item com rateio incorreto" : "itens com rateios incorretos"}';
    }

    return '';
  }

  Future<bool> finalizarConferencia() async {
    if (_documentoSelecionado == null) {
      MessengerService.showError('Nenhum documento selecionado.');
      return false;
    }

    final documento = _documentoSelecionado!;
    final user = _session.currentUser;

    if (user == null) {
      MessengerService.showError('Usuário não autenticado.');
      return false;
    }

    // ========================================================================
    // VALIDAÇÃO 1: Todos os itens devem ter quantidade conferida
    // ========================================================================
    if (!documento.todosItensConferidos) {
      final itensNaoConferidos = documento.itensNaoConferidos;
      final mensagem =
          'Existem ${itensNaoConferidos.length} '
          '${itensNaoConferidos.length == 1 ? "item não conferido" : "itens não conferidos"}.\n\n'
          'Itens pendentes:\n'
          '${itensNaoConferidos.map((item) => '• ${item.codItem} - ${item.descrItem}').take(5).join('\n')}'
          '${itensNaoConferidos.length > 5 ? '\n... e mais ${itensNaoConferidos.length - 5}' : ''}\n\n'
          'Por favor, confira todos os itens antes de finalizar.';

      MessengerService.showError(mensagem);
      return false;
    }

    // ========================================================================
    // VALIDAÇÃO 2: Todos os rateios devem estar corretos
    // ========================================================================
    if (!documento.todosRateiosCorretos) {
      final itensRateiosIncorretos = documento.itensComRateiosIncorretos;

      final mensagem =
          'Existem ${itensRateiosIncorretos.length} '
          '${itensRateiosIncorretos.length == 1 ? "item com rateio incorreto" : "itens com rateios incorretos"}.\n\n'
          'A soma dos rateios deve ser igual à quantidade conferida.\n\n'
          'Itens com problema:\n'
          '${itensRateiosIncorretos.map((item) => '• ${item.codItem}: '
              'Conferido ${item.qtdeConferida.toStringAsFixed(2)}, '
              'Rateado ${item.somaTotalRateios.toStringAsFixed(2)}').take(5).join('\n')}'
          '${itensRateiosIncorretos.length > 5 ? '\n... e mais ${itensRateiosIncorretos.length - 5}' : ''}';

      MessengerService.showError(mensagem);
      return false;
    }

    // ========================================================================
    // VALIDAÇÃO 3: Verifica se tem divergência de quantidade
    // ========================================================================
    if (documento.temDivergenciasQuantidade) {
      // Neste caso, retorna false para a UI mostrar dialog de confirmação
      if (kDebugMode) {
        debugPrint(
          '[RecebimentoVM] Documento possui divergências de quantidade',
        );
      }
      return false;
    }

    // ========================================================================
    // TUDO OK: Finaliza sem divergência
    // ========================================================================
    return await _finalizarConferenciaComConfirmacao(comDivergencia: false);
  }

  Future<bool> _finalizarConferenciaComConfirmacao({
    required bool comDivergencia,
  }) async {
    if (_documentoSelecionado == null) return false;

    final user = _session.currentUser;
    if (user == null) return false;

    if (kDebugMode) {
      debugPrint(
        '[RecebimentoVM] Finalizando conferência. Divergência: $comDivergencia',
      );
    }

    final success = await runAsync(() async {
      return await _repository.finalizarConferencia(
        docto: _documentoSelecionado!,
        username: user.username,
        password: user.password,
        comDivergencia: comDivergencia,
      );
    });

    if (success == true) {
      MessengerService.showSuccess(
        comDivergencia
            ? 'Conferência finalizada com divergência registrada!'
            : 'Conferência finalizada com sucesso!',
      );

      _documentos.removeWhere(
        (doc) => doc.chaveDocumento == _documentoSelecionado!.chaveDocumento,
      );

      if (_documentos.isNotEmpty) {
        _documentoSelecionado = _documentos.first;
      } else {
        _documentoSelecionado = null;
      }

      notifyListeners();
      return true;
    } else {
      MessengerService.showError(
        errorMessage ?? 'Erro ao finalizar conferência',
      );
      return false;
    }
  }

  Future<bool> finalizarComDivergencia() async {
    return await _finalizarConferenciaComConfirmacao(comDivergencia: true);
  }

  @override
  void dispose() {
    if (kDebugMode) {
      debugPrint('[RecebimentoVM] Disposed');
    }
    super.dispose();
  }
}
