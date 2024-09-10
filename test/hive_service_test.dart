import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:rpe_strength/src/database/models/workout_data_item.dart';
import 'package:rpe_strength/src/database/hive_service.dart';

// Generate mocks for the required classes
@GenerateMocks([Box, FirebaseAuth, DatabaseReference, DataSnapshot, User])
import 'hive_service_test.mocks.dart';

void main() {
  group('HiveService', () {
    late HiveService hiveService;
    late MockBox<WorkoutDataItem> mockWorkoutBox;
    late MockBox<String> mockExerciseBox;
    late MockBox<String> mockRemovedDefaultExerciseBox;
    late MockFirebaseAuth mockAuth;
    late MockDatabaseReference mockDatabaseRef;
    late MockUser mockUser;

    setUp(() {
      mockWorkoutBox = MockBox<WorkoutDataItem>();
      mockExerciseBox = MockBox<String>();
      mockRemovedDefaultExerciseBox = MockBox<String>();
      mockAuth = MockFirebaseAuth();
      mockDatabaseRef = MockDatabaseReference();
      mockUser = MockUser();

      when(mockAuth.authStateChanges()).thenAnswer((_) => Stream.fromIterable([mockUser]));

      hiveService = HiveService();
    });

    test('initializeBoxes opens Hive boxes', () async {
      when(Hive.openBox<WorkoutDataItem>(''))
          .thenAnswer((_) async => mockWorkoutBox);
      when(Hive.openBox<String>(''))
          .thenAnswer((_) async => mockExerciseBox);

      await hiveService.initializeBoxes();

      verify(Hive.openBox<WorkoutDataItem>('workoutDataBox')).called(1);
      verify(Hive.openBox<String>('exerciseNameBox')).called(1);
      verify(Hive.openBox<String>('removedDefaultExerciseNameBox')).called(1);
    });

    test('saveWorkoutItemList saves items to Hive and Firebase', () async {
      final items = [
        WorkoutDataItem(
          weight: 75.0,
          numReps: 10,
          RPE: '8',
          numSets: 3,
          hype: 3,
          notes: 'Felt strong',
          timestamp: DateTime.now(),
          exercise: 'Squat',
        ),
      ];

      when(mockWorkoutBox.add(any)).thenAnswer((_) async => 0);

      await hiveService.saveWorkoutItemList(items);

      verify(mockWorkoutBox.add(any)).called(items.length);
      // You can add more verifications for Firebase interactions if needed
    });

    // Add more tests for other methods...
  });
}
