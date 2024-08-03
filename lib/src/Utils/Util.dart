import 'package:rpe_strength/src/database/models/workout_data_item.dart';
import 'dart:math';

class Util {
  Util._();

  static double calculateWeight(WorkoutDataItem item, double e1RM, String selectedMethod) {
    double modNumReps = (item.numReps + 10 - (double.tryParse(item.RPE) ?? 11));
    switch (selectedMethod) {
      case 'Epley':
        return e1RM / (1 + 0.0333 * modNumReps);
      case 'Brzycki':
        return e1RM * (1.0278 - 0.0278 * modNumReps);
      case 'Lombardi':
        return e1RM / pow(modNumReps, 0.10);
      case 'O\'Conner':
        return e1RM / (1 + 0.025 * modNumReps);
      case 'Wathan':
        return (100 * e1RM) * (48.8 + 53.8 * exp(-0.075 * modNumReps));
      case 'RPE-based':
        return (item.weight * (10 - (double.tryParse(item.RPE) ?? 10.0))) / 0.0333;
      default:
        return item.weight; // Fallback to the actual weight if no method is selected
    }
  }

  static double calculate1RM(WorkoutDataItem item, String selectedMethod) {
    double modNumReps = (item.numReps + 10 - (double.tryParse(item.RPE) ?? 11));
    switch (selectedMethod) {
      case 'Epley':
        return item.weight * (1 + 0.0333 * modNumReps);
      case 'Brzycki':
        return item.weight / (1.0278 - 0.0278 * modNumReps);
      case 'Lombardi':
        return item.weight * pow(modNumReps, 0.10);
      case 'O\'Conner':
        return item.weight * (1 + 0.025 * modNumReps);
      case 'Wathan':
        return (100 * item.weight) / (48.8 + 53.8 * exp(-0.075 * modNumReps));
      case 'RPE-based':
        return (item.weight * (10 - (double.tryParse(item.RPE) ?? 10.0))) / 0.0333;
      default:
        return item.weight; // Fallback to the actual weight if no method is selected
    }
  }
}