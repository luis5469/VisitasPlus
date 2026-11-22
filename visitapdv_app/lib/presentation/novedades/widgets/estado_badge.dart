import 'package:flutter/material.dart';

class EstadoBadge extends StatelessWidget {
  final String estado;
  final bool large;
  const EstadoBadge({super.key, required this.estado, this.large = false});

  @override
  Widget build(BuildContext context) {
    final color = _color(estado);
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: large ? 12 : 8, vertical: large ? 6 : 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        estado,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: large ? 14 : 11,
        ),
      ),
    );
  }

  Color _color(String estado) {
    switch (estado.toLowerCase()) {
      case 'abierta':
        return Colors.blue;
      case 'enprogreso':
        return Colors.orange;
      case 'resuelta':
        return Colors.green;
      case 'cerrada':
        return Colors.grey;
      case 'reabierta':
        return Colors.purple;
      case 'vencida':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }
}
