import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:wmsapp/core/services/messenger_service.dart';
import 'package:wmsapp/core/viewmodel/base_view_model.dart';
import 'package:wmsapp/core/viewmodel/session_view_model.dart';
import 'package:wmsapp/data/models/estoque/recebimento/docto_fisico_model.dart';
import 'package:wmsapp/data/models/estoque/recebimento/rat_lote_model.dart';
import 'package:wmsapp/data/repositories/estoque/recebimento/recebimento_repository.dart';
import 'package:wmsapp/data/services/conferencia_sync_service.dart'; // ✅ ADICIONAR

class RecebimentoViewModel extends BaseViewModel {
  final RecebimentoRepository _repository;
  final SessionViewModel _session;
  final ConferenciaSyncService _syncService; // ✅ ADICIONAR

  RecebimentoViewModel({
    required RecebimentoRepository repository,
    required SessionViewModel session,
    required ConferenciaSyncService syncService, // ✅ ADICIONAR
  }) : _repository = repository,
       _session = session,
       _syncService = syncService {
    // ✅ ADICIONAR
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
  bool _isInitialized = false;
  bool _isLoadingItens = false;
  bool _isSyncing = false;

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
  bool get isLoadingItens => _isLoadingItens;
  bool get isSyncing => _isSyncing;
  Timer? _debounceTimer;

  Future<void> fetchDocumentosPendentes() async {
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
      _isInitialized = true;

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
    if (_documentoSelecionado?.chaveDocumento == documento.chaveDocumento) {
      if (kDebugMode) {
        debugPrint(
          '[RecebimentoVM] Documento já selecionado: ${documento.nroDocto}',
        );
      }
      return;
    }

    _documentoSelecionado = documento;

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

    if (kDebugMode) {
      debugPrint(
        '[RecebimentoVM] Buscando detalhes do documento: ${documento.nroDocto}',
      );
    }
    final user = _session.currentUser;
    if (user == null) return;

    _isLoadingItens = true;
    notifyListeners();

    try {
      final result = await _repository.iniciarConferencia(
        codEstabel: documento.codEstabel,
        codEmitente: documento.codEmitente,
        nroDocto: documento.nroDocto,
        serieDocto: documento.serieDocto,
        username: user.username,
        password: user.password,
      );

      if (result != null) {
        final index = _documentos.indexWhere(
          (d) => d.chaveDocumento == documento.chaveDocumento,
        );

        if (index >= 0) {
          _documentos[index] = result;
        }

        _documentoSelecionado = result;

        // ✅ ADICIONAR: Inicia auto-sync após carregar documento
        _iniciarAutoSync();

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
    } finally {
      _isLoadingItens = false;
    }

    notifyListeners();
  }

  void voltarParaLista() {
    // ✅ ADICIONAR: Para auto-sync ao sair do documento
    _pararAutoSync();

    _documentoSelecionado = null;
    notifyListeners();
  }

  void atualizarQuantidadeItem(int nrSequencia, double quantidade) {
    if (_documentoSelecionado == null) return;

    final item = _documentoSelecionado!.itensDoc.firstWhere(
      (item) => item.nrSequencia == nrSequencia,
    );

    if (item.qtdeConferida == quantidade) {
      if (kDebugMode) {
        debugPrint(
          '[RecebimentoVM] ⏭️ Valor não mudou (${item.qtdeConferida} == $quantidade), ignorando...',
        );
      }
      return; // ← NÃO FAZ NADA se valor for igual
    }

    if (kDebugMode) {
      debugPrint(
        '[RecebimentoVM] 📝 Atualizando item seq=$nrSequencia:\n'
        '  Versão atual: ${item.versao}\n'
        '  Qtde atual: ${item.qtdeConferida}\n'
        '  Nova qtde: $quantidade\n'
        '  Alterado local: ${item.alteradoLocal}',
      );
    }

    // ✅ IMPORTANTE: Marca como alterado localmente
    item.qtdeConferida = quantidade;
    item.alteradoLocal = true; // ✅ ADICIONAR - Marca para sync

    if (kDebugMode) {
      debugPrint(
        '[RecebimentoVM] ✅ Item atualizado:\n'
        '  Versão: ${item.versao} (mantida)\n'
        '  Qtde conferida: ${item.qtdeConferida}\n'
        '  Foi conferido: ${item.foiConferido}\n'
        '  Alterado local: ${item.alteradoLocal}',
      );
    }

    if (kDebugMode) {
      debugPrint(
        '[RecebimentoVM] Quantidade atualizada: Item ${item.codItem}, '
        'Qtde: $quantidade (marcado para sync)',
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
      orElse: () {
        if (kDebugMode) {
          debugPrint('⚠️ Item com sequência $nrSequencia não encontrado!');
        }
        throw StateError('Item não encontrado');
      },
    );

    if (!item.hasRateios) {
      if (kDebugMode) {
        debugPrint('⚠️ Item seq=$nrSequencia não tem rateios');
      }
      return;
    }

    // ✅ Busca rateio com tratamento de erro
    RatLoteModel? rateio;
    try {
      rateio = item.rateios!.firstWhere(
        (rat) => rat.chaveRateio == chaveRateio,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ Rateio $chaveRateio não encontrado no item seq=$nrSequencia',
        );
        debugPrint('   Rateios disponíveis:');
        for (final r in item.rateios!) {
          debugPrint('     - ${r.chaveRateio}');
        }
      }
      return; // ✅ Retorna sem fazer nada se não encontrar
    }

    // ✅ CRÍTICO: Só marca como alterado se o valor REALMENTE mudou
    if (rateio.qtdeLote == quantidade) {
      if (kDebugMode) {
        debugPrint(
          '[RecebimentoVM] ⏭️ Rateio não mudou (${rateio.qtdeLote} == $quantidade), ignorando...',
        );
      }
      return;
    }

    rateio.qtdeLote = quantidade;

    item.qtdeConferida = item.rateios!.fold<double>(
      0.0,
      (sum, rat) => sum + rat.qtdeLote,
    );

    item.alteradoLocal = true; // ✅ ADICIONAR - Marca para sync

    if (kDebugMode) {
      debugPrint(
        '[RecebimentoVM] Rateio atualizado: ${rateio.chaveRateio}, '
        'Nova soma: ${item.qtdeConferida} (marcado para sync)',
      );
    }

    notifyListeners();
  }

  void adicionarRateio(int nrSequencia, RatLoteModel rateio) {
    if (_documentoSelecionado == null) return;

    final item = _documentoSelecionado!.itensDoc.firstWhere(
      (item) => item.nrSequencia == nrSequencia,
      orElse: () => throw StateError('Item não encontrado'),
    );

    // ✅ VALIDAÇÃO antes de adicionar
    final erro = item.validarNovoRateio(
      codDepos: rateio.codDepos,
      codLocaliz: rateio.codLocaliz,
      codLote: rateio.codLote,
      quantidade: rateio.qtdeLote,
    );

    if (erro != null) {
      if (kDebugMode) {
        debugPrint('❌ Validação falhou: $erro');
      }
      MessengerService.showError(
        'Valiadação falhou $erro. Tente novamente.',
      );
      notifyListeners();
      return;
    }

    if (kDebugMode) {
      debugPrint(
        '[RecebimentoVM] ➕ Adicionando rateio:\n'
        '  Item seq: $nrSequencia\n'
        '  Rateio seq: ${rateio.sequencia}\n'
        '  Depósito: ${rateio.codDepos}\n'
        '  Localização: ${rateio.codLocaliz}\n'
        '  Lote: ${rateio.codLote}\n'
        '  Quantidade: ${rateio.qtdeLote}',
      );
    }

    item.rateios ??= [];
    final rateioSeq = rateio.copyWith(sequencia: item.nrSequencia);
    item.rateios!.add(rateioSeq);
    item.alteradoLocal = true; // ✅ ADICIONAR - Marca para sync

    notifyListeners();

    _salvarRateioNoBackend(nrSequencia, item.rateios!.length - 1);

    if (kDebugMode) {
      debugPrint(
        '[RecebimentoVM] Rateio adicionado: ${rateio.chaveRateio} (marcado para sync)',
      );
    }
  }

  void removerRateio(int nrSequencia, String chaveRateio) {
    if (_documentoSelecionado == null) return;

    final item = _documentoSelecionado!.itensDoc.firstWhere(
      (item) => item.nrSequencia == nrSequencia,
      orElse: () {
        if (kDebugMode) {
          debugPrint('⚠️ Item não encontrado ao remover rateio');
        }
        throw StateError('Item não encontrado');
      },
    );

    if (!item.hasRateios) return;

    item.rateios!.removeWhere((rat) => rat.chaveRateio == chaveRateio);

    item.qtdeConferida = item.hasRateios
        ? item.rateios!.fold<double>(0.0, (sum, rat) => sum + rat.qtdeLote)
        : 0.0;

    item.alteradoLocal = true; // ✅ ADICIONAR - Marca para sync

    notifyListeners();

    if (kDebugMode) {
      debugPrint(
        '[RecebimentoVM] Rateio removido: $chaveRateio (marcado para sync)',
      );
    }
  }

  // ==========================================================================
  // 🔄 SINCRONIZAÇÃO (NOVO)
  // ==========================================================================

  /// Inicia auto-sync (chamado ao selecionar documento)
  void _iniciarAutoSync() {
    _syncService.iniciarAutoSync(
      onSyncNeeded: () => _sincronizarItensAlterados(),
    );

    if (kDebugMode) {
      debugPrint('[RecebimentoVM] 🔁 Auto-sync iniciado');
    }
  }

  /// Para auto-sync (chamado ao sair do documento)
  void _pararAutoSync() {
    _syncService.pararAutoSync();

    if (kDebugMode) {
      debugPrint('[RecebimentoVM] ⏹️ Auto-sync parado');
    }
  }

  /// Sincroniza itens alterados com o backend
  Future<void> _sincronizarItensAlterados() async {
    if (_documentoSelecionado == null) return;

    final user = _session.currentUser;
    if (user == null) return;

    if (_isSyncing) {
      if (kDebugMode) {
        debugPrint('⏸️ Sincronização já em andamento, aguardando...');
      }
      return; // Ignora chamada duplicada
    }

    // Filtra apenas itens alterados
    final itensAlterados = _documentoSelecionado!.itensDoc
        .where((item) => item.alteradoLocal)
        .toList();

    if (itensAlterados.isEmpty) {
      if (kDebugMode) {
        debugPrint('[RecebimentoVM] 📭 Nenhum item alterado para sincronizar');
      }
      return;
    }

    _isSyncing = true;
    notifyListeners();

    if (kDebugMode) {
      debugPrint(
        '[RecebimentoVM] 📤 Sincronizando ${itensAlterados.length} itens...',
      );
    }

    try {
      if (kDebugMode) {
        debugPrint(
          '[RecebimentoVM] 📤 Sincronizando ${itensAlterados.length} itens...',
        );
        for (final item in itensAlterados) {
          debugPrint(
            '  - Item seq=${item.nrSequencia}, versao=${item.versao}, alteradoLocal=${item.alteradoLocal}',
          );
        }
      }

      final response = await _syncService.sincronizarDocumento(
        documento: _documentoSelecionado!,
        itensAlterados: itensAlterados,
        username: user.username,
        password: user.password,
      );

      // ✅ CORREÇÃO: Converte corretamente o map de versões
      if (response['versoes'] != null) {
        final versoesMap = Map<int, int>.from(response['versoes'] as Map);
        _atualizarVersoesLocais(versoesMap);
      }

      // ✅ ADICIONE ESTES LOGS:
      if (kDebugMode) {
        debugPrint(
          '[RecebimentoVM] 🔓 Desmarcando ${itensAlterados.length} itens como sincronizados...',
        );
      }

      // ✅ ADICIONAR - Marca itens como sincronizados
      for (final item in itensAlterados) {
        item.alteradoLocal = false;

        if (kDebugMode) {
          debugPrint(
            '  ✅ Item seq=${item.nrSequencia} DESMARCADO (versao=${item.versao}, alteradoLocal=${item.alteradoLocal})',
          );
        }
      }

      if (kDebugMode) {
        debugPrint('[RecebimentoVM] ✅ Sincronização concluída!');
      }
    } on ConflictException catch (e) {
      // ⚠️ CONFLITO: Recarrega documento
      if (kDebugMode) {
        debugPrint('[RecebimentoVM] ⚠️ Conflito detectado: ${e.message}');
      }

      await _recarregarDocumento();

      MessengerService.showError(
        'Documento atualizado por outro usuário. Dados recarregados.',
      );
    } catch (e) {
      // ❌ Erro genérico
      if (kDebugMode) {
        debugPrint('[RecebimentoVM] ❌ Erro ao sincronizar: $e');
      }
      // Não mostra erro ao usuário em sync automático
      // Apenas em finalização manual
    } finally {
      // ✅ ADICIONE LOG AQUI
      if (kDebugMode) {
        debugPrint(
          '[RecebimentoVM] 🔓 FINALLY: Liberando campo (_isSyncing=$_isSyncing → false)',
        );
      }

      _isSyncing = false;

      if (kDebugMode) {
        debugPrint('[RecebimentoVM] 📢 Chamando notifyListeners()...');
      }

      notifyListeners();

      if (kDebugMode) {
        debugPrint('[RecebimentoVM] ✅ Campo LIBERADO (_isSyncing=$_isSyncing)');
      }
    }
  }

  /// Atualiza versões locais após sync bem-sucedido
  void _atualizarVersoesLocais(Map<int, int> versoes) {
    if (_documentoSelecionado == null) return;

    if (kDebugMode) {
      debugPrint('[RecebimentoVM] 🔄 Iniciando atualização de versões...');
      debugPrint('[RecebimentoVM] Versões recebidas do backend: $versoes');
    }

    for (final item in _documentoSelecionado!.itensDoc) {
      final novaVersao = versoes[item.nrSequencia];

      if (kDebugMode) {
        debugPrint(
          '[RecebimentoVM] Item seq=${item.nrSequencia}: '
          'versão ANTES=${item.versao}, versão NOVA=$novaVersao',
        );
      }

      if (novaVersao != null) {
        final versaoAntiga = item.versao;
        item.versao = novaVersao;

        if (kDebugMode) {
          debugPrint(
            '[RecebimentoVM] ✅ Item seq=${item.nrSequencia}: '
            'atualizado de $versaoAntiga para ${item.versao}',
          );
        }
      } else {
        if (kDebugMode) {
          debugPrint(
            '[RecebimentoVM] ⚠️ Item seq=${item.nrSequencia}: '
            'NÃO TEM versão no retorno! Mantendo versão ${item.versao}',
          );
        }
      }
    }

    //notifyListeners();

    if (kDebugMode) {
      debugPrint('[RecebimentoVM] 📋 Versões atualizadas localmente');
    }
  }

  /// Recarrega documento do servidor (em caso de conflito)
  Future<void> _recarregarDocumento() async {
    if (_documentoSelecionado == null) return;

    final user = _session.currentUser;
    if (user == null) return;

    try {
      if (kDebugMode) {
        debugPrint('[RecebimentoVM] 🔄 Recarregando documento do servidor...');
      }

      final result = await _repository.iniciarConferencia(
        codEstabel: _documentoSelecionado!.codEstabel,
        codEmitente: _documentoSelecionado!.codEmitente,
        nroDocto: _documentoSelecionado!.nroDocto,
        serieDocto: _documentoSelecionado!.serieDocto,
        username: user.username,
        password: user.password,
      );

      if (result != null) {
        _documentoSelecionado = result;
        notifyListeners();

        if (kDebugMode) {
          debugPrint('[RecebimentoVM] ✅ Documento recarregado');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[RecebimentoVM] ❌ Erro ao recarregar: $e');
      }
    }
  }

  /// Força sincronização manual (para botão na UI, se quiser)
  Future<void> sincronizarAgora() async {
    _debounceTimer?.cancel();

    if (kDebugMode) {
      debugPrint('[RecebimentoVM] 📤 sincronizarAgora() chamado');
    }

    if (_isSyncing) {
      if (kDebugMode) {
        debugPrint('[RecebimentoVM] ⏳ Sync manual aguardando sync anterior...');
      }
      return;
    }
    // ⚠️ Cancela timer anterior (debounce)

    // ⚠️ Aguarda 300ms para evitar múltiplas chamadas rápidas
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (kDebugMode) {
        debugPrint('[RecebimentoVM] 📤 Sincronização MANUAL disparada');
      }
      // Verifica novamente se não está sincronizando
      if (!_isSyncing) {
        _sincronizarItensAlterados();
      } else {
        if (kDebugMode) {
          debugPrint(
            '[RecebimentoVM] ⏸️ Sync já em andamento no momento do timer',
          );
        }
      }
    });
  }

  // ==========================================================================
  // VALIDAÇÕES DE FINALIZAÇÃO
  // ==========================================================================

  bool get podeFinalizar {
    if (_documentoSelecionado == null) return false;
    return _documentoSelecionado!.podeFinalizar;
  }

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

    if (documento.temDivergenciasQuantidade) {
      if (kDebugMode) {
        debugPrint(
          '[RecebimentoVM] Documento possui divergências de quantidade',
        );
      }
      return false;
    }

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

    // ✅ ADICIONAR: Sincroniza tudo antes de finalizar
    try {
      await _sincronizarItensAlterados();

      // Aguarda um pouco para garantir que sync completou
      await Future.delayed(const Duration(milliseconds: 500));

      // Verifica se ainda tem itens alterados
      final temItensAlterados = _documentoSelecionado!.itensDoc.any(
        (item) => item.alteradoLocal,
      );

      if (temItensAlterados) {
        MessengerService.showError(
          'Ainda há alterações não sincronizadas. Aguarde um momento e tente novamente.',
        );
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[RecebimentoVM] Erro na sincronização final: $e');
      }
      MessengerService.showError(
        'Erro ao sincronizar dados. Tente novamente.',
      );
      return false;
    }

    // ✅ MODIFICAR: Usa o service de sync para finalizar
    try {
      final sucesso = await _syncService.finalizarConferencia(
        documento: _documentoSelecionado!,
        username: user.username,
        password: user.password,
        comDivergencia: comDivergencia,
      );

      if (sucesso) {
        // Para auto-sync
        _pararAutoSync();

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
        MessengerService.showError('Erro ao finalizar conferência');
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[RecebimentoVM] Erro ao finalizar: $e');
      }
      MessengerService.showError(
        'Erro ao finalizar conferência: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> finalizarComDivergencia() async {
    return await _finalizarConferenciaComConfirmacao(comDivergencia: true);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel(); // ✅ ADICIONAR
    _pararAutoSync(); // ✅ ADICIONAR - Para sync ao destruir ViewModel

    if (kDebugMode) {
      debugPrint('[RecebimentoVM] Disposed');
    }
    super.dispose();
  }

  /// Atualiza quantidade de rateio por ÍNDICE (mais confiável)
  void atualizarQuantidadeRateioPorIndice(
    int nrSequencia,
    int rateioIndex,
    double quantidade,
  ) {
    if (_documentoSelecionado == null) return;

    final item = _documentoSelecionado!.itensDoc.firstWhere(
      (item) => item.nrSequencia == nrSequencia,
      orElse: () {
        if (kDebugMode) {
          debugPrint('⚠️ Item com sequência $nrSequencia não encontrado!');
        }
        throw StateError('Item não encontrado');
      },
    );

    if (!item.hasRateios || rateioIndex >= item.rateios!.length) {
      if (kDebugMode) {
        debugPrint(
          '⚠️ Índice de rateio inválido: $rateioIndex (total: ${item.rateios?.length ?? 0})',
        );
      }
      return;
    }

    final rateio = item.rateios![rateioIndex];

    // Verifica se valor realmente mudou
    if ((rateio.qtdeLote - quantidade).abs() < 0.01) {
      if (kDebugMode) {
        debugPrint(
          '[RecebimentoVM] ⏭️ Rateio index=$rateioIndex não mudou (${rateio.qtdeLote} == $quantidade), ignorando...',
        );
      }
      return;
    }

    if (kDebugMode) {
      debugPrint(
        '[RecebimentoVM] 📝 Atualizando rateio index=$rateioIndex:\n'
        '  Depósito: ${rateio.codDepos}\n'
        '  Localização: ${rateio.codLocaliz}\n'
        '  Lote: ${rateio.codLote}\n'
        '  Qtde: ${rateio.qtdeLote} → $quantidade',
      );
    }

    // ✅ ADICIONE: VALIDAÇÃO antes de atualizar
    final erro = item.validarAtualizacaoRateio(
      rateioIndex: rateioIndex,
      novaQuantidade: quantidade,
    );
    if (erro != null) {
      if (kDebugMode) {
        debugPrint('❌ Validação falhou: $erro');
      }
      MessengerService.showError(erro);
      return;
    }

    if (kDebugMode) {
      debugPrint(
        '[RecebimentoVM] 📝 Atualizando rateio index=$rateioIndex:\n'
        '  Depósito: ${rateio.codDepos}\n'
        '  Localização: ${rateio.codLocaliz}\n'
        '  Lote: ${rateio.codLote}\n'
        '  Qtde: ${rateio.qtdeLote} → $quantidade',
      );
    }

    rateio.qtdeLote = quantidade;
    item.alteradoLocal = true;

    if (kDebugMode) {
      debugPrint(
        '[RecebimentoVM] ✅ Rateio atualizado: Nova soma total = ${item.qtdeConferida}',
      );
    }

    notifyListeners();
  }

  /// Remove rateio por ÍNDICE
  void removerRateioPorIndice(int nrSequencia, int rateioIndex) {
    if (_documentoSelecionado == null) return;

    final item = _documentoSelecionado!.itensDoc.firstWhere(
      (item) => item.nrSequencia == nrSequencia,
      orElse: () => throw StateError('Item não encontrado'),
    );

    if (!item.hasRateios || rateioIndex >= item.rateios!.length) {
      if (kDebugMode) {
        debugPrint('⚠️ Índice de rateio inválido para remoção: $rateioIndex');
      }
      return;
    }

    final rateio = item.rateios![rateioIndex];

    if (kDebugMode) {
      debugPrint(
        '[RecebimentoVM] 🗑️ Removendo rateio index=$rateioIndex:\n'
        '  ${rateio.codDepos}-${rateio.codLocaliz}-${rateio.codLote}',
      );
    }

    _deletarRateioNoBackend(nrSequencia, rateio).then((sucesso) {
      if (sucesso) {
        item.rateios!.removeAt(rateioIndex);

        item.alteradoLocal = true;

        notifyListeners();

        if (kDebugMode) {
          debugPrint('[RecebimentoVM] ✅ Rateio removido (marcado para sync)');
        }
      }
    });
  }
  // ==========================================================================
  // RATEIOS - Sincronização individual com backend
  // ==========================================================================

  /// Salva um rateio individual (quando usuário clica no botão salvar)
  Future<bool> salvarRateioIndividual(
    int nrSequencia,
    int rateioIndex,
  ) async {
    if (_documentoSelecionado == null) return false;

    final item = _documentoSelecionado!.itensDoc.firstWhere(
      (item) => item.nrSequencia == nrSequencia,
      orElse: () => throw StateError('Item não encontrado'),
    );

    if (!item.hasRateios || rateioIndex >= item.rateios!.length) {
      if (kDebugMode) {
        debugPrint('⚠️ Índice de rateio inválido: $rateioIndex');
      }
      return false;
    }

    final rateio = item.rateios![rateioIndex];

    if (kDebugMode) {
      debugPrint('💾 Salvando rateio individual:');
      debugPrint('   Item: ${item.codItem}');
      debugPrint('   Sequência: $nrSequencia');
      debugPrint('   Rateio index: $rateioIndex');
      debugPrint(
        '   ${rateio.codDepos}-${rateio.codLocaliz}-${rateio.codLote}',
      );
    }

    try {
      final user = _session.currentUser;
      if (user == null) return false;

      final result = await _syncService.salvarRateio(
        codEstabel: _documentoSelecionado!.codEstabel,
        codEmitente: _documentoSelecionado!.codEmitente,
        nroDocto: _documentoSelecionado!.nroDocto,
        serieDocto: _documentoSelecionado!.serieDocto,
        sequencia: nrSequencia,
        rateio: rateio,
        username: user.username,
        password: user.password,
      );

      // ✅ Se chegou aqui, foi sucesso
      if (kDebugMode) {
        debugPrint('✅ Rateio salvo com sucesso no backend');
      }

      // Marca como não editado localmente
      item.alteradoLocal = false;
      notifyListeners();

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Exceção ao salvar rateio: $e');
      }
      MessengerService.showError('Erro ao salvar rateio: $e');
      return false;
    }
  }

  /// Salva rateio no backend de forma assíncrona (após adicionar)
  Future<void> _salvarRateioNoBackend(
    int nrSequencia,
    int rateioIndex,
  ) async {
    if (_documentoSelecionado == null) return;

    final user = _session.currentUser;
    if (user == null) return;

    final item = _documentoSelecionado!.itensDoc.firstWhere(
      (item) => item.nrSequencia == nrSequencia,
      orElse: () => throw StateError('Item não encontrado'),
    );

    if (!item.hasRateios || rateioIndex >= item.rateios!.length) return;

    final rateio = item.rateios![rateioIndex];

    try {
      final result = await _syncService.salvarRateio(
        codEstabel: _documentoSelecionado!.codEstabel,
        codEmitente: _documentoSelecionado!.codEmitente,
        nroDocto: _documentoSelecionado!.nroDocto,
        serieDocto: _documentoSelecionado!.serieDocto,
        sequencia: nrSequencia,
        rateio: rateio,
        username: user.username,
        password: user.password,
      );

      // ✅ Se chegou aqui, foi sucesso
      if (kDebugMode) {
        debugPrint('✅ Rateio salvo com sucesso no backend');
      }

      // Marca como não editado localmente
      item.alteradoLocal = false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Exceção ao salvar rateio: $e');
      }
      MessengerService.showError('Erro ao salvar rateio: $e');
    }
  }

  /// Deleta rateio no backend
  Future<bool> _deletarRateioNoBackend(
    int nrSequencia,
    RatLoteModel rateio,
  ) async {
    if (_documentoSelecionado == null) return false;

    final user = _session.currentUser;
    if (user == null) return false;

    try {
      final result = await _syncService.removerRateio(
        codEstabel: _documentoSelecionado!.codEstabel,
        codEmitente: _documentoSelecionado!.codEmitente,
        nroDocto: _documentoSelecionado!.nroDocto,
        serieDocto: _documentoSelecionado!.serieDocto,
        sequencia: nrSequencia,
        codDepos: rateio.codDepos,
        codLocaliz: rateio.codLocaliz,
        codLote: rateio.codLote,
        username: user.username,
        password: user.password,
      );

      // ✅ Se chegou aqui, foi sucesso
      if (kDebugMode) {
        debugPrint('✅ Rateio deletado no backend');
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Exceção ao deletar rateio: $e');
      }
      MessengerService.showError('Erro ao deletar rateio: $e');
      return false;
    }
  }

  /// Atualiza rateio existente (botão "Salvar" na edição)
  ///
  /// FLUXO:
  /// 1. Valida item e rateio
  /// 2. Chama API de atualização (envia chave-busca + dados-novos)
  /// 3. Atualiza valores originais após sucesso
  /// 4. Remove flag de "alterado"
  Future<bool> atualizarRateioExistente(
    int nrSequencia,
    int rateioIndex,
  ) async {
    // ========================================================================
    // PASSO 1: Validações básicas
    // ========================================================================

    if (kDebugMode) {
      debugPrint('═══════════════════════════════════════');
      debugPrint('📝 [RecebimentoVM] Atualizando rateio existente');
      debugPrint('   Item sequência: $nrSequencia');
      debugPrint('   Rateio índice: $rateioIndex');
      debugPrint('═══════════════════════════════════════');
    }

    if (_documentoSelecionado == null) {
      MessengerService.showError('Documento não selecionado');
      return false;
    }

    final item = _documentoSelecionado!.itensDoc.firstWhere(
      (item) => item.nrSequencia == nrSequencia,
      orElse: () => throw StateError('Item não encontrado'),
    );

    if (!item.hasRateios || rateioIndex >= item.rateios!.length) {
      MessengerService.showError('Rateio inválido');
      return false;
    }

    final rateio = item.rateios![rateioIndex];
    final user = _session.currentUser;

    if (user == null) {
      MessengerService.showError('Usuário não autenticado');
      return false;
    }

    // ========================================================================
    // PASSO 2: Debug - Estado atual do rateio
    // ========================================================================

    if (kDebugMode) {
      debugPrint('📦 Estado do rateio:');
      debugPrint('   Valores ATUAIS:');
      debugPrint('     Depósito: ${rateio.codDepos}');
      debugPrint('     Localização: ${rateio.codLocaliz}');
      debugPrint('     Lote: ${rateio.codLote}');
      debugPrint('     Quantidade: ${rateio.qtdeLote}');
      debugPrint('   Valores ORIGINAIS (para busca no backend):');
      debugPrint('     Depósito: ${rateio.codDeposOriginal}');
      debugPrint('     Localização: ${rateio.codLocalizOriginal}');
      debugPrint('     Lote: ${rateio.codLoteOriginal}');
      debugPrint('   Chave mudou? ${rateio.chaveMudou}');
    }

    // ========================================================================
    // PASSO 3: Chama API de atualização
    // ========================================================================

    try {
      if (kDebugMode) {
        debugPrint('📡 Chamando API de atualização...');
      }

      // ✅ Service vai enviar:
      //    - chave-busca: usa valores ORIGINAIS
      //    - dados-novos: usa valores ATUAIS
      await _syncService.atualizarRateio(
        codEstabel: _documentoSelecionado!.codEstabel,
        codEmitente: _documentoSelecionado!.codEmitente,
        nroDocto: _documentoSelecionado!.nroDocto,
        serieDocto: _documentoSelecionado!.serieDocto,
        sequencia: nrSequencia,
        rateio: rateio,
        username: user.username,
        password: user.password,
      );

      // ========================================================================
      // PASSO 4: Atualiza valores originais após sucesso
      // ========================================================================

      if (kDebugMode) {
        debugPrint('✅ API retornou sucesso!');
        debugPrint('🔄 Atualizando valores originais...');
      }

      // ✅ IMPORTANTE: Agora os valores ATUAIS viram os ORIGINAIS
      //    Na próxima edição, vai buscar por esses valores
      rateio.codDeposOriginal = rateio.codDepos;
      rateio.codLocalizOriginal = rateio.codLocaliz;
      rateio.codLoteOriginal = rateio.codLote;

      if (kDebugMode) {
        debugPrint('   Novo estado original:');
        debugPrint('     Depósito: ${rateio.codDeposOriginal}');
        debugPrint('     Localização: ${rateio.codLocalizOriginal}');
        debugPrint('     Lote: ${rateio.codLoteOriginal}');
      }

      // ========================================================================
      // PASSO 5: Remove flag de alterado e notifica UI
      // ========================================================================

      item.alteradoLocal = false;
      notifyListeners();

      MessengerService.showSuccess('Rateio atualizado com sucesso!');

      if (kDebugMode) {
        debugPrint('═══════════════════════════════════════');
        debugPrint('✅ Processo concluído com sucesso!');
        debugPrint('═══════════════════════════════════════');
      }

      return true;
    } catch (e, stackTrace) {
      // ========================================================================
      // ERRO: Loga e mostra mensagem
      // ========================================================================

      if (kDebugMode) {
        debugPrint('═══════════════════════════════════════');
        debugPrint('❌ ERRO ao atualizar rateio');
        debugPrint('   Erro: $e');
        debugPrint('   Stack: $stackTrace');
        debugPrint('═══════════════════════════════════════');
      }

      MessengerService.showError('Erro ao atualizar rateio: $e');
      return false;
    }
  }
}
