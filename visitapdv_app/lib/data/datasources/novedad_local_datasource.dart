import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/novedad_entity.dart';
import '../local/models/novedad_hive_model.dart';

@lazySingleton
class NovedadLocalDataSource {
  static const _boxName = 'novedades';
  final _uuid = const Uuid();

  late Box<NovedadHiveModel> _box;

  @PostConstruct(preResolve: true)
  Future<void> init() async {
    _box = await Hive.openBox<NovedadHiveModel>(_boxName);
  }

  Future<void> cacheNovedades(List<NovedadEntity> novedades) async {
    for (final n in novedades) {
      await _box.put(n.id, _toHive(n));
    }
  }

  Future<void> saveNovedad(NovedadEntity novedad) async {
    await _box.put(novedad.id, _toHive(novedad));
  }

  Future<List<NovedadEntity>> getNovedades() async {
    return _box.values.map(_fromHive).toList();
  }

  Future<NovedadEntity?> getNovedadById(String id) async {
    final h = _box.get(id);
    return h != null ? _fromHive(h) : null;
  }

  Future<List<NovedadEntity>> getByVisita(String visitaId) async {
    return _box.values
        .where((n) => n.visitaId == visitaId)
        .map(_fromHive)
        .toList();
  }

  Future<List<NovedadEntity>> getPendientesSincronizacion() async {
    return _box.values
        .where((n) => n.pendienteSincronizacion)
        .map(_fromHive)
        .toList();
  }

  // ─── MAPPERS ─────────────────────────────────────────────────────────────
  NovedadHiveModel _toHive(NovedadEntity n) => NovedadHiveModel()
    ..id = n.id
    ..visitaId = n.visitaId
    ..pdvId = n.pdvId
    ..titulo = n.titulo
    ..descripcion = n.descripcion
    ..categoria = n.categoria
    ..prioridad = n.prioridad
    ..estado = n.estado
    ..responsableSolucionId = n.responsableSolucionId
    ..responsableSeguimientoId = n.responsableSeguimientoId
    ..fechaSeguimiento = n.fechaSeguimiento
    ..sincronizado = n.sincronizado
    ..creadoEn = n.creadoEn
    ..pendienteSincronizacion = !n.sincronizado;

  NovedadEntity _fromHive(NovedadHiveModel h) => NovedadEntity(
        id: h.id,
        visitaId: h.visitaId,
        pdvId: h.pdvId,
        titulo: h.titulo,
        descripcion: h.descripcion,
        categoria: h.categoria,
        prioridad: h.prioridad,
        estado: h.estado,
        responsableSolucionId: h.responsableSolucionId,
        responsableSeguimientoId: h.responsableSeguimientoId,
        fechaSeguimiento: h.fechaSeguimiento,
        sincronizado: h.sincronizado,
        creadoEn: h.creadoEn,
      );
}
