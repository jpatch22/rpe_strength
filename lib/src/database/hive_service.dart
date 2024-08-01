import 'package:hive/hive.dart';
import 'package:rpe_strength/src/database/models/workout_data_item.dart';
import 'package:rpe_strength/src/models/adv_row_data.dart';
import 'package:rpe_strength/src/models/hype_level.dart';
import 'package:rpe_strength/src/models/row_data.dart';

class HiveService {
  static const String workoutItemBoxName = 'workoutDataBox';
  static const String exerciseNameBoxName = 'exerciseNameBox';
  static const String removedDefaultExerciseNameBoxName = 'removedDefaultExerciseNameBox';
  static const List<String> defaultExerciseNames = ['Squat', 'Bench Press', 'Deadlift'];

  Box<WorkoutDataItem>? _workoutItemBox;
  Box<String>? _exerciseNameBox;
  Box<String>? _removedDefaultExerciseNameBox;

  Future<void> initializeBoxes() async {
    _workoutItemBox = await Hive.openBox<WorkoutDataItem>(workoutItemBoxName);
    _exerciseNameBox = await Hive.openBox<String>(exerciseNameBoxName);
    _removedDefaultExerciseNameBox = await Hive.openBox<String>(removedDefaultExerciseNameBoxName);
  }

  Future<void> saveWorkoutItemList(List<WorkoutDataItem> items) async {
    try {
      if (_workoutItemBox == null) return;
      for (WorkoutDataItem item in items) {
        await _workoutItemBox!.add(item);
        print('Saved WorkoutDataItem: $item');
      }
      print('All items saved. Current box contents: ${_workoutItemBox!.values.toList()}');
    } catch (e) {
      print('Error saving workout items: $e');
    }
  }

  Future<void> saveBaseRowItemList(List<RowData> rowData, String exercise) async {
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
          exercise: exercise,
        );
        converted.add(item);
        print('Converted RowData to WorkoutDataItem: $item');
      }
      if (_workoutItemBox == null) return;
      for (var item in converted) {
        await _workoutItemBox!.add(item);
        print('Saved BaseRow WorkoutDataItem: $item');
      }
      print('All base row items saved. Current box contents: ${_workoutItemBox!.values.toList()}');
    } catch (e) {
      print('Error saving base row items: $e');
    }
  }

  Future<void> saveAdvancedRowItemList(List<AdvancedRowData> rowData, String exercise) async {
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
          exercise: exercise,
        );
        converted.add(item);
        print('Converted AdvancedRowData to WorkoutDataItem: $item');
      }
      if (_workoutItemBox == null) return;
      for (var item in converted) {
        await _workoutItemBox!.add(item);
        print('Saved AdvancedRow WorkoutDataItem: $item');
      }
      print('All advanced row items saved. Current box contents: ${_workoutItemBox!.values.toList()}');
    } catch (e) {
      print('Error saving advanced row items: $e');
    }
  }

  Future<List<WorkoutDataItem>> getWorkoutDataItems() async {
    try {
      if (_workoutItemBox == null) return [];
      return _workoutItemBox!.values.toList();
    } catch (e) {
      print("Error fetching workout items: $e");
      return [];
    }
  }

  Future<void> initializeExerciseNames() async {
    try {
      if (_exerciseNameBox == null || _removedDefaultExerciseNameBox == null) return;
      for (String name in defaultExerciseNames) {
        if (!_exerciseNameBox!.values.contains(name) && !_removedDefaultExerciseNameBox!.values.contains(name)) {
          await _exerciseNameBox!.add(name);
          print('Added default exercise name: $name');
        }
      }
      print('Exercise names initialized. Current box contents: ${_exerciseNameBox!.values.toList()}');
    } catch (e) {
      print('Error initializing exercise names: $e');
    }
  }

  Future<List<String>> getExerciseNames() async {
    try {
      if (_exerciseNameBox == null) return [];
      return _exerciseNameBox!.values.toList();
    } catch (e) {
      print('Error fetching exercise names: $e');
      return [];
    }
  }

  Future<void> addExerciseName(String name) async {
    try {
      if (_exerciseNameBox == null) return;
      if (!_exerciseNameBox!.values.contains(name)) {
        await _exerciseNameBox!.add(name);
        print('Added exercise name: $name');
      } else {
        print('Exercise name already exists: $name');
      }
    } catch (e) {
      print('Error adding exercise name: $e');
    }
  }

  Future<void> deleteExerciseName(String name) async {
    try {
      if (_exerciseNameBox == null) return;
      final key = _exerciseNameBox!.keys.firstWhere((k) => _exerciseNameBox!.get(k) == name, orElse: () => null);
      if (key != null) {
        await _exerciseNameBox!.delete(key);
        print('Deleted exercise name: $name');
        await _addRemovedDefaultExerciseName(name);
      } else {
        print('Exercise name not found: $name');
      }
    } catch (e) {
      print('Error deleting exercise name: $e');
    }
  }

  Future<void> _addRemovedDefaultExerciseName(String name) async {
    try {
      if (_removedDefaultExerciseNameBox == null) return;
      if (!_removedDefaultExerciseNameBox!.values.contains(name)) {
        await _removedDefaultExerciseNameBox!.add(name);
        print('Tracked removed default exercise name: $name');
      }
    } catch (e) {
      print('Error tracking removed default exercise name: $e');
    }
  }
}
