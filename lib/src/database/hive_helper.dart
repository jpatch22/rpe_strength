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
    }
  }

  static Future<void> saveBaseRowItemList(List<RowData> rowData) async {
    List<WorkoutDataItem> converted = [];
    for (var data in rowData) {
      if (data.numReps == "" || data.weight == "") {
        continue;
      }
      converted.add(
        WorkoutDataItem(
          weight: double.tryParse(data.weight) ?? 0,
          numReps: int.tryParse(data.numReps) ?? 0,
          RPE: data.RPE,
          numSets: 1,
          hype: HypeLevel.Moderate.ordinal,
          notes: ""
        )
        );
    }
  }

  static Future<void> saveAdvancedRowItemList(List<AdvancedRowData> rowData) async {
    List<WorkoutDataItem> converted = [];
    for (var data in rowData) {
      if (data.numReps == "" || data.weight == "") {
        continue;
      }
      converted.add(
        WorkoutDataItem(
          weight: double.tryParse(data.weight) ?? 0,
          numReps: int.tryParse(data.numReps) ?? 0,
          RPE: data.RPE,
          numSets: int.tryParse(data.numSets) ?? 0,
          hype: HypeLevel.fromString(data.hype).ordinal,
          notes: data.notes
        )
        );
    }
  }
}