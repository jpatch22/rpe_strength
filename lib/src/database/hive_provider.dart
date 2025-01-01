import 'package:flutter/foundation.dart';
import 'package:rpe_strength/src/database/hive_service.dart';
import 'package:rpe_strength/src/database/models/workout_data_item.dart';
import 'package:rpe_strength/src/models/adv_row_data.dart';
import 'package:rpe_strength/src/models/row_data.dart';

class HiveProvider extends ChangeNotifier {
  HiveProvider({Map<String, bool>? defaultVisibility}) {
    if (defaultVisibility != null) {
      _seriesVisibility = defaultVisibility;
    }
    _initializeData();
  }
  final HiveService _hiveService = HiveService();

  List<String> _exerciseNames = [];
  List<String> get exerciseNames => _exerciseNames;

  List<WorkoutDataItem> _workoutDataItems = [];
  List<WorkoutDataItem> get workoutDataItems => _workoutDataItems;

  Map<String, bool> _seriesVisibility = {};
  Map<String, bool> get seriesVisibility => _seriesVisibility;

  Future<void> _initializeData() async {
    await _hiveService.initializeBoxes();
    await _hiveService.initializeExerciseNames();
    await fetchExerciseNames();
    await fetchWorkoutDataItems();
  }

  Future<void> fetchExerciseNames() async {
    _exerciseNames = await _hiveService.getExerciseNames();
    notifyListeners();
  }

  Future<void> fetchWorkoutDataItems() async {
    _workoutDataItems = await _hiveService.getWorkoutDataItems();
    notifyListeners();
  }

  Future<void> addExerciseName(String name) async {
    await _hiveService.addExerciseName(name);
    await fetchExerciseNames();
    
    // Add the new exercise to visibility map
    _seriesVisibility[name] = true; // Default to visible
    notifyListeners(); // Notify listeners about the visibility change
  }

  Future<void> deleteExerciseName(String name) async {
    await _hiveService.deleteExerciseName(name);
    await fetchExerciseNames();
    
    // Remove the exercise from visibility map
    _seriesVisibility.remove(name);
    notifyListeners(); // Notify listeners about the visibility change
  }

  Future<void> saveWorkoutItemList(List<WorkoutDataItem> items) async {
    await _hiveService.saveWorkoutItemList(items);
    await fetchWorkoutDataItems();
  }

  Future<void> saveBaseRowItemList(List<RowData> rowData, String exercise) async {
    await _hiveService.saveBaseRowItemList(rowData, exercise);
    await fetchWorkoutDataItems();
  }

  Future<void> saveAdvancedRowItemList(List<AdvancedRowData> rowData, String exercise, {DateTime? timestamp}) async {
    await _hiveService.saveAdvancedRowItemList(rowData, exercise, timestamp: timestamp);
    await fetchWorkoutDataItems();
  }

  Future<void> deleteWorkoutDataItem(WorkoutDataItem item) async {
    await _hiveService.deleteWorkoutDataItem(item);
    await fetchWorkoutDataItems();
  }

  void toggleSeriesVisibility(String exercise) {
    if (_seriesVisibility.containsKey(exercise)) {
      _seriesVisibility[exercise] = !(_seriesVisibility[exercise] ?? true);
      notifyListeners(); // Notify listeners about the change
    }
  }

  void clearLocalData() {
    _hiveService.clearLocalData();
  }

  void pullCloudChanges() {
    _hiveService.syncToLocal();
  }
}
