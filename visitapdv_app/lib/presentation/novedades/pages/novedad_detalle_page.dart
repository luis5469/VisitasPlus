import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/novedad_entity.dart';
import '../bloc/novedad_bloc.dart';
import '../widgets/estado_badge.dart';

class NovedadDetallePage extends StatelessWidget {
  final String novedadId;
  const NovedadDetallePage({super.key, required this.novedadId});

  @override
  Widget build(BuildContext context) {
    context.read<NovedadBloc>().add(NovedadDetailRequested(novedadId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle Novedad'),
        actions: [
          IconButton(
            icon: const Icon(Icons.timeline),
            tooltip: 'Timeline',
            onPressed: () =>
                context.push('/novedades/$novedadId/timeline'),
          ),
          IconButton(
            icon: const Icon(Icons.photo_camera),
            tooltip: 'Fotos',
            onPressed: () =>
                context.push('/novedades/$novedadId/fotos'),
          ),
        ],
      ),
      body: BlocConsumer<NovedadBloc, NovedadState>(
        listener: (context, state) {
          if (state is NovedadActionSuccess) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
            context.read<NovedadBloc>().add(
                NovedadDetailRequested(novedadId));
          }
          if (state is NovedadError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is NovedadLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is NovedadError) {
            return Center(child: Text(state.message));
          }
          if (state is NovedadDetailLoaded) {
            return _Body(novedad: state.novedad, novedadId: novedadId);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ─── Body ────────────────────────────────────────────────────────────────────
class _Body extends StatelessWidget {
  final NovedadEntity novedad;
  final String novedadId;
  const _Body({required this.novedad, required this.novedadId});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM/yyyy HH:mm');
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Estado
          Row(
            children: [
              EstadoBadge(estado: novedad.estado, large: true),
              const Spacer(),
              TextButton.icon(
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Cambiar estado'),
                onPressed: () => _cambiarEstado(context),
              ),
            ],
          ),
          const Divider(height: 24),

          // Info principal
          _campo('Título', novedad.titulo),
          _campo('Descripción', novedad.descripcion),
          _campo('Categoría', novedad.categoria),
          _campo('Prioridad', novedad.prioridad),
          _campo('Fecha seguimiento',
              DateFormat('dd/MM/yyyy').format(novedad.fechaSeguimiento)),
          _campo('Creado en', fmt.format(novedad.creadoEn)),
          const Divider(height: 24),

          // Archivos Adjuntos
          if (novedad.imagenes.isNotEmpty) ...[
            const Text('Archivos Adjuntos',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: novedad.imagenes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final img = novedad.imagenes[i];
                  return GestureDetector(
                    onTap: () => context
                        .push('/novedades/$novedadId/fotos'),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey.shade200,
                        child: img.isImage
                            ? (img.urlImagen != null || img.rutaLocal != null
                                ? Image.network(img.urlImagen ?? img.rutaLocal!,
                                    width: 100, height: 100, fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 40, color: Colors.grey))
                                : const Icon(Icons.image, size: 40, color: Colors.grey))
                            : img.isVideo
                                ? Container(
                                    color: Colors.black87,
                                    child: const Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.play_circle_outline, color: Colors.white, size: 36),
                                          SizedBox(height: 2),
                                          Text('Video', style: TextStyle(color: Colors.white, fontSize: 11)),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(
                                    color: Colors.blueGrey.shade50,
                                    padding: const EdgeInsets.all(4),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            img.nombreArchivo.toLowerCase().endsWith('.pdf')
                                                ? Icons.picture_as_pdf
                                                : Icons.insert_drive_file,
                                            color: Colors.blueGrey.shade700,
                                            size: 32,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            img.nombreArchivo,
                                            maxLines: 2,
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 9),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _campo(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.grey, fontSize: 12)),
          Text(valor, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }

  void _cambiarEstado(BuildContext context) {
    final estados = [
      'EnProgreso', 'Resuelta', 'Cerrada', 'Reabierta', 'Vencida'
    ];
    final comentarioCtrl = TextEditingController();
    String estadoElegido = estados.first;

    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cambiar Estado'),
        content: StatefulBuilder(
          builder: (ctx, ss) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: estadoElegido,
                items: estados
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => ss(() => estadoElegido = v!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: comentarioCtrl,
                decoration: const InputDecoration(
                    labelText: 'Comentario', border: OutlineInputBorder()),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<NovedadBloc>().add(
                    NovedadCambiarEstadoRequested(
                      novedadId: novedad.id,
                      nuevoEstado: estadoElegido,
                      comentario: comentarioCtrl.text.trim(),
                    ),
                  );
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}
