import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rpe_strength/src/database/models/workout_data_item.dart';
import 'package:rpe_strength/src/models/hype_level.dart';
import '../database/hive_provider.dart';
import '../widgets/custom_dropdown_search_base.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool showAdvanced = false;
  List<String> selectedExercises = [];

  @override
  void initState() {
    super.initState();
    final hiveProvider = Provider.of<HiveProvider>(context, listen: false);
    hiveProvider.fetchExerciseNames();
  }

  void _onDropdownChanged(List<String> selectedItems) {
    setState(() {
      selectedExercises = selectedItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Workout History'),
        actions: [
          Switch(
            value: showAdvanced,
            onChanged: (value) {
              setState(() {
                showAdvanced = value;
              });
            },
          ),
        ],
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
                child: CustomDropdownSearchBase(
                  items: hiveProvider.exerciseNames,
                  onChanged: _onDropdownChanged,
                  selectedItems: selectedExercises,
                  labelText: "Filter Exercises",
                  hintText: "Select exercises to filter",
                ),
              ),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: Hive.box<WorkoutDataItem>('workoutDataBox').listenable(),
                  builder: (context, Box<WorkoutDataItem> box, _) {
                    var items = box.values.toList();
                    items.sort((a, b) {
                      if (a.timestamp == null && b.timestamp == null) return 0;
                      if (a.timestamp == null) return 1; // Consider null as the earliest
                      if (b.timestamp == null) return -1;
                      return b.timestamp!.compareTo(a.timestamp!);
                    });

                    // Filter items based on selected exercises
                    if (selectedExercises.isNotEmpty) {
                      items = items.where((item) => selectedExercises.contains(item.exercise)).toList();
                    }

                    if (items.isEmpty) {
                      return Center(child: Text('No workout data available'));
                    }

                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        WorkoutDataItem item = items[index];
                        return ListTile(
                          title: Text('Exercise: ${item.exercise}'),
                          subtitle: showAdvanced
                              ? Text('Reps: ${item.numReps}, Weight: ${item.weight}, RPE: ${item.RPE}, Sets: ${item.numSets}, Hype: ${HypeLevel.fromOrdinal(item.hype).name}, Notes: ${item.notes}')
                              : Text('Reps: ${item.numReps}, Weight: ${item.weight}, RPE: ${item.RPE}'),
                          trailing: Text('Time: ${item.timestamp?.toLocal().toString().substring(0, 16) ?? "No timestamp"}'),
                        );
                      },
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
