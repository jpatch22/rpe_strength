import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rpe_strength/src/Utils/Util.dart';
import 'package:rpe_strength/src/providers/advanced_mode_provider.dart';
import 'package:rpe_strength/src/providers/method_provider.dart';
import '../database/hive_provider.dart';
import 'settings_controller.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.controller});

  static const routeName = '/settings';

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme selection dropdown
            DropdownButton<ThemeMode>(
              value: controller.themeMode,
              onChanged: controller.updateThemeMode,
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('System Theme'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text('Light Theme'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text('Dark Theme'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Toggle for advanced recording mode
            Consumer<AdvancedModeProvider>(
              builder: (context, advancedModeProvider, child) {
                return Row(
                  children: [
                    Switch(
                      value: advancedModeProvider.showAdvanced,
                      onChanged: (value) {
                        advancedModeProvider.setAdvancedMode(value);
                      },
                    ),
                    const SizedBox(width: 8),
                    const Text('Advanced Recording Mode'),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            // Dropdown for method selection with a label
            Consumer<MethodProvider>(
              builder: (context, methodProvider, child) {
                return Row(
                  children: [
                    const Text('Calculation Method: '),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: methodProvider.selectedMethod,
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          methodProvider.setSelectedMethod(newValue);
                        }
                      },
                      items: Util.calculationMethods.map<DropdownMenuItem<String>>((String method) {
                        return DropdownMenuItem<String>(
                          value: method,
                          child: Text(method),
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            // Button for syncing cloud changes
            ElevatedButton(
              onPressed: () {
                // Assuming you have access to HiveProvider via Provider
                var hiveProvider = Provider.of<HiveProvider>(context, listen: false);
                hiveProvider.pullCloudChanges();
              },
              child: const Text('Sync Cloud Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
