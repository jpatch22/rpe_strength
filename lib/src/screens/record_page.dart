import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpe_strength/src/models/adv_row_data.dart';
import 'package:rpe_strength/src/models/row_data.dart';
import 'package:rpe_strength/src/providers/record_page_provider.dart';
import 'package:rpe_strength/src/widgets/row_item.dart';
import 'package:rpe_strength/src/widgets/adv_row_item.dart';
import 'package:rpe_strength/src/widgets/custom_dropdown_search.dart';
import '../providers/advanced_mode_provider.dart';

class RecordPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final advancedModeProvider = Provider.of<AdvancedModeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Record Sets'),
      ),
      body: Consumer<RecordPageProvider>(
        builder: (context, recordPageProvider, child) {
          if (recordPageProvider.hiveProvider.exerciseNames.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => recordPageProvider.onSaveButtonPress(advancedModeProvider.showAdvanced),
                      child: const Text("Save Data"),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 300,
                      child: CustomDropdownSearch(
                        items: recordPageProvider.hiveProvider.exerciseNames,
                        onChanged: recordPageProvider.onDropdownChanged,
                        selectedItem: recordPageProvider.selectedExercise,
                        labelText: "",
                        hintText: "Search and select an exercise",
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => recordPageProvider.addRow(advancedModeProvider.showAdvanced),
                      child: const Text("+"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: recordPageProvider.removeRow,
                      child: const Text("-"),
                    ),
                    const SizedBox(width: 10),
                    Switch(
                      value: advancedModeProvider.showAdvanced,
                      onChanged: (value) {
                        advancedModeProvider.setAdvancedMode(value);
                        recordPageProvider.rows = value
                            ? recordPageProvider.rows.map((e) => AdvancedRowData(
                                  weight: e.weight,
                                  numReps: e.numReps,
                                  RPE: e.RPE,
                                  timestamp: e.timestamp,
                                )).toList()
                            : recordPageProvider.rows.map((e) => RowData(
                                  weight: e.weight,
                                  numReps: e.numReps,
                                  RPE: e.RPE,
                                  timestamp: e.timestamp,
                                )).toList();
                        recordPageProvider.notifyListeners();
                      },
                      activeColor: Colors.blue,
                      inactiveThumbColor: Colors.grey,
                      inactiveTrackColor: Colors.grey[300],
                    ),
                    Text(advancedModeProvider.showAdvanced ? 'Advanced' : 'Basic'),
                    const SizedBox(width: 10),
                    Switch(
                      value: recordPageProvider.editTime,
                      onChanged: recordPageProvider.toggleEditTime,
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
                      if (recordPageProvider.editTime) 5: FlexColumnWidth(),
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
                          if (recordPageProvider.editTime) Text('Time', textAlign: TextAlign.center),
                        ],
                      ),
                    ],
                  ),
                ),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: recordPageProvider.rows.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: advancedModeProvider.showAdvanced
                          ? AdvancedRowItem(
                              key: UniqueKey(),
                              rowData: recordPageProvider.rows[index] as AdvancedRowData,
                              onAdd: () => recordPageProvider.addRow(advancedModeProvider.showAdvanced),
                              onRemove: recordPageProvider.removeRow,
                              editTime: recordPageProvider.editTime,
                            )
                          : RowItem(
                              key: UniqueKey(),
                              rowData: recordPageProvider.rows[index],
                              onAdd: () => recordPageProvider.addRow(advancedModeProvider.showAdvanced),
                              onRemove: recordPageProvider.removeRow,
                              editTime: recordPageProvider.editTime,
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
