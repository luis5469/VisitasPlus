import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../core/error/failures.dart';
import 'package:visitapdv_app/core/services/connectivity_service.dart';
import 'package:visitapdv_app/core/services/sync_service.dart';
import '../../data/datasources/visita_local_datasource.dart';
import '../../data/datasources/visita_remote_datasource.dart';
import '../../domain/entities/pdv_entity.dart';
import '../../domain/entities/visita_entity.dart';
import '../../domain/repositories/visita_repository.dart';

@LazySingleton(as: VisitaRepository)
class VisitaRepositoryImpl implements VisitaRepository {
  final VisitaRemoteDataSource _remote;
  final VisitaLocalDataSource  _local;
  final ConnectivityService    _connectivity;
  final SyncService            _sync;

  VisitaRepositoryImpl(this._remote, this._local, this._connectivity, this._sync);

  // ─── PDV ───────────────────────────────────────────────────────────────
  @override
  Future<(List<PdvEntity>, Failure?)> getPdvs() async {
    if (!_connectivity.isOnline) {
      return (await _local.getPdvs(), null);
    }
    final (data, err) = await _remote.getPdvs();
    if (err == null && data.isNotEmpty) {
      await _local.cachePdvs(data);
      return (data, null);
    }
    if (err is NetworkFailure) {
      return (await _local.getPdvs(), null);
    }
    return (await _local.getPdvs(), err);
  }

  @override
  Future<(PdvEntity?, Failure?)> getPdvById(String id) async {
    if (!_connectivity.isOnline) {
      return (await _local.getPdvById(id), null);
    }
    final (data, err) = await _remote.getPdvById(id);
    if (err is NetworkFailure || (err != null && data == null)) {
      return (await _local.getPdvById(id), null);
    }
    return (data, err);
  }

  // ─── Visitas ───────────────────────────────────────────────────────────
  @override
  Future<(List<VisitaEntity>, Failure?)> getVisitas() async {
    if (!_connectivity.isOnline) {
      return (await _local.getVisitas(), null);
    }
    final (data, err) = await _remote.getVisitas();
    if (err == null) {
      await _local.cacheVisitas(data);
      return (data, null);
    }
    if (err is NetworkFailure) {
      return (await _local.getVisitas(), null);
    }
    return (await _local.getVisitas(), err);
  }

  @override
  Future<(VisitaEntity?, Failure?)> iniciarVisita({
    required String pdvId,
    required double latitud,
    required double longitud,
  }) async {
    if (!_connectivity.isOnline) {
      final localId = const Uuid().v4();
      await _sync.enqueue('iniciarVisita', {
        'localId' : localId,
        'pdvId'   : pdvId,
        'latitud' : latitud,
        'longitud': longitud,
      });
      // Devolver entidad pendiente para que el BLoC la muestre
      return (null, const NetworkFailure('Sin conexión. Visita encolada para sincronizar.'));
    }
    return _remote.iniciarVisita(pdvId: pdvId, latitud: latitud, longitud: longitud);
  }

  @override
  Future<(VisitaEntity?, Failure?)> finalizarVisita({
    required String visitaId,
    required double latitud,
    required double longitud,
  }) async {
    if (!_connectivity.isOnline) {
      await _sync.enqueue('finalizarVisita', {
        'visitaId': visitaId,
        'latitud' : latitud,
        'longitud': longitud,
      });
      return (null, const NetworkFailure('Sin conexión. Finalización encolada para sincronizar.'));
    }
    return _remote.finalizarVisita(visitaId: visitaId, latitud: latitud, longitud: longitud);
  }

  @override
  Future<VisitaEntity?> getVisitaActiva() => _local.getVisitaActiva();
}
