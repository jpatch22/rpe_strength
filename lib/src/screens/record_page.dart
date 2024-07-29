import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../models/row_data.dart';
import '../widgets/row_item.dart';

class RecordPage extends StatefulWidget {
  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  List<RowData> rows = [RowData()];
  String? selectedValue;

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
                  child: const Text("Save Data")
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 200, // Adjust the width as needed
                  child: DropdownSearch<String>(
                    items: [
                      "Option 1",
                      "Option 2",
                      "Option 3",
                      'Option 4'
                    ],
                    popupProps: PopupProps.dialog(
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(
                          labelText: "Search",
                          hintText: "Search for an option",
                        ),
                      ),
                      itemBuilder: (context, item, isSelected) {
                        return ListTile(
                          title: Text(item),
                        );
                      },
                    ),
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: "Select Option",
                        hintText: "Search and select an option",
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        selectedValue = value;
                      });
                    },
                    selectedItem: selectedValue,
                    clearButtonProps: ClearButtonProps(
                      isVisible: true,
                    ),
                    filterFn: (item, filter) {
                      if (filter == null || filter.isEmpty) {
                        return true;
                      }
                      return item.toLowerCase().contains(filter.toLowerCase());
                    },
                  ),
                ),
                const SizedBox(height: 10)
              ],
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
                          RowItem(
                            key: UniqueKey(),
                            rowData: rows[index],
                            onAdd: () => addRowAt(index),
                            onRemove: () => removeRowAt(index),
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
    // Print the current data
    for (var row in rows) {
      print(row.toString());
    }

    // Reset rows to the base configuration
    setState(() {
      rows = [RowData()];
      selectedValue = null; // Reset the selected value of the dropdown
    });
  }

  void addRow() {
    setState(() {
      rows.add(RowData());
    });
  }

  void removeRow() {
    if (rows.length > 1) {
      setState(() {
        rows.removeLast();
      });
    }
  }

  void addRowAt(int index) {
    setState(() {
      rows.insert(index + 1, RowData());
    });
  }

  void removeRowAt(int index) {
    if (rows.length > 1) {
      setState(() {
        rows.removeAt(index);
      });
    }
  }
}
