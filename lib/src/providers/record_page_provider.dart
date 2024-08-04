import 'package:flutter/material.dart';
import '../models/adv_row_data.dart';
import '../models/row_data.dart';
import '../database/hive_provider.dart';

class RecordPageProvider extends ChangeNotifier {
  late HiveProvider hiveProvider;
  List<dynamic> rows = [AdvancedRowData(weight: '', numReps: '', RPE: '5')];
  String? selectedExercise;
  bool editTime = false;
  bool _initialized = false;

  bool get initialized => _initialized;

  Future<void> initialize(HiveProvider provider) async {
    hiveProvider = provider;
    await hiveProvider.fetchExerciseNames();
    _initialized = true;
    notifyListeners();
  }

  void onDropdownChanged(String? value) {
    selectedExercise = value;
    notifyListeners();
  }

  void onSaveButtonPress(bool showAdvanced) {
    if (showAdvanced) {
      hiveProvider.saveAdvancedRowItemList(rows.cast<AdvancedRowData>(), selectedExercise ?? "");
    } else {
      hiveProvider.saveBaseRowItemList(rows.cast<RowData>(), selectedExercise ?? "");
    }

    rows = showAdvanced
        ? [AdvancedRowData(weight: '', numReps: '', RPE: '5')]
        : [RowData()];
    selectedExercise = null; // Reset the selected value of the dropdown
    notifyListeners();
  }

  void addRow(bool showAdvanced) {
    rows.add(showAdvanced
        ? AdvancedRowData(weight: '', numReps: '', RPE: '5')
        : RowData());
    notifyListeners();
  }

  void removeRow() {
    if (rows.length > 1) {
      rows.removeLast();
      notifyListeners();
    }
  }

  void toggleEditTime(bool value) {
    editTime = value;
    notifyListeners();
  }

  void convertRows(bool showAdvanced) {
    rows = showAdvanced
        ? rows.map((e) => e is AdvancedRowData ? e : AdvancedRowData(weight: e.weight, numReps: e.numReps, RPE: e.RPE, timestamp: e.timestamp)).toList()
        : rows.map((e) => e is RowData ? e : RowData(weight: e.weight, numReps: e.numReps, RPE: e.RPE, timestamp: e.timestamp)).toList();
    notifyListeners();
  }
}
