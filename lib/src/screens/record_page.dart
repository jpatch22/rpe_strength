import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpe_strength/src/database/hive_provider.dart';
import 'package:rpe_strength/src/models/adv_row_data.dart';
import 'package:rpe_strength/src/models/row_data.dart';
import 'package:rpe_strength/src/widgets/row_item.dart';
import 'package:rpe_strength/src/widgets/adv_row_item.dart';
import 'package:rpe_strength/src/widgets/custom_dropdown_search.dart';

class RecordPage extends StatefulWidget {
  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  List<RowData> rows = [RowData()];
  String? selectedExercise;
  bool showAdvanced = false;
  bool editTime = false;

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

  void onSaveButtonPress(HiveProvider hiveProvider) {
    if (showAdvanced) {
      hiveProvider.saveAdvancedRowItemList(rows.cast<AdvancedRowData>(), selectedExercise ?? "");
    } else {
      hiveProvider.saveBaseRowItemList(rows, selectedExercise ?? "");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Record Sets'),
      ),
      body: Consumer<HiveProvider>(
        builder: (context, hiveProvider, child) {
          if (hiveProvider.exerciseNames.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => onSaveButtonPress(hiveProvider),
                      child: const Text("Save Data"),
                    ),
                    const SizedBox(width: 10),
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
                                timestamp: e.timestamp,
                              )).toList()
                              : rows.map((e) => RowData(
                                weight: e.weight,
                                numReps: e.numReps,
                                RPE: e.RPE,
                                timestamp: e.timestamp,
                              )).toList();
                        });
                      },
                      activeColor: Colors.blue,
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey[300],
                    ),
                    Text(showAdvanced ? 'Advanced' : 'Basic'),
                    const SizedBox(width: 10),
                    Switch(
                      value: editTime,
                      onChanged: (value) {
                        setState(() {
                          editTime = value;
                        });
                      },
                      activeColor: Colors.blue,
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey[300],
                    ),
                    Text('Edit Time'),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Table(
                    columnWidths: {
                      0: FlexColumnWidth(),
                      1: FlexColumnWidth(),
                      2: FlexColumnWidth(),
                      if (showAdvanced) 3: FlexColumnWidth(),
                      if (showAdvanced) 4: FlexColumnWidth(),
                      if (editTime) 5: FlexColumnWidth(),
                    },
                    children: [
                      TableRow(
                        children: [
                          Text('Weight', textAlign: TextAlign.center),
                          if (showAdvanced) Text('Sets', textAlign: TextAlign.center),
                          Text('Reps', textAlign: TextAlign.center),
                          Text('RPE', textAlign: TextAlign.center),
                          if (showAdvanced) Text('Hype', textAlign: TextAlign.center),
                          if (showAdvanced) Text('Notes', textAlign: TextAlign.center),
                          if (editTime) Text('Time', textAlign: TextAlign.center),
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
                      child: showAdvanced
                          ? AdvancedRowItem(
                              key: UniqueKey(),
                              rowData: rows[index] as AdvancedRowData,
                              onAdd: addRow,
                              onRemove: removeRow,
                              editTime: editTime,
                            )
                          : RowItem(
                              key: UniqueKey(),
                              rowData: rows[index],
                              onAdd: addRow,
                              onRemove: removeRow,
                              editTime: editTime,
                            ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
