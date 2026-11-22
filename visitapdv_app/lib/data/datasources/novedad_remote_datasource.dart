import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../core/constants/api_constants.dart';
import '../../core/error/failures.dart';
import '../../core/network/api_client.dart';
import '../../domain/entities/novedad_entity.dart';

@lazySingleton
class NovedadRemoteDataSource {
  final ApiClient _client;
  NovedadRemoteDataSource(this._client);

  // ─── GETS ────────────────────────────────────────────────────────────────
  Future<(List<NovedadEntity>, Failure?)> getNovedades({
    String? estado,
    String? categoria,
    String? pdvId,
    int pagina = 1,
    int tamano = 50,
  }) async {
    try {
      final res = await _client.dio.get(
        ApiConstants.novedades,
        queryParameters: {
          if (estado != null) 'estado': estado,
          if (categoria != null) 'categoria': categoria,
          if (pdvId != null) 'pdvId': pdvId,
          'pagina': pagina,
          'tamano': tamano,
        },
      );
      final items = (res.data['data']['items'] as List)
          .map<NovedadEntity>((j) => _fromJson(j as Map<String, dynamic>))
          .toList();
      return (items, null);
    } on DioException catch (e) {
      return (<NovedadEntity>[], _mapError(e));
    }
  }

  Future<(NovedadEntity?, Failure?)> getNovedadById(String id) async {
    try {
      final res = await _client.dio.get('${ApiConstants.novedades}/$id');
      return (_fromJson(res.data['data'] as Map<String, dynamic>), null);
    } on DioException catch (e) {
      return (null, _mapError(e));
    }
  }

  Future<(List<NovedadEntity>, Failure?)> getByVisita(String visitaId) async {
    try {
      final res = await _client.dio
          .get('${ApiConstants.novedades}/visita/$visitaId');
      final items = (res.data['data'] as List)
          .map<NovedadEntity>((j) => _fromJson(j as Map<String, dynamic>))
          .toList();
      return (items, null);
    } on DioException catch (e) {
      return (<NovedadEntity>[], _mapError(e));
    }
  }

  Future<(List<NovedadEntity>, Failure?)> getMisNovedades() async {
    try {
      final res = await _client.dio
          .get('${ApiConstants.novedades}/mis-novedades');
      final items = (res.data['data'] as List)
          .map<NovedadEntity>((j) => _fromJson(j as Map<String, dynamic>))
          .toList();
      return (items, null);
    } on DioException catch (e) {
      return (<NovedadEntity>[], _mapError(e));
    }
  }

  // ─── CRUD ────────────────────────────────────────────────────────────────
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
    try {
      final res = await _client.dio.post(
        ApiConstants.novedades,
        data: {
          'visitaId': visitaId,
          'pdvId': pdvId,
          'titulo': titulo,
          'descripcion': descripcion,
          'categoria': categoria,
          'prioridad': prioridad,
          'responsableSolucionId': responsableSolucionId,
          'responsableSeguimientoId': responsableSeguimientoId,
          'fechaSeguimiento': fechaSeguimiento.toIso8601String(),
        },
      );
      return (_fromJson(res.data['data'] as Map<String, dynamic>), null);
    } on DioException catch (e) {
      return (null, _mapError(e));
    }
  }

  Future<(NovedadEntity?, Failure?)> cambiarEstado({
    required String novedadId,
    required String nuevoEstado,
    required String comentario,
  }) async {
    try {
      final res = await _client.dio.patch(
        '${ApiConstants.novedades}/$novedadId/estado',
        data: {'nuevoEstado': nuevoEstado, 'comentario': comentario},
      );
      return (_fromJson(res.data['data'] as Map<String, dynamic>), null);
    } on DioException catch (e) {
      return (null, _mapError(e));
    }
  }

  // ─── IMÁGENES ────────────────────────────────────────────────────────────
  Future<Failure?> subirImagen({
    required String novedadId,
    required File archivo,
    required String nombreArchivo,
    double? latitud,
    double? longitud,
  }) async {
    try {
      final formData = FormData.fromMap({
        'archivo': await MultipartFile.fromFile(
          archivo.path,
          filename: nombreArchivo,
        ),
        if (latitud != null) 'latitud': latitud.toString(),
        if (longitud != null) 'longitud': longitud.toString(),
      });
      await _client.dio.post(
        '${ApiConstants.novedades}/$novedadId/imagenes',
        data: formData,
      );
      return null;
    } on DioException catch (e) {
      return _mapError(e);
    }
  }

  Future<(String?, Failure?)> getSasUrl(
      String novedadId, String imagenId) async {
    try {
      final res = await _client.dio.get(
        '${ApiConstants.novedades}/$novedadId/imagenes/$imagenId/sas',
      );
      return (res.data['data'] as String, null);
    } on DioException catch (e) {
      return (null, _mapError(e));
    }
  }

  // ─── MAPPERS ─────────────────────────────────────────────────────────────
  NovedadEntity _fromJson(Map<String, dynamic> j) => NovedadEntity(
        id: j['id'] as String? ?? '',
        visitaId: j['visitaId'] as String? ?? '',
        pdvId: j['pdvId'] as String? ?? '',
        titulo: j['titulo'] as String? ?? '',
        descripcion: j['descripcion'] as String? ?? '',
        categoria: j['categoria'] as String? ?? '',
        prioridad: j['prioridad'] as String? ?? '',
        estado: j['estado'] as String? ?? '',
        responsableSolucionId: j['responsableSolucionId'] as String? ?? '',
        responsableSeguimientoId: j['responsableSeguimientoId'] as String? ?? '',
        fechaSeguimiento: j['fechaSeguimiento'] != null
            ? DateTime.parse(j['fechaSeguimiento'] as String)
            : DateTime.now(),
        sincronizado: j['sincronizado'] as bool? ?? true,
        creadoEn: j['creadoEn'] != null
            ? DateTime.parse(j['creadoEn'] as String)
            : DateTime.now(),
        imagenes: (j['imagenes'] as List? ?? [])
            .map((i) => NovedadImagenEntity(
                  id: i['id'] as String? ?? '',
                  novedadId: (j['id'] as String?) ?? '',
                  urlImagen: i['urlImagen'] as String?,
                  nombreArchivo: i['nombreArchivo'] as String? ?? '',
                  tamanoBytes: i['tamanoBytes'] as int? ?? 0,
                  marcaAguaAplicada: i['marcaAguaAplicada'] as bool? ?? false,
                  latitud: (i['latitud'] as num?)?.toDouble(),
                  longitud: (i['longitud'] as num?)?.toDouble(),
                  timestampCaptura: i['timestampCaptura'] != null
                      ? DateTime.parse(i['timestampCaptura'] as String)
                      : null,
                  subida: true,
                ))
            .toList(),
        historial: (j['historial'] as List? ?? [])
            .map((h) => NovedadHistorialEntity(
                  id: h['id'] as String? ?? '',
                  estadoAnterior: h['estadoAnterior'] as String? ?? '',
                  estadoNuevo: h['estadoNuevo'] as String? ?? '',
                  comentario: h['comentario'] as String? ?? '',
                  usuarioId: h['usuarioId'] as String? ?? '',
                  creadoEn: h['creadoEn'] != null
                      ? DateTime.parse(h['creadoEn'] as String)
                      : DateTime.now(),
                ))
            .toList(),
      );

  Failure _mapError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const NetworkFailure();
    }
    final status = e.response?.statusCode;
    if (status == 401) return const AuthFailure();
    if (status == 404) return const NotFoundFailure('Recurso no encontrado.');
    return ServerFailure(e.response?.data?['message'] as String? ?? 'Error del servidor');
  }
}
