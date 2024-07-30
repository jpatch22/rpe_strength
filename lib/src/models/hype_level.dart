enum HypeLevel {
  High,
  Moderate,
  Low;

  int get ordinal {
    return HypeLevel.values.indexOf(this);
  }

  String get stringValue {
    return toString().split('.').last;
  }

  static HypeLevel fromOrdinal(int ordinal) {
    return HypeLevel.values[ordinal];
  }

  static HypeLevel fromString(String stringValue) {
    return HypeLevel.values.firstWhere((e) => e.toString().split('.').last == stringValue);
  }
}
