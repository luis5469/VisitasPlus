import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/pdv_entity.dart';
import '../../domain/entities/visita_entity.dart';
import '../local/models/pdv_hive_model.dart';
import '../local/models/visita_hive_model.dart';

@lazySingleton
class VisitaLocalDataSource {
  static const _pdvBox    = 'pdvs';
  static const _visitasBox = 'visitas';

  // ─── PDV ───────────────────────────────────────────────────────────────
  Future<void> cachePdvs(List<PdvEntity> pdvs) async {
    final box = await Hive.openBox<PdvHiveModel>(_pdvBox);
    await box.clear();
    final models = {for (final p in pdvs) p.id: _pdvToHive(p)};
    await box.putAll(models);
  }

  Future<List<PdvEntity>> getPdvs() async {
    final box = await Hive.openBox<PdvHiveModel>(_pdvBox);
    return box.values.map(_pdvFromHive).toList();
  }

  Future<PdvEntity?> getPdvById(String id) async {
    final box = await Hive.openBox<PdvHiveModel>(_pdvBox);
    final h = box.get(id);
    return h != null ? _pdvFromHive(h) : null;
  }

  // ─── Visitas ───────────────────────────────────────────────────────────
  Future<void> saveVisita(VisitaEntity visita) async {
    final box = await Hive.openBox<VisitaHiveModel>(_visitasBox);
    await box.put(visita.id, _visitaToHive(visita));
  }

  Future<void> cacheVisitas(List<VisitaEntity> visitas) async {
    final box = await Hive.openBox<VisitaHiveModel>(_visitasBox);
    final models = {for (final v in visitas) v.id: _visitaToHive(v)};
    await box.putAll(models);
  }

  Future<List<VisitaEntity>> getVisitas() async {
    final box = await Hive.openBox<VisitaHiveModel>(_visitasBox);
    return box.values.map(_visitaFromHive).toList()
      ..sort((a, b) => b.timestampInicio.compareTo(a.timestampInicio));
  }

  Future<VisitaEntity?> getVisitaActiva() async {
    final box = await Hive.openBox<VisitaHiveModel>(_visitasBox);
    final activa = box.values
        .where((v) => v.estado == 'EnCurso')
        .firstOrNull;
    return activa != null ? _visitaFromHive(activa) : null;
  }

  // ─── Converters ────────────────────────────────────────────────────────
  PdvHiveModel _pdvToHive(PdvEntity p) => PdvHiveModel()
    ..id             = p.id
    ..codigo         = p.codigo
    ..nombre         = p.nombre
    ..direccion      = p.direccion
    ..ciudad         = p.ciudad
    ..zona           = p.zona
    ..responsable    = p.responsable
    ..telefono       = p.telefono
    ..latitud        = p.latitud
    ..longitud       = p.longitud
    ..geofenceMetros = p.geofenceMetros
    ..activo         = p.activo
    ..updatedAt      = DateTime.now();

  PdvEntity _pdvFromHive(PdvHiveModel h) => PdvEntity(
        id:             h.id,
        codigo:         h.codigo,
        nombre:         h.nombre,
        direccion:      h.direccion,
        ciudad:         h.ciudad,
        zona:           h.zona,
        responsable:    h.responsable,
        telefono:       h.telefono,
        latitud:        h.latitud,
        longitud:       h.longitud,
        geofenceMetros: h.geofenceMetros,
        activo:         h.activo,
      );

  VisitaHiveModel _visitaToHive(VisitaEntity v) => VisitaHiveModel()
    ..id              = v.id
    ..pdvId           = v.pdvId
    ..pdvNombre       = v.pdvNombre
    ..pdvCodigo       = v.pdvCodigo
    ..visitadorId     = v.visitadorId
    ..estado          = v.estado
    ..latitudInicio   = v.latitudInicio
    ..longitudInicio  = v.longitudInicio
    ..latitudFin      = v.latitudFin
    ..longitudFin     = v.longitudFin
    ..timestampInicio = v.timestampInicio
    ..timestampFin    = v.timestampFin
    ..actaPdfUrl      = v.actaPdfUrl
    ..sincronizado    = v.sincronizado
    ..updatedAt       = DateTime.now();

  VisitaEntity _visitaFromHive(VisitaHiveModel h) => VisitaEntity(
        id:              h.id,
        pdvId:           h.pdvId,
        pdvNombre:       h.pdvNombre,
        pdvCodigo:       h.pdvCodigo,
        visitadorId:     h.visitadorId,
        estado:          h.estado,
        latitudInicio:   h.latitudInicio,
        longitudInicio:  h.longitudInicio,
        latitudFin:      h.latitudFin,
        longitudFin:     h.longitudFin,
        timestampInicio: h.timestampInicio,
        timestampFin:    h.timestampFin,
        actaPdfUrl:      h.actaPdfUrl,
        sincronizado:    h.sincronizado,
      );
}
