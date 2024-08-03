import 'package:flutter/material.dart';
import '../models/adv_row_data.dart';
import '../models/row_data.dart';
import '../database/hive_provider.dart';

class RecordPageProvider extends ChangeNotifier {
  late HiveProvider hiveProvider;
  List<RowData> rows = [RowData()];
  String? selectedExercise;
  bool editTime = false;

  void initialize(HiveProvider provider) {
    hiveProvider = provider;
    hiveProvider.fetchExerciseNames();
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
      hiveProvider.saveBaseRowItemList(rows, selectedExercise ?? "");
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
}
