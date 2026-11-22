// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visita_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VisitaHiveModelAdapter extends TypeAdapter<VisitaHiveModel> {
  @override
  final int typeId = 11;

  @override
  VisitaHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VisitaHiveModel()
      ..id = fields[0] as String
      ..pdvId = fields[1] as String
      ..pdvNombre = fields[2] as String
      ..pdvCodigo = fields[3] as String
      ..visitadorId = fields[4] as String
      ..estado = fields[5] as String
      ..latitudInicio = fields[6] as double?
      ..longitudInicio = fields[7] as double?
      ..latitudFin = fields[8] as double?
      ..longitudFin = fields[9] as double?
      ..timestampInicio = fields[10] as DateTime
      ..timestampFin = fields[11] as DateTime?
      ..actaPdfUrl = fields[12] as String?
      ..sincronizado = fields[13] as bool
      ..updatedAt = fields[14] as DateTime;
  }

  @override
  void write(BinaryWriter writer, VisitaHiveModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.pdvId)
      ..writeByte(2)
      ..write(obj.pdvNombre)
      ..writeByte(3)
      ..write(obj.pdvCodigo)
      ..writeByte(4)
      ..write(obj.visitadorId)
      ..writeByte(5)
      ..write(obj.estado)
      ..writeByte(6)
      ..write(obj.latitudInicio)
      ..writeByte(7)
      ..write(obj.longitudInicio)
      ..writeByte(8)
      ..write(obj.latitudFin)
      ..writeByte(9)
      ..write(obj.longitudFin)
      ..writeByte(10)
      ..write(obj.timestampInicio)
      ..writeByte(11)
      ..write(obj.timestampFin)
      ..writeByte(12)
      ..write(obj.actaPdfUrl)
      ..writeByte(13)
      ..write(obj.sincronizado)
      ..writeByte(14)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VisitaHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
