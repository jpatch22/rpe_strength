import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpe_strength/src/database/hive_provider.dart';
import 'package:rpe_strength/src/models/adv_row_data.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hiveProvider = Provider.of<HiveProvider>(context, listen: false);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            'assets/images/home_image.webp',
            fit: BoxFit.cover,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Gym Progress Tracker',
                  style: TextStyle(
                    fontSize: 36,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    saveRandTestData(hiveProvider);
                  },
                  child: Text("Debug"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void saveRandTestData(HiveProvider hiveProvider) {
    DateTime time0 = DateTime(2024, 5, 1);
    DateTime time1 = DateTime(2024, 6, 1);
    DateTime time2 = DateTime(2024, 7, 1);
    hiveProvider.saveAdvancedRowItemList(
        [AdvancedRowData(weight: "225", numReps: "5", RPE: "6")],
        "Squat",
        timestamp: time0);
    hiveProvider.saveAdvancedRowItemList(
        [AdvancedRowData(weight: "235", numReps: "5", RPE: "6")],
        "Squat",
        timestamp: time1);
    hiveProvider.saveAdvancedRowItemList(
        [AdvancedRowData(weight: "245", numReps: "5", RPE: "6")],
        "Squat",
        timestamp: time2);
  }
}
