import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rpe_strength/src/database/models/workout_data_item.dart';
import '../database/hive_provider.dart';
import '../providers/method_provider.dart';
import '../utils/util.dart';

class ProgressPage extends StatefulWidget {
  @override
  _ProgressPageState createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  List<String> selectedExercises = [];

  @override
  Widget build(BuildContext context) {
    final methodProvider = Provider.of<MethodProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Tracking'),
      ),
      body: Consumer<HiveProvider>(
        builder: (context, hiveProvider, child) {
          if (hiveProvider.exerciseNames.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 200, // Set a fixed width for the dropdown
                  child: DropdownButton<String>(
                    value: methodProvider.selectedMethod,
                    onChanged: (newMethod) {
                      methodProvider.setSelectedMethod(newMethod!);
                      setState(() {}); // Rebuild chart when the method changes
                    },
                    items: Util.calculationMethods.map((String method) {
                      return DropdownMenuItem<String>(
                        value: method,
                        child: Text(method),
                      );
                    }).toList(),
                    isExpanded: true, // Keep this for full width within the box
                  ),
                ),

              ),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: Hive.box<WorkoutDataItem>('workoutDataBox').listenable(),
                  builder: (context, Box<WorkoutDataItem> box, _) {
                    // Fetch and filter workout data items
                    var items = box.values.toList();

                    // Filter items based on selected exercises
                    if (selectedExercises.isNotEmpty) {
                      items = items
                          .where((item) => selectedExercises.contains(item.exercise))
                          .toList();
                    }

                    // Group items by exercise and create series for each exercise
                    Map<String, List<WorkoutDataItem>> groupedItems = {};
                    for (var item in items) {
                      if (groupedItems.containsKey(item.exercise)) {
                        groupedItems[item.exercise]!.add(item);
                      } else {
                        groupedItems[item.exercise] = [item];
                      }
                    }

                    List<ChartSeries<WorkoutDataItem, DateTime>> seriesList = [];
                    groupedItems.forEach((exercise, items) {
                      seriesList.add(LineSeries<WorkoutDataItem, DateTime>(
                        dataSource: items,
                        xValueMapper: (WorkoutDataItem item, _) => item.timestamp!,
                        yValueMapper: (WorkoutDataItem item, _) =>
                            Util.calculate1RM(item, methodProvider.selectedMethod),
                        name: exercise,
                        markerSettings: MarkerSettings(
                          isVisible: true,
                          shape: DataMarkerType.circle,
                        ),
                      ));
                    });

                    if (seriesList.isEmpty) {
                      return const Center(child: Text('No workout data available'));
                    }

                    // Build the chart with the updated series
                    return SfCartesianChart(
                      title: ChartTitle(text: 'e1RM Progress'),
                      legend: Legend(isVisible: true),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: seriesList,
                      primaryXAxis: DateTimeAxis(),
                      primaryYAxis: NumericAxis(
                        title: AxisTitle(text: '1RM Weight'),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
