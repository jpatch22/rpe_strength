import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../database/hive_provider.dart';
import '../database/models/workout_data_item.dart';

class HistoryPageProvider extends ChangeNotifier {
  final HiveProvider hiveProvider;
  List<String> selectedExercises = [];

  HistoryPageProvider(this.hiveProvider) {
    hiveProvider.fetchExerciseNames();
  }

  void onDropdownChanged(List<String> selectedItems) {
    selectedExercises = selectedItems;
    notifyListeners();
  }

  void deleteItem(BuildContext context, WorkoutDataItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Confirmation'),
          content: Text('Are you sure you want to delete this item?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                hiveProvider.deleteWorkoutDataItem(item);
                Navigator.of(context).pop();
                notifyListeners(); // Notify listeners after deletion
              },
            ),
          ],
        );
      },
    );
  }
}
