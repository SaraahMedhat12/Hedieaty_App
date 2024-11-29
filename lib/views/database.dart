import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  // Singleton pattern to ensure only one database instance
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
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  void _onCreate(Database db, int version) async {
    // Create `Users` table
    await db.execute('''
      CREATE TABLE Users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        preferences TEXT
      )
    ''');

    // Create `Events` table
    await db.execute('''
      CREATE TABLE Events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        date TEXT NOT NULL,
        location TEXT,
        description TEXT,
        user_id INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES Users (id) ON DELETE CASCADE ON UPDATE CASCADE
      )
    ''');

    // Create `Gifts` table
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

    // Create `Friends` table
    await db.execute('''
      CREATE TABLE Friends (
        user_id INTEGER NOT NULL,
        friend_id INTEGER NOT NULL,
        PRIMARY KEY (user_id, friend_id),
        FOREIGN KEY (user_id) REFERENCES Users (id) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY (friend_id) REFERENCES Users (id) ON DELETE CASCADE ON UPDATE CASCADE
      )
    ''');

    // Add index for the `email` column in `Users` for performance
    await db.execute('CREATE INDEX idx_users_email ON Users (email)');
  }

  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Example migration: Adding a new column to Users
      await db.execute('ALTER TABLE Users ADD COLUMN profile_picture TEXT');
    }
    // Add further migrations for newer versions as needed
  }

  // CRUD Operations for Users
  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    try {
      // Check if the email already exists
      final existingUser = await db.query(
        'Users',
        where: 'email = ?',
        whereArgs: [user['email']],
      );

      if (existingUser.isNotEmpty) {
        throw Exception('Email already exists.');
      }

      return await db.insert('Users', user);
    } catch (e) {
      print('Database error: $e');
      throw Exception('Failed to insert user: $e');
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
      print('Database error while fetching user by email: $e');
      return null;
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

  Future<List<Map<String, dynamic>>> getAllEvents() async {
    final db = await database;
    try {
      return await db.query('Events');
    } catch (e) {
      print('Database error while fetching events: $e');
      return [];
    }
  }

  Future<int> updateEvent(Map<String, dynamic> event) async {
    final db = await database;
    try {
      return await db.update(
        'Events',
        event,
        where: 'id = ?',
        whereArgs: [event['id']],
      );
    } catch (e) {
      print('Database error while updating event: $e');
      return 0;
    }
  }

  Future<int> deleteEvent(int id) async {
    final db = await database;
    try {
      return await db.delete(
        'Events',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Database error while deleting event: $e');
      return 0;
    }
  }

  // CRUD operations for `Gifts`
  Future<int> insertGift(Map<String, dynamic> gift) async {
    final db = await database;
    return await db.insert('Gifts', gift);
  }

  Future<List<Map<String, dynamic>>> getAllGifts() async {
    final db = await database;
    return await db.query('Gifts');
  }

  Future<int> updateGift(Map<String, dynamic> gift) async {
    final db = await database;
    return await db.update(
      'Gifts',
      gift,
      where: 'id = ?',
      whereArgs: [gift['id']],
    );
  }

  Future<int> deleteGift(int id) async {
    final db = await database;
    return await db.delete(
      'Gifts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD operations for `Friends`
  Future<int> addFriend(int userId, int friendId) async {
    final db = await database;
    return await db.insert('Friends', {'user_id': userId, 'friend_id': friendId});
  }

  Future<List<Map<String, dynamic>>> getAllFriends(int userId) async {
    final db = await database;
    return await db.query('Friends', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<int> deleteFriend(int userId, int friendId) async {
    final db = await database;
    return await db.delete(
      'Friends',
      where: 'user_id = ? AND friend_id = ?',
      whereArgs: [userId, friendId],
    );
  }
}
