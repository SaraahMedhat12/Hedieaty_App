// import 'dart:io'; // Import the dart:io package to use File
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';
//
// class DatabaseHelper {
//   static Database? _database;
//
//   // Singleton pattern: Ensures only one instance of DatabaseHelper
//   static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
//   DatabaseHelper._privateConstructor();
//
//   // Initialize and get the database
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }
//
//   // Database initialization
//   Future<Database> _initDatabase() async {
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, 'hedieaty.db');
//
//     // Check if the database exists
//     if (await _databaseExists(path)) {
//       print("Database already exists.");
//     } else {
//       print("Database does not exist, creating a new one.");
//     }
//
//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: _onCreate,
//     );
//   }
//
//   // Check if the database file exists
//   Future<bool> _databaseExists(String path) async {
//     final file = File(path);
//     return file.exists();
//   }
//
//   // Create tables
//   Future<void> _onCreate(Database db, int version) async {
//     await db.execute('''CREATE TABLE User (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         name TEXT NOT NULL,
//         email TEXT NOT NULL,
//         preferences TEXT
//       )''');
//
//     await db.execute('''CREATE TABLE Event (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         name TEXT NOT NULL,
//         date TEXT NOT NULL,
//         location TEXT,
//         description TEXT,
//         userId INTEGER,
//         FOREIGN KEY (userId) REFERENCES User (id)
//       )''');
//
//     await db.execute('''CREATE TABLE Gift (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         name TEXT NOT NULL,
//         description TEXT,
//         category TEXT,
//         price REAL,
//         status TEXT,
//         eventId INTEGER,
//         FOREIGN KEY (eventId) REFERENCES Event (id)
//       )''');
//
//     await db.execute('''CREATE TABLE Friend (
//         userId INTEGER,
//         friendId INTEGER,
//         PRIMARY KEY (userId, friendId),
//         FOREIGN KEY (userId) REFERENCES User (id),
//         FOREIGN KEY (friendId) REFERENCES User (id)
//       )''');
//   }
// }
