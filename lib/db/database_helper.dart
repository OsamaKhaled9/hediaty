import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = 'Hedieaty.db';
  static const _databaseVersion = 1;
  
  static const userTable = 'users';
  static const friendTable = 'friends';
  static const eventTable = 'events';
  static const giftTable = 'gifts';

  static const columnId = '_id';
  static const columnName = 'name';
  static const columnEmail = 'email';
  static const columnFriendId = 'friendId';
  static const columnEventId = 'eventId';
  static const columnGiftName = 'giftName';
  static const columnGiftStatus = 'status';
  static const columnEventName = 'eventName';
  static const columnEventDescription = 'description';
  static const columnEventLocation = 'location';

  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute(''' 
      CREATE TABLE $userTable (
        $columnId INTEGER PRIMARY KEY,
        $columnName TEXT NOT NULL,
        $columnEmail TEXT NOT NULL
      );
    ''');

    await db.execute(''' 
      CREATE TABLE $friendTable (
        $columnId INTEGER PRIMARY KEY,
        $columnFriendId INTEGER NOT NULL,
        $columnName TEXT NOT NULL
      );
    ''');

    await db.execute(''' 
      CREATE TABLE $eventTable (
        $columnId INTEGER PRIMARY KEY,
        $columnEventName TEXT NOT NULL,
        $columnEventDescription TEXT,
        $columnEventLocation TEXT
      );
    ''');

    await db.execute(''' 
      CREATE TABLE $giftTable (
        $columnId INTEGER PRIMARY KEY,
        $columnGiftName TEXT NOT NULL,
        $columnGiftStatus TEXT NOT NULL,
        $columnEventId INTEGER NOT NULL,
        FOREIGN KEY ($columnEventId) REFERENCES $eventTable($columnId)
      );
    ''');
  }

  // Insert Event
  Future<int> insertEvent(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert(eventTable, row);
  }

  // Update Event
  Future<int> updateEvent(int eventId, Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.update(
      eventTable,
      row,
      where: '$columnId = ?',
      whereArgs: [eventId],
    );
  }

  // Delete Event
  Future<int> deleteEvent(int eventId) async {
    final db = await instance.database;
    return await db.delete(
      eventTable,
      where: '$columnId = ?',
      whereArgs: [eventId],
    );
  }

  // Query Event by ID
  Future<Map<String, dynamic>> queryEventById(int eventId) async {
    final db = await instance.database;
    var result = await db.query(
      eventTable,
      where: '$columnId = ?',
      whereArgs: [eventId],
    );
    return result.isNotEmpty ? result.first : {};
  }

  // Insert Gift
  Future<int> insertGift(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert(giftTable, row);
  }

  // Query Gift by ID
  Future<Map<String, dynamic>> queryGiftById(int giftId) async {
    final db = await instance.database;
    var result = await db.query(
      giftTable,
      where: '$columnId = ?',
      whereArgs: [giftId],
    );
    return result.isNotEmpty ? result.first : {};
  }

  // Update Gift
  Future<int> updateGift(int giftId, Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.update(
      giftTable,
      row,
      where: '$columnId = ?',
      whereArgs: [giftId],
    );
  }

  // Query Gifts by Event ID
  Future<List<Map<String, dynamic>>> queryGiftsByEvent(int eventId) async {
    final db = await instance.database;
    return await db.query(
      giftTable,
      where: '$columnEventId = ?',
      whereArgs: [eventId],
    );
  }

  // Query all users
  Future<List<Map<String, dynamic>>> queryAllUsers() async {
    final db = await instance.database;
    return await db.query(userTable);
  }

    // Insert User
  Future<int> insertUser(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert(userTable, row);
  }

  // Query all friends
  Future<List<Map<String, dynamic>>> queryAllFriends() async {
    final db = await instance.database;
    return await db.query(friendTable);
  }

  // Query all events
  Future<List<Map<String, dynamic>>> queryAllEvents() async {
    final db = await instance.database;
    return await db.query(eventTable);
  }

  // Query all gifts
  Future<List<Map<String, dynamic>>> queryAllGifts() async {
    final db = await instance.database;
    return await db.query(giftTable);
  }
}
