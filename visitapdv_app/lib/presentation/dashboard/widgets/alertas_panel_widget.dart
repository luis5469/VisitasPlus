import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/dashboard_model.dart';

class AlertasPanel extends StatelessWidget {
  final List<AlertaDashboardModel> alertas;

  const AlertasPanel({super.key, required this.alertas});

  @override
  Widget build(BuildContext context) {
    if (alertas.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.green.shade400),
              const SizedBox(width: 10),
              const Text('Sin alertas activas',
                  style: TextStyle(color: Colors.green)),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Colors.red, size: 20),
                const SizedBox(width: 6),
                Text(
                  'Alertas Activas (${alertas.length})',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...alertas.take(10).map((a) => _AlertaTile(alerta: a)),
            if (alertas.length > 10)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '+ ${alertas.length - 10} alertas más',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AlertaTile extends StatelessWidget {
  final AlertaDashboardModel alerta;

  const _AlertaTile({required this.alerta});

  Color get _prioridadColor {
    switch (alerta.prioridad.toLowerCase()) {
      case 'crítica':
      case 'alta':
        return Colors.red.shade700;
      case 'media':
        return Colors.orange.shade700;
      default:
        return Colors.blue.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _prioridadColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              alerta.prioridad,
              style:
                  const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alerta.titulo,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 2),
                Text('${alerta.nombrePdv} · ${alerta.categoria}',
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade600)),
                const SizedBox(height: 2),
                Text(
                  'Resp: ${alerta.responsableNombre}  |  '
                  'Vence: ${DateFormat('dd/MM/yy').format(alerta.fechaSeguimiento)}',
                  style:
                      TextStyle(fontSize: 10, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              Text(
                '${alerta.diasVencida}d',
                style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
              Text('vencida',
                  style: TextStyle(fontSize: 9, color: Colors.grey.shade500)),
            ],
          ),
        ],
      ),
    );
  }
}
