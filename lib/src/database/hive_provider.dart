import 'package:flutter/foundation.dart';
import 'package:rpe_strength/src/database/hive_service.dart';
import 'package:rpe_strength/src/database/models/workout_data_item.dart';
import 'package:rpe_strength/src/models/adv_row_data.dart';
import 'package:rpe_strength/src/models/row_data.dart';

class HiveProvider extends ChangeNotifier {
  final HiveService _hiveService = HiveService();

  List<String> _exerciseNames = [];
  List<String> get exerciseNames => _exerciseNames;

  List<WorkoutDataItem> _workoutDataItems = [];
  List<WorkoutDataItem> get workoutDataItems => _workoutDataItems;

  HiveProvider() {
    _initializeData();
  }

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
  }

  Future<void> deleteExerciseName(String name) async {
    await _hiveService.deleteExerciseName(name);
    await fetchExerciseNames();
  }

  Future<void> saveWorkoutItemList(List<WorkoutDataItem> items) async {
    await _hiveService.saveWorkoutItemList(items);
    await fetchWorkoutDataItems();
  }

  Future<void> saveBaseRowItemList(List<RowData> rowData, String exercise) async {
    await _hiveService.saveBaseRowItemList(rowData, exercise);
    await fetchWorkoutDataItems();
  }

  Future<void> saveAdvancedRowItemList(List<AdvancedRowData> rowData, String exercise) async {
    await _hiveService.saveAdvancedRowItemList(rowData, exercise);
    await fetchWorkoutDataItems();
  }
}
