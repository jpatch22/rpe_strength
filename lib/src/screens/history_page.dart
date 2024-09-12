import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rpe_strength/src/database/models/workout_data_item.dart';
import 'package:rpe_strength/src/models/hype_level.dart';
import 'package:rpe_strength/src/providers/advanced_mode_provider.dart';
import 'package:rpe_strength/src/providers/history_page_provider.dart';
import 'package:rpe_strength/src/widgets/custom_dropdown_search_base.dart';

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final advancedModeProvider = Provider.of<AdvancedModeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Workout History'),
        actions: [
          Switch(
            value: advancedModeProvider.showAdvanced,
            onChanged: (value) {
              advancedModeProvider.setAdvancedMode(value);
            },
          ),
        ],
      ),
      body: Consumer<HistoryPageProvider>(
        builder: (context, historyPageProvider, child) {
          if (historyPageProvider.hiveProvider.exerciseNames.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomDropdownSearchBase(
                  items: historyPageProvider.hiveProvider.exerciseNames,
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
                    if (historyPageProvider.selectedExercises.isNotEmpty) {
                      items = items.where((item) => historyPageProvider.selectedExercises.contains(item.exercise)).toList();
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
                          subtitle: advancedModeProvider.showAdvanced
                              ? Text('Reps: ${item.numReps}, Weight: ${item.weight}, RPE: ${item.RPE}, Sets: ${item.numSets}, Hype: ${HypeLevel.fromOrdinal(item.hype).name}, Notes: ${item.notes}')
                              : Text('Reps: ${item.numReps}, Weight: ${item.weight}, RPE: ${item.RPE}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Time: ${item.timestamp?.toLocal().toString().substring(0, 16) ?? "No timestamp"}'),
                              IconButton(
                                icon: Icon(Icons.remove_circle, color: Colors.red),
                                onPressed: () => historyPageProvider.deleteItem(context, item),
                              ),
                            ],
                          ),
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
