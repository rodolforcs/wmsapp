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
    fetchDocumentosPendentes();
  }

  List<DoctoFisicoModel> _documentos = [];
  DoctoFisicoModel? _documentoSelecionado;
  String _searchTerm = '';

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

  Future<void> fetchDocumentosPendentes() async {
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
    _documentoSelecionado = documento;
    notifyListeners(); // Smpre notifica aqui primeiro

    if (documento.itensDoc.isNotEmpty) {
      if (kDebugMode) {
        debugPrint(
          '[RecebimentoVM] Documento selecionado: ${documento.nroDocto} \n'
          '[RecebimentoVM] Documento já possui itens carregados',
        );
      }
      return;
    }

    ///Busca detalhes complementos do documento
    if (kDebugMode) {
      debugPrint(
        '[RecebimentoVM] Buscando detalhes do documento: ${documento.nroDocto}',
      );
    }
    final user = _session.currentUser;
    if (user == null) return;

    final result = await runAsync(() async {
      return await _repository.buscarDetalhesDocto(
        codEstabel: documento.codEstabel,
        codEmitente: documento.codEmitente,
        nroDocto: documento.nroDocto,
        serieDocto: documento.serieDocto,
        username: user.username,
        password: user.password,
      );
    });

    if (result != null) {
      // Atualiza o documento na lista com os itens carregados
      final index = _documentos.indexWhere(
        (d) => d.chaveDocumento == documento.chaveDocumento,
      );

      if (index >= 0) {
        _documentos[index] = result;
        // _documentoSelecionado = result;
      }

      _documentoSelecionado = result;

      if (kDebugMode) {
        debugPrint(
          '[RecebimentoVM] Detalhes carregados: ${result.itensDoc.length} itens',
        );
      }
    }

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

    item.qtdeConferida = quantidade;

    if (item.hasRateios) {
      item.qtdeConferida = item.rateios!.fold<double>(
        0.0,
        (sum, rat) => sum + rat.qtdeLote,
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

    item.qtdeConferida = item.rateios!.fold<double>(
      0.0,
      (sum, rat) => sum + rat.qtdeLote,
    );

    notifyListeners();
  }

  void adicionarRateio(int nrSequencia, RatLoteModel rateio) {
    if (_documentoSelecionado == null) return;

    final item = _documentoSelecionado!.itensDoc.firstWhere(
      (item) => item.nrSequencia == nrSequencia,
    );

    item.rateios ??= [];
    item.rateios!.add(rateio);

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

    item.qtdeConferida = item.hasRateios
        ? item.rateios!.fold<double>(0.0, (sum, rat) => sum + rat.qtdeLote)
        : 0.0;

    notifyListeners();

    if (kDebugMode) {
      debugPrint('[RecebimentoVM] Rateio removido: $chaveRateio');
    }
  }

  Future<bool> finalizarConferencia() async {
    if (_documentoSelecionado == null) {
      MessengerService.showError('Nenhum documento selecionado.');
      return false;
    }

    final documento = _documentoSelecionado!;

    if (!documento.todosItensConferidos) {
      MessengerService.showError(
        'Por favor, confira todos os itens antes de finalizar.',
      );
      return false;
    }

    final user = _session.currentUser;
    if (user == null) {
      MessengerService.showError('Usuário não autenticado.');
      return false;
    }

    if (documento.temDivergencias) {
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
