import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import '../views/signup.dart';
//import"package:project_hedieaty/service/notfications_service.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // NotificationService notificationService =NotificationService();
  // await notificationService.initNotification();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignupPage(), // Replace with your desired starting page
    );
  }
}
