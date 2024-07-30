import 'package:flutter/material.dart';
import '../models/adv_row_data.dart';

class AdvancedRowItem extends StatefulWidget {
  final AdvancedRowData rowData;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  AdvancedRowItem({
    Key? key,
    required this.rowData,
    required this.onAdd,
    required this.onRemove,
  }) : super(key: key);

  @override
  _AdvancedRowItemState createState() => _AdvancedRowItemState();
}

class _AdvancedRowItemState extends State<AdvancedRowItem> {
  late TextEditingController weight;
  late TextEditingController reps;
  late TextEditingController sets;
  late TextEditingController notes;
  late String rpe;
  late String hype;

  @override
  void initState() {
    super.initState();
    rpe = widget.rowData.RPE;
    weight = TextEditingController(text: widget.rowData.weight);
    reps = TextEditingController(text: widget.rowData.numReps);
    sets = TextEditingController(text: widget.rowData.numSets);
    hype = widget.rowData.hype;
    notes = TextEditingController(text: widget.rowData.notes);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          width: 100,
          child: TextField(
            controller: weight,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              widget.rowData.weight = value;
            },
          ),
        ),
        Container(
          width: 100,
          child: TextField(
            controller: sets,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              widget.rowData.numSets = value;
            },
          ),
        ),
        Container(
          width: 100,
          child: TextField(
            controller: reps,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              widget.rowData.numReps = value;
            },
          ),
        ),
        DropdownButton<String>(
          value: rpe,
          onChanged: (String? newValue) {
            setState(() {
              rpe = newValue!;
              widget.rowData.RPE = rpe;
            });
          },
          items: <String>['Fail', '10', '9.5', '9', '8.5', '8', '7.5', '7', '6.5', '6', '5.5', '5']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        DropdownButton<String>(
          value: hype,
          onChanged: (String? newValue) {
            setState(() {
              hype = newValue!;
              widget.rowData.hype = hype;
            });
          },
          items: <String>['High', 'Moderate', 'Low']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        Container(
          width: 100,
          child: TextField(
            controller: notes,
            onChanged: (value) {
              widget.rowData.notes = value;
            },
            decoration: InputDecoration(
              labelText: 'Notes',
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    weight.dispose();
    reps.dispose();
    sets.dispose();
    notes.dispose();
    super.dispose();
  }
}
