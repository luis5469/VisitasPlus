import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../core/constants/api_constants.dart';
import '../../core/error/failures.dart';
import '../../core/network/api_client.dart';
import '../../domain/entities/pdv_entity.dart';
import '../../domain/entities/visita_entity.dart';

@lazySingleton
class VisitaRemoteDataSource {
  final ApiClient _client;

  VisitaRemoteDataSource(this._client);

  // ─── PDV ───────────────────────────────────────────────────────────────
  Future<(List<PdvEntity>, Failure?)> getPdvs() async {
    try {
      final res = await _client.dio.get(ApiConstants.pdv);
      final data = (res.data['data'] as List)
          .map<PdvEntity>((j) => _pdvFromJson(j as Map<String, dynamic>))
          .toList();
      return (data, null);
    } on DioException catch (e) {
      return (<PdvEntity>[], _mapError(e));
    }
  }

  Future<(PdvEntity?, Failure?)> getPdvById(String id) async {
    try {
      final res = await _client.dio.get('${ApiConstants.pdv}/$id');
      return (_pdvFromJson(res.data['data'] as Map<String, dynamic>), null);
    } on DioException catch (e) {
      return (null, _mapError(e));
    }
  }

  // ─── Visitas ───────────────────────────────────────────────────────────
  Future<(List<VisitaEntity>, Failure?)> getVisitas() async {
    try {
      final res = await _client.dio.get(ApiConstants.visitas);
      final data = (res.data['data'] as List)
          .map<VisitaEntity>((j) => _visitaFromJson(j as Map<String, dynamic>))
          .toList();
      return (data, null);
    } on DioException catch (e) {
      return (<VisitaEntity>[], _mapError(e));
    }
  }

  Future<(VisitaEntity?, Failure?)> iniciarVisita({
    required String pdvId,
    required double latitud,
    required double longitud,
  }) async {
    try {
      final res = await _client.dio.post(
        ApiConstants.iniciarVisita,
        data: {'pdvId': pdvId, 'latitud': latitud, 'longitud': longitud},
      );
      return (_visitaFromJson(res.data['data'] as Map<String, dynamic>), null);
    } on DioException catch (e) {
      return (null, _mapError(e));
    }
  }

  Future<(VisitaEntity?, Failure?)> finalizarVisita({
    required String visitaId,
    required double latitud,
    required double longitud,
  }) async {
    try {
      final res = await _client.dio.post(
        ApiConstants.finalizarVisita,
        data: {'visitaId': visitaId, 'latitud': latitud, 'longitud': longitud},
      );
      return (_visitaFromJson(res.data['data'] as Map<String, dynamic>), null);
    } on DioException catch (e) {
      return (null, _mapError(e));
    }
  }

  // ─── Mappers ───────────────────────────────────────────────────────────
  PdvEntity _pdvFromJson(Map<String, dynamic> j) => PdvEntity(
        id:             j['id'] as String,
        codigo:         j['codigo'] as String,
        nombre:         j['nombre'] as String,
        direccion:      j['direccion'] as String,
        ciudad:         j['ciudad'] as String,
        zona:           j['zona'] as String?,
        responsable:    j['responsable'] as String?,
        telefono:       j['telefono'] as String?,
        latitud:        (j['latitud'] as num).toDouble(),
        longitud:       (j['longitud'] as num).toDouble(),
        geofenceMetros: (j['geofenceMetros'] as num).toInt(),
        activo:         j['activo'] as bool,
      );

  VisitaEntity _visitaFromJson(Map<String, dynamic> j) => VisitaEntity(
        id:              j['id'] as String,
        pdvId:           j['pdvId'] as String,
        pdvNombre:       j['pdvNombre'] as String? ?? '',
        pdvCodigo:       j['pdvCodigo'] as String? ?? '',
        visitadorId:     j['visitadorId'] as String,
        estado:          j['estado'] as String,
        latitudInicio:   (j['latitudInicio'] as num?)?.toDouble(),
        longitudInicio:  (j['longitudInicio'] as num?)?.toDouble(),
        latitudFin:      (j['latitudFin'] as num?)?.toDouble(),
        longitudFin:     (j['longitudFin'] as num?)?.toDouble(),
        timestampInicio: DateTime.parse(j['timestampInicio'] as String),
        timestampFin:    j['timestampFin'] != null
            ? DateTime.parse(j['timestampFin'] as String)
            : null,
        actaPdfUrl:      j['actaPdfUrl'] as String?,
        sincronizado:    j['sincronizado'] as bool? ?? false,
      );

  Failure _mapError(DioException e) {
    final status = e.response?.statusCode;
    final msg    = e.response?.data?['message'] as String? ?? e.message ?? 'Error de red';
    return switch (status) {
      400 => ValidationFailure(msg),
      401 => AuthFailure('Sesión expirada'),
      403 => AuthFailure('Sin permiso'),
      404 => NotFoundFailure(msg),
      _   => NetworkFailure(msg),
    };
  }
}
