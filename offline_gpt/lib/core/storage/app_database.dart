import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final filePath = path.join(dbPath, 'offlinegpt.db');
    return openDatabase(
      filePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE messages (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            role TEXT NOT NULL,
            content TEXT NOT NULL,
            createdAt INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE models (
            modelId TEXT PRIMARY KEY,
            status TEXT NOT NULL,
            localPath TEXT,
            isActive INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  Future<List<Map<String, Object?>>> fetchMessages() async {
    final db = await database;
    return db.query('messages', orderBy: 'createdAt ASC');
  }

  Future<void> insertMessage(Map<String, Object?> values) async {
    final db = await database;
    await db.insert('messages', values);
  }

  Future<List<Map<String, Object?>>> fetchModels() async {
    final db = await database;
    return db.query('models');
  }

  Future<void> upsertModel(Map<String, Object?> values) async {
    final db = await database;
    await db.insert('models', values, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deactivateAllModels() async {
    final db = await database;
    await db.update('models', {'isActive': 0});
  }

  Future<void> setActiveModel(String modelId) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update('models', {'isActive': 0});
      await txn.update(
        'models',
        {'status': 'installed'},
        where: 'status = ?',
        whereArgs: ['active'],
      );
      await txn.update(
        'models',
        {'isActive': 1, 'status': 'active'},
        where: 'modelId = ?',
        whereArgs: [modelId],
      );
    });
  }
}
