import 'package:flutter/material.dart';
import 'package:rpe_strength/src/Utils/Util.dart';
import 'package:rpe_strength/src/database/hive_provider.dart';
import 'package:rpe_strength/src/database/models/workout_data_item.dart';
import 'package:rpe_strength/src/providers/method_provider.dart';

class PredictPageProvider extends ChangeNotifier {
  String? selectedExercise;
  final TextEditingController rpeController = TextEditingController();
  final TextEditingController repsController = TextEditingController();
  double estimatedWeight = 0;

  PredictPageProvider() {
    rpeController.addListener(_onInputChange);
    repsController.addListener(_onInputChange);
  }

  void _onInputChange() {
    notifyListeners(); // Notify listeners when input changes
  }

  void setSelectedExercise(String? value) {
    selectedExercise = value;
    notifyListeners();
  }

  void calculateEstimate(HiveProvider hiveProvider, MethodProvider methodProvider) {
    if (selectedExercise != null &&
        rpeController.text.isNotEmpty &&
        repsController.text.isNotEmpty) {
      final latestItem = hiveProvider.workoutDataItems
          .where((item) => item.exercise == selectedExercise)
          .reduce((a, b) =>
              (a.timestamp?.isAfter(b.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0)) ?? false)
                  ? a
                  : b);

      final item = WorkoutDataItem(
        exercise: selectedExercise!,
        weight: latestItem.weight,
        numReps: int.tryParse(repsController.text) ?? latestItem.numReps,
        RPE: rpeController.text,
      );

      estimatedWeight = Util.calculateWeight(
        latestItem,
        Util.calculate1RM(item, methodProvider.selectedMethod),
        methodProvider.selectedMethod,
      );
      notifyListeners();
    }
  }

  @override
  void dispose() {
    rpeController.removeListener(_onInputChange);
    repsController.removeListener(_onInputChange);
    rpeController.dispose();
    repsController.dispose();
    super.dispose();
  }
}