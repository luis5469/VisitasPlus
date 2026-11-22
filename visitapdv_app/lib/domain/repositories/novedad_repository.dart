import 'dart:io';
import '../../core/error/failures.dart';
import '../entities/novedad_entity.dart';

abstract class NovedadRepository {
  Future<(List<NovedadEntity>, Failure?)> getNovedades({
    String? estado,
    String? categoria,
    String? pdvId,
  });

  Future<(NovedadEntity?, Failure?)> getNovedadById(String id);

  Future<(List<NovedadEntity>, Failure?)> getByVisita(String visitaId);

  Future<(List<NovedadEntity>, Failure?)> getMisNovedades();

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
  });

  Future<(NovedadEntity?, Failure?)> cambiarEstado({
    required String novedadId,
    required String nuevoEstado,
    required String comentario,
  });

  Future<Failure?> subirImagen({
    required String novedadId,
    required File archivo,
    required String nombreArchivo,
    double? latitud,
    double? longitud,
  });
}
