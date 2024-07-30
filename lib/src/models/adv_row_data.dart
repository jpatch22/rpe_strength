import 'row_data.dart';

class AdvancedRowData extends RowData {
  String numSets;
  String hype;
  String notes;

  AdvancedRowData({
    required String weight,
    required String numReps,
    required String RPE,
    this.numSets = '',
    this.hype = 'Moderate',
    this.notes = '',
  }) : super(
          weight: weight,
          numReps: numReps,
          RPE: RPE,
        );
}
