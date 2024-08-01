import 'package:hive/hive.dart';

part 'workout_data_item.g.dart';

@HiveType(typeId: 0)
class WorkoutDataItem extends HiveObject {
  @HiveField(0)
  double weight;

  @HiveField(1)
  int numReps;

  @HiveField(2)
  String RPE;

  @HiveField(3)
  int numSets;

  @HiveField(4)
  int hype;

  @HiveField(5)
  String notes;

  @HiveField(6)
  DateTime? timestamp;

  @HiveField(7)
  String exercise;

  WorkoutDataItem({
    this.weight = 0.0,
    this.numReps = 0,
    this.RPE = '5',
    this.numSets = 1,
    this.hype = 2, // Moderate by default
    this.notes = '',
    this.timestamp, 
    this.exercise = '',
  });
}
