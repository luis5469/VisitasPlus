import 'dart:io';

import 'package:injectable/injectable.dart';

import '../../core/error/failures.dart';
import 'package:visitapdv_app/core/services/connectivity_service.dart';
import '../../core/services/imagen_offline_queue.dart';
import 'package:visitapdv_app/core/services/sync_service.dart';
import '../../data/datasources/novedad_local_datasource.dart';
import '../../data/datasources/novedad_remote_datasource.dart';
import '../../data/local/models/novedad_hive_model.dart';
import '../../domain/entities/novedad_entity.dart';
import '../../domain/repositories/novedad_repository.dart';

@LazySingleton(as: NovedadRepository)
class NovedadRepositoryImpl implements NovedadRepository {
  final NovedadRemoteDataSource _remote;
  final NovedadLocalDataSource _local;
  final ConnectivityService _connectivity;
  final SyncService _sync;
  final ImagenOfflineQueue _imagenQueue;

  NovedadRepositoryImpl(
      this._remote, this._local, this._connectivity, this._sync, this._imagenQueue);

  @override
  Future<(List<NovedadEntity>, Failure?)> getNovedades({
    String? estado,
    String? categoria,
    String? pdvId,
  }) async {
    if (!_connectivity.isOnline) {
      return (await _local.getNovedades(), null);
    }
    final (data, err) = await _remote.getNovedades(
        estado: estado, categoria: categoria, pdvId: pdvId);
    if (err == null) {
      await _local.cacheNovedades(data);
      return (data, null);
    }
    if (err is NetworkFailure) {
      return (await _local.getNovedades(), null);
    }
    return (await _local.getNovedades(), err);
  }

  @override
  Future<(NovedadEntity?, Failure?)> getNovedadById(String id) async {
    if (!_connectivity.isOnline) {
      return (await _local.getNovedadById(id), null);
    }
    final (data, err) = await _remote.getNovedadById(id);
    if (err is NetworkFailure) {
      return (await _local.getNovedadById(id), null);
    }
    return (data, err);
  }

  @override
  Future<(List<NovedadEntity>, Failure?)> getByVisita(String visitaId) async {
    if (!_connectivity.isOnline) {
      return (await _local.getByVisita(visitaId), null);
    }
    final (data, err) = await _remote.getByVisita(visitaId);
    if (err == null) {
      await _local.cacheNovedades(data);
    }
    return (data, err);
  }

  @override
  Future<(List<NovedadEntity>, Failure?)> getMisNovedades() async {
    if (!_connectivity.isOnline) {
      return (await _local.getNovedades(), null);
    }
    return _remote.getMisNovedades();
  }

  @override
  Future<(NovedadEntity?, Failure?)> crearNovedad({
    required String visitaId,
    required String pdvId,
    required String titulo,
    required String descripcion,
    required String categoria,
    required String prioridad,
    required String responsableSolucionId,
    required String responsableSeguimientoId,
    required DateTime fechaSeguimiento,
  }) async {
    if (!_connectivity.isOnline) {
      // Encolar para sync posterior
      await _sync.enqueue('crear_novedad', {
        'visitaId': visitaId,
        'pdvId': pdvId,
        'titulo': titulo,
        'descripcion': descripcion,
        'categoria': categoria,
        'prioridad': prioridad,
        'responsableSolucionId': responsableSolucionId,
        'responsableSeguimientoId': responsableSeguimientoId,
        'fechaSeguimiento': fechaSeguimiento.toIso8601String(),
      });
      return (null, const NetworkFailure());
    }

    final (data, err) = await _remote.crearNovedad(
      visitaId: visitaId,
      pdvId: pdvId,
      titulo: titulo,
      descripcion: descripcion,
      categoria: categoria,
      prioridad: prioridad,
      responsableSolucionId: responsableSolucionId,
      responsableSeguimientoId: responsableSeguimientoId,
      fechaSeguimiento: fechaSeguimiento,
    );
    if (err == null && data != null) {
      await _local.saveNovedad(data);
    }
    return (data, err);
  }

  @override
  Future<(NovedadEntity?, Failure?)> cambiarEstado({
    required String novedadId,
    required String nuevoEstado,
    required String comentario,
  }) async {
    if (!_connectivity.isOnline) {
      await _sync.enqueue('cambiar_estado_novedad', {
        'novedadId': novedadId,
        'nuevoEstado': nuevoEstado,
        'comentario': comentario,
      });
      return (null, const NetworkFailure());
    }
    return _remote.cambiarEstado(
        novedadId: novedadId, nuevoEstado: nuevoEstado, comentario: comentario);
  }

  @override
  Future<Failure?> subirImagen({
    required String novedadId,
    required File archivo,
    required String nombreArchivo,
    double? latitud,
    double? longitud,
  }) async {
    if (!_connectivity.isOnline) {
      // Encolar imagen offline
      final hive = NovedadImagenHiveModel()
        ..id = DateTime.now().millisecondsSinceEpoch.toString()
        ..novedadId = novedadId
        ..rutaLocal = archivo.path
        ..nombreArchivo = nombreArchivo
        ..tamanoBytes = await archivo.length()
        ..latitud = latitud
        ..longitud = longitud
        ..timestampCaptura = DateTime.now()
        ..marcaAguaAplicada = true
        ..subida = false;
      await _imagenQueue.encolar(hive);
      return const NetworkFailure();
    }
    return _remote.subirImagen(
        novedadId: novedadId,
        archivo: archivo,
        nombreArchivo: nombreArchivo,
        latitud: latitud,
        longitud: longitud);
  }
}
