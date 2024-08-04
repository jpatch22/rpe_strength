import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MethodProvider with ChangeNotifier {
  static const String _selectedMethodKey = 'selected_method';
  String _selectedMethod = "Epley";

  String get selectedMethod => _selectedMethod;

  MethodProvider() {
    _loadSelectedMethod();
  }

  void setSelectedMethod(String method) {
    _selectedMethod = method;
    _saveSelectedMethod(method);
    notifyListeners();
  }

  Future<void> _saveSelectedMethod(String method) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedMethodKey, method);
  }

  Future<void> _loadSelectedMethod() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedMethod = prefs.getString(_selectedMethodKey) ?? "Epley";
    notifyListeners();
  }
}
