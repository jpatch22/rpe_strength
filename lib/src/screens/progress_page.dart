import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpe_strength/src/Utils/Util.dart';
import 'package:rpe_strength/src/database/models/workout_data_item.dart';
import '../database/hive_provider.dart';
import 'package:rpe_strength/src/widgets/custom_dropdown_search_base.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ProgressPage extends StatefulWidget {
  @override
  _ProgressPageState createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  List<String> selectedExercises = [];
  List<ChartSeries<WorkoutDataItem, DateTime>> seriesList = [];
  String selectedMethod = 'Epley';
  List<String> calculationMethods = ['Epley', 'Brzycki', 'Lombardi', 'O\'Conner', 'Wathan'];

  @override
  void initState() {
    super.initState();
    final hiveProvider = Provider.of<HiveProvider>(context, listen: false);
    hiveProvider.fetchExerciseNames();
    _updateChartSeries(hiveProvider);
  }

  void _onDropdownChanged(List<String> selectedItems) {
    setState(() {
      selectedExercises = selectedItems;
      final hiveProvider = Provider.of<HiveProvider>(context, listen: false);
      _updateChartSeries(hiveProvider);
    });
  }

  void _updateChartSeries(HiveProvider hiveProvider) {
    List<WorkoutDataItem> items = hiveProvider.workoutDataItems;

    // Filter items based on selected exercises
    if (selectedExercises.isNotEmpty) {
      items = items.where((item) => selectedExercises.contains(item.exercise)).toList();
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

    List<ChartSeries<WorkoutDataItem, DateTime>> updatedSeriesList = [];
    groupedItems.forEach((exercise, items) {
      updatedSeriesList.add(LineSeries<WorkoutDataItem, DateTime>(
        dataSource: items,
        xValueMapper: (WorkoutDataItem item, _) => item.timestamp!,
        yValueMapper: (WorkoutDataItem item, _) => Util.calculate1RM(item, selectedMethod),
        name: exercise,
        markerSettings: MarkerSettings(
          isVisible: true,
          shape: DataMarkerType.circle
        )
      ));
    });

    setState(() {
      seriesList = updatedSeriesList;
    });
  }

  void _onMethodChanged(String? newMethod) {
    setState(() {
      selectedMethod = newMethod!;
      final hiveProvider = Provider.of<HiveProvider>(context, listen: false);
      _updateChartSeries(hiveProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
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
                child: Column(
                  children: [
                    SizedBox(
                      width: 300.0,
                      child: DropdownButton<String>(
                        value: selectedMethod,
                        onChanged: _onMethodChanged,
                        items: calculationMethods.map((String method) {
                          return DropdownMenuItem<String>(
                            value: method,
                            child: Text(method),
                          );
                        }).toList(),
                        isExpanded: true,
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                child: SfCartesianChart(
                  title: ChartTitle(text: 'e1RM Progress'),
                  legend: Legend(isVisible: true),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: seriesList,
                  primaryXAxis: DateTimeAxis(),
                  primaryYAxis: NumericAxis(
                    title: AxisTitle(text: '1RM Weight'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
