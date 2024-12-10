import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'database.dart';

class FirebaseService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add user to the Realtime Database
  // Future<void> addUser(String name, String email, String preferences) async {
  //   User? user = _auth.currentUser;
  //   if (user != null) {
  //     DatabaseReference userRef = _database.ref('users').child(user.uid);
  //     await userRef.set({
  //       'name': name,
  //       'email': email,
  //       'preferences': preferences,
  //     });
  //   }
  // }

  // Add event to the Firebase Realtime Database
  Future<void> addEvent(String name, String date, String location, String description) async {
  User? user = _auth.currentUser;
  if (user != null) {
  DatabaseReference eventRef = _database.ref('events').push();
  await eventRef.set({
  'name': name,
  'date': date,
  'location': location,
  'description': description,
  'user_id': user.uid,
  });
  }
  }

  // Add gift to the Firebase Realtime Database
  Future<void> addGift(String name, String description, String category, double price, String eventId) async {
  DatabaseReference giftRef = _database.ref('gifts').push();
  await giftRef.set({
  'name': name,
  'description': description,
  'category': category,
  'price': price,
  'status': 'available',
  'event_id': eventId,
  });
  }

  // Update gift status (available, pledged, purchased)
  Future<void> updateGiftStatus(String giftId, String status) async {
  DatabaseReference giftRef = _database.ref('gifts').child(giftId);
  await giftRef.update({
  'status': status,
  });
  }

  // Add friend by friend ID
  Future<void> addFriend(String friendId) async {
  User? user = _auth.currentUser;
  if (user != null) {
  DatabaseReference friendsRef = _database.ref('friends').child(user.uid);
  await friendsRef.update({
  friendId: true,
  });
  }
  }

  // Real-time listener for gifts status
  void listenForGiftStatusUpdates(String giftId, Function(String) onStatusChanged) {
  DatabaseReference giftRef = _database.ref('gifts').child(giftId);
  giftRef.onValue.listen((event) {
  final giftStatus = event.snapshot.child('status').value as String;
  onStatusChanged(giftStatus);
  });
  }

  // User Registration (sign-up)
  Future<User?> signUp(String email, String password) async {
  try {
  UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
  email: email,
  password: password,
  );
  return userCredential.user;
  } catch (e) {
  print("Error during sign-up: $e");
  return null;
  }
  }

  // User login (sign-in)
  Future<User?> signIn(String email, String password) async {
  try {
  UserCredential userCredential = await _auth.signInWithEmailAndPassword(
  email: email,
  password: password,
  );
  return userCredential.user;
  } catch (e) {
  print("Error during sign-in: $e");
  return null;
  }
  }

  // User sign-out
  Future<void> signOut() async {
  await _auth.signOut();
  }
  }
