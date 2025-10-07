import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wmsapp/ui/features/estoque/viewmodel/estoque_view_model.dart';
import 'package:wmsapp/ui/features/menu/widgets/menu_item_card.dart';
import 'package:wmsapp/ui/features/estoque/recebimento/view/recebimento_screen.dart';

class EstoqueOperationsView extends StatelessWidget {
  const EstoqueOperationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<EstoqueViewModel>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.0,
        ),
        itemCount: viewModel.subModulos.length,
        itemBuilder: (context, index) {
          final subModulo = viewModel.subModulos[index];
          return MenuItemCard(
            label: subModulo.label,
            icon: subModulo.icon,
            isEnabled: subModulo.isEnabled,
            onTap: () {
              if (subModulo.isEnabled) {
                // Navega baseado no label do submódulo
                _navegarParaSubModulo(context, subModulo.label);
              }
            },
          );
        },
      ),
    );
  }

  /// Navega para o submódulo correto baseado no label
  void _navegarParaSubModulo(BuildContext context, String label) {
    switch (label.toLowerCase()) {
      case 'recebimento':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const RecebimentoScreen(),
          ),
        );
        break;

      case 'expedição':
      case 'expedicao':
        // TODO: Criar tela de Expedição
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expedição em desenvolvimento')),
        );
        break;

      case 'inventário':
      case 'inventario':
        // TODO: Criar tela de Inventário
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inventário em desenvolvimento')),
        );
        break;

      case 'transferência':
      case 'transferencia':
        // TODO: Criar tela de Transferência
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transferência em desenvolvimento')),
        );
        break;

      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Acessando: $label')),
        );
    }
  }
}
