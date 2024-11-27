import 'dart:math';

class OneRepMaxCalculator {
  // Adjust reps based on RPE
int adjustRepsForRPE(int reps, double rpe) {
  return reps + (10 - rpe).round();
}

// Adjusted Mayhew 1-RM
double mayhew1RM(double repWeight, int reps, double rpe) {
  int adjustedReps = adjustRepsForRPE(reps, rpe);
  return (100 * repWeight) / (52.2 + 41.9 * exp(-0.055 * adjustedReps));
}

// Adjusted Wathan 1-RM
double wathan1RM(double repWeight, int reps, double rpe) {
  int adjustedReps = adjustRepsForRPE(reps, rpe);
  return (100 * repWeight) / (48.8 + 53.8 * exp(-0.075 * adjustedReps));
}

// Helms RPE-Based 1-RM
double helms1RM(double repWeight, int reps, double rpe) {
  int rir = (10 - rpe).round();
  return repWeight / (1 - (rir * 0.03));
}

// Barbell Medicine RPE-Based 1-RM
double barbellMedicine1RM(double repWeight, int reps, double rpe) {
  int rir = (10 - rpe).round();
  return repWeight * (1 + (rir * 0.033));
}

// Predict weight for a given 1-RM, reps, and RPE using Mayhew
double mayhewPredictedWeight(double oneRM, int reps, double rpe) {
  int adjustedReps = adjustRepsForRPE(reps, rpe);
  return oneRM * (52.2 + 41.9 * exp(-0.055 * adjustedReps)) / 100;
}

// Predict weight for a given 1-RM, reps, and RPE using Wathan
double wathanPredictedWeight(double oneRM, int reps, double rpe) {
  int adjustedReps = adjustRepsForRPE(reps, rpe);
  return oneRM * (48.8 + 53.8 * exp(-0.075 * adjustedReps)) / 100;
}

// Predict weight for a given 1-RM, reps, and RPE using Helms
double helmsPredictedWeight(double oneRM, int reps, double rpe) {
  int rir = (10 - rpe).round();
  return oneRM * (1 - (rir * 0.03));
}

// Predict weight for a given 1-RM, reps, and RPE using Barbell Medicine
double barbellMedicinePredictedWeight(double oneRM, int reps, double rpe) {
  int rir = (10 - rpe).round();
  return oneRM / (1 + (rir * 0.033));
}
}
