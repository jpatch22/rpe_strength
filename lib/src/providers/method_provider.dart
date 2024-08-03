import 'package:flutter/material.dart';

class MethodProvider with ChangeNotifier {
  String _selectedMethod = "Epley";
  String get selectedMethod => _selectedMethod;

  void setSelectedMethod(String method) {
    _selectedMethod = method;
    notifyListeners();
  }
}