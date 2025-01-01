import 'package:rpe_strength/src/algos/one_rep_max_calculator.dart';
import 'package:rpe_strength/src/database/models/workout_data_item.dart';

class Util {
  Util._();
  static List<String> calculationMethods = ['Barbell Medicine', 'Mayhew', 'Wathan', 'Helms'];
  static OneRepMaxCalculator calculator = OneRepMaxCalculator();

  static DateTime? parseTime(String ddmmyy) {
    if (ddmmyy.length < 6) {
      return null;
    }
    int? day = int.tryParse(ddmmyy.substring(0, 2));
    int? month = int.tryParse(ddmmyy.substring(2, 4));
    int? year = int.tryParse(ddmmyy.substring(4));
    
    if (day == null || month == null || day > 31 || month > 12 || year == null) {
      return null;
    } else {
      return DateTime(year, month, day);
    }
  }


  static double calculateWeight(WorkoutDataItem item, double e1RM, String selectedMethod) {
    double rpe = double.tryParse(item.RPE) ?? 11;
    switch (selectedMethod) {
      case 'Helms':
        return calculator.helmsPredictedWeight(e1RM, item.numReps, rpe);
      case 'Wathan':
        return calculator.wathanPredictedWeight(e1RM, item.numReps, rpe);
      case 'Mayhew':
        return calculator.mayhewPredictedWeight(e1RM, item.numReps, rpe);
      case 'Barbell Medicine':
        return calculator.barbellMedicine1RM(e1RM, item.numReps, rpe);
      default:
        return item.weight; // Fallback to the actual weight if no method is selected
    }
  }

  static double calculate1RM(WorkoutDataItem item, String selectedMethod) {
    double rpe = double.tryParse(item.RPE) ?? 11;
    switch (selectedMethod) {
      case 'Helms':
        return calculator.helms1RM(item.weight, item.numReps, rpe);
      case 'Wathan':
        return calculator.wathan1RM(item.weight, item.numReps, rpe);
      case 'Mayhew':
        return calculator.mayhew1RM(item.weight, item.numReps, rpe);
      case 'Barbell Medicine':
        return calculator.barbellMedicine1RM(item.weight, item.numReps, rpe);
      default:
        return item.weight; // Fallback to the actual weight if no method is selected
    }
  }
}