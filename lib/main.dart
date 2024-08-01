import 'package:flutter/material.dart';

import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'src/database/models/workout_data_item.dart';
import 'src/database/hive_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(WorkoutDataItemAdapter());

  await Hive.openBox<WorkoutDataItem>('workoutDataBox');
  HiveHelper.initializeExerciseNames();

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
  runApp(MyApp(settingsController: settingsController));
}
