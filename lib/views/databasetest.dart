// import 'package:flutter/material.dart';
// import '../database.dart';
//
// class DatabaseTestPage extends StatefulWidget {
//   @override
//   _DatabaseTestPageState createState() => _DatabaseTestPageState();
// }
//
// class _DatabaseTestPageState extends State<DatabaseTestPage> {
//   @override
//   void initState() {
//     super.initState();
//     _checkDatabaseExistence();
//   }
//
//   // Method to check if the database exists
//   Future<void> _checkDatabaseExistence() async {
//     // Call the database getter to trigger the existence check
//     final db = await DatabaseHelper.instance.database;
//     // Any additional logic can be added here, based on whether the db exists or not.
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Database Test'),
//         backgroundColor: Colors.brown,
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: _checkDatabaseExistence,
//           child: Text('Check Database Existence'),
//         ),
//       ),
//     );
//   }
// }
