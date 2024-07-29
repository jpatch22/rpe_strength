import 'package:sembast/sembast.dart';
import 'package:path/path.dart';
import 'dart:io' show Platform;

import 'database_helper_io.dart' if (dart.library.html) 'database_helper_web.dart';

class DatabaseHelper {
  static final DatabaseHelper _singleton = DatabaseHelper._internal();
  factory DatabaseHelper() => _singleton;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    return await initDatabase();
  }

  Future<int> insertItem(Map<String, dynamic> item) async {
    final db = await database;
    final store = intMapStoreFactory.store('items');
    return await store.add(db, item);
  }

  Future<List<Map<String, dynamic>>> retrieveItems() async {
    final db = await database;
    final store = intMapStoreFactory.store('items');
    final snapshots = await store.find(db);
    return snapshots.map((snapshot) => snapshot.value).toList();
  }
}
