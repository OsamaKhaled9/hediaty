import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:hediaty/core/models/user.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'users.db');
    return await openDatabase(path, onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE users(id TEXT PRIMARY KEY, fullName TEXT, email TEXT, phoneNumber TEXT, profilePictureUrl TEXT)",
      );
    }, version: 1);
  }

  Future<void> insertUser(user user) async {
    final db = await database;
    await db.insert('users', user.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<user?> getUser(String id) async {
    final db = await database;
    var res = await db.query('users', where: "id = ?", whereArgs: [id]);
    if (res.isNotEmpty) {
      return user.fromJson(res.first);
    } else {
      return null;
    }
  }
}
