import 'package:flutter/material.dart';

class SeriesVisibilityProvider with ChangeNotifier {
  Map<String, bool> _seriesVisibility = {};

  SeriesVisibilityProvider({Map<String, bool>? defaultVisibility}) {
    // Initialize visibility map with defaults, or leave it empty
    if (defaultVisibility != null) {
      _seriesVisibility = defaultVisibility;
    }
  }

  Map<String, bool> get seriesVisibility => _seriesVisibility;

  void toggleVisibility(String seriesName) {
    if (_seriesVisibility.containsKey(seriesName)) {
      _seriesVisibility[seriesName] = !(_seriesVisibility[seriesName] ?? true);
      notifyListeners();
    }
  }

  bool isVisible(String seriesName) {
    return _seriesVisibility[seriesName] ?? false;
  }

  void setVisibility(String seriesName, bool isVisible) {
    _seriesVisibility[seriesName] = isVisible;
    notifyListeners();
  }

  void addSeries(String seriesName, {bool isVisible = false}) {
    if (!_seriesVisibility.containsKey(seriesName)) {
      _seriesVisibility[seriesName] = isVisible;
      notifyListeners();
    }
  }

  void removeSeries(String seriesName) {
    if (_seriesVisibility.containsKey(seriesName)) {
      _seriesVisibility.remove(seriesName);
      notifyListeners();
    }
  }
}
