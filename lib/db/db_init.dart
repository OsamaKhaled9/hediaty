import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Import sqflite_common_ffi
import 'database_helper.dart';

class DBInit {
  static Future<void> setupDB() async {
    // Initialize the database factory for ffi
    databaseFactory = databaseFactoryFfi;  // Set up the database factory for FFI

    // This function will run once when the app starts
    await DatabaseHelper.instance.database;
    print('Database Initialized!');
  }
}
