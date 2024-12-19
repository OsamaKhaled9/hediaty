//import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:hediaty/core/models/user.dart';
import 'package:hediaty/core/models/friend.dart';
import 'package:hediaty/core/models/event.dart';
import 'package:hediaty/core/models/gift.dart';

class DatabaseService {
  static Database? _database;

  // Singleton pattern for database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'users.db');
      print("Database path: $path");

      return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          // Create Users Table
          await db.execute('''
            CREATE TABLE users (
              id TEXT PRIMARY KEY,
              fullName TEXT,
              email TEXT,
              phoneNumber TEXT,
              profilePictureUrl TEXT,
              passwordHash TEXT
            )
          ''');

          // Create Friends Table
          await db.execute('''
            CREATE TABLE friends (
              id TEXT PRIMARY KEY,
              userId TEXT,
              friendId TEXT,
              friendName TEXT,
              friendAvatar TEXT,
              upcomingEventsCount INTEGER
            )
          ''');

          // Create Gifts Table
          await db.execute('''
            CREATE TABLE gifts (
              id TEXT PRIMARY KEY,
              eventId TEXT,
              name TEXT,
              description TEXT,
              category TEXT,
              price REAL,
              imagePath TEXT,
              status TEXT,
              pledgedBy TEXT
            )
          ''');

          // Create Events Table
          await db.execute('''
            CREATE TABLE events (
              id TEXT PRIMARY KEY,
              date TEXT,
              description TEXT,
              userId TEXT,
              location TEXT,
              name TEXT
            )
          ''');
        },
      );
    } catch (e) {
      print("Error initializing database: $e");
      rethrow;
    }
  }

  // Insert user into SQLite database
Future<void> insertUser(user user) async {
  final db = await database;
  try {
    // Check if the user already exists
    final existingUser = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [user.id],
    );

    if (existingUser.isNotEmpty) {
      print("User already exists in the database.");
      return;
    }

    // Insert the user if it does not exist
    await db.insert('users', user.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    print("User inserted successfully.");
  } catch (e) {
    print("Error inserting user: $e");
  }
}

  // Insert a friend into SQLite database
  Future<void> insertFriend(Friend friend) async {
    try {
      final db = await database;
      await db.insert('friends', friend.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
      print("Friend inserted");
    } catch (e) {
      print("Error inserting friend: $e");
    }
  }

  // Fetch user by id
  Future<user?> getUser(String id) async {
    final db = await database;
    var res = await db.query('users', where: "id = ?", whereArgs: [id]);
    if (res.isNotEmpty) {
      return user.fromJson(res.first);
    } else {
      return null;
    }
  }

  // Fetch friends from database
  Future<List<Friend>> getFriends(String userId) async {
    final db = await database;
    var res = await db.query('friends', where: "userId = ?", whereArgs: [userId]);
    return res.isNotEmpty
        ? res.map((e) => Friend.fromJson(e)).toList()
        : [];
  }
  Future<Event?> getLocalEventDetails(String eventId) async {
  final db = await database;
  final result = await db.query(
    'events',
    where: 'id = ?',
    whereArgs: [eventId],
  );

  if (result.isNotEmpty) {
    return Event.fromMap(result.first, eventId);
  }

  return null;
}
  // Insert an event into the database
  Future<void> insertEvent(Event event) async {
    try {
      final db = await database;
      await db.insert(
        'events',
        event.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print("Event inserted successfully: ${event.id}");
    } catch (e) {
      print("Error inserting event: $e");
    }
  }

  // Delete an event from the database by its ID
  Future<void> deleteEvent(String eventId) async {
    try {
      final db = await database;
      final count = await db.delete(
        'events',
        where: 'id = ?',
        whereArgs: [eventId],
      );
      if (count > 0) {
        print("Event deleted successfully: $eventId");
      } else {
        print("No event found with ID: $eventId");
      }
    } catch (e) {
      print("Error deleting event: $e");
    }
  }

  // Optional: Get all events for debugging or testing
  Future<List<Event>> getAllEvents() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> result = await db.query('events');
      return result.map((e) => Event.fromMap(e, e['id'])).toList();
    } catch (e) {
      print("Error fetching all events: $e");
      return [];
    }
  }
  Future<List<Gift>> getLocalEventGifts(String eventId) async {
  final db = await database;
  final result = await db.query(
    'gifts',
    where: 'eventId = ?',
    whereArgs: [eventId],
  );

  return result.map((gift) => Gift.fromMap(gift)).toList();
}
  // 1. Insert Gift
Future<void> insertGift(Gift gift) async {
  final db = await database;
  try {
    print("Inserting gift: ${gift.toJson()}");
    await db.insert(
      'gifts',
      gift.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print("Gift inserted successfully: ${gift.id}");
  } catch (e) {
    print("Error inserting gift: $e");
    throw Exception("Error inserting gift: $e");
  }
}

  // 2. Fetch Gifts by Event ID
Future<List<Gift>> getGiftsByEventId(String eventId) async {
  final db = await database;
  try {
    print("Fetching gifts for eventId: $eventId");
    final List<Map<String, dynamic>> maps = await db.query(
      'gifts',
      where: 'eventId = ?',
      whereArgs: [eventId],
    );
    print("Gifts fetched from local database: $maps");
    return maps.map((map) => Gift.fromMap(map)).toList();
  } catch (e) {
    print("Error fetching gifts: $e");
    return [];
  }
  
}
  /// Fetch events from the local database by userId.
Future<List<Event>> getEventsByUserId(String userId) async {
  final db = await database;

  try {
    List<Map<String, dynamic>> results = await db.query(
      'events',
      where: 'ownerId = ?',
      whereArgs: [userId],
    );

    return results.map((event) {
      final eventId = event['id'] as String; // Ensure `id` field exists in the map
      return Event.fromMap(event, eventId); // Pass the map and the event ID
    }).toList();
  } catch (e) {
    print("Error fetching events from local database for userId $userId: $e");
    return [];
  }
}



  // 3. Update Gift Status
  Future<void> updateGiftStatus(String giftId, String status, String? pledgedBy) async {
  final db = await database;
  await db.update(
    'gifts',
    {'status': status, 'pledgedBy': pledgedBy},
    where: 'id = ?',
    whereArgs: [giftId],
  );
}


  // 4. Delete Gift
  Future<void> deleteGift(String giftId) async {
    final db = await database;
    await db.delete(
      'gifts',
      where: 'id = ?',
      whereArgs: [giftId],
    );
  }

  // 5. Get All Gifts (for debugging or general use)
  Future<List<Gift>> getAllGifts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('gifts');
    return List.generate(maps.length, (i) {
      return Gift.fromMap(maps[i]);
    });
  }
    // Fetch gift details by ID
  Future<Gift?> getGiftById(String giftId) async {
    final db = await database;
    try {
      final List<Map<String, dynamic>> result = await db.query(
        'gifts',
        where: 'id = ?',
        whereArgs: [giftId],
      );

      if (result.isNotEmpty) {
        return Gift.fromMap(result.first);
      } else {
        print("No gift found with ID $giftId");
        return null;
      }
    } catch (e) {
      print("Error querying gift by ID: $e");
      return null;
    }
  }
  Stream<List<Gift>> getGiftsByEventIdStream(String eventId) async* {
  final db = await database;
  // Query the database and convert the result to a stream
  final List<Map<String, dynamic>> queryResult =
      await db.query('gifts', where: 'eventId = ?', whereArgs: [eventId]);
  yield queryResult.map((item) => Gift.fromMap(item)).toList();
}

Future<void> updateGift(Gift gift) async {
  final db = await database;

  await db.update(
    'gifts',
    gift.toJson(),
    where: 'id = ?',
    whereArgs: [gift.id],
  );
}


}
