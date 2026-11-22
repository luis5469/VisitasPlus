import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../data/datasources/novedad_remote_datasource.dart';
import '../../data/local/models/novedad_hive_model.dart';

/// Cola offline para subir imágenes de novedades cuando se recupera la conexión.
@lazySingleton
class ImagenOfflineQueue {
  static const _boxName = 'imagen_queue';
  final NovedadRemoteDataSource _remote;
  final _uuid = const Uuid();

  late Box<NovedadImagenHiveModel> _box;
  bool _sincronizando = false;

  ImagenOfflineQueue(this._remote);

  @PostConstruct(preResolve: true)
  Future<void> init() async {
    _box = await Hive.openBox<NovedadImagenHiveModel>(_boxName);
  }

  /// Encola una imagen pendiente de subida.
  Future<String> encolar(NovedadImagenHiveModel imagen) async {
    final key = _uuid.v4();
    await _box.put(key, imagen);
    return key;
  }

  /// Intenta subir todas las imágenes pendientes.
  Future<void> sincronizar() async {
    if (_sincronizando || _box.isEmpty) return;
    _sincronizando = true;

    try {
      for (final key in _box.keys.toList()) {
        final imagen = _box.get(key);
        if (imagen == null || imagen.subida) {
          await _box.delete(key);
          continue;
        }
        await _subirImagen(key, imagen);
      }
    } finally {
      _sincronizando = false;
    }
  }

  Future<void> _subirImagen(dynamic key, NovedadImagenHiveModel imagen) async {
    try {
      final file = File(imagen.rutaLocal);
      if (!file.existsSync()) {
        await _box.delete(key);
        return;
      }

      await _remote.subirImagen(
        novedadId: imagen.novedadId,
        archivo: file,
        nombreArchivo: imagen.nombreArchivo,
        latitud: imagen.latitud,
        longitud: imagen.longitud,
      );

      imagen.subida = true;
      imagen.save();
      await _box.delete(key);
    } on DioException {
      // Mantener en cola para reintentar
    } catch (_) {
      await _box.delete(key);
    }
  }

  int get pendientes => _box.values.where((i) => !i.subida).length;
}
