import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rpe_strength/src/Utils/Util.dart';
import 'package:rpe_strength/src/database/hive_provider.dart';
import 'package:rpe_strength/src/database/models/workout_data_item.dart';
import 'package:rpe_strength/src/models/hype_level.dart';
import 'package:rpe_strength/src/providers/advanced_mode_provider.dart';
import 'package:rpe_strength/src/providers/method_provider.dart';
import 'package:rpe_strength/src/providers/predict_page_provider.dart';
import 'package:rpe_strength/src/widgets/custom_dropdown_search.dart';

class PredictPage extends StatelessWidget {
  void showToast(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final webBgColor = isDarkMode
        ? "linear-gradient(to right, #0d47a1, #1976d2)"
        : "linear-gradient(to right, #42a5f5, #90caf9)";

    Fluttertoast.showToast(
      msg: "Not enough information to calculate weight",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 1,
      backgroundColor: isDarkMode ? Colors.blueAccent : Colors.blue,
      textColor: isDarkMode ? Colors.white : Colors.black,
      fontSize: 16.0,
      webPosition: "center",
      webBgColor: webBgColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Predict Weight'),
      ),
      body: Consumer3<PredictPageProvider, HiveProvider, MethodProvider>(
        builder: (context, predictPageProvider, hiveProvider, methodProvider,
            child) {
          final advancedModeProvider = Provider.of<AdvancedModeProvider>(context);

          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 300,
                      child: CustomDropdownSearch(
                        items: hiveProvider.exerciseNames,
                        onChanged: (value) =>
                            predictPageProvider.setSelectedExercise(value),
                        selectedItem: predictPageProvider.selectedExercise,
                        labelText: "",
                        hintText: "Search and select an exercise",
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 300.0,
                      child: DropdownButton<String>(
                        value: methodProvider.selectedMethod,
                        onChanged: (newMethod) {
                          methodProvider.setSelectedMethod(newMethod!);
                        },
                        items: Util.calculationMethods.map((String method) {
                          return DropdownMenuItem<String>(
                            value: method,
                            child: Text(method),
                          );
                        }).toList(),
                        isExpanded: true,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: predictPageProvider.rpeController,
                    decoration: InputDecoration(
                      labelText: "RPE",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: predictPageProvider.repsController,
                    decoration: InputDecoration(
                      labelText: "Reps",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    try {
                      predictPageProvider.calculateEstimate(
                          hiveProvider, methodProvider);
                      if (predictPageProvider.estimatedWeight <= 0) {
                        showToast(context);
                      }
                    } catch (error) {
                      showToast(context);
                    }
                  },
                  child: const Text("Calculate Estimate"),
                ),
                if (predictPageProvider.estimatedWeight > 0)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Estimated Weight: ${predictPageProvider.estimatedWeight.toStringAsFixed(2)}',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                const Divider(height: 20), // Separator for visual clarity
                // Workout Data Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Workout Data',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Text('Advanced Mode'),
                          Switch(
                            value: advancedModeProvider.showAdvanced,
                            onChanged: (value) {
                              advancedModeProvider.setAdvancedMode(value);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 300, // Define a fixed height for the ListView
                  child: ValueListenableBuilder(
                    valueListenable:
                        Hive.box<WorkoutDataItem>('workoutDataBox').listenable(),
                    builder: (context, Box<WorkoutDataItem> box, _) {
                      var items = box.values.toList();

                      // Filter items to match selected exercise
                      items = items.where((item) {
                        return predictPageProvider.selectedExercise == null ||
                            predictPageProvider.selectedExercise == item.exercise;
                      }).toList();

                      // Sort items by timestamp (descending)
                      items.sort((a, b) {
                        if (a.timestamp == null && b.timestamp == null) return 0;
                        if (a.timestamp == null) return 1;
                        if (b.timestamp == null) return -1;
                        return b.timestamp!.compareTo(a.timestamp!);
                      });

                      if (items.isEmpty) {
                        return Center(
                          child: Text('No workout data available'),
                        );
                      }

                      return ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          WorkoutDataItem item = items[index];
                          return ListTile(
                            title: Text('Exercise: ${item.exercise}'),
                            subtitle: advancedModeProvider.showAdvanced
                                ? Text(
                                    'Reps: ${item.numReps}, Weight: ${item.weight}, RPE: ${item.RPE}, Sets: ${item.numSets}, Hype: ${HypeLevel.fromOrdinal(item.hype).name}, Notes: ${item.notes}')
                                : Text(
                                    'Reps: ${item.numReps}, Weight: ${item.weight}, RPE: ${item.RPE}'),
                            trailing: Text(
                              'Time: ${item.timestamp?.toLocal().toString().substring(0, 16) ?? "No timestamp"}',
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
