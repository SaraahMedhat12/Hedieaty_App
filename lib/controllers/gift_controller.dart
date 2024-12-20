import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../service/auth_service.dart';
import '../service/firebase.dart';
import '../models/gift.dart';

class GiftController {
  List<Gift> _gifts = [];
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Gift> get gifts => _gifts;

  // Load gifts for a specific event
  Stream<List<Gift>> loadGiftsForEvent(String eventId) {
    final currentUser = AuthService.getCurrentUser(); // Get the logged-in user
    if (currentUser == null) {
      print("Error: No user is logged in.");
      return Stream.value([]); // Return empty stream if user is not logged in
    }

    print("Fetching gifts for event ID: $eventId");

    // Correct path to match the gift addition path
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid) // User ID
        .collection('events')
        .doc(eventId) // Event ID
        .collection('gifts') // Gifts under the event
        .snapshots()
        .map((snapshot) {
      print("Gifts Snapshot: ${snapshot.docs.length} docs found");
      return snapshot.docs.map((doc) {
        print("Gift Data: ${doc.data()}");
        return Gift.fromMap(doc.id, doc.data());
      }).toList();
    });
  }



  Future<void> addGiftToEvent(String eventId, Gift gift) async {
    final currentUser = AuthService.getCurrentUser();
    if (currentUser == null) {
      print("Error: No user is logged in.");
      return;
    }

    try {
      // Check for duplicate names
      final existingGiftsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('events')
          .doc(eventId)
          .collection('gifts')
          .where('name', isEqualTo: gift.name)
          .get();

      if (existingGiftsSnapshot.docs.isNotEmpty) {
        throw Exception("A gift with this name already exists in the list.");
      }

      // Add the gift if no duplicates
      final giftsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('events')
          .doc(eventId)
          .collection('gifts');

      final newDoc = await giftsRef.add(gift.toMap());
      print("Gift added successfully under user ${currentUser.uid}, event $eventId with ID: ${newDoc.id}");
    } catch (e) {
      print("Error adding gift: $e");
      throw e;
    }
  }


  // Delete a gift
  Future<void> deleteGift(String eventId, String giftId) async {
    try {
      final currentUser = AuthService.getCurrentUser();
      if (currentUser != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('events')
            .doc(eventId)
            .collection('gifts')
            .doc(giftId)
            .delete();

        _gifts.removeWhere((gift) => gift.id == giftId);
        print('Gift deleted successfully.');
      }
    } catch (e) {
      print('Error deleting gift: $e');
    }
  }

  // Sort gifts
  List<Gift> getSortedGifts(String sortBy, bool ascending) {
    List<Gift> sortedGifts = List.from(_gifts);

    sortedGifts.sort((a, b) {
      int comparison = 0;
      if (sortBy == 'name') {
        comparison = a.name.compareTo(b.name);
      } else if (sortBy == 'category') {
        comparison = a.category.compareTo(b.category);
      } else if (sortBy == 'status') {
        comparison = a.isPledged.toString().compareTo(b.isPledged.toString());
      }
      return ascending ? comparison : -comparison;
    });

    return sortedGifts;
  }

// Load events for the current user
  Future<List<Map<String, dynamic>>> loadEventsForUser(String userId) async {
    List<Map<String, dynamic>> events = [];

    try {
      final currentUser = AuthService.getCurrentUser();

      if (currentUser != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid) // Use the current user's UID
            .collection('events')
            .orderBy('date', descending: false) // Sort events by date
            .get();

        events = snapshot.docs.map((doc) {
          return {
            'id': doc.id, // Event document ID
            'name': doc['name'] ?? 'Unnamed Event',
            'date': doc['date'] ?? 'No Date',
            'location': doc['location'] ?? 'No Location',
            'description': doc['description'] ?? '',
          };
        }).toList();

        print('Loaded ${events.length} events for user: ${currentUser.uid}');
      }
    } catch (e) {
      print('Error loading events: $e');
    }

    return events;
  }


  // Get gifts by event
  Future<List<Gift>> getGiftsByEvent(String eventId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .collection('gifts')
          .get();

      _gifts = snapshot.docs.map((doc) => Gift.fromMap(doc.id, doc.data())).toList();
      print('Loaded ${_gifts.length} gifts for event ID: $eventId');
      return _gifts;
    } catch (e) {
      print('Error loading gifts: $e');
      return [];
    }
  }

  // Update an existing gift
  Future<void> updateGiftInEvent(String eventId, Gift updatedGift) async {
    try {
      if (updatedGift.id.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('events')
            .doc(eventId)
            .collection('gifts')
            .doc(updatedGift.id)
            .update(updatedGift.toMap());
        print("Gift updated successfully: ${updatedGift.id}");
      } else {
        print("Error: Invalid gift ID.");
      }
    } catch (e) {
      print("Error updating gift: $e");
    }
  }




  Future<List<Map<String, dynamic>>> loadEventsFromFirebase(String userId) async {
    try {
      // Firebase query logic returning List<Map<String, dynamic>>
      final snapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }

  Stream<List<Gift>> loadGiftsForFriend(String friendId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(friendId)
        .collection('events')
        .snapshots()
        .asyncMap((eventSnapshot) async {
      // Map each event to its gifts
      List<Gift> allGifts = [];
      for (var eventDoc in eventSnapshot.docs) {
        final giftsSnapshot = await eventDoc.reference.collection('gifts').get();
        final gifts = giftsSnapshot.docs
            .map((doc) => Gift.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList();
        allGifts.addAll(gifts);
      }
      return allGifts; // Flattened list of all gifts
    });
  }


  // Future<void> pledgeGift(String friendId, String eventId, String giftId) async {
  //   try {
  //     final giftRef = FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(friendId)
  //         .collection('events')
  //         .doc(eventId)
  //         .collection('gifts')
  //         .doc(giftId);
  //
  //     await giftRef.update({
  //       'status': 'Pledged',
  //       'isPledged': true,
  //     });
  //
  //     print("Gift successfully pledged!");
  //   } catch (e) {
  //     print("Error pledging gift: $e");
  //   }
  // }

  Stream<List<Gift>> loadGiftsForEventForUser(String userId, String eventId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('events')
        .doc(eventId)
        .collection('gifts')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Gift.fromMap(doc.id, doc.data())).toList();
    });
  }

  /// Pledge a gift: Update gift status and copy to current user's pledged list
  Future<void> pledgeGift( {
    required String friendId,
    required String eventId,
    required String giftId,
    required String currentUserId,
    required Map<String, dynamic> giftInfo,
  }) async {
    final firestore = FirebaseFirestore.instance;

    try {
      // Update gift status in the friend's collection
      await firestore
          .collection('users')
          .doc(friendId)
          .collection('events')
          .doc(eventId)
          .collection('gifts')
          .doc(giftId)
          .update({
        'status': 'Pledged',
        'isPledged': true,
      });

      // Add the pledged gift to the current user's collection
      await firestore
          .collection('users')
          .doc(currentUserId)
          .collection('pledged_gifts')
          .doc(giftId)
          .set(giftInfo);

      print("Gift pledged and saved successfully.");
    } catch (e) {
      print("Error in pledgeGift: $e");
      rethrow;
    }
  }

  Future<void> updateGift(String userId, String eventId, String giftId, Map<String, dynamic> giftData) async {
    try {
      // Validate the userId
      if (userId.isEmpty || !userId.startsWith('H')) { // Assuming userId starts with an H
        throw Exception("Invalid userId: $userId");
      }

      // Validate eventId and giftId
      if (eventId.isEmpty || giftId.isEmpty) {
        throw Exception("Invalid eventId or giftId: eventId=$eventId, giftId=$giftId");
      }

      // Validate giftData (required fields only as per Firestore schema)
      if (!giftData.containsKey('name') || !giftData.containsKey('category') || !giftData.containsKey('price')) {
        throw Exception("Gift data is missing required fields: $giftData");
      }

      // Correct Firestore path
      final docRef = FirebaseFirestore.instance
          .collection('users') // Top-level users collection
          .doc(userId)         // User's ID
          .collection('events') // Events collection for the user
          .doc(eventId)         // Specific event ID
          .collection('gifts')  // Gifts collection within the event
          .doc(giftId);         // Specific gift ID

      // Debugging: Log the Firestore path and gift data
      print("Firestore Path: users/$userId/events/$eventId/gifts/$giftId");
      print("Gift Data to Update: $giftData");

      // Check if the document exists
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        // Proceed with the update
        await docRef.update(giftData);
        print("Gift updated successfully!");
      } else {
        throw Exception("Document not found at path: users/$userId/events/$eventId/gifts/$giftId");
      }
    } catch (e) {
      // Print and rethrow the error for debugging
      print("Error updating gift: $e");
      throw e;
    }
  }


}




