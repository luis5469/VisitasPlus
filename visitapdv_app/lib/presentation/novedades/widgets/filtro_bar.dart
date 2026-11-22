import 'package:flutter/material.dart';

class FiltroBar extends StatelessWidget {
  final String? estado;
  final String? categoria;
  final VoidCallback onClear;
  const FiltroBar({
    super.key,
    this.estado,
    this.categoria,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.filter_list, size: 16),
          const SizedBox(width: 6),
          if (estado != null)
            Chip(
                label: Text(estado!),
                visualDensity: VisualDensity.compact),
          if (estado != null && categoria != null)
            const SizedBox(width: 4),
          if (categoria != null)
            Chip(
                label: Text(categoria!),
                visualDensity: VisualDensity.compact),
          const Spacer(),
          TextButton(
              onPressed: onClear, child: const Text('Limpiar')),
        ],
      ),
    );
  }
}
