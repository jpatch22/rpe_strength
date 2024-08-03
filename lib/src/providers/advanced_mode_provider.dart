import 'package:flutter/material.dart';

class AdvancedModeProvider with ChangeNotifier {
  bool _showAdvanced = false;

  bool get showAdvanced => _showAdvanced;

  void toggleAdvancedMode() {
    _showAdvanced = !_showAdvanced;
    notifyListeners();
  }

  void setAdvancedMode(bool value) {
    _showAdvanced = value;
    notifyListeners();
  }
}
