import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdvancedModeProvider with ChangeNotifier {
  static const String _showAdvancedKey = 'show_advanced';
  bool _showAdvanced = false;

  bool get showAdvanced => _showAdvanced;

  AdvancedModeProvider() {
    _loadAdvancedMode();
  }

  void toggleAdvancedMode() {
    _showAdvanced = !_showAdvanced;
    _saveAdvancedMode(_showAdvanced);
    notifyListeners();
  }

  void setAdvancedMode(bool value) {
    _showAdvanced = value;
    _saveAdvancedMode(value);
    notifyListeners();
  }

  Future<void> _saveAdvancedMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showAdvancedKey, value);
  }

  Future<void> _loadAdvancedMode() async {
    final prefs = await SharedPreferences.getInstance();
    _showAdvanced = prefs.getBool(_showAdvancedKey) ?? false;
    notifyListeners();
  }
}
