import 'package:flutter/material.dart';
import 'package:rpe_strength/src/screens/history_page.dart';
import 'package:rpe_strength/src/screens/predict_page.dart';
import 'package:rpe_strength/src/screens/progress_page.dart';
import 'package:rpe_strength/src/screens/home_page.dart';
import 'package:rpe_strength/src/screens/record_page.dart';
import 'package:rpe_strength/src/settings/settings_controller.dart';
import 'package:rpe_strength/src/themes/themes.dart';

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    RecordPage(),
    HistoryPage(),
    ProgressPage(),
    PredictPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.settingsController,
      builder: (BuildContext context, Widget? child) {
        bool isDarkMode = widget.settingsController.themeMode == ThemeMode.dark;
        return MaterialApp(
          theme: customLightTheme,
          darkTheme: customDarkTheme,
          themeMode: widget.settingsController.themeMode,
          home: Scaffold(
            body: _widgetOptions.elementAt(_selectedIndex),
            bottomNavigationBar: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.fitness_center),
                  label: 'Record',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history),
                  label: 'History',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.show_chart),
                  label: 'Progress',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.assessment),
                  label: 'Predict',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: isDarkMode ? Colors.amber[800] : Colors.blue,
              unselectedItemColor: Colors.grey,
              onTap: _onItemTapped,
            ),
          ),
        );
      },
    );
  }
}
