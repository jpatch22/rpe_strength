import 'package:flutter/material.dart';
import '../widgets/custom_dropdown_search.dart';
import 'package:rpe_strength/src/database/hive_helper.dart';
import '../models/row_data.dart';
import '../models/adv_row_data.dart';
import '../widgets/row_item.dart';
import '../widgets/adv_row_item.dart';

class RecordPage extends StatefulWidget {
  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  List<RowData> rows = [RowData()];
  String? selectedExercise;
  bool showAdvanced = false; // Toggle for showing advanced row items
  List<String> exerciseOptions = []; // Placeholder for your exercise options

  @override
  void initState() {
    super.initState();
    _loadExerciseNames();
  }

  Future<void> _loadExerciseNames() async {
    try {
      final options = await HiveHelper.getExerciseNames();
      setState(() {
        exerciseOptions = options;
      });
    } catch (e) {
      print('Error loading exercise names: $e');
    }
  }

  void _onDropdownChanged(String? value) {
    setState(() {
      selectedExercise = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Record Sets'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: onSaveButtonPress,
                  child: const Text("Save Data"),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 300,
                  child: CustomDropdownSearch(
                    items: exerciseOptions,
                    onChanged: _onDropdownChanged,
                    selectedItem: selectedExercise,
                    labelText: "Select Exercise",
                    hintText: "Search and select an exercise",
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: addRow,
                  child: const Text("+"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: removeRow,
                  child: const Text("-"),
                ),
                const SizedBox(width: 10),
                Switch(
                  value: showAdvanced,
                  onChanged: (value) {
                    setState(() {
                      showAdvanced = value;
                      rows = value
                          ? rows.map((e) => AdvancedRowData(
                                weight: e.weight,
                                numReps: e.numReps,
                                RPE: e.RPE,
                              )).toList()
                          : rows.map((e) => RowData(
                                weight: e.weight,
                                numReps: e.numReps,
                                RPE: e.RPE,
                              )).toList();
                    });
                  },
                  activeColor: Colors.blue,
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey[300],
                ),
                Text(showAdvanced ? 'Advanced' : 'Basic'),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Table(
                columnWidths: {
                  0: FlexColumnWidth(),
                  1: FlexColumnWidth(),
                  2: FlexColumnWidth(),
                  3: FixedColumnWidth(50),
                  4: FixedColumnWidth(50),
                },
                children: [
                  TableRow(
                    children: [
                      Text('Weight'),
                      Text('Sets'),
                      Text('Reps'),
                      if (showAdvanced) Text('Hype'),
                      if (showAdvanced) Text('Notes'),
                      SizedBox.shrink(), // Empty cell
                      SizedBox.shrink(), // Empty cell
                    ],
                  ),
                ],
              ),
            ),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: rows.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Table(
                    columnWidths: {
                      0: FlexColumnWidth(),
                      1: FlexColumnWidth(),
                      2: FlexColumnWidth(),
                      3: FixedColumnWidth(50),
                      4: FixedColumnWidth(50),
                    },
                    children: [
                      TableRow(
                        children: [
                          showAdvanced
                              ? AdvancedRowItem(
                                  key: UniqueKey(),
                                  rowData: rows[index] as AdvancedRowData,
                                  onAdd: addRow,
                                  onRemove: removeRow,
                                )
                              : RowItem(
                                  key: UniqueKey(),
                                  rowData: rows[index],
                                  onAdd: addRow,
                                  onRemove: removeRow,
                                ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void onSaveButtonPress() {
    if (showAdvanced) {
      HiveHelper.saveAdvancedRowItemList(rows.cast<AdvancedRowData>(), selectedExercise ?? "");
    } else {
      HiveHelper.saveBaseRowItemList(rows, selectedExercise ?? "");
    }

    setState(() {
      rows = showAdvanced
          ? [AdvancedRowData(weight: '', numReps: '', RPE: '5')]
          : [RowData()];
      selectedExercise = null; // Reset the selected value of the dropdown
    });
  }

  void addRow() {
    setState(() {
      rows.add(showAdvanced
          ? AdvancedRowData(weight: '', numReps: '', RPE: '5')
          : RowData());
    });
  }

  void removeRow() {
    if (rows.length > 1) {
      setState(() {
        rows.removeLast();
      });
    }
  }
}
