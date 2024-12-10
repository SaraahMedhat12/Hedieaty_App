import 'dart:convert';
import 'package:crypto/crypto.dart';

class HashUtil {
  // Hash the password using SHA-256
  static String hashPassword(String password) {
    final bytes = utf8.encode(password); // Convert to bytes
    return sha256.convert(bytes).toString(); // Generate hash
  }

  // Verify the entered password by comparing the hashed password
  static bool verifyPassword(String password, String storedHash) {
    String hashedPassword = hashPassword(password);
    return hashedPassword == storedHash; // Compare the hashes
  }
}
