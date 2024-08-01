import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Make sure to import the provider package
import 'package:rpe_strength/src/database/hive_provider.dart';
import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'src/database/models/workout_data_item.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(WorkoutDataItemAdapter());

  // Initialize Firebase
  // try {
    // await Firebase.initializeApp(
      // options: DefaultFirebaseOptions.currentPlatform,
    // );
    // print("successful initialization");
  // } catch (e) {
    // print("Error initializing firebase: $e");
  // }
  
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  final settingsController = SettingsController(SettingsService());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(
    ChangeNotifierProvider(
      create: (_) {
        final hiveProvider = HiveProvider();
        return hiveProvider;
      },
      child: MyApp(settingsController: settingsController),
    ),
  );
}
