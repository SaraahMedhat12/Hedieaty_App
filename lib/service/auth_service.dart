import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign up a new user with a unique username
  static Future<void> signUp(String email, String password, String username) async {
    try {
      // Check if username already exists
      final QuerySnapshot existingUsernames = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (existingUsernames.docs.isNotEmpty) {
        throw Exception('Username already taken.');
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user details in Firestore
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'email': email,
        'username': username,
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to sign up: ${e.toString()}');
    }
  }

  // Login an existing user
  static Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to log in: ${e.toString()}');
    }
  }

  // Logout the current user
  static Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to log out: ${e.toString()}');
    }
  }

  // Get the current user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Check if user is authenticated
  static bool isUserAuthenticated() {
    return _auth.currentUser != null;
  }

  // Update user details in Firestore
  static Future<void> updateUserDetails(Map<String, dynamic> data) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update(data);
      } else {
        throw Exception('No authenticated user found.');
      }
    } catch (e) {
      throw Exception('Failed to update user details: ${e.toString()}');
    }
  }

  // Fetch user details from Firestore
  static Future<Map<String, dynamic>?> getUserDetails() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(user.uid).get();
        return userDoc.data() as Map<String, dynamic>?;
      } else {
        throw Exception('No authenticated user found.');
      }
    } catch (e) {
      throw Exception('Failed to fetch user details: ${e.toString()}');
    }
  }
}
