// lib/ui/features/estoque/recebimento/widgets/checklist_item_tile.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wmsapp/data/models/checklist/checklist_item_model.dart';
import 'package:wmsapp/ui/features/estoque/recebimento/viewmodel/checklist_view_model.dart';

class ChecklistItemTile extends StatefulWidget {
  final ChecklistItemModel item;
  final int codChecklist;
  final int sequenciaCat;

  const ChecklistItemTile({
    Key? key,
    required this.item,
    required this.codChecklist,
    required this.sequenciaCat,
  }) : super(key: key);

  @override
  State<ChecklistItemTile> createState() => _ChecklistItemTileState();
}

class _ChecklistItemTileState extends State<ChecklistItemTile> {
  final TextEditingController _obsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.item.resposta?.observacao != null) {
      _obsController.text = widget.item.resposta!.observacao!;
    }
  }

  @override
  void dispose() {
    _obsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    // Item informativo (TEXT)
    if (item.tipoResposta == 'TEXT') {
      return _buildItemInformativo();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: item.isRespondido ? Colors.green.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: item.isRespondido
              ? Colors.green.shade300
              : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ================================================================
          // COLUNA 1: PERGUNTA (40%)
          // ================================================================
          Expanded(
            flex: 4,
            child: Row(
              children: [
                // Ícone de status
                Icon(
                  item.isRespondido
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  size: 20,
                  color: item.isRespondido
                      ? (item.isConforme ? Colors.green : Colors.orange)
                      : Colors.grey.shade400,
                ),
                const SizedBox(width: 8),

                // Texto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.desItem,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (item.tooltip.isNotEmpty)
                        Text(
                          item.tooltip,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ================================================================
          // COLUNA 2: OPÇÕES (30%)
          // ================================================================
          Expanded(
            flex: 3,
            child: _buildOpcoes(),
          ),

          const SizedBox(width: 12),

          // ================================================================
          // COLUNA 3: OBSERVAÇÃO (30%)
          // ================================================================
          if (item.permiteObs)
            Expanded(
              flex: 3,
              child: TextField(
                controller: _obsController,
                decoration: InputDecoration(
                  hintText: "Obs.",
                  hintStyle: const TextStyle(fontSize: 12),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                    borderSide: const BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
                style: const TextStyle(fontSize: 12),
                onChanged: (_) {
                  if (item.isRespondido) {
                    _salvarObservacao();
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================================================
  // OPÇÕES
  // ==========================================================================

  Widget _buildOpcoes() {
    if (widget.item.tipoResposta == 'SELECT') {
      return _buildOpcoesSelect();
    } else if (widget.item.tipoResposta == 'BOOLEAN') {
      return _buildOpcoesBoolean();
    }
    return const SizedBox.shrink();
  }

  Widget _buildOpcoesSelect() {
    final opcoes = widget.item.opcoes;
    final respostaAtual = widget.item.resposta?.respostaText;

    return Wrap(
      spacing: 4,
      runSpacing: 0,
      children: opcoes.map((opcao) {
        final isSelected = respostaAtual == opcao;

        return InkWell(
          onTap: () => _salvarRespostaSelect(opcao),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Radio<String>(
                value: opcao,
                groupValue: respostaAtual,
                onChanged: (value) {
                  if (value != null) _salvarRespostaSelect(value);
                },
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              Text(
                opcao,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? _getCorOpcao(opcao)
                      : Colors.grey.shade700,
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getCorOpcao(String opcao) {
    switch (opcao.toUpperCase()) {
      case 'OK':
        return Colors.green.shade700;
      case 'NOK':
        return Colors.red.shade700;
      case 'N/A':
        return Colors.orange.shade700;
      default:
        return Colors.blue.shade700;
    }
  }

  Widget _buildOpcoesBoolean() {
    final resposta = widget.item.resposta?.respostaBoolean ?? false;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'NÃO',
          style: TextStyle(
            fontSize: 12,
            fontWeight: !resposta ? FontWeight.bold : FontWeight.normal,
            color: !resposta ? Colors.red.shade700 : Colors.grey,
          ),
        ),
        Switch(
          value: resposta,
          onChanged: (value) => _salvarRespostaBoolean(value),
          activeColor: Colors.green,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Text(
          'SIM',
          style: TextStyle(
            fontSize: 12,
            fontWeight: resposta ? FontWeight.bold : FontWeight.normal,
            color: resposta ? Colors.green.shade700 : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildItemInformativo() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.item.desItem,
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade900,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // SALVAR
  // ==========================================================================

  void _salvarRespostaSelect(String resposta) {
    final viewModel = context.read<ChecklistViewModel>();
    viewModel.salvarRespostaSelect(
      sequenciaCat: widget.sequenciaCat,
      sequenciaItem: widget.item.sequenciaItem,
      resposta: resposta,
      observacao: _obsController.text.isNotEmpty ? _obsController.text : null,
    );
  }

  void _salvarRespostaBoolean(bool resposta) {
    final viewModel = context.read<ChecklistViewModel>();
    viewModel.salvarRespostaBoolean(
      sequenciaCat: widget.sequenciaCat,
      sequenciaItem: widget.item.sequenciaItem,
      resposta: resposta,
      observacao: _obsController.text.isNotEmpty ? _obsController.text : null,
    );
  }

  void _salvarObservacao() {
    if (!widget.item.isRespondido) return;

    final viewModel = context.read<ChecklistViewModel>();

    if (widget.item.tipoResposta == 'SELECT') {
      viewModel.salvarRespostaSelect(
        sequenciaCat: widget.sequenciaCat,
        sequenciaItem: widget.item.sequenciaItem,
        resposta: widget.item.resposta!.respostaText!,
        observacao: _obsController.text,
      );
    } else if (widget.item.tipoResposta == 'BOOLEAN') {
      viewModel.salvarRespostaBoolean(
        sequenciaCat: widget.sequenciaCat,
        sequenciaItem: widget.item.sequenciaItem,
        resposta: widget.item.resposta!.respostaBoolean!,
        observacao: _obsController.text,
      );
    }
  }
}
/*
```

---

## ✅ **RESULTADO FINAL:**
```
┌────────────────────────────────────────────┐
│ 📋 Checklist Padrão                        │ AppBar
│    NF 0220727-1                            │
├────────────────────────────────────────────┤
│ 2 de 6 itens                        33%    │ Progresso
│ [████░░░░░░░░]                             │ (direto)
├────────────────────────────────────────────┤
│                                            │
│ ┌────────────────────────────────────────┐ │
│ │ 🚚 Veículo                      50% ▼  │ │ Categoria
│ ├────────────────────────────────────────┤ │
│ │ ✓ Protegido? │ ●OK ○NOK ○N/A │ [Obs_]│ │ Item
│ │ ○ Limpo?     │ ○OK ○NOK ○N/A │ [____]│ │ Item
│ └────────────────────────────────────────┘ │
│                                            │
│ ┌────────────────────────────────────────┐ │
│ │ 📦 Material                     0%  ▼  │ │ Categoria
│ └────────────────────────────────────────┘ │
├────────────────────────────────────────────┤
│ [Salvar Rascunho]  [✓ Finalizar]          │ Footer
└────────────────────────────────────────────┘
*/