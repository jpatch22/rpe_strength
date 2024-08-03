import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpe_strength/src/database/hive_provider.dart';
import 'package:rpe_strength/src/database/models/workout_data_item.dart';
import 'package:rpe_strength/src/providers/method_provider.dart';
import 'package:rpe_strength/src/widgets/custom_dropdown_search.dart';
import '../Utils/Util.dart';

class PredictPage extends StatefulWidget {
  @override
  _PredictPageState createState() => _PredictPageState();
}

class _PredictPageState extends State<PredictPage> {
  String? selectedExercise;
  String rpe = '';
  String reps = '';
  double estimatedWeight = 0;

  @override
  void initState() {
    super.initState();
    final hiveProvider = Provider.of<HiveProvider>(context, listen: false);
    hiveProvider.fetchExerciseNames();
  }

  void _onDropdownChanged(String? value) {
    setState(() {
      selectedExercise = value;
    });
  }

  void _calculateEstimate(HiveProvider hiveProvider, MethodProvider methodProvider) {
    if (selectedExercise != null && rpe.isNotEmpty && reps.isNotEmpty) {
      final latestItem = hiveProvider.workoutDataItems
          .where((item) => item.exercise == selectedExercise)
          .reduce((a, b) => (a.timestamp?.isAfter(b.timestamp ?? DateTime.fromMillisecondsSinceEpoch(0)) ?? false) ? a : b);
      
      final item = WorkoutDataItem(
        exercise: selectedExercise!,
        weight: latestItem.weight,
        numReps: int.tryParse(reps) ?? latestItem.numReps,
        RPE: rpe,
      );
      setState(() {
        estimatedWeight = Util.calculateWeight(latestItem,
            Util.calculate1RM(item, methodProvider.selectedMethod), methodProvider.selectedMethod);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hiveProvider = Provider.of<HiveProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Predict Weight'),
      ),
      body: Consumer<HiveProvider>(
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
                            onChanged: _onDropdownChanged,
                            selectedItem: selectedExercise,
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
                        decoration: InputDecoration(
                          labelText: "RPE",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            rpe = value;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: "Reps",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            reps = value;
                          });
                        },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _calculateEstimate(hiveProvider, methodProvider),
                      child: const Text("Calculate Estimate"),
                    ),
                    if (estimatedWeight > 0)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Estimated Weight: ${estimatedWeight.toStringAsFixed(2)} kg',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
