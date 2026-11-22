import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:geolocator/geolocator.dart';

import '../bloc/novedad_bloc.dart';
import '../../../core/services/camera_service.dart';
import '../../../core/services/imagen_offline_queue.dart';
import '../../../core/utils/gps_helper.dart';

class AdjuntarFotosPage extends StatefulWidget {
  final String novedadId;
  final String usuarioNombre;
  const AdjuntarFotosPage({
    super.key,
    required this.novedadId,
    required this.usuarioNombre,
  });

  @override
  State<AdjuntarFotosPage> createState() => _AdjuntarFotosPageState();
}

class _AdjuntarFotosPageState extends State<AdjuntarFotosPage> {
  final List<CameraCaptura> _preview = [];
  bool _cargando = false;

  bool _esImagen(String filename) {
    final name = filename.toLowerCase();
    return name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.png') ||
        name.endsWith('.gif') ||
        name.endsWith('.webp');
  }

  bool _esVideo(String filename) {
    final name = filename.toLowerCase();
    return name.endsWith('.mp4') ||
        name.endsWith('.mov') ||
        name.endsWith('.avi') ||
        name.endsWith('.mkv');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adjuntar Multimedia'),
        actions: [
          BlocBuilder<NovedadBloc, NovedadState>(
            builder: (context, state) {
              final pendientes =
                  state is NovedadImagenesSincronizadas
                      ? state.pendientes
                      : 0;
              if (pendientes == 0) return const SizedBox.shrink();
              return Badge(
                label: Text('$pendientes'),
                child: IconButton(
                  icon: const Icon(Icons.cloud_upload),
                  tooltip: 'Sincronizar cola offline',
                  onPressed: () {
                    context.read<NovedadBloc>().add(
                        const NovedadSincronizarImagenesRequested());
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: BlocListener<NovedadBloc, NovedadState>(
        listener: (context, state) {
          if (state is NovedadActionSuccess) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
            setState(() => _cargando = false);
          }
          if (state is NovedadError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red),
            );
            setState(() => _cargando = false);
          }
          if (state is NovedadSubiendoImagen) {
            setState(() => _cargando = true);
          }
        },
        child: Column(
          children: [
            // Botones captura multimedia y documentos
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Foto (Cámara)'),
                          onPressed: _cargando
                              ? null
                              : () => _capturarFoto(ImageSource.camera),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.videocam),
                          label: const Text('Video (Cámara)'),
                          onPressed: _cargando
                              ? null
                              : () => _capturarVideo(ImageSource.camera),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.collections),
                          label: const Text('Galería'),
                          onPressed: _cargando
                              ? null
                              : () => _mostrarOpcionesGalerias(context),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.attach_file),
                          label: const Text('Documento'),
                          onPressed: _cargando
                              ? null
                              : () => _seleccionarDocumento(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (_cargando) const LinearProgressIndicator(),

            // Vista previa
            Expanded(
              child: _preview.isEmpty
                  ? const Center(
                      child: Text(
                          'Sin adjuntos aún. Selecciona foto, video o documento.'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                      ),
                      itemCount: _preview.length,
                      itemBuilder: (context, i) {
                        final captura = _preview[i];
                        final file = File(captura.rutaLocal);
                        final isImg = _esImagen(captura.nombreArchivo);
                        final isVid = _esVideo(captura.nombreArchivo);

                        return GestureDetector(
                          onTap: () => _verPreview(context, i),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (isImg)
                                Image.file(file, fit: BoxFit.cover)
                              else if (isVid)
                                Container(
                                  color: Colors.black87,
                                  child: const Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.play_circle_fill,
                                            color: Colors.white, size: 40),
                                        SizedBox(height: 4),
                                        Text('Video',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  color: Colors.blueGrey.shade100,
                                  padding: const EdgeInsets.all(8),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          captura.nombreArchivo
                                                  .toLowerCase()
                                                  .endsWith('.pdf')
                                              ? Icons.picture_as_pdf
                                              : Icons.description,
                                          color: Colors.blueGrey.shade700,
                                          size: 36,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          captura.nombreArchivo.split('/').last,
                                          style: TextStyle(
                                              color: Colors.blueGrey.shade900,
                                              fontSize: 10),
                                          maxLines: 2,
                                          textAlign: TextAlign.center,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => setState(
                                      () => _preview.removeAt(i)),
                                  child: const CircleAvatar(
                                    radius: 12,
                                    backgroundColor: Colors.red,
                                    child: Icon(Icons.close,
                                        size: 14,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            // Botón subir todo
            if (_preview.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.upload),
                    label: Text(
                        'Subir ${_preview.length} archivo(s)'),
                    onPressed: _cargando ? null : _subirTodas,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _mostrarOpcionesGalerias(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Seleccionar Foto de Galería'),
                onTap: () {
                  Navigator.pop(context);
                  _capturarFoto(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_library),
                title: const Text('Seleccionar Video de Galería'),
                onTap: () {
                  Navigator.pop(context);
                  _capturarVideo(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _capturarFoto(ImageSource source) async {
    final bloc = context.read<NovedadBloc>();
    bloc.add(NovedadCapturarImagenRequested(
      usuarioNombre: widget.usuarioNombre,
      source: source,
    ));

    await _esperarCaptura(bloc);
  }

  Future<void> _capturarVideo(ImageSource source) async {
    final bloc = context.read<NovedadBloc>();
    bloc.add(NovedadCapturarVideoRequested(
      usuarioNombre: widget.usuarioNombre,
      source: source,
    ));

    await _esperarCaptura(bloc);
  }

  Future<void> _seleccionarDocumento() async {
    final bloc = context.read<NovedadBloc>();
    bloc.add(const NovedadSeleccionarDocumentoRequested());

    await _esperarCaptura(bloc);
  }

  Future<void> _esperarCaptura(NovedadBloc bloc) async {
    await bloc.stream
        .firstWhere((s) =>
            s is NovedadImagenCapturada ||
            s is NovedadError)
        .then((s) {
      if (s is NovedadImagenCapturada) {
        setState(() => _preview.add(s.captura));
      }
    });
  }

  Future<void> _subirTodas() async {
    final bloc = context.read<NovedadBloc>();

    for (final captura in List<CameraCaptura>.from(_preview)) {
      bloc.add(NovedadSubirImagenRequested(
        novedadId: widget.novedadId,
        archivo: File(captura.rutaLocal),
        nombreArchivo: captura.nombreArchivo,
        latitud: captura.latitud,
        longitud: captura.longitud,
      ));
      // Pequeña espera para no saturar
      await Future.delayed(const Duration(milliseconds: 300));
    }
    setState(() => _preview.clear());
  }

  void _verPreview(BuildContext context, int index) {
    final captura = _preview[index];
    if (_esImagen(captura.nombreArchivo)) {
      showDialog<void>(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: Colors.black,
          child: PhotoViewGallery.builder(
            itemCount: _preview.where((c) => _esImagen(c.nombreArchivo)).length,
            pageController: PageController(
              initialPage: _preview
                  .take(index)
                  .where((c) => _esImagen(c.nombreArchivo))
                  .length,
            ),
            builder: (_, i) {
              final imgCapturas = _preview
                  .where((c) => _esImagen(c.nombreArchivo))
                  .toList();
              return PhotoViewGalleryPageOptions(
                imageProvider: FileImage(File(imgCapturas[i].rutaLocal)),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2,
              );
            },
          ),
        ),
      );
    } else if (_esVideo(captura.nombreArchivo)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Vista previa de video no disponible en borrador.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Documento seleccionado: ${captura.nombreArchivo.split("/").last}')),
      );
    }
  }
}
