import 'dart:io';  // For platform-specific imports
import 'package:path/path.dart';  // To help with file paths
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // For FFI (Desktop platforms)
// For mobile (Android/iOS)
import 'package:hediaty/core/models/user.dart';  // Assuming you have a user model
import 'package:flutter/foundation.dart'; // For Platform.isX on web and mobile

class DatabaseService {
  static Database? _database;

  // Platform-specific database initialization

Future<Database> get database async {
  if (_database != null) return _database!;

  // Check the platform and use sqflite or sqflite_common_ffi accordingly
  if (kIsWeb) {
    // Handle web case separately if necessary
    print("Web platform detected. SQLite is not supported.");
    // You could fall back to another local database solution, like IndexedDB for the web
  } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
    sqfliteFfiInit();  // Initialize sqflite FFI for desktop
    _database = await _initDatabaseFFI();
  } else {
    _database = await _initDatabase(); // For mobile platforms
  }

  return _database!;
}


  // FFI Database initialization for desktop platforms
  Future<Database> _initDatabaseFFI() async {
    String path = join(await getDatabasesPath(), 'users.db');
    return await databaseFactoryFfi.openDatabase(path, options: OpenDatabaseOptions());
  }

  // Mobile Database initialization (sqflite)
Future<Database> _initDatabase() async {
  String path = join(await getDatabasesPath(), 'users.db');
  print("Database path: $path"); // Log the database path
  return await openDatabase(path, version: 1, onCreate: (db, version) {
    return db.execute(
      "CREATE TABLE IF NOT EXISTS users(id TEXT PRIMARY KEY, fullName TEXT, email TEXT, phoneNumber TEXT, profilePictureUrl TEXT, passwordHash TEXT)"
    );
  });
}


  // Insert a user into SQLite database
Future<void> insertUser(user user) async {
  try {
    
    final db = await database;  // This should call _initDatabase() internally
    print("Database initialized: $db");  // Verify that the database is initialized
    await db.insert('users', user.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    print("User inserted");
  } catch (e) {
    print("Error inserting user: $e");
  }
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
