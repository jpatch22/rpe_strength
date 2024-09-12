import 'package:flutter/material.dart';
import 'package:rpe_strength/src/models/row_data.dart';

class RowItem extends StatefulWidget {
  final RowData rowData;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final bool editTime;

  RowItem({
    Key? key,
    required this.rowData,
    required this.onAdd,
    required this.onRemove,
    required this.editTime,
  }) : super(key: key);

  @override
  _RowItemState createState() => _RowItemState();
}

class _RowItemState extends State<RowItem> {
  late TextEditingController weight;
  late TextEditingController reps;
  late TextEditingController timeController;
  late String rpe;

  @override
  void initState() {
    super.initState();
    rpe = widget.rowData.RPE;
    weight = TextEditingController(text: widget.rowData.weight);
    reps = TextEditingController(text: widget.rowData.numReps);
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
              widget.rowData.RPE= rpe;
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
    timeController.dispose();
    super.dispose();
  }
}
