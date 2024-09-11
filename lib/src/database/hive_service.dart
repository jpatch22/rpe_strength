import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:rpe_strength/src/Utils/Util.dart';
import 'package:rpe_strength/src/database/models/workout_data_item.dart';
import 'package:rpe_strength/src/models/adv_row_data.dart';
import 'package:rpe_strength/src/models/hype_level.dart';
import 'package:rpe_strength/src/models/row_data.dart';

class HiveService {
  static const String workoutItemBoxName = 'workoutDataBox';
  static const String exerciseNameBoxName = 'exerciseNameBox';
  static const String removedDefaultExerciseNameBoxName = 'removedDefaultExerciseNameBox';
  static const List<String> defaultExerciseNames = ['Squat', 'Bench Press', 'Deadlift'];

  Box<WorkoutDataItem>? _workoutItemBox;
  Box<String>? _exerciseNameBox;
  Box<String>? _removedDefaultExerciseNameBox;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

HiveService() {
    _auth.authStateChanges().listen(_authStateChanges);
    initializeBoxes();
  }

  void _authStateChanges(User? user) {
    if (user != null) {
      totalSyncWithFirebase();
    } 
  }

  Future<void> initializeBoxes() async {
    _workoutItemBox = await Hive.openBox<WorkoutDataItem>(workoutItemBoxName);
    _exerciseNameBox = await Hive.openBox<String>(exerciseNameBoxName);
    _removedDefaultExerciseNameBox = await Hive.openBox<String>(removedDefaultExerciseNameBoxName);
  }

  Future<void> totalSyncWithFirebase() async {
  }

  Future<void> syncWorkoutItemsFirebase() async {
    if (_auth.currentUser == null) return;
  }

  Future<void> syncExerciseNamesToFirebase() async {
    if (_auth.currentUser == null) return;
    
    final userDocRef = _firestore.collection('users').doc(_auth.currentUser!.uid);
    final exerciseCollectionRef = userDocRef.collection('exercises');
    
    // Retrieve Firestore exercises
    final firestoreSnapshot = await exerciseCollectionRef.get();
    final Map<String, String> firestoreNames = {
      for (var doc in firestoreSnapshot.docs) doc.id: doc.data()['name'] as String
    };

    // Retrieve local exercises
    final List<String> localNames = _exerciseNameBox!.values.toList();

    // Compare and update Firestore with any new local exercises
    for (var localName in localNames) {
      if (!firestoreNames.containsValue(localName)) {
        // Add new exercise name to Firestore if it doesn't exist
        await exerciseCollectionRef.add({'name': localName});
      }
    }

    // Detect and delete Firestore entries that are no longer present locally
    firestoreNames.forEach((docId, name) {
      if (!localNames.contains(name)) {
        // Delete the document from Firestore if it no longer exists locally
        exerciseCollectionRef.doc(docId).delete();
      }
    });
    
    print('Sync completed.');
  }


  void clearLocalData() {
    _workoutItemBox?.clear();
    _exerciseNameBox?.clear();
    _removedDefaultExerciseNameBox?.clear();
  }

  Future<void> saveWorkoutItemList(List<WorkoutDataItem> items) async {
    try {
      if (_workoutItemBox == null) return;
      for (WorkoutDataItem item in items) {
        await _workoutItemBox!.add(item);
        print('Saved WorkoutDataItem: $item');
      }
      print('All items saved. Current box contents: ${_workoutItemBox!.values.toList()}');
    } catch (e) {
      print('Error saving workout items: $e');
    }
  }

  Future<void> saveBaseRowItemList(List<RowData> rowData, String exercise) async {
    DateTime now = DateTime.now();
    DateTime nowSave = DateTime(now.year, now.month, now.day, now.hour, now.minute);
    List<WorkoutDataItem> converted = [];
    try {
      for (var data in rowData) {
        if (data.numReps == "" || data.weight == "" || exercise == "") {
          continue;
        }
        DateTime? attemptParse = Util.parseTime(data.timestamp ?? "");
        var item = WorkoutDataItem(
          weight: double.tryParse(data.weight) ?? 0,
          numReps: int.tryParse(data.numReps) ?? 0,
          RPE: data.RPE,
          numSets: 1,
          hype: HypeLevel.Moderate.ordinal,
          notes: "",
          timestamp: attemptParse ?? nowSave,
          exercise: exercise,
        );
        converted.add(item);
        print('Converted RowData to WorkoutDataItem: $item');
      }
      if (_workoutItemBox == null) return;
      for (var item in converted) {
        await _workoutItemBox!.add(item);
        print('Saved BaseRow WorkoutDataItem: $item');
      }
      print('All base row items saved. Current box contents: ${_workoutItemBox!.values.toList()}');
    } catch (e) {
      print('Error saving base row items: $e');
    }
  }

  Future<void> saveAdvancedRowItemList(
    List<AdvancedRowData> rowData, 
    String exercise,
    {DateTime? timestamp}
  ) async {
    DateTime saveTime;
    if (timestamp == null) {
      DateTime now = DateTime.now();
      saveTime = DateTime(now.year, now.month, now.day, now.hour, now.minute);
    } else {
      saveTime = DateTime(timestamp.year, timestamp.month, timestamp.day, timestamp.hour, timestamp.minute);
    }
    List<WorkoutDataItem> converted = [];
    try {
      for (var data in rowData) {
        if (data.numReps == "" || data.weight == "" || exercise == "") {
          continue;
        }
        DateTime? attemptParse = Util.parseTime(data.timestamp ?? "");
        var item = WorkoutDataItem(
          weight: double.tryParse(data.weight) ?? 0,
          numReps: int.tryParse(data.numReps) ?? 0,
          RPE: data.RPE,
          numSets: int.tryParse(data.numSets) ?? 0,
          hype: HypeLevel.fromString(data.hype).ordinal,
          notes: data.notes,
          timestamp: attemptParse ?? saveTime,
          exercise: exercise,
        );
        converted.add(item);
        print('Converted AdvancedRowData to WorkoutDataItem: $item');
      }
      if (_workoutItemBox == null) return;
      for (var item in converted) {
        await _workoutItemBox!.add(item);
        print('Saved AdvancedRow WorkoutDataItem: $item');
      }
      print('All advanced row items saved. Current box contents: ${_workoutItemBox!.values.toList()}');
    } catch (e) {
      print('Error saving advanced row items: $e');
    }
  }

  Future<List<WorkoutDataItem>> getWorkoutDataItems() async {
    try {
      if (_workoutItemBox == null) return [];
      return _workoutItemBox!.values.toList();
    } catch (e) {
      print("Error fetching workout items: $e");
      return [];
    }
  }

  Future<void> deleteWorkoutDataItem(WorkoutDataItem item) async {
    try {
      if (_workoutItemBox == null) return;
      final key = _workoutItemBox!.keys.firstWhere(
        (k) => _workoutItemBox!.get(k) == item,
        orElse: () => null,
      );
      if (key != null) {
        await _workoutItemBox!.delete(key);
        print('Deleted WorkoutDataItem: $item');
      } else {
        print('WorkoutDataItem not found: $item');
      }
    } catch (e) {
      print('Error deleting workout data item: $e');
    }
  }

  Future<void> initializeExerciseNames() async {
    try {
      if (_exerciseNameBox == null || _removedDefaultExerciseNameBox == null) return;
      for (String name in defaultExerciseNames) {
        if (!_exerciseNameBox!.values.contains(name) && !_removedDefaultExerciseNameBox!.values.contains(name)) {
          await _exerciseNameBox!.add(name);
          print('Added default exercise name: $name');
        }
      }
      print('Exercise names initialized. Current box contents: ${_exerciseNameBox!.values.toList()}');
      syncExerciseNamesToFirebase();
    } catch (e) {
      print('Error initializing exercise names: $e');
    }
  }

  Future<List<String>> getExerciseNames() async {
    try {
      if (_exerciseNameBox == null) return [];
      return _exerciseNameBox!.values.toList();
    } catch (e) {
      print('Error fetching exercise names: $e');
      return [];
    }
  }

  Future<void> addExerciseName(String name) async {
    try {
      if (_exerciseNameBox == null) return;
      if (!_exerciseNameBox!.values.contains(name)) {
        await _exerciseNameBox!.add(name);
        print('Added exercise name: $name');
      } else {
        print('Exercise name already exists: $name');
      }
      syncExerciseNamesToFirebase();
    } catch (e) {
      print('Error adding exercise name: $e');
    }
  }

  Future<void> deleteExerciseName(String name) async {
    try {
      if (_exerciseNameBox == null) return;
      final key = _exerciseNameBox!.keys.firstWhere((k) => _exerciseNameBox!.get(k) == name, orElse: () => null);
      if (key != null) {
        await _exerciseNameBox!.delete(key);
        print('Deleted exercise name: $name');
        await _addRemovedDefaultExerciseName(name);
      } else {
        print('Exercise name not found: $name');
      }
      syncExerciseNamesToFirebase();
    } catch (e) {
      print('Error deleting exercise name: $e');
    }
  }

  Future<void> _addRemovedDefaultExerciseName(String name) async {
    try {
      if (_removedDefaultExerciseNameBox == null) return;
      if (!_removedDefaultExerciseNameBox!.values.contains(name)) {
        await _removedDefaultExerciseNameBox!.add(name);
        print('Tracked removed default exercise name: $name');
      }
    } catch (e) {
      print('Error tracking removed default exercise name: $e');
    }
  }
}
