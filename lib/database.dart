import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, 'hedieaty.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  void _onCreate(Database db, int version) async {
    await db.execute('PRAGMA foreign_keys = ON;');
    await db.execute('''
      CREATE TABLE Users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        preferences TEXT,
        upcomingEvents INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE Events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        date TEXT NOT NULL,
        location TEXT,
        category TEXT,
        status TEXT,
        description TEXT,
        user_id INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES Users (id) ON DELETE CASCADE ON UPDATE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE Gifts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        category TEXT,
        price REAL,
        status TEXT,
        event_id INTEGER NOT NULL,
        FOREIGN KEY (event_id) REFERENCES Events (id) ON DELETE CASCADE ON UPDATE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE Friends (
        user_id INTEGER NOT NULL,
        friend_id INTEGER NOT NULL,
        friend_phone_number TEXT,
        friend_name TEXT,
        PRIMARY KEY (user_id, friend_id),
        FOREIGN KEY (user_id) REFERENCES Users (id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY (friend_id) REFERENCES Users (id) ON DELETE CASCADE ON UPDATE CASCADE
      )
    ''');

    await db.execute('CREATE INDEX idx_users_email ON Users (email)');
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE Users ADD COLUMN upcomingEvents INTEGER DEFAULT 0');
    }
  }

  // CRUD Operations for Users
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    try {
      final existingUser = await db.query(
        'Users',
        where: 'email = ?',
        whereArgs: [user['email']],
      );

      if (existingUser.isNotEmpty) {
        print('Email already exists.');
        return -1;
      }

      return await db.insert('Users', user);
    } catch (e) {
      print('Database error: $e');
      throw Exception('Failed to insert user: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserById(int userId) async {
    final db = await database;
    try {
      final result = await db.query(
        'Users',
        where: 'id = ?',
        whereArgs: [userId],
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print('Error fetching user by ID: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    try {
      final result = await db.query(
        'Users',
        where: 'email = ?',
        whereArgs: [email],
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print('Error fetching user by email: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    try {
      return await db.query('Users');
    } catch (e) {
      print('Database error while fetching users: $e');
      return [];
    }
  }

  Future<int> updateUser(Map<String, dynamic> user) async {
    final db = await database;
    try {
      return await db.update(
        'Users',
        user,
        where: 'id = ?',
        whereArgs: [user['id']],
      );
    } catch (e) {
      print('Database error while updating user: $e');
      return 0;
    }
  }

  Future<int> deleteUser(int id) async {
    final db = await database;
    try {
      return await db.delete(
        'Users',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Database error while deleting user: $e');
      return 0;
    }
  }

  // CRUD Operations for Events
  Future<int> insertEvent(Map<String, dynamic> event) async {
    final db = await database;
    try {
      return await db.insert('Events', event);
    } catch (e) {
      print('Database error while inserting event: $e');
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> getAllEventsForUser(int userId) async {
    final db = await database;
    try {
      final result = await db.rawQuery(
        'SELECT DISTINCT * FROM Events WHERE user_id = ?',
        [userId],
      );
      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      print('Error fetching events for user: $e');
      return [];
    }
  }

  Future<int> updateEventForUser(int userId, Map<String, dynamic> event) async {
    final db = await database;
    try {
      return await db.update(
        'Events',
        event,
        where: 'id = ? AND user_id = ?',
        whereArgs: [event['id'], userId],
      );
    } catch (e) {
      print('Database error while updating event for user: $e');
      return 0;
    }
  }

  Future<int> deleteEventForUser(int userId, int eventId) async {
    final db = await database;
    try {
      return await db.delete(
        'Events',
        where: 'id = ? AND user_id = ?',
        whereArgs: [eventId, userId],
      );
    } catch (e) {
      print('Database error while deleting event for user: $e');
      return 0;
    }
  }

  // CRUD Operations for Gifts
  Future<int> insertGift(Map<String, dynamic> gift) async {
    final db = await database;
    try {
      return await db.insert('Gifts', gift);
    } catch (e) {
      print('Database error while inserting gift: $e');
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> getAllGiftsForEvent(int eventId) async {
    final db = await database;
    try {
      final result = await db.query(
        'Gifts',
        where: 'event_id = ?',
        whereArgs: [eventId],
      );
      return result;
    } catch (e) {
      print('Error fetching gifts for event $eventId: $e');
      return [];
    }
  }

  Future<int> updateGift(Map<String, dynamic> gift) async {
    final db = await database;
    try {
      return await db.update(
        'Gifts',
        gift,
        where: 'id = ?',
        whereArgs: [gift['id']],
      );
    } catch (e) {
      print('Database error while updating gift: $e');
      return 0;
    }
  }

  Future<int> deleteGiftForEvent(int eventId, int giftId) async {
    final db = await database;
    try {
      return await db.delete(
        'Gifts',
        where: 'id = ? AND event_id = ?',
        whereArgs: [giftId, eventId],
      );
    } catch (e) {
      print('Database error while deleting gift: $e');
      return 0;
    }
  }

  Future<void> incrementUpcomingEvents(int userId) async {
    final db = await database;
    await db.rawUpdate(
      "UPDATE Users SET upcomingEvents = upcomingEvents + 1 WHERE id = ?",
      [userId],
    );
  }




  Future<int> insertEventForUser(int userId, Map<String, dynamic> event) async {
    final db = await DatabaseHelper().database;
    try {
      // Include user_id in the event map
      event['user_id'] = userId;
      return await db.insert('Events', event);
    } catch (e) {
      print('Database error while inserting event for user: $e');
      return 0;
    }
  }

}
