import 'package:cloud_firestore/cloud_firestore.dart';
import '../auth_service.dart';
import '../firebase.dart';
import '../models/gift.dart';

class GiftController {
  List<Gift> _gifts = [];
  final FirebaseService _firebaseService = FirebaseService();
  List<Gift> get gifts => _gifts;

  // Load gifts for a specific event
  Stream<List<Gift>> LoadGiftsForEvent(String eventId) {
    final currentUser = AuthService.getCurrentUser();
    print("Fetching gifts for event ID: $eventId"); // Add this debug line


    if (currentUser != null) {
      // Query the gifts subcollection under the specific event
      return FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('events')
          .doc(eventId)
          .collection('gifts')
          .snapshots()
          .map((snapshot) {
        print("Gifts Snapshot: ${snapshot.docs.length} docs found"); // Add this debug line
        return snapshot.docs.map((doc) {
          print("Gift Data: ${doc.data()}"); // Print each gift data
          return Gift.fromMap(doc.id, doc.data());
        }).toList();
      });
    } else {
      print("Error: No user is logged in.");
      return Stream.value([]);
    }
  }



  // Add a new gift to an event
  Future<void> addGiftToEvent(String eventId, Gift gift) async {
    final currentUser = AuthService.getCurrentUser();
    if (currentUser != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('events')
          .doc(eventId)
          .collection('gifts')
          .add(gift.toMap());
      print("Gift added successfully under event: $eventId");
    } else {
      print("Error: User not authenticated.");
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


  // Function to load gifts by eventId
  Future<List<Gift>> getGiftsByEvent(String eventId) async {
    try {
      final currentUser = AuthService.getCurrentUser(); // Get the logged-in user
      if (currentUser != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid) // Reference the logged-in user
            .collection('events')
            .doc(eventId) // Reference the specific event
            .collection('gifts') // Fetch gifts under this event
            .get();

        // Map Firestore documents to Gift objects
        _gifts = snapshot.docs.map((doc) {
          return Gift.fromMap(doc.id, doc.data());
        }).toList();

        print('Loaded ${_gifts.length} gifts for event ID: $eventId');
        return _gifts; // Return the fetched gifts
      } else {
        print('No user is logged in.');
        return [];
      }
    } catch (e) {
      print('Error loading gifts: $e');
      return [];
    }
  }

  // Update an existing gift in the specified event
  Future<void> updateGiftInEvent(String eventId, Gift updatedGift) async {
    final currentUser = AuthService.getCurrentUser();
    if (currentUser != null && updatedGift.id.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('events')
          .doc(eventId)
          .collection('gifts')
          .doc(updatedGift.id) // Correct document reference
          .update(updatedGift.toMap());
      print("Gift updated successfully with ID: ${updatedGift.id}");
    } else {
      print("Error: Invalid user or gift ID.");
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



}




