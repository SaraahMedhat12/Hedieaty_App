import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // User Registration (sign-up)
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await _addUserToFirestore(userCredential.user); // Add user to Firestore
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
          email: email, password: password);
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

  // Add user to Firestore
  Future<void> _addUserToFirestore(User? user) async {
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'username': user.displayName ?? 'No Name',
        'friends': [],
        'upcomingEvents': 0, // Initialize upcoming events to 0
      });
    }
  }

  // Add a friend by friend's username
  Future<void> addFriendByUsername(String friendUsername) async {
    User? user = _auth.currentUser;
    if (user != null) {
      final friendQuery = await _firestore
          .collection('users')
          .where('username', isEqualTo: friendUsername)
          .get();

      if (friendQuery.docs.isNotEmpty) {
        final friendDoc = friendQuery.docs.first;
        final friendId = friendDoc.id;

        // Add friend to the user's friend list
        await _firestore.collection('users').doc(user.uid).update({
          'friends': FieldValue.arrayUnion([friendId])
        });

        // Optionally add the user to the friend's friend list
        await _firestore.collection('users').doc(friendId).update({
          'friends': FieldValue.arrayUnion([user.uid])
        });

        print("Friend $friendUsername added successfully.");
      } else {
        print("Friend with username '$friendUsername' not found.");
        throw Exception("Friend with username '$friendUsername' not found.");
      }
    }
  }

  // Get all friends of the current user
  Future<List<Map<String, dynamic>>> getFriends() async {
    User? user = _auth.currentUser;
    List<Map<String, dynamic>> friends = [];
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      List<dynamic> friendIds = userDoc.data()?['friends'] ?? [];

      // List of static profile pictures to choose from
      final List<String> defaultPics = [
        'assets/bg2.jpeg',
        'assets/p3.jpeg',
        'assets/bg3.jpeg',
      ];
      final Random random = Random(); // Random instance for selecting images

      for (String friendId in friendIds) {
        final friendDoc = await _firestore.collection('users').doc(friendId).get();
        if (friendDoc.exists) {
          final friendData = friendDoc.data()!;
          friends.add({
            'uid': friendId,
            'username': friendData['username'] ?? 'Unknown',
            // Randomly choose a default profile picture if none is found
            'profilePic': friendData['profilePic'] ??
                defaultPics[random.nextInt(defaultPics.length)],
            'upcomingEvents': friendData['upcomingEvents'] ?? 0,
          });
        }
      }
    }
    return friends;
  }

  // Get events for a specific friend
  Future<List<Map<String, dynamic>>> getEventsForFriend(String friendId) async {
    try {
      final eventsSnapshot = await _firestore
          .collection('users')
          .doc(friendId)
          .collection('events')
          .get();

      return eventsSnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
          'date': doc['date'],
          'location': doc['location'],
          'description': doc['description'],
        };
      }).toList();
    } catch (e) {
      print("Error fetching friend's events: $e");
      return [];
    }
  }

  // Add event for the logged-in user
  Future<void> addEventForLoggedInUser(
      String name, String date, String location, String description) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // Add the event under the logged-in user's document
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('events')
            .add({
          'name': name,
          'date': date,
          'location': location,
          'description': description,
        });

        // Increment the upcoming events count if the event date is in the future
        DateTime eventDate = DateTime.parse(date);
        if (eventDate.isAfter(DateTime.now())) {
          await _firestore.collection('users').doc(user.uid).update({
            'upcomingEvents': FieldValue.increment(1),
          });
        }

        print("Event added successfully for the logged-in user.");
      } catch (e) {
        print("Error adding event for the logged-in user: $e");
        throw Exception("Failed to add event for the logged-in user.");
      }
    } else {
      throw Exception("No logged-in user found.");
    }
  }

  // Add event for a friend
  Future<void> addEventForFriend(
      String friendId, String name, String date, String location, String description) async {
    try {
      // Add the event under the friend's document
      await _firestore
          .collection('users')
          .doc(friendId)
          .collection('events')
          .add({
        'name': name,
        'date': date,
        'location': location,
        'description': description,
      });

      // Increment the friend's upcoming events count if the event date is in the future
      DateTime eventDate = DateTime.parse(date);
      if (eventDate.isAfter(DateTime.now())) {
        await _firestore.collection('users').doc(friendId).update({
          'upcomingEvents': FieldValue.increment(1),
        });
      }

      print("Event added successfully for the friend.");
    } catch (e) {
      print("Error adding event for the friend: $e");
      throw Exception("Failed to add event for the friend.");
    }
  }
}
