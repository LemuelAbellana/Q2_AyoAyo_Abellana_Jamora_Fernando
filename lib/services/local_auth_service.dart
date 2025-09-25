import 'package:crypto/crypto.dart';
import 'dart:convert';

class LocalAuthService {
  // Simple password hashing
  static String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Generate a unique user ID
  static String generateUserId(String email) {
    return 'local_${DateTime.now().millisecondsSinceEpoch}_${email.hashCode.abs()}';
  }

  // Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate password strength
  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  // Create user data for local registration
  static Map<String, dynamic> createUserData({
    required String name,
    required String email,
    required String password,
  }) {
    return {
      'uid': generateUserId(email),
      'email': email.toLowerCase().trim(),
      'display_name': name.trim(),
      'photo_url': '',
      'auth_provider': 'local',
      'provider_id': email.toLowerCase().trim(),
      'email_verified': 1, // Assume verified for local accounts
      'password_hash': _hashPassword(password),
      'is_active': 1,
      'preferences': '{}',
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'last_login': DateTime.now().millisecondsSinceEpoch,
    };
  }

  // Verify password
  static bool verifyPassword(String password, String hashedPassword) {
    return _hashPassword(password) == hashedPassword;
  }

  // Create demo user data (for testing)
  static Map<String, dynamic> createDemoUserData(String email) {
    return {
      'uid': generateUserId(email),
      'email': email,
      'display_name': email.split('@')[0],
      'photo_url': '',
      'auth_provider': 'demo',
      'provider_id': email,
      'email_verified': 1,
      'is_active': 1,
      'preferences': '{}',
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'last_login': DateTime.now().millisecondsSinceEpoch,
    };
  }
}