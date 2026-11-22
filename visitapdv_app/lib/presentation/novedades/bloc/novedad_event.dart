import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class NovedadEvent extends Equatable {
  const NovedadEvent();
  @override
  List<Object?> get props => [];
}

class NovedadLoadRequested extends NovedadEvent {
  final String? estado;
  final String? categoria;
  final String? pdvId;
  const NovedadLoadRequested({this.estado, this.categoria, this.pdvId});
  @override
  List<Object?> get props => [estado, categoria, pdvId];
}

class NovedadByVisitaRequested extends NovedadEvent {
  final String visitaId;
  const NovedadByVisitaRequested(this.visitaId);
  @override
  List<Object?> get props => [visitaId];
}

class NovedadDetailRequested extends NovedadEvent {
  final String novedadId;
  const NovedadDetailRequested(this.novedadId);
  @override
  List<Object?> get props => [novedadId];
}

class NovedadCrearRequested extends NovedadEvent {
  final String visitaId;
  final String pdvId;
  final String titulo;
  final String descripcion;
  final String categoria;
  final String prioridad;
  final String responsableSolucionId;
  final String responsableSeguimientoId;
  final DateTime fechaSeguimiento;

  const NovedadCrearRequested({
    required this.visitaId,
    required this.pdvId,
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.prioridad,
    required this.responsableSolucionId,
    required this.responsableSeguimientoId,
    required this.fechaSeguimiento,
  });

  @override
  List<Object?> get props => [visitaId, titulo];
}

class NovedadCambiarEstadoRequested extends NovedadEvent {
  final String novedadId;
  final String nuevoEstado;
  final String comentario;
  const NovedadCambiarEstadoRequested({
    required this.novedadId,
    required this.nuevoEstado,
    required this.comentario,
  });
  @override
  List<Object?> get props => [novedadId, nuevoEstado];
}

class NovedadCapturarImagenRequested extends NovedadEvent {
  final String usuarioNombre;
  final dynamic source; // ImageSource
  const NovedadCapturarImagenRequested({
    required this.usuarioNombre,
    required this.source,
  });
  @override
  List<Object?> get props => [usuarioNombre];
}

class NovedadCapturarVideoRequested extends NovedadEvent {
  final String usuarioNombre;
  final dynamic source; // ImageSource
  const NovedadCapturarVideoRequested({
    required this.usuarioNombre,
    required this.source,
  });
  @override
  List<Object?> get props => [usuarioNombre];
}

class NovedadSeleccionarDocumentoRequested extends NovedadEvent {
  const NovedadSeleccionarDocumentoRequested();
  @override
  List<Object?> get props => [];
}


class NovedadSubirImagenRequested extends NovedadEvent {
  final String novedadId;
  final File archivo;
  final String nombreArchivo;
  final double? latitud;
  final double? longitud;
  const NovedadSubirImagenRequested({
    required this.novedadId,
    required this.archivo,
    required this.nombreArchivo,
    this.latitud,
    this.longitud,
  });
  @override
  List<Object?> get props => [novedadId, nombreArchivo];
}

class NovedadFiltroChanged extends NovedadEvent {
  final String? estado;
  final String? categoria;
  final String? pdvId;
  const NovedadFiltroChanged({this.estado, this.categoria, this.pdvId});
  @override
  List<Object?> get props => [estado, categoria, pdvId];
}

class NovedadSincronizarImagenesRequested extends NovedadEvent {
  const NovedadSincronizarImagenesRequested();
}
