import '../../core/error/failures.dart';
import '../entities/pdv_entity.dart';
import '../entities/visita_entity.dart';

abstract class VisitaRepository {
  // PDV
  Future<(List<PdvEntity>, Failure?)> getPdvs();
  Future<(PdvEntity?, Failure?)> getPdvById(String id);

  // Visitas
  Future<(List<VisitaEntity>, Failure?)> getVisitas();
  Future<(VisitaEntity?, Failure?)> iniciarVisita({
    required String pdvId,
    required double latitud,
    required double longitud,
  });
  Future<(VisitaEntity?, Failure?)> finalizarVisita({
    required String visitaId,
    required double latitud,
    required double longitud,
  });
  Future<VisitaEntity?> getVisitaActiva();
}
