// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pdv_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PdvHiveModelAdapter extends TypeAdapter<PdvHiveModel> {
  @override
  final int typeId = 10;

  @override
  PdvHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PdvHiveModel()
      ..id = fields[0] as String
      ..codigo = fields[1] as String
      ..nombre = fields[2] as String
      ..direccion = fields[3] as String
      ..ciudad = fields[4] as String
      ..zona = fields[5] as String?
      ..responsable = fields[6] as String?
      ..telefono = fields[7] as String?
      ..latitud = fields[8] as double
      ..longitud = fields[9] as double
      ..geofenceMetros = fields[10] as int
      ..activo = fields[11] as bool
      ..updatedAt = fields[12] as DateTime;
  }

  @override
  void write(BinaryWriter writer, PdvHiveModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.codigo)
      ..writeByte(2)
      ..write(obj.nombre)
      ..writeByte(3)
      ..write(obj.direccion)
      ..writeByte(4)
      ..write(obj.ciudad)
      ..writeByte(5)
      ..write(obj.zona)
      ..writeByte(6)
      ..write(obj.responsable)
      ..writeByte(7)
      ..write(obj.telefono)
      ..writeByte(8)
      ..write(obj.latitud)
      ..writeByte(9)
      ..write(obj.longitud)
      ..writeByte(10)
      ..write(obj.geofenceMetros)
      ..writeByte(11)
      ..write(obj.activo)
      ..writeByte(12)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PdvHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
