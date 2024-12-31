import 'package:flutter/material.dart';

class ShownExercisesProvider extends ChangeNotifier {
  List<String> _shownExercises = ["Bench Press"];

  List<String> get shownExercises => _shownExercises;

  void toggleExercise(String exercise) {
    if (_shownExercises.contains(exercise)) {
      _shownExercises.remove(exercise);
    } else {
      _shownExercises.add(exercise);
    }
    notifyListeners();
  }

  void setShownExercises(List<String> exercises) {
    _shownExercises = exercises;
    notifyListeners();
  }
}
