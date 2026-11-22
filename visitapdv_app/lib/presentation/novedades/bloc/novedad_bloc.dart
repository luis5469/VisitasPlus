import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/failures.dart';
import '../../../core/services/camera_service.dart';
import '../../../core/services/imagen_offline_queue.dart';
import '../../../domain/entities/novedad_entity.dart';
import '../../../domain/repositories/novedad_repository.dart';

import 'novedad_event.dart';
import 'novedad_state.dart';

export 'novedad_event.dart';
export 'novedad_state.dart';

@injectable
class NovedadBloc extends Bloc<NovedadEvent, NovedadState> {
  final NovedadRepository _repo;
  final CameraService _camera;
  final ImagenOfflineQueue _imagenQueue;

  NovedadBloc(this._repo, this._camera, this._imagenQueue)
      : super(const NovedadInitial()) {
    on<NovedadLoadRequested>(_onLoad);
    on<NovedadByVisitaRequested>(_onByVisita);
    on<NovedadDetailRequested>(_onDetail);
    on<NovedadCrearRequested>(_onCrear);
    on<NovedadCambiarEstadoRequested>(_onCambiarEstado);
    on<NovedadCapturarImagenRequested>(_onCapturarImagen);
    on<NovedadCapturarVideoRequested>(_onCapturarVideo);
    on<NovedadSeleccionarDocumentoRequested>(_onSeleccionarDocumento);
    on<NovedadSubirImagenRequested>(_onSubirImagen);
    on<NovedadFiltroChanged>(_onFiltro);
    on<NovedadSincronizarImagenesRequested>(_onSincronizarImagenes);
  }

  // ─── HANDLERS ─────────────────────────────────────────────────────────────

  Future<void> _onLoad(
      NovedadLoadRequested event, Emitter<NovedadState> emit) async {
    emit(const NovedadLoading());
    final (data, err) = await _repo.getNovedades(
      estado: event.estado,
      categoria: event.categoria,
      pdvId: event.pdvId,
    );
    if (err != null && data.isEmpty) {
      emit(NovedadError(err.message));
    } else {
      emit(NovedadLoaded(novedades: data));
    }
  }

  Future<void> _onByVisita(
      NovedadByVisitaRequested event, Emitter<NovedadState> emit) async {
    emit(const NovedadLoading());
    final (data, err) = await _repo.getByVisita(event.visitaId);
    if (err != null && data.isEmpty) {
      emit(NovedadError(err.message));
    } else {
      emit(NovedadLoaded(novedades: data));
    }
  }

  Future<void> _onDetail(
      NovedadDetailRequested event, Emitter<NovedadState> emit) async {
    emit(const NovedadLoading());
    final (n, err) = await _repo.getNovedadById(event.novedadId);
    if (err != null || n == null) {
      emit(NovedadError(err?.message ?? 'Novedad no encontrada'));
    } else {
      emit(NovedadDetailLoaded(novedad: n));
    }
  }

  Future<void> _onCrear(
      NovedadCrearRequested event, Emitter<NovedadState> emit) async {
    emit(const NovedadLoading());
    final (n, err) = await _repo.crearNovedad(
      visitaId: event.visitaId,
      pdvId: event.pdvId,
      titulo: event.titulo,
      descripcion: event.descripcion,
      categoria: event.categoria,
      prioridad: event.prioridad,
      responsableSolucionId: event.responsableSolucionId,
      responsableSeguimientoId: event.responsableSeguimientoId,
      fechaSeguimiento: event.fechaSeguimiento,
    );
    if (err != null && err is! NetworkFailure) {
      emit(NovedadError(err.message));
    } else {
      emit(NovedadActionSuccess(
        message: err is NetworkFailure
            ? 'Novedad guardada offline. Se sincronizará cuando recuperes conexión.'
            : 'Novedad creada exitosamente.',
        novedad: n,
      ));
    }
  }

  Future<void> _onCambiarEstado(
      NovedadCambiarEstadoRequested event, Emitter<NovedadState> emit) async {
    emit(const NovedadLoading());
    final (n, err) = await _repo.cambiarEstado(
      novedadId: event.novedadId,
      nuevoEstado: event.nuevoEstado,
      comentario: event.comentario,
    );
    if (err != null && err is! NetworkFailure) {
      emit(NovedadError(err.message));
    } else {
      emit(NovedadActionSuccess(
        message: 'Estado actualizado a ${event.nuevoEstado}.',
        novedad: n,
      ));
    }
  }

  Future<void> _onCapturarImagen(
      NovedadCapturarImagenRequested event, Emitter<NovedadState> emit) async {
    final captura = await _camera.capturar(
      usuarioNombre: event.usuarioNombre,
      source: event.source,
    );
    if (captura == null) return;
    emit(NovedadImagenCapturada(captura: captura));
  }

  Future<void> _onCapturarVideo(
      NovedadCapturarVideoRequested event, Emitter<NovedadState> emit) async {
    final captura = await _camera.capturarVideo(
      usuarioNombre: event.usuarioNombre,
      source: event.source,
    );
    if (captura == null) return;
    emit(NovedadImagenCapturada(captura: captura));
  }

  Future<void> _onSeleccionarDocumento(
      NovedadSeleccionarDocumentoRequested event, Emitter<NovedadState> emit) async {
    final captura = await _camera.seleccionarDocumento();
    if (captura == null) return;
    emit(NovedadImagenCapturada(captura: captura));
  }

  Future<void> _onSubirImagen(
      NovedadSubirImagenRequested event, Emitter<NovedadState> emit) async {
    emit(const NovedadSubiendoImagen());
    final err = await _repo.subirImagen(
      novedadId: event.novedadId,
      archivo: event.archivo,
      nombreArchivo: event.nombreArchivo,
      latitud: event.latitud,
      longitud: event.longitud,
    );
    if (err != null && err is! NetworkFailure) {
      emit(NovedadError(err.message));
    } else {
      emit(NovedadActionSuccess(
        message: err is NetworkFailure
            ? 'Imagen en cola offline.'
            : 'Imagen subida exitosamente.',
      ));
    }
  }

  Future<void> _onFiltro(
      NovedadFiltroChanged event, Emitter<NovedadState> emit) async {
    add(NovedadLoadRequested(
      estado: event.estado,
      categoria: event.categoria,
      pdvId: event.pdvId,
    ));
  }

  Future<void> _onSincronizarImagenes(
      NovedadSincronizarImagenesRequested event,
      Emitter<NovedadState> emit) async {
    await _imagenQueue.sincronizar();
    emit(NovedadImagenesSincronizadas(
        pendientes: _imagenQueue.pendientes));
  }
}
