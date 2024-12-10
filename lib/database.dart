import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';


class DatabaseHelper {
  // Singleton pattern to ensure only one database instance
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  // Getter for database instance
  Future<Database> get database async {
    // If the database is already opened, return the existing instance
    if (_database != null) return _database!;

    // Otherwise, open the database
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String dbPath = await getDatabasesPath();
    String path = join(await dbPath, 'hedieaty.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  void _onCreate(Database db, int version) async {
    // Enable foreign key support
    await db.execute('PRAGMA foreign_keys = ON;');
    // Create `Users` table
    await db.execute('''
      CREATE TABLE Users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
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
        category TEXT,
        status TEXT,
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
        friend_phone_number TEXT,
        friend_name TEXT,
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
        print('Email already exists.');
        return -1; // Returning a failure status
      }

      return await db.insert('Users', user);
    } catch (e) {
      print('Database error: $e');
      throw Exception('Failed to insert user: $e');
    }
  }

  // Future<int?> getUserId() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getInt('userId') ?? -1;  // Return -1 if not found
  // }

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


  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    try {
      return await db.query('Users');
    } catch (e) {
      print('Database error while fetching users: $e');
      return [];
    }
  }

  // Get a user by their email from the 'Users' table
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database; // Using the existing database instance
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
    return await db.insert(
        'Friends', {'user_id': userId, 'friend_id': friendId});
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

  Future<List<Map<String, dynamic>>> getAllGiftsForEvent(int eventId) async {
    final db = await DatabaseHelper().database;

    try {
      final result = await db.query(
        'gifts', // The table where gifts are stored
        where: 'event_id = ?',
        whereArgs: [eventId],
      );

      return result; // List<Map<String, dynamic>> containing the gifts
    } catch (e) {
      print("Error fetching gifts for event $eventId: $e");
      return []; // Return an empty list if there's an error
    }
  }


// Add an event for a specific user
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

// Get all events for a specific user
  Future<List<Map<String, dynamic>>> getAllEventsForUser(int userId) async {
    final db = await database; // Using the singleton database instance
    try {
      final result = await db.query(
        'Events',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      return result;
    } catch (e) {
      print("Error fetching events for user: $e");
      return [];
    }
  }


// Update an event for a specific user
  Future<int> updateEventForUser(int userId, Map<String, dynamic> event) async {
    final db = await DatabaseHelper().database;
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

// Delete an event for a specific user
  Future<int> deleteEventForUser(int userId, int eventId) async {
    final db = await DatabaseHelper().database;
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

// Add a gift to a specific event
  Future<int> insertGiftForEvent(int eventId, Map<String, dynamic> gift) async {
    final db = await DatabaseHelper().database;
    try {
      gift['event_id'] = eventId;
      return await db.insert('Gifts', gift);
    } catch (e) {
      print('Database error while inserting gift for event: $e');
      return 0;
    }
  }

// Future<List<Map<String, dynamic>>> getAllGiftsForEvent(int eventId) async {
//   final db = await DatabaseHelper().database;
//
//   try {
//     final result = await db.query(
//       'gifts', // The table where gifts are stored
//       where: 'event_id = ?',
//       whereArgs: [eventId],
//     );
//
//     return result; // List<Map<String, dynamic>> containing the gifts
//   } catch (e) {
//     print("Error fetching gifts for event $eventId: $e");
//     return []; // Return an empty list if there's an error
//   }
// }


// Update a gift for a specific event
  Future<int> updateGiftForEvent(int eventId, Map<String, dynamic> gift) async {
    final db = await DatabaseHelper().database;
    try {
      return await db.update(
        'Gifts',
        gift,
        where: 'id = ? AND event_id = ?',
        whereArgs: [gift['id'], eventId],
      );
    } catch (e) {
      print('Database error while updating gift for event: $e');
      return 0;
    }
  }

// Delete a gift for a specific event
  Future<int> deleteGiftForEvent(int eventId, int giftId) async {
    final db = await DatabaseHelper().database;
    try {
      return await db.delete(
        'Gifts',
        where: 'id = ? AND event_id = ?',
        whereArgs: [giftId, eventId],
      );
    } catch (e) {
      print('Database error while deleting gift for event: $e');
      return 0;
    }
  }

// Add a friend by phone number for a specific user (Manually)
  Future<int> addFriendByPhone(int userId, String friendPhoneNumber,
      String friendName) async {
    final db = await DatabaseHelper().database;
    try {
      // Insert manually by phone number and name
      return await db.insert('Friends', {
        'user_id': userId,
        'friend_phone_number': friendPhoneNumber,
        'friend_name': friendName,
      });
    } catch (e) {
      print('Database error while adding friend by phone: $e');
      return 0;
    }
  }

// Get all friends of a specific user
  Future<List<Map<String, dynamic>>> getAllFriendsForUser(int userId) async {
    final db = await DatabaseHelper().database;
    try {
      return await db.query(
          'Friends', where: 'user_id = ?', whereArgs: [userId]);
    } catch (e) {
      print('Database error while fetching friends for user: $e');
      return [];
    }
  }

// Delete a friend for a specific user
  Future<int> deleteFriendForUser(int userId, int friendId) async {
    final db = await DatabaseHelper().database;
    try {
      return await db.delete(
        'Friends',
        where: 'user_id = ? AND friend_id = ?',
        whereArgs: [userId, friendId],
      );
    } catch (e) {
      print('Database error while deleting friend for user: $e');
      return 0;
    }
  }

// import 'package:contacts_service/contacts_service.dart';
//
// // Add a friend from the contact list
// Future<void> addFriendFromContactList(int userId) async {
//   Iterable<Contact> contacts = await ContactsService.getContacts();
//
//   // Show the contacts and let the user pick one (You could create a dialog for this)
//   var selectedContact = contacts.first;  // Example: picking the first contact
//
//   String phoneNumber = selectedContact.phones?.first.value ?? '';
//   String friendName = selectedContact.displayName ?? '';
//
//   // Call addFriendByPhone with selected contact details
//   await addFriendByPhone(userId, phoneNumber, friendName);
// }

  // SharedPreferences to save and retrieve userId
  // Save the userId in SharedPreferences
  Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', userId);
  }

// Retrieve the userId from SharedPreferences
  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }
}

