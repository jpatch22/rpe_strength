import 'row_data.dart';

class AdvancedRowData extends RowData {
  String numSets;
  String hype;
  String notes;

  AdvancedRowData({
    required String weight,
    required String numReps,
    required String RPE,
    this.numSets = '1',
    this.hype = 'Moderate',
    this.notes = '',
    String? timestamp,
  }) : super(
          weight: weight,
          numReps: numReps,
          RPE: RPE,
          timestamp: timestamp,
        );

  @override
  String toString() {
    return 'AdvancedRowData(weight: $weight, numReps: $numReps, RPE: $RPE, numSets: $numSets, hype: $hype, notes: $notes, timestamp: $timestamp)';
  }
}
