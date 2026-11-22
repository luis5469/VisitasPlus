import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/novedad_bloc.dart';
import '../../../domain/entities/novedad_entity.dart';
import '../widgets/estado_badge.dart';

class NovedadTimelinePage extends StatelessWidget {
  final String novedadId;
  const NovedadTimelinePage({super.key, required this.novedadId});

  @override
  Widget build(BuildContext context) {
    context.read<NovedadBloc>().add(NovedadDetailRequested(novedadId));

    return Scaffold(
      appBar: AppBar(title: const Text('Timeline')),
      body: BlocBuilder<NovedadBloc, NovedadState>(
        builder: (context, state) {
          if (state is NovedadLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is NovedadError) {
            return Center(child: Text(state.message));
          }
          if (state is NovedadDetailLoaded) {
            final historial = state.novedad.historial;
            if (historial.isEmpty) {
              return const Center(
                  child: Text('Sin historial de cambios aún.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(
                  vertical: 16, horizontal: 8),
              itemCount: historial.length,
              itemBuilder: (context, i) {
                final h = historial[i];
                return _TimelineItem(
                  item: h,
                  isLast: i == historial.length - 1,
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final NovedadHistorialEntity item;
  final bool isLast;
  const _TimelineItem({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    final colorEstado = _colorPorEstado(item.estadoNuevo);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline line + dot
          SizedBox(
            width: 48,
            child: Column(
              children: [
                CircleAvatar(
                  backgroundColor: colorEstado,
                  radius: 10,
                  child: const Icon(Icons.circle,
                      size: 10, color: Colors.white),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                        width: 2, color: Colors.grey.shade300),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorEstado.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorEstado.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      EstadoBadge(estado: item.estadoNuevo),
                      const SizedBox(width: 8),
                      if (item.estadoAnterior != null)
                        Text('← ${item.estadoAnterior}',
                            style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (item.comentario != null && item.comentario!.isNotEmpty)
                    Text(item.comentario!),
                  const SizedBox(height: 4),
                  Text(
                    fmt.format(item.creadoEn),
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _colorPorEstado(String estado) {
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
