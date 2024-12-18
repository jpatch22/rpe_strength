import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:rpe_strength/src/Utils/Util.dart';
import 'package:rpe_strength/src/database/hive_provider.dart';
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
                      // Show a toast if an error occurs
                      showToast(context);
                    }},
                  child: const Text("Calculate Estimate"),
                ),
                if (predictPageProvider.estimatedWeight > 0)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Estimated Weight: ${predictPageProvider.estimatedWeight.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
