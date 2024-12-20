import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';


class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // User Registration (sign-up)
  Future<User?> signUp(String email, String password, String localId) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      await _addUserToFirestore(userCredential.user, localId); // Add user to Firestore
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

  // Add user to Firestore with localId
  Future<void> _addUserToFirestore(User? user, String localId) async {
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'username': user.displayName ?? 'No Name',
        'localId': localId, // Save the local ID for cross-referencing
        'friends': [],
        'upcomingEvents': 0,
      });
      print("User added to Firestore with UID: ${user.uid} and localId: $localId");
    }
  }

  // Initialize Firestore User ID using localId
  Future<String?> getFirestoreUserIdFromLocalId(String localId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('localId', isEqualTo: localId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final firestoreUserId = snapshot.docs.first.id; // Firestore document ID
        print("Firestore User ID found: $firestoreUserId for localId: $localId");
        return firestoreUserId;
      } else {
        print("No Firestore user found for localId: $localId");
        return null;
      }
    } catch (e) {
      print("Error retrieving Firestore User ID: $e");
      return null;
    }
  }

  // Updated Get Events for Firebase User
  Future<List<Map<String, dynamic>>> getEventsForFirestoreUser(String localId) async {
    try {
      // Fetch Firestore User ID using localId
      String? firestoreUserId = await getFirestoreUserIdFromLocalId(localId);
      if (firestoreUserId == null) {
        throw Exception("No Firestore user found for localId: $localId");
      }

      final eventsSnapshot = await _firestore
          .collection('users')
          .doc(firestoreUserId)
          .collection('events')
          .orderBy('date')
          .get();

      print("Found ${eventsSnapshot.docs.length} events for Firestore User ID: $firestoreUserId");

      return eventsSnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
          'date': doc['date'],
          'location': doc['location'],
          'description': doc['description'],
          'status': _determineEventStatus(DateTime.parse(doc['date'])),
        };
      }).toList();
    } catch (e) {
      print("Error fetching events for Firestore user: $e");
      return [];
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
  // Add event for the logged-in user
  Future<void> addEventForLoggedInUser(
      String name, String date, String location, String description) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await addEventInFirebase(user.uid, {
        'name': name,
        'date': date,
        'location': location,
        'description': description,
      });
    } else {
      throw Exception("No logged-in user found.");
    }
  }
  // Add event for a friend
  Future<void> addEventForFriend(
      String friendId, String name, String date, String location, String description) async {
    await addEventInFirebase(friendId, {
      'name': name,
      'date': date,
      'location': location,
      'description': description,
    });
  }

  // Add an event in Firebase
  Future<void> addEventInFirebase(String userId, Map<String, dynamic> eventData) async {
    try {
      await _firestore.collection('users').doc(userId).collection('events').add(eventData);

      // Increment the upcoming events count if the event date is in the future
      DateTime eventDate = DateTime.parse(eventData['date']);
      if (eventDate.isAfter(DateTime.now())) {
        await _firestore.collection('users').doc(userId).update({
          'upcomingEvents': FieldValue.increment(1),
        });
      }

      print("Event added successfully to Firebase for user: $userId");
    } catch (e) {
      print("Error adding event to Firebase: $e");
      throw Exception("Failed to add event to Firebase.");
    }
  }

  // Get events from Firebase
  Future<List<Map<String, dynamic>>> getEventsFromFirebase(String userId) async {
    try {
      final eventsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .orderBy('date') // Sort by date
          .get();

      return eventsSnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'name': doc['name'],
          'date': doc['date'],
          'location': doc['location'],
          'description': doc['description'],
          'status': _determineEventStatus(DateTime.parse(doc['date'])),
        };
      }).toList();
    } catch (e) {
      print("Error fetching events from Firebase for user $userId: $e");
      return [];
    }
  }

  // Update an event in Firebase
  Future<void> editEventInFirebase(
      String userId, String eventId, Map<String, dynamic> updatedData) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .doc(eventId)
          .update(updatedData);

      print("Event updated successfully in Firebase for user: $userId");
    } catch (e) {
      print("Error updating event in Firebase: $e");
      throw Exception("Failed to update event in Firebase.");
    }
  }

  // Delete an event from Firebase
  Future<void> deleteEventFromFirebase(String userId, String eventId, String eventDate) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .doc(eventId)
          .delete();

      // Decrement the upcoming events count if the date is in the future
      DateTime eventDateTime = DateTime.parse(eventDate);
      if (eventDateTime.isAfter(DateTime.now())) {
        await _firestore.collection('users').doc(userId).update({
          'upcomingEvents': FieldValue.increment(-1),
        });
      }

      print("Event deleted successfully from Firebase for user: $userId");
    } catch (e) {
      print("Error deleting event from Firebase: $e");
      throw Exception("Failed to delete event from Firebase.");
    }
  }

  // Helper to determine event status
  String _determineEventStatus(DateTime eventDate) {
    final now = DateTime.now();
    if (eventDate.isBefore(now)) return 'Past';
    if (eventDate.isAfter(now)) return 'Upcoming';
    return 'Current';
  }

  // Check if a friend exists by username
  Future<bool> isFriendExists(String friendUsername) async {
    final friendQuery = await _firestore
        .collection('users')
        .where('username', isEqualTo: friendUsername)
        .get();

    // Check if any documents exist for the provided username
    if (friendQuery.docs.isNotEmpty) {
      print("Friend with username '$friendUsername' exists.");
      return true;
    } else {
      print("Friend with username '$friendUsername' not found.");
      return false;
    }
  }

  Future<void> addOrUpdateGift(
      String userId, String eventId, String giftId, Map<String, dynamic> giftData) async {
    try {
      final giftDocRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .doc(eventId)
          .collection('gifts')
          .doc(giftId);

      // Check if the gift already exists
      final giftSnapshot = await giftDocRef.get();
      if (giftSnapshot.exists) {
        // Update the existing gift
        await giftDocRef.update(giftData);
        print("Gift updated successfully for user: $userId, event: $eventId, gift: $giftId");
      } else {
        // Add the gift if it doesn't exist
        await giftDocRef.set(giftData);
        print("Gift added successfully for user: $userId, event: $eventId, gift: $giftId");
      }
    } catch (e) {
      print("Error adding or updating gift: $e");
      throw Exception("Failed to add or update gift in Firebase.");
    }
  }
  Future<void> editGift({
    required String eventId,
    required String giftId,
    required Map<String, dynamic> updatedGiftData,
  }) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      // Validate the authenticated user
      if (currentUser == null) {
        throw Exception("No authenticated user found.");
      }

      final firestore = FirebaseFirestore.instance;

      // Firestore reference to the gift document
      final giftDocRef = firestore
          .collection('users')
          .doc(currentUser.uid) // User ID
          .collection('events')
          .doc(eventId) // Event ID
          .collection('gifts')
          .doc(giftId); // Gift ID

      // Debugging: Log the Firestore path and the update data
      print("Editing Gift at Path: users/${currentUser.uid}/events/$eventId/gifts/$giftId");
      print("Updated Gift Data: $updatedGiftData");

      // Check if the document exists
      final giftSnapshot = await giftDocRef.get();
      if (!giftSnapshot.exists) {
        throw Exception("Gift document not found at path: users/${currentUser.uid}/events/$eventId/gifts/$giftId");
      }

      // Update the gift document
      await giftDocRef.update(updatedGiftData);
      print("Gift updated successfully: $giftId");
    } catch (e) {
      // Log and rethrow the error for higher-level handling
      print("Error editing gift: $e");
      rethrow;
    }
  }


}
