import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class LegendProvider with ChangeNotifier {
  List<String> _selectedExercises = [];
  final List<String> allExercises;

  LegendProvider({required this.allExercises, List<String>? defaultSelected}) {
    // Initialize with defaults or all exercises selected
    _selectedExercises = defaultSelected ?? List.from(allExercises);
    _loadSelections();
  }

  List<String> get selectedExercises => _selectedExercises;

  void toggleExercise(String exercise) {
    if (_selectedExercises.contains(exercise)) {
      _selectedExercises.remove(exercise);
    } else {
      _selectedExercises.add(exercise);
    }
    notifyListeners();
    _saveSelections();
  }

  bool isSelected(String exercise) {
    return _selectedExercises.contains(exercise);
  }

  Future<void> _loadSelections() async {
    var box = await Hive.openBox('legendSelectionsBox');
    List<dynamic>? savedSelections = box.get('selectedExercises');
    if (savedSelections != null) {
      _selectedExercises = savedSelections.cast<String>();
      notifyListeners();
    }
  }

  Future<void> _saveSelections() async {
    var box = await Hive.openBox('legendSelectionsBox');
    await box.put('selectedExercises', _selectedExercises);
  }
}
