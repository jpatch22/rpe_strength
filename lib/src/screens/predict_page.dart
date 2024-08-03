import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpe_strength/src/database/hive_provider.dart';
import 'package:rpe_strength/src/providers/method_provider.dart';
import 'package:rpe_strength/src/providers/predict_page_provider.dart';
import 'package:rpe_strength/src/widgets/custom_dropdown_search.dart';
import '../Utils/Util.dart';

class PredictPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Predict Weight'),
      ),
      body: Consumer<PredictPageProvider>(
        builder: (context, predictPageProvider, child) {
          return Consumer<HiveProvider>(
            builder: (context, hiveProvider, child) {
              if (hiveProvider.exerciseNames.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return Consumer<MethodProvider>(
                builder: (context, methodProvider, child) {
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
                                onChanged: (value) => predictPageProvider.setSelectedExercise(value),
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
                          onPressed: () => predictPageProvider.calculateEstimate(hiveProvider, methodProvider),
                          child: const Text("Calculate Estimate"),
                        ),
                        if (predictPageProvider.estimatedWeight > 0)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Estimated Weight: ${predictPageProvider.estimatedWeight.toStringAsFixed(2)} kg',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
