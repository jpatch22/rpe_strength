import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpe_strength/src/database/hive_provider.dart';
import 'package:rpe_strength/src/models/adv_row_data.dart';
import 'package:rpe_strength/src/providers/auth_service.dart';
import 'package:rpe_strength/src/settings/settings_controller.dart';
import 'package:rpe_strength/src/settings/settings_view.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hiveProvider = Provider.of<HiveProvider>(context, listen: false);
    final settingsController = Provider.of<SettingsController>(context, listen: false);
    final authService = Provider.of<AuthService>(context);
    final user = authService.user;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            'assets/images/home_image.webp',
            fit: BoxFit.cover,
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsView(controller: settingsController),
                    ),
                  );
                },
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 50),
              const Text(
                'RPE Zero Logging',
                style: TextStyle(
                  fontSize: 36,
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
              // SizedBox(height: 20), // Space between text and button
              // ElevatedButton(
                // onPressed: () {
                  // saveRandTestData(hiveProvider);
                // },
                // child: Text("Debug"),
              // ),
              // SizedBox(height: 20), // Space between text and button
              // ElevatedButton(
                // onPressed: () {
                  // _clearLocalData(hiveProvider);
                // },
                // child: Text("Clear Local Data"),
              // ),
              SizedBox(height: 20), // Space between buttons
              if (user == null)
                ElevatedButton(
                  onPressed: () async {
                    User? user = await authService.signInWithGoogle();
                    if (user != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Sign In Successful: ${user.displayName}'),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Sign In Failed'),
                        ),
                      );
                    }
                  },
                  child: Text('Sign In with Google'),
                )
              else ...[
                Text(
                  'Hello, ${user.displayName}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 5.0,
                        color: Colors.black,
                        offset: Offset(1.0, 1.0),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    await authService.signOut();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Signed Out'),
                      ),
                    );
                  },
                  child: Text('Sign Out'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _clearLocalData(HiveProvider hiveProvider) {
    hiveProvider.clearLocalData();
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
