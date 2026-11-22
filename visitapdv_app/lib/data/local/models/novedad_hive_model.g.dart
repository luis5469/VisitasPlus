// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'novedad_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NovedadHiveModelAdapter extends TypeAdapter<NovedadHiveModel> {
  @override
  final int typeId = 13;

  @override
  NovedadHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NovedadHiveModel()
      ..id = fields[0] as String
      ..visitaId = fields[1] as String
      ..pdvId = fields[2] as String
      ..titulo = fields[3] as String
      ..descripcion = fields[4] as String
      ..categoria = fields[5] as String
      ..prioridad = fields[6] as String
      ..estado = fields[7] as String
      ..responsableSolucionId = fields[8] as String
      ..responsableSeguimientoId = fields[9] as String
      ..fechaSeguimiento = fields[10] as DateTime
      ..sincronizado = fields[11] as bool
      ..creadoEn = fields[12] as DateTime
      ..imagenes = (fields[13] as List)
          .map((dynamic e) => (e as Map).cast<dynamic, dynamic>())
          .toList()
      ..pendienteSincronizacion = fields[14] as bool;
  }

  @override
  void write(BinaryWriter writer, NovedadHiveModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.visitaId)
      ..writeByte(2)
      ..write(obj.pdvId)
      ..writeByte(3)
      ..write(obj.titulo)
      ..writeByte(4)
      ..write(obj.descripcion)
      ..writeByte(5)
      ..write(obj.categoria)
      ..writeByte(6)
      ..write(obj.prioridad)
      ..writeByte(7)
      ..write(obj.estado)
      ..writeByte(8)
      ..write(obj.responsableSolucionId)
      ..writeByte(9)
      ..write(obj.responsableSeguimientoId)
      ..writeByte(10)
      ..write(obj.fechaSeguimiento)
      ..writeByte(11)
      ..write(obj.sincronizado)
      ..writeByte(12)
      ..write(obj.creadoEn)
      ..writeByte(13)
      ..write(obj.imagenes)
      ..writeByte(14)
      ..write(obj.pendienteSincronizacion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NovedadHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NovedadImagenHiveModelAdapter
    extends TypeAdapter<NovedadImagenHiveModel> {
  @override
  final int typeId = 14;

  @override
  NovedadImagenHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NovedadImagenHiveModel()
      ..id = fields[0] as String
      ..novedadId = fields[1] as String
      ..rutaLocal = fields[2] as String
      ..urlRemota = fields[3] as String?
      ..nombreArchivo = fields[4] as String
      ..tamanoBytes = fields[5] as int
      ..latitud = fields[6] as double?
      ..longitud = fields[7] as double?
      ..timestampCaptura = fields[8] as DateTime
      ..marcaAguaAplicada = fields[9] as bool
      ..subida = fields[10] as bool;
  }

  @override
  void write(BinaryWriter writer, NovedadImagenHiveModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.novedadId)
      ..writeByte(2)
      ..write(obj.rutaLocal)
      ..writeByte(3)
      ..write(obj.urlRemota)
      ..writeByte(4)
      ..write(obj.nombreArchivo)
      ..writeByte(5)
      ..write(obj.tamanoBytes)
      ..writeByte(6)
      ..write(obj.latitud)
      ..writeByte(7)
      ..write(obj.longitud)
      ..writeByte(8)
      ..write(obj.timestampCaptura)
      ..writeByte(9)
      ..write(obj.marcaAguaAplicada)
      ..writeByte(10)
      ..write(obj.subida);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NovedadImagenHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
