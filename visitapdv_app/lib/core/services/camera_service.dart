import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';

@lazySingleton
class CameraService {
  final _picker = ImagePicker();
  final _uuid = const Uuid();

  /// Toma foto con cámara o galería, aplica watermark y devuelve el path local.
  Future<CameraCaptura?> capturar({
    required String usuarioNombre,
    ImageSource source = ImageSource.camera,
    Position? posicion,
  }) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1920,
    );
    if (picked == null) return null;

    final posActual = posicion ?? await _obtenerPosicion();
    final rutaConMarca = await _aplicarWatermark(
      rutaOriginal: picked.path,
      usuario: usuarioNombre,
      posicion: posActual,
    );

    final file = File(rutaConMarca);
    return CameraCaptura(
      rutaLocal: rutaConMarca,
      nombreArchivo: '${_uuid.v4()}.jpg',
      tamanoBytes: await file.length(),
      latitud: posActual?.latitude,
      longitud: posActual?.longitude,
      timestampCaptura: DateTime.now(),
    );
  }

  /// Graba o selecciona un video y devuelve los metadatos de captura.
  Future<CameraCaptura?> capturarVideo({
    required String usuarioNombre,
    ImageSource source = ImageSource.camera,
    Position? posicion,
  }) async {
    final picked = await _picker.pickVideo(
      source: source,
      maxDuration: const Duration(minutes: 3),
    );
    if (picked == null) return null;

    final posActual = posicion ?? await _obtenerPosicion();
    final file = File(picked.path);
    final ext = picked.path.split('.').last.toLowerCase();
    
    return CameraCaptura(
      rutaLocal: picked.path,
      nombreArchivo: '${_uuid.v4()}.$ext',
      tamanoBytes: await file.length(),
      latitud: posActual?.latitude,
      longitud: posActual?.longitude,
      timestampCaptura: DateTime.now(),
    );
  }

  /// Selecciona un documento del almacenamiento local y devuelve los metadatos.
  Future<CameraCaptura?> seleccionarDocumento({
    Position? posicion,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt'],
    );
    if (result == null || result.files.single.path == null) return null;

    final pickedPath = result.files.single.path!;
    final posActual = posicion ?? await _obtenerPosicion();
    final file = File(pickedPath);
    final ext = pickedPath.split('.').last.toLowerCase();

    return CameraCaptura(
      rutaLocal: pickedPath,
      nombreArchivo: '${_uuid.v4()}.$ext',
      tamanoBytes: await file.length(),
      latitud: posActual?.latitude,
      longitud: posActual?.longitude,
      timestampCaptura: DateTime.now(),
    );
  }


  // ─── WATERMARK ──────────────────────────────────────────────────────────────
  Future<String> _aplicarWatermark({
    required String rutaOriginal,
    required String usuario,
    Position? posicion,
  }) async {
    final bytes = await File(rutaOriginal).readAsBytes();
    var image = img.decodeImage(bytes);
    if (image == null) return rutaOriginal;

    final ahora = DateTime.now();
    final fecha = DateFormat('dd/MM/yyyy').format(ahora);
    final hora = DateFormat('HH:mm:ss').format(ahora);
    final gps = posicion != null
        ? '${posicion.latitude.toStringAsFixed(5)}, ${posicion.longitude.toStringAsFixed(5)}'
        : 'GPS no disponible';

    final lineas = [
      usuario,
      '$fecha  $hora',
      gps,
    ];

    // Fondo semitransparente para legibilidad
    final anchoFondo = image.width;
    const altoLinea = 28;
    final altoFondo = lineas.length * altoLinea + 16;
    final yInicio = image.height - altoFondo;

    img.fillRect(
      image,
      x1: 0,
      y1: yInicio,
      x2: anchoFondo,
      y2: image.height,
      color: img.ColorRgba8(0, 0, 0, 140),
    );

    // Texto blanco
    final fuente = img.arial14;
    for (var i = 0; i < lineas.length; i++) {
      img.drawString(
        image,
        lineas[i],
        font: fuente,
        x: 10,
        y: yInicio + 8 + i * altoLinea,
        color: img.ColorRgb8(255, 255, 255),
      );
    }

    // Guardar en directorio de documentos
    final dir = await getApplicationDocumentsDirectory();
    final rutaSalida = '${dir.path}/wm_${_uuid.v4()}.jpg';
    final jpegBytes = img.encodeJpg(image, quality: 85);
    await File(rutaSalida).writeAsBytes(jpegBytes);

    return rutaSalida;
  }

  // ─── GPS ────────────────────────────────────────────────────────────────────
  Future<Position?> _obtenerPosicion() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) return null;
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );
    } catch (_) {
      return null;
    }
  }
}

class CameraCaptura {
  final String rutaLocal;
  final String nombreArchivo;
  final int tamanoBytes;
  final double? latitud;
  final double? longitud;
  final DateTime timestampCaptura;

  CameraCaptura({
    required this.rutaLocal,
    required this.nombreArchivo,
    required this.tamanoBytes,
    this.latitud,
    this.longitud,
    required this.timestampCaptura,
  });
}
