// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_data_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutDataItemAdapter extends TypeAdapter<WorkoutDataItem> {
  @override
  final int typeId = 0;

  @override
  WorkoutDataItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutDataItem(
      weight: fields[0] as double,
      numReps: fields[1] as int,
      RPE: fields[2] as String,
      numSets: fields[3] as int,
      hype: fields[4] as int,
      notes: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutDataItem obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.weight)
      ..writeByte(1)
      ..write(obj.numReps)
      ..writeByte(2)
      ..write(obj.RPE)
      ..writeByte(3)
      ..write(obj.numSets)
      ..writeByte(4)
      ..write(obj.hype)
      ..writeByte(5)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutDataItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
