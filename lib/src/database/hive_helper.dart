import 'package:hive/hive.dart';
import 'package:rpe_strength/src/database/models/workout_data_item.dart';
import 'package:rpe_strength/src/models/adv_row_data.dart';
import 'package:rpe_strength/src/models/hype_level.dart';
import 'package:rpe_strength/src/models/row_data.dart';

class HiveHelper {
  static const String workoutItemBoxName = 'workoutDataBox';

  static Future<void> saveWorkoutItemList(List<WorkoutDataItem> items) async {
    final box = await Hive.openBox<WorkoutDataItem>(workoutItemBoxName);
    for (WorkoutDataItem item in items) {
      await box.add(item);
      print('Saved WorkoutDataItem: $item');
    }
    print('All items saved. Current box contents: ${box.values.toList()}');
  }

  static Future<void> saveBaseRowItemList(List<RowData> rowData, String exercise) async {
    DateTime now = DateTime.now();
    DateTime nowSave = DateTime(now.year, now.month, now.day, now.hour, now.minute);
    List<WorkoutDataItem> converted = [];
    for (var data in rowData) {
      if (data.numReps == "" || data.weight == "" || exercise == "") {
        continue;
      }
      var item = WorkoutDataItem(
        weight: double.tryParse(data.weight) ?? 0,
        numReps: int.tryParse(data.numReps) ?? 0,
        RPE: data.RPE,
        numSets: 1,
        hype: HypeLevel.Moderate.ordinal,
        notes: "",
        timestamp: nowSave,
        exercise: exercise
      );
      converted.add(item);
      print('Converted RowData to WorkoutDataItem: $item');
    }
    final box = await Hive.openBox<WorkoutDataItem>(workoutItemBoxName);
    for (var item in converted) {
      await box.add(item);
      print('Saved BaseRow WorkoutDataItem: $item');
    }
    print('All base row items saved. Current box contents: ${box.values.toList()}');
  }

  static Future<void> saveAdvancedRowItemList(List<AdvancedRowData> rowData, String exercise) async {
    DateTime now = DateTime.now();
    DateTime nowSave = DateTime(now.year, now.month, now.day, now.hour, now.minute);
    List<WorkoutDataItem> converted = [];
    for (var data in rowData) {
      if (data.numReps == "" || data.weight == "" || exercise == "") {
        continue;
      }
      var item = WorkoutDataItem(
        weight: double.tryParse(data.weight) ?? 0,
        numReps: int.tryParse(data.numReps) ?? 0,
        RPE: data.RPE,
        numSets: int.tryParse(data.numSets) ?? 0,
        hype: HypeLevel.fromString(data.hype).ordinal,
        notes: data.notes,
        timestamp: nowSave,
        exercise: exercise
      );
      converted.add(item);
      print('Converted AdvancedRowData to WorkoutDataItem: $item');
    }
    final box = await Hive.openBox<WorkoutDataItem>(workoutItemBoxName);
    for (var item in converted) {
      await box.add(item);
      print('Saved AdvancedRow WorkoutDataItem: $item');
    }
    print('All advanced row items saved. Current box contents: ${box.values.toList()}');
  }
}
