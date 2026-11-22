import 'package:equatable/equatable.dart';

class NovedadEntity extends Equatable {
  final String id;
  final String visitaId;
  final String pdvId;
  final String titulo;
  final String descripcion;
  final String categoria;
  final String prioridad;
  final String estado;
  final String responsableSolucionId;
  final String responsableSeguimientoId;
  final DateTime fechaSeguimiento;
  final bool sincronizado;
  final DateTime creadoEn;
  final List<NovedadImagenEntity> imagenes;
  final List<NovedadHistorialEntity> historial;

  const NovedadEntity({
    required this.id,
    required this.visitaId,
    required this.pdvId,
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.prioridad,
    required this.estado,
    required this.responsableSolucionId,
    required this.responsableSeguimientoId,
    required this.fechaSeguimiento,
    required this.sincronizado,
    required this.creadoEn,
    this.imagenes = const [],
    this.historial = const [],
  });

  bool get estaAbierta => estado == 'Abierta';
  bool get estaEnProgreso => estado == 'EnProgreso';
  bool get estaResuelta => estado == 'Resuelta';
  bool get estaCerrada => estado == 'Cerrada';
  bool get estaVencida =>
      DateTime.now().isAfter(fechaSeguimiento) && !estaResuelta && !estaCerrada;

  @override
  List<Object?> get props => [id, estado, sincronizado];
}

class NovedadImagenEntity extends Equatable {
  final String id;
  final String novedadId;
  final String? urlImagen;
  final String? rutaLocal;
  final String nombreArchivo;
  final int tamanoBytes;
  final bool marcaAguaAplicada;
  final double? latitud;
  final double? longitud;
  final DateTime? timestampCaptura;
  final bool subida;

  const NovedadImagenEntity({
    required this.id,
    required this.novedadId,
    this.urlImagen,
    this.rutaLocal,
    required this.nombreArchivo,
    required this.tamanoBytes,
    required this.marcaAguaAplicada,
    this.latitud,
    this.longitud,
    this.timestampCaptura,
    this.subida = false,
  });

  bool get isImage {
    final name = nombreArchivo.toLowerCase();
    return name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.png') ||
        name.endsWith('.gif') ||
        name.endsWith('.webp');
  }

  bool get isVideo {
    final name = nombreArchivo.toLowerCase();
    return name.endsWith('.mp4') ||
        name.endsWith('.mov') ||
        name.endsWith('.avi') ||
        name.endsWith('.mkv');
  }

  bool get isDocument => !isImage && !isVideo;

  @override
  List<Object?> get props => [id, subida];
}


class NovedadHistorialEntity extends Equatable {
  final String id;
  final String estadoAnterior;
  final String estadoNuevo;
  final String comentario;
  final String usuarioId;
  final DateTime creadoEn;

  const NovedadHistorialEntity({
    required this.id,
    required this.estadoAnterior,
    required this.estadoNuevo,
    required this.comentario,
    required this.usuarioId,
    required this.creadoEn,
  });

  @override
  List<Object?> get props => [id];
}
