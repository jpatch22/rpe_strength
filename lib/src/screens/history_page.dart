import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rpe_strength/src/database/models/workout_data_item.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool showAdvanced = false;
  Box<WorkoutDataItem>? workoutBox;

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    workoutBox = await Hive.openBox<WorkoutDataItem>('workoutDataBox');
    setState(() {}); // Trigger a rebuild after the box is opened
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
      body: workoutBox == null
          ? const Center(child: CircularProgressIndicator())
          : ValueListenableBuilder(
              valueListenable: workoutBox!.listenable(),
              builder: (context, Box<WorkoutDataItem> box, _) {
                var items = box.values.toList();
                items.sort((a, b) {
                  if (a.timestamp == null && b.timestamp == null) return 0;
                  if (a.timestamp == null) return 1; // Consider null as the earliest
                  if (b.timestamp == null) return -1;
                  return b.timestamp!.compareTo(a.timestamp!);
                });

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
                          ? Text('Reps: ${item.numReps}, Weight: ${item.weight}, RPE: ${item.RPE}, Sets: ${item.numSets}, Hype: ${item.hype}, Notes: ${item.notes}')
                          : Text('Reps: ${item.numReps}, Weight: ${item.weight}, RPE: ${item.RPE}'),
                      trailing: Text('Time: ${item.timestamp?.toLocal().toString().substring(0, 16) ?? "No timestamp"}'),
                    );
                  },
                );
              },
            ),
    );
  }

  @override
  void dispose() {
    workoutBox?.close();
    super.dispose();
  }
}
