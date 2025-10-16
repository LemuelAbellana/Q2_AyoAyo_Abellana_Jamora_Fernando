import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Simple UserDao using SharedPreferences only
/// No SQLite dependency
class UserDao {
  static final UserDao _instance = UserDao._internal();
  factory UserDao() => _instance;
  UserDao._internal();

  Future<SharedPreferences> get _prefs async {
    return await SharedPreferences.getInstance();
  }

  // Insert user
  Future<int> insertUser(Map<String, dynamic> userData) async {
    try {
      final prefs = await _prefs;
      final uid = userData['uid'];
      final userJson = jsonEncode({
        'id': DateTime.now().millisecondsSinceEpoch,
        'uid': uid,
        'email': userData['email']?.toLowerCase(),
        'display_name': userData['display_name'],
        'photo_url': userData['photo_url'],
        'auth_provider': userData['auth_provider'] ?? 'email',
        'provider_id': userData['provider_id'],
        'password_hash': userData['password_hash'],
        'email_verified': userData['email_verified'] ?? 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'last_login_at': DateTime.now().toIso8601String(),
        'is_active': 1,
        'preferences': userData['preferences'] ?? '{}',
      });

      await prefs.setString('user_$uid', userJson);
      List<String> userUids = prefs.getStringList('user_uids') ?? [];
      if (!userUids.contains(uid)) {
        userUids.add(uid);
        await prefs.setStringList('user_uids', userUids);
      }

      return DateTime.now().millisecondsSinceEpoch;
    } catch (e) {
      debugPrint('Error inserting user: $e');
      return 0;
    }
  }

  // Get user by Firebase UID
  Future<Map<String, dynamic>?> getUserByUid(String uid) async {
    try {
      final prefs = await _prefs;
      final userJson = prefs.getString('user_$uid');
      if (userJson != null) {
        return jsonDecode(userJson);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user by UID: $e');
      return null;
    }
  }

  // Get user by email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      final prefs = await _prefs;
      final userUids = prefs.getStringList('user_uids') ?? [];

      for (final uid in userUids) {
        final userJson = prefs.getString('user_$uid');
        if (userJson != null) {
          final user = jsonDecode(userJson);
          if (user['email'] == email.toLowerCase()) {
            return user;
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user by email: $e');
      return null;
    }
  }

  // Get user by provider ID
  Future<Map<String, dynamic>?> getUserByProviderId(String providerId) async {
    try {
      final prefs = await _prefs;
      final userUids = prefs.getStringList('user_uids') ?? [];

      for (final uid in userUids) {
        final userJson = prefs.getString('user_$uid');
        if (userJson != null) {
          final user = jsonDecode(userJson);
          if (user['provider_id'] == providerId) {
            return user;
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user by provider ID: $e');
      return null;
    }
  }

  // Update user
  Future<int> updateUser(int id, Map<String, dynamic> userData) async {
    try {
      final prefs = await _prefs;
      final userUids = prefs.getStringList('user_uids') ?? [];

      for (final uid in userUids) {
        final userJson = prefs.getString('user_$uid');
        if (userJson != null) {
          final user = jsonDecode(userJson);
          if (user['id'] == id) {
            final updatedUser = {
              ...user,
              ...userData,
              'updated_at': DateTime.now().toIso8601String(),
            };
            await prefs.setString('user_$uid', jsonEncode(updatedUser));
            return 1;
          }
        }
      }
      return 0;
    } catch (e) {
      debugPrint('Error updating user: $e');
      return 0;
    }
  }

  // Update user by UID
  Future<int> updateUserByUid(String uid, Map<String, dynamic> userData) async {
    try {
      final prefs = await _prefs;
      final userJson = prefs.getString('user_$uid');
      if (userJson != null) {
        final user = jsonDecode(userJson);
        final updatedUser = {
          ...user,
          ...userData,
          'updated_at': DateTime.now().toIso8601String(),
        };
        await prefs.setString('user_$uid', jsonEncode(updatedUser));
        return 1;
      }
      return 0;
    } catch (e) {
      debugPrint('Error updating user by UID: $e');
      return 0;
    }
  }

  // Delete user (soft delete)
  Future<int> deleteUser(int id) async {
    try {
      final prefs = await _prefs;
      final userUids = prefs.getStringList('user_uids') ?? [];

      for (final uid in userUids) {
        final userJson = prefs.getString('user_$uid');
        if (userJson != null) {
          final user = jsonDecode(userJson);
          if (user['id'] == id) {
            user['is_active'] = 0;
            user['updated_at'] = DateTime.now().toIso8601String();
            await prefs.setString('user_$uid', jsonEncode(user));
            return 1;
          }
        }
      }
      return 0;
    } catch (e) {
      debugPrint('Error deleting user: $e');
      return 0;
    }
  }

  // Get all active users (for admin purposes)
  Future<List<Map<String, dynamic>>> getAllActiveUsers() async {
    try {
      final prefs = await _prefs;
      final userUids = prefs.getStringList('user_uids') ?? [];
      final users = <Map<String, dynamic>>[];

      for (final uid in userUids) {
        final userJson = prefs.getString('user_$uid');
        if (userJson != null) {
          final user = jsonDecode(userJson);
          if (user['is_active'] == 1) {
            users.add(user);
          }
        }
      }

      // Sort by created_at DESC
      users.sort(
        (a, b) => DateTime.parse(
          b['created_at'],
        ).compareTo(DateTime.parse(a['created_at'])),
      );
      return users;
    } catch (e) {
      debugPrint('Error getting all active users: $e');
      return [];
    }
  }

  // Update last login
  Future<void> updateLastLogin(int userId) async {
    try {
      final prefs = await _prefs;
      final userUids = prefs.getStringList('user_uids') ?? [];

      for (final uid in userUids) {
        final userJson = prefs.getString('user_$uid');
        if (userJson != null) {
          final user = jsonDecode(userJson);
          if (user['id'] == userId) {
            user['last_login_at'] = DateTime.now().toIso8601String();
            await prefs.setString('user_$uid', jsonEncode(user));
            break;
          }
        }
      }
    } catch (e) {
      debugPrint('Error updating last login: $e');
    }
  }

  // Delete user by email (hard delete)
  Future<int> deleteUserByEmail(String email) async {
    try {
      final prefs = await _prefs;
      final userUids = prefs.getStringList('user_uids') ?? [];
      final targetEmail = email.toLowerCase();

      for (final uid in userUids) {
        final userJson = prefs.getString('user_$uid');
        if (userJson != null) {
          final user = jsonDecode(userJson);
          if (user['email'] == targetEmail) {
            // Remove from user list
            userUids.remove(uid);
            await prefs.setStringList('user_uids', userUids);

            // Remove user data
            await prefs.remove('user_$uid');

            debugPrint('✅ Deleted user: $email');
            return 1;
          }
        }
      }
      debugPrint('⚠️ User not found: $email');
      return 0;
    } catch (e) {
      debugPrint('❌ Error deleting user by email: $e');
      return 0;
    }
  }

  // Get users by auth provider
  Future<List<Map<String, dynamic>>> getUsersByProvider(String provider) async {
    try {
      final prefs = await _prefs;
      final userUids = prefs.getStringList('user_uids') ?? [];
      final users = <Map<String, dynamic>>[];

      for (final uid in userUids) {
        final userJson = prefs.getString('user_$uid');
        if (userJson != null) {
          final user = jsonDecode(userJson);
          if (user['auth_provider'] == provider && user['is_active'] == 1) {
            users.add(user);
          }
        }
      }

      // Sort by created_at DESC
      users.sort(
        (a, b) => DateTime.parse(
          b['created_at'],
        ).compareTo(DateTime.parse(a['created_at'])),
      );
      return users;
    } catch (e) {
      debugPrint('Error getting users by provider: $e');
      return [];
    }
  }
}
