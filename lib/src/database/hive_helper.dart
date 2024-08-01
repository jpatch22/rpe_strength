import 'package:hive/hive.dart';
import 'package:rpe_strength/src/database/models/workout_data_item.dart';
import 'package:rpe_strength/src/models/adv_row_data.dart';
import 'package:rpe_strength/src/models/hype_level.dart';
import 'package:rpe_strength/src/models/row_data.dart';

class HiveHelper {
  static const String workoutItemBoxName = 'workoutDataBox';
  static const String exerciseNameBoxName = 'exerciseNameBox';
  static const String removedDefaultExerciseNameBoxName = 'removedDefaultExerciseNameBox';
  static const List<String> defaultExerciseNames = ['Squat', 'Bench Press', 'Deadlift'];

  static Future<void> saveWorkoutItemList(List<WorkoutDataItem> items) async {
    try {
      final box = await Hive.openBox<WorkoutDataItem>(workoutItemBoxName);
      for (WorkoutDataItem item in items) {
        await box.add(item);
        print('Saved WorkoutDataItem: $item');
      }
      print('All items saved. Current box contents: ${box.values.toList()}');
    } catch (e) {
      print('Error saving workout items: $e');
    }
  }

  static Future<void> saveBaseRowItemList(List<RowData> rowData, String exercise) async {
    DateTime now = DateTime.now();
    DateTime nowSave = DateTime(now.year, now.month, now.day, now.hour, now.minute);
    List<WorkoutDataItem> converted = [];
    try {
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
    } catch (e) {
      print('Error saving base row items: $e');
    }
  }

  static Future<void> saveAdvancedRowItemList(List<AdvancedRowData> rowData, String exercise) async {
    DateTime now = DateTime.now();
    DateTime nowSave = DateTime(now.year, now.month, now.day, now.hour, now.minute);
    List<WorkoutDataItem> converted = [];
    try {
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
    } catch (e) {
      print('Error saving advanced row items: $e');
    }
  }

  static Future<void> initializeExerciseNames() async {
    try {
      final box = await Hive.openBox<String>(exerciseNameBoxName);
      final removedBox = await Hive.openBox<String>(removedDefaultExerciseNameBoxName);
      for (String name in defaultExerciseNames) {
        if (!box.values.contains(name) && !removedBox.values.contains(name)) {
          await box.add(name);
          print('Added default exercise name: $name');
        }
      }
      print('Exercise names initialized. Current box contents: ${box.values.toList()}');
    } catch (e) {
      print('Error initializing exercise names: $e');
    }
  }

  static Future<List<String>> getExerciseNames() async {
    try {
      final box = await Hive.openBox<String>(exerciseNameBoxName);
      return box.values.toList();
    } catch (e) {
      print('Error fetching exercise names: $e');
      return [];
    }
  }

  static Future<void> addExerciseName(String name) async {
    try {
      final box = await Hive.openBox<String>(exerciseNameBoxName);
      if (!box.values.contains(name)) {
        await box.add(name);
        print('Added exercise name: $name');
      } else {
        print('Exercise name already exists: $name');
      }
    } catch (e) {
      print('Error adding exercise name: $e');
    }
  }

  static Future<void> deleteExerciseName(String name) async {
    try {
      final box = await Hive.openBox<String>(exerciseNameBoxName);
      final key = box.keys.firstWhere((k) => box.get(k) == name, orElse: () => null);
      if (key != null) {
        await box.delete(key);
        print('Deleted exercise name: $name');
        await _addRemovedDefaultExerciseName(name);
      } else {
        print('Exercise name not found: $name');
      }
    } catch (e) {
      print('Error deleting exercise name: $e');
    }
  }

  static Future<void> _addRemovedDefaultExerciseName(String name) async {
    try {
      final removedBox = await Hive.openBox<String>(removedDefaultExerciseNameBoxName);
      if (!removedBox.values.contains(name)) {
        await removedBox.add(name);
        print('Tracked removed default exercise name: $name');
      }
    } catch (e) {
      print('Error tracking removed default exercise name: $e');
    }
  }
}
