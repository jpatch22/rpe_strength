import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpe_strength/firebase_options.dart';
import 'package:rpe_strength/src/database/hive_provider.dart';
import 'package:rpe_strength/src/providers/advanced_mode_provider.dart';
import 'package:rpe_strength/src/providers/auth_service.dart';
import 'package:rpe_strength/src/providers/method_provider.dart';
import 'package:rpe_strength/src/providers/predict_page_provider.dart';
import 'package:rpe_strength/src/providers/record_page_provider.dart';
import 'package:rpe_strength/src/providers/history_page_provider.dart';
import 'package:rpe_strength/src/providers/series_vis_provider.dart';
import 'package:rpe_strength/src/providers/shown_exercises_provider.dart';
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
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("successful initialization");
  } catch (e) {
    print("Error initializing firebase: $e");
  }
  
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
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HiveProvider()),
        ChangeNotifierProvider(create: (_) => settingsController),
        ChangeNotifierProvider(create: (_) => AdvancedModeProvider()),
        ChangeNotifierProvider(create: (_) => MethodProvider()),
        ChangeNotifierProvider(create: (_) => PredictPageProvider()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(
            create: (_) => SeriesVisibilityProvider(defaultVisibility: {
                  "Bench Press": true,
                  "Squat": true,
                  "Deadlift": true
                })),
        ChangeNotifierProvider(create: (context) {
          final provider = RecordPageProvider();
          provider
              .initialize(Provider.of<HiveProvider>(context, listen: false));
          return provider;
        }),
        ChangeNotifierProvider(create: (context) {
          final provider = HistoryPageProvider(
              Provider.of<HiveProvider>(context, listen: false));
          return provider;
        }),
      ],
      child: MyApp(settingsController: settingsController),
    ),
  );
}
