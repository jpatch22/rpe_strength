import 'package:flutter/material.dart';
import 'package:rpe_strength/src/database/hive_provider.dart';
import 'package:rpe_strength/src/database/models/workout_data_item.dart';
import 'package:rpe_strength/src/providers/method_provider.dart';
import '../Utils/Util.dart';

class PredictPageProvider extends ChangeNotifier {
  String? selectedExercise;
  final TextEditingController rpeController = TextEditingController();
  final TextEditingController repsController = TextEditingController();
  double estimatedWeight = 0;

  void setSelectedExercise(String? value) {
    selectedExercise = value;
    notifyListeners();
  }

  void calculateEstimate(HiveProvider hiveProvider, MethodProvider methodProvider) {
    print("Trying to calclc ex ${hiveProvider.workoutDataItems}");
    if (selectedExercise != null && rpeController.text.isNotEmpty && repsController.text.isNotEmpty) {
      final latestItem = hiveProvider.workoutDataItems
          .where((item) => item.exercise == selectedExercise)
          .reduce((a, b) => (a.timestamp?.isAfter(b.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0)) ?? false) ? a : b);
      
      final item = WorkoutDataItem(
        exercise: selectedExercise!,
        weight: latestItem.weight,
        numReps: int.tryParse(repsController.text) ?? latestItem.numReps,
        RPE: rpeController.text,
      );

      estimatedWeight = Util.calculateWeight(
        latestItem,
        Util.calculate1RM(item, methodProvider.selectedMethod),
        methodProvider.selectedMethod
      );
      notifyListeners();
    }
  }

  @override
  void dispose() {
    rpeController.dispose();
    repsController.dispose();
    super.dispose();
  }
}
