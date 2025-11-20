// lib/ui/features/estoque/recebimento/viewmodel/checklist_view_model.dart

import 'package:flutter/foundation.dart';
import 'package:wmsapp/core/services/messenger_service.dart';
import 'package:wmsapp/core/viewmodel/base_view_model.dart';
import 'package:wmsapp/core/viewmodel/session_view_model.dart';
import 'package:wmsapp/data/models/checklist/checklist_model.dart';
import 'package:wmsapp/data/models/checklist/checklist_categoria_model.dart';
import 'package:wmsapp/data/models/checklist/checklist_item_model.dart';
import 'package:wmsapp/data/repositories/checklist/checklist_repository.dart';

/// 📋 ViewModel responsável pela lógica do Checklist
///
/// Segue o mesmo padrão do RecebimentoViewModel:
/// - Extends BaseViewModel
/// - Usa SessionViewModel para dados do usuário
/// - Notifica listeners com notifyListeners()
class ChecklistViewModel extends BaseViewModel {
  final ChecklistRepository _repository;
  final SessionViewModel _session;

  ChecklistViewModel({
    required ChecklistRepository repository,
    required SessionViewModel session,
  }) : _repository = repository,
       _session = session {
    if (kDebugMode) {
      debugPrint(
        '[ChecklistVM] 🏗️ ViewModel CRIADO (ID: ${identityHashCode(this)})',
      );
    }
  }

  // ==========================================================================
  // ESTADO
  // ==========================================================================

  ChecklistModel? _checklist;
  bool _isSaving = false;
  bool _isFinalizing = false;

  // ==========================================================================
  // GETTERS
  // ==========================================================================

  ChecklistModel? get checklist => _checklist;
  bool get hasChecklist => _checklist != null;
  bool get isSaving => _isSaving;
  bool get isFinalizing => _isFinalizing;

  // Informações do checklist
  String get tituloChecklist => _checklist?.desTemplate ?? 'Checklist';
  String get situacaoDescricao => _checklist?.situacaoDescricao ?? 'Pendente';
  double get percentualConclusao => _checklist?.percentualConclusao ?? 0.0;
  int get totalItens => _checklist?.totalItens ?? 0;
  int get itensRespondidos => _checklist?.itensRespondidos ?? 0;

  // Validações
  bool get todosItensRespondidos => _checklist?.todosItensRespondidos ?? false;
  bool get podeFinalizar => todosItensRespondidos;

  String get motivoNaoPodeFinalizar {
    if (_checklist == null) return 'Checklist não carregado';

    final erro = _repository.validarPodeFinalizar(_checklist!);
    return erro ?? '';
  }

  // ==========================================================================
  // 🔍 BUSCAR/CRIAR CHECKLIST
  // ==========================================================================

  /// Busca ou cria checklist para o documento
  ///
  /// Exemplo de uso:
  /// ```dart
  /// await checklistViewModel.carregarChecklist(
  ///   codEstabel: '203',
  ///   codEmitente: 89750,
  ///   nroDocto: '0220727',
  ///   serieDocto: '1',
  /// );
  /// ```
  Future<void> carregarChecklist({
    required String codEstabel,
    required int codEmitente,
    required String nroDocto,
    required String serieDocto,
  }) async {
    if (kDebugMode) {
      debugPrint('═══════════════════════════════════════');
      debugPrint('[ChecklistVM] 🔄 Carregando checklist...');
      debugPrint('   Documento: $nroDocto-$serieDocto');
      debugPrint('   Emitente: $codEmitente');
      debugPrint('═══════════════════════════════════════');
    }

    final user = _session.currentUser;
    if (user == null) {
      setError('Usuário não autenticado.');
      MessengerService.showError('Usuário não autenticado');
      notifyListeners();
      return;
    }

    // Usa runAsync do BaseViewModel (gerencia isLoading automaticamente)
    final result = await runAsync(() async {
      return await _repository.buscarOuCriarChecklist(
        codEstabel: codEstabel,
        codEmitente: codEmitente,
        nroDocto: nroDocto,
        serieDocto: serieDocto,
        username: user.username,
        password: user.password,
      );
    });

    if (result != null) {
      _checklist = result;

      if (kDebugMode) {
        debugPrint('✅ [ChecklistVM] Checklist carregado:');
        debugPrint('   Código: ${result.codChecklist}');
        debugPrint('   Template: ${result.desTemplate}');
        debugPrint('   Criado agora: ${result.criadoAgora}');
        debugPrint('   Categorias: ${result.categorias.length}');
        debugPrint('   Total itens: ${result.totalItens}');
        debugPrint(
          '   Progresso: ${result.percentualConclusao.toStringAsFixed(1)}%',
        );
        debugPrint('═══════════════════════════════════════');
      }

      if (result.criadoAgora) {
        MessengerService.showSuccess('Checklist iniciado com sucesso!');
      }
    } else {
      _checklist = null;

      if (kDebugMode) {
        debugPrint('❌ [ChecklistVM] Erro ao carregar: $errorMessage');
        debugPrint('═══════════════════════════════════════');
      }

      MessengerService.showError(
        errorMessage ?? 'Erro ao carregar checklist',
      );
    }

    notifyListeners();
  }

  // ==========================================================================
  // 💾 SALVAR RESPOSTA DE ITEM
  // ==========================================================================

  /// Salva resposta de um item (SELECT)
  ///
  /// Exemplo:
  /// ```dart
  /// await salvarRespostaSelect(
  ///   sequenciaCat: 1,
  ///   sequenciaItem: 1,
  ///   resposta: 'OK',
  ///   observacao: 'Tudo conforme',
  /// );
  /// ```
  Future<void> salvarRespostaSelect({
    required int sequenciaCat,
    required int sequenciaItem,
    required String resposta,
    String? observacao,
  }) async {
    if (_checklist == null) return;

    if (kDebugMode) {
      debugPrint('═══════════════════════════════════════');
      debugPrint('[ChecklistVM] 💾 Salvando resposta SELECT...');
      debugPrint('   Item: $sequenciaCat-$sequenciaItem');
      debugPrint('   Resposta: $resposta');
      if (observacao != null && observacao.isNotEmpty) {
        debugPrint('   Observação: $observacao');
      }
    }

    _isSaving = true;
    notifyListeners();

    final user = _session.currentUser;
    if (user == null) {
      MessengerService.showError('Usuário não autenticado');
      _isSaving = false;
      notifyListeners();
      return;
    }

    try {
      // Determina se é conforme (OK = conforme, NOK/N/A = não conforme)
      final conforme = resposta.toUpperCase() == 'OK';

      // Salva no backend
      await _repository.salvarRespostaItem(
        codChecklist: _checklist!.codChecklist,
        sequenciaCat: sequenciaCat,
        sequenciaItem: sequenciaItem,
        respostaText: resposta,
        observacao: observacao,
        conforme: conforme,
        username: user.username,
        password: user.password,
      );

      // Atualiza localmente
      _atualizarRespostaLocal(
        sequenciaCat: sequenciaCat,
        sequenciaItem: sequenciaItem,
        respostaText: resposta,
        observacao: observacao,
        conforme: conforme,
      );

      if (kDebugMode) {
        debugPrint('✅ [ChecklistVM] Resposta salva!');
        debugPrint('═══════════════════════════════════════');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('❌ [ChecklistVM] Erro ao salvar resposta: $e');
        debugPrint('Stack: $stack');
        debugPrint('═══════════════════════════════════════');
      }

      MessengerService.showError('Erro ao salvar resposta: $e');
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Salva resposta de um item (BOOLEAN)
  Future<void> salvarRespostaBoolean({
    required int sequenciaCat,
    required int sequenciaItem,
    required bool resposta,
    String? observacao,
  }) async {
    if (_checklist == null) return;

    if (kDebugMode) {
      debugPrint('═══════════════════════════════════════');
      debugPrint('[ChecklistVM] 💾 Salvando resposta BOOLEAN...');
      debugPrint('   Item: $sequenciaCat-$sequenciaItem');
      debugPrint('   Resposta: ${resposta ? "SIM" : "NÃO"}');
    }

    _isSaving = true;
    notifyListeners();

    final user = _session.currentUser;
    if (user == null) {
      MessengerService.showError('Usuário não autenticado');
      _isSaving = false;
      notifyListeners();
      return;
    }

    try {
      await _repository.salvarRespostaItem(
        codChecklist: _checklist!.codChecklist,
        sequenciaCat: sequenciaCat,
        sequenciaItem: sequenciaItem,
        respostaBoolean: resposta,
        observacao: observacao,
        conforme: resposta, // TRUE = conforme
        username: user.username,
        password: user.password,
      );

      // Atualiza localmente
      _atualizarRespostaLocal(
        sequenciaCat: sequenciaCat,
        sequenciaItem: sequenciaItem,
        respostaBoolean: resposta,
        observacao: observacao,
        conforme: resposta,
      );

      if (kDebugMode) {
        debugPrint('✅ [ChecklistVM] Resposta salva!');
        debugPrint('═══════════════════════════════════════');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('❌ [ChecklistVM] Erro ao salvar resposta: $e');
        debugPrint('Stack: $stack');
        debugPrint('═══════════════════════════════════════');
      }

      MessengerService.showError('Erro ao salvar resposta: $e');
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Salva resposta de um item (TEXT)
  Future<void> salvarRespostaText({
    required int sequenciaCat,
    required int sequenciaItem,
    required String resposta,
    String? observacao,
  }) async {
    if (_checklist == null) return;

    if (kDebugMode) {
      debugPrint('═══════════════════════════════════════');
      debugPrint('[ChecklistVM] 💾 Salvando resposta TEXT...');
      debugPrint('   Item: $sequenciaCat-$sequenciaItem');
      debugPrint('   Resposta: $resposta');
    }

    _isSaving = true;
    notifyListeners();

    final user = _session.currentUser;
    if (user == null) {
      MessengerService.showError('Usuário não autenticado');
      _isSaving = false;
      notifyListeners();
      return;
    }

    try {
      await _repository.salvarRespostaItem(
        codChecklist: _checklist!.codChecklist,
        sequenciaCat: sequenciaCat,
        sequenciaItem: sequenciaItem,
        respostaText: resposta,
        observacao: observacao,
        username: user.username,
        password: user.password,
      );

      // Atualiza localmente
      _atualizarRespostaLocal(
        sequenciaCat: sequenciaCat,
        sequenciaItem: sequenciaItem,
        respostaText: resposta,
        observacao: observacao,
      );

      if (kDebugMode) {
        debugPrint('✅ [ChecklistVM] Resposta salva!');
        debugPrint('═══════════════════════════════════════');
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('❌ [ChecklistVM] Erro ao salvar resposta: $e');
        debugPrint('Stack: $stack');
        debugPrint('═══════════════════════════════════════');
      }

      MessengerService.showError('Erro ao salvar resposta: $e');
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // ==========================================================================
  // 🔄 ATUALIZAR RESPOSTA LOCAL
  // ==========================================================================

  /// Atualiza resposta localmente (após salvar no backend)
  void _atualizarRespostaLocal({
    required int sequenciaCat,
    required int sequenciaItem,
    bool? respostaBoolean,
    String? respostaText,
    double? respostaNumber,
    DateTime? respostaDate,
    String? observacao,
    bool? conforme,
  }) {
    if (_checklist == null) return;

    // Busca categoria
    final categoriaIndex = _checklist!.categorias.indexWhere(
      (cat) => cat.sequenciaCat == sequenciaCat,
    );

    if (categoriaIndex == -1) {
      if (kDebugMode) {
        debugPrint('⚠️ Categoria $sequenciaCat não encontrada');
      }
      return;
    }

    final categoria = _checklist!.categorias[categoriaIndex];

    // Busca item
    final itemIndex = categoria.itens.indexWhere(
      (item) => item.sequenciaItem == sequenciaItem,
    );

    if (itemIndex == -1) {
      if (kDebugMode) {
        debugPrint('⚠️ Item $sequenciaItem não encontrado');
      }
      return;
    }

    // Atualiza item com nova resposta
    final itemAtualizado = categoria.itens[itemIndex].comResposta(
      respostaBoolean: respostaBoolean,
      respostaText: respostaText,
      respostaNumber: respostaNumber,
      respostaDate: respostaDate,
      observacao: observacao,
      conforme: conforme,
    );

    // Substitui item na lista
    final novosItens = List<ChecklistItemModel>.from(categoria.itens);
    novosItens[itemIndex] = itemAtualizado;

    // Atualiza categoria
    final categoriaAtualizada = categoria.copyWith(itens: novosItens);

    // Substitui categoria na lista
    final novasCategorias = List<ChecklistCategoriaModel>.from(
      _checklist!.categorias,
    );
    novasCategorias[categoriaIndex] = categoriaAtualizada;

    // Atualiza checklist
    _checklist = _checklist!.copyWith(categorias: novasCategorias);

    // Recalcula percentual (simplificado - backend calcula o real)
    final novoPercentual =
        (_checklist!.itensRespondidos / _checklist!.totalItens) * 100;
    _checklist = _checklist!.copyWith(percentualConclusao: novoPercentual);

    if (kDebugMode) {
      debugPrint('✅ Resposta atualizada localmente');
      debugPrint('   Progresso: ${novoPercentual.toStringAsFixed(1)}%');
      debugPrint(
        '   Itens respondidos: ${_checklist!.itensRespondidos}/${_checklist!.totalItens}',
      );
    }
  }

  // ==========================================================================
  // 🏁 FINALIZAR CHECKLIST
  // ==========================================================================

  /// Finaliza o checklist
  Future<bool> finalizarChecklist({
    String? observacaoGeral,
    bool aprovado = true,
  }) async {
    if (_checklist == null) {
      MessengerService.showError('Checklist não carregado');
      return false;
    }

    if (kDebugMode) {
      debugPrint('═══════════════════════════════════════');
      debugPrint('[ChecklistVM] 🏁 Finalizando checklist...');
      debugPrint('   Código: ${_checklist!.codChecklist}');
      debugPrint('   Aprovado: $aprovado');
    }

    // Validação
    if (!todosItensRespondidos) {
      final mensagem = motivoNaoPodeFinalizar;
      MessengerService.showError(mensagem);
      return false;
    }

    _isFinalizing = true;
    notifyListeners();

    final user = _session.currentUser;
    if (user == null) {
      MessengerService.showError('Usuário não autenticado');
      _isFinalizing = false;
      notifyListeners();
      return false;
    }

    try {
      final sucesso = await _repository.finalizarChecklist(
        checklist: _checklist!,
        username: user.username,
        password: user.password,
        observacaoGeral: observacaoGeral,
        aprovado: aprovado,
      );

      if (sucesso) {
        if (kDebugMode) {
          debugPrint('✅ [ChecklistVM] Checklist finalizado!');
          debugPrint('═══════════════════════════════════════');
        }

        MessengerService.showSuccess(
          aprovado
              ? 'Checklist aprovado com sucesso!'
              : 'Checklist finalizado!',
        );

        // Atualiza situação localmente
        _checklist = _checklist!.copyWith(
          situacao: aprovado ? 3 : 2, // 3=Aprovado, 2=Concluído
        );

        notifyListeners();
        return true;
      }

      return false;
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('❌ [ChecklistVM] Erro ao finalizar: $e');
        debugPrint('Stack: $stack');
        debugPrint('═══════════════════════════════════════');
      }

      MessengerService.showError('Erro ao finalizar checklist: $e');
      return false;
    } finally {
      _isFinalizing = false;
      notifyListeners();
    }
  }

  // ==========================================================================
  // 🧹 CLEANUP
  // ==========================================================================

  void limparChecklist() {
    _checklist = null;
    notifyListeners();

    if (kDebugMode) {
      debugPrint('[ChecklistVM] Checklist limpo');
    }
  }

  @override
  void dispose() {
    if (kDebugMode) {
      debugPrint('[ChecklistVM] Disposed');
    }
    super.dispose();
  }
}
/*
```

---

## ✅ VIEWMODEL CRIADO!

**Estrutura:**
```
lib/ui/features/estoque/recebimento/viewmodel/
└── checklist_view_model.dart
```

---

## 📋 MÉTODOS PÚBLICOS:

| Método | Função | Notifica UI |
|--------|--------|-------------|
| **carregarChecklist** | Busca/cria checklist | ✅ |
| **salvarRespostaSelect** | Salva SELECT | ✅ |
| **salvarRespostaBoolean** | Salva SIM/NÃO | ✅ |
| **salvarRespostaText** | Salva texto livre | ✅ |
| **finalizarChecklist** | Finaliza checklist | ✅ |
| **limparChecklist** | Limpa estado | ✅ |

---

## 🎯 CARACTERÍSTICAS:

✅ Extends `BaseViewModel` (gerencia `isLoading`)
✅ Usa `SessionViewModel` para dados do usuário
✅ Logs detalhados com debugPrint
✅ Atualização otimista (local + backend)
✅ Tratamento de erros com `MessengerService`
✅ Validações antes de finalizar
✅ Recalcula percentual automaticamente

---

## 📊 PROGRESSO:
```
✅ Models     (4 arquivos)
✅ Service    (1 arquivo)
✅ Repository (1 arquivo)
✅ ViewModel  (1 arquivo)
⏳ View       (próximo)
⏳ Widgets    (próximo)
*/