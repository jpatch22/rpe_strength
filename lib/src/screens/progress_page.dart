import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpe_strength/src/Utils/Util.dart';
import 'package:rpe_strength/src/database/hive_provider.dart';
import 'package:rpe_strength/src/providers/method_provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rpe_strength/src/database/models/workout_data_item.dart';

class ProgressPage extends StatefulWidget {
  @override
  _ProgressPageState createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  List<String> selectedExercises = [];
  Map<String, bool> seriesVisibility = {}; // Track visibility of each series

  @override
  Widget build(BuildContext context) {
    final methodProvider = Provider.of<MethodProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Tracking'),
      ),
      body: Consumer<HiveProvider>(
        builder: (context, hiveProvider, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 200,
                  child: DropdownButton<String>(
                    value: methodProvider.selectedMethod,
                    onChanged: (newMethod) {
                      methodProvider.setSelectedMethod(newMethod!);
                      setState(() {});
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
              ),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: Hive.box<WorkoutDataItem>('workoutDataBox').listenable(),
                  builder: (context, Box<WorkoutDataItem> box, _) {
                    var items = box.values.toList();

                    if (selectedExercises.isNotEmpty) {
                      items = items
                          .where((item) => selectedExercises.contains(item.exercise))
                          .toList();
                    }

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
                      Map<String, WorkoutDataItem> filteredItems = {};
                      for (var item in items) {
                        final dateKey =
                            "${item.timestamp!.year}-${item.timestamp!.month}-${item.timestamp!.day}";
                        final calculated1RM = Util.calculate1RM(item, methodProvider.selectedMethod);
                        if (filteredItems.containsKey(dateKey)) {
                          final existing1RM = Util.calculate1RM(
                              filteredItems[dateKey]!, methodProvider.selectedMethod);
                          if (calculated1RM > existing1RM) {
                            filteredItems[dateKey] = item;
                          }
                        } else {
                          filteredItems[dateKey] = item;
                        }
                      }
                      final sortedItems = filteredItems.values.toList()
                        ..sort((a, b) => a.timestamp!.compareTo(b.timestamp!));

                      seriesList.add(LineSeries<WorkoutDataItem, DateTime>(
                        dataSource: sortedItems,
                        xValueMapper: (WorkoutDataItem item, _) => item.timestamp!,
                        yValueMapper: (WorkoutDataItem item, _) =>
                            Util.calculate1RM(item, methodProvider.selectedMethod),
                        name: exercise,
                        markerSettings: MarkerSettings(
                          isVisible: true,
                          shape: DataMarkerType.circle,
                        ),
                      ));

                      // Initialize visibility map for this exercise
                      seriesVisibility[exercise] = true;
                    });
                    print("Starter: $seriesVisibility");

                    if (seriesList.isEmpty) {
                      return const Center(child: Text('No workout data available'));
                    }

                    return Column(
                      children: [
                        Expanded(
                          child: SfCartesianChart(
                            title: ChartTitle(text: 'e1RM Progress'),
                            legend: Legend(
                              isVisible: true,
                              toggleSeriesVisibility: true,
                            ),
                            tooltipBehavior: TooltipBehavior(enable: true),
                            onLegendTapped: (LegendTapArgs args) {
                              setState(() {
                                // Get the series name from the tapped legend item
                                String seriesName = args.series.name ?? '';
                                // Toggle visibility for the series
                                seriesVisibility[seriesName] =
                                    !(seriesVisibility[seriesName] ?? true);
                              });

                              // Log currently visible series
                              print('Currently visible series:');
                              seriesVisibility.forEach((seriesName, isVisible) {
                                if (isVisible) {
                                  print('$seriesName is visible');
                                }
                              });
                              print("Overview: $seriesVisibility");
                            },
                            series: seriesList,
                            primaryXAxis: DateTimeAxis(),
                            primaryYAxis: NumericAxis(
                              title: AxisTitle(text: '1RM Weight'),
                            ),
                          ),
                        ),
                        // Display the list of visible series
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Visible Exercises: ${seriesVisibility.entries.where((entry) => entry.value).map((entry) => entry.key).join(', ')}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
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
