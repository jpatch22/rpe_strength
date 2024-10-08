import 'package:flutter/material.dart';
import 'package:rpe_strength/src/models/adv_row_data.dart';

class AdvancedRowItem extends StatefulWidget {
  final AdvancedRowData rowData;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final bool editTime;

  AdvancedRowItem({
    Key? key,
    required this.rowData,
    required this.onAdd,
    required this.onRemove,
    required this.editTime,
  }) : super(key: key);

  @override
  _AdvancedRowItemState createState() => _AdvancedRowItemState();
}

class _AdvancedRowItemState extends State<AdvancedRowItem> {
  late TextEditingController weight;
  late TextEditingController reps;
  late TextEditingController sets;
  late TextEditingController notes;
  late TextEditingController timeController;
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
    timeController = TextEditingController(text: widget.rowData.timestamp ?? "");
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
        if (widget.editTime)
          Container(
            width: 150,
            child: TextField(
              controller: timeController,
              decoration: InputDecoration(labelText: 'Time (DDMMYY)'),
              onChanged: (value) {
                widget.rowData.timestamp = value;
              },
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
    timeController.dispose();
    super.dispose();
  }
}
