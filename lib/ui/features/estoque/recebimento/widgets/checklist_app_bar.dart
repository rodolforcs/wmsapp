// lib/ui/features/estoque/recebimento/widgets/checklist_app_bar.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wmsapp/ui/features/estoque/recebimento/viewmodel/checklist_view_model.dart';

/// AppBar customizada do Checklist
class ChecklistAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String nroDocto;
  final String serieDocto;
  final VoidCallback onInfoPressed;

  const ChecklistAppBar({
    super.key,
    required this.nroDocto,
    required this.serieDocto,
    required this.onInfoPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Consumer<ChecklistViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                viewModel.tituloChecklist,
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                'NF $nroDocto-$serieDocto',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: onInfoPressed,
          tooltip: 'Informações',
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
