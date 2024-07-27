import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'app_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_data (
        id TEXT PRIMARY KEY,
        json_data TEXT
      )
    ''');
  }

  Future<void> insertUserData(String id, String jsonData) async {
    final db = await database;
    await db.insert(
      'user_data',
      {'id': id, 'json_data': jsonData},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getUserData(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_data',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return maps.first['json_data'] as String?;
    }
    return null;
  }

  Future<void> deleteUserData(String id) async {
    final db = await database;
    await db.delete(
      'user_data',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getAllUserData() async {
    final db = await database;
    return await db.query('user_data');
  }
}
