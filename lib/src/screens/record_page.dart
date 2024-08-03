import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpe_strength/src/database/hive_provider.dart';
import 'package:rpe_strength/src/models/adv_row_data.dart';
import 'package:rpe_strength/src/models/row_data.dart';
import 'package:rpe_strength/src/widgets/row_item.dart';
import 'package:rpe_strength/src/widgets/adv_row_item.dart';
import 'package:rpe_strength/src/widgets/custom_dropdown_search.dart';
import '../providers/advanced_mode_provider.dart';

class RecordPage extends StatefulWidget {
  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  List<RowData> rows = [RowData()];
  String? selectedExercise;
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

  void onSaveButtonPress(HiveProvider hiveProvider, bool showAdvanced) {
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

  void addRow(bool showAdvanced) {
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
    final advancedModeProvider = Provider.of<AdvancedModeProvider>(context);

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
                      onPressed: () => onSaveButtonPress(hiveProvider, advancedModeProvider.showAdvanced),
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
                      onPressed: () => addRow(advancedModeProvider.showAdvanced),
                      child: const Text("+"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: removeRow,
                      child: const Text("-"),
                    ),
                    const SizedBox(width: 10),
                    Switch(
                      value: advancedModeProvider.showAdvanced,
                      onChanged: (value) {
                        advancedModeProvider.setAdvancedMode(value);
                        setState(() {
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
                    Text(advancedModeProvider.showAdvanced ? 'Advanced' : 'Basic'),
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
                      if (advancedModeProvider.showAdvanced) 3: FlexColumnWidth(),
                      if (advancedModeProvider.showAdvanced) 4: FlexColumnWidth(),
                      if (editTime) 5: FlexColumnWidth(),
                    },
                    children: [
                      TableRow(
                        children: [
                          Text('Weight', textAlign: TextAlign.center),
                          if (advancedModeProvider.showAdvanced) Text('Sets', textAlign: TextAlign.center),
                          Text('Reps', textAlign: TextAlign.center),
                          Text('RPE', textAlign: TextAlign.center),
                          if (advancedModeProvider.showAdvanced) Text('Hype', textAlign: TextAlign.center),
                          if (advancedModeProvider.showAdvanced) Text('Notes', textAlign: TextAlign.center),
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
                      child: advancedModeProvider.showAdvanced
                          ? AdvancedRowItem(
                              key: UniqueKey(),
                              rowData: rows[index] as AdvancedRowData,
                              onAdd: () => addRow(advancedModeProvider.showAdvanced),
                              onRemove: removeRow,
                              editTime: editTime,
                            )
                          : RowItem(
                              key: UniqueKey(),
                              rowData: rows[index],
                              onAdd: () => addRow(advancedModeProvider.showAdvanced),
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
