import 'dart:math';

class OneRepMaxCalculator {
  static double epley(double weight, int reps) {
    return weight * (1 + 0.0333 * reps);
  }

  static double brzycki(double weight, int reps) {
    return weight / (1.0278 - 0.0278 * reps);
  }

  static double lombardi(double weight, int reps) {
    return weight * pow(reps, 0.10);
  }

  static double oconner(double weight, int reps) {
    return weight * (1 + 0.025 * reps);
  }

  static double wathan(double weight, int reps) {
    return (100 * weight) / (48.8 + 53.8 * exp(-0.075 * reps));
  }

  static double rpeBased(double weight, int reps, double rpe) {
    return (weight * (10 - rpe)) / 0.0333;
  }
}
