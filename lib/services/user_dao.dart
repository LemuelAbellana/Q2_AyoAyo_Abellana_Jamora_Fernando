import 'dart:convert';
import 'database_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class UserDao {
  static final UserDao _instance = UserDao._internal();
  factory UserDao() => _instance;
  UserDao._internal();

  Future<Database?> get _database async {
    if (kIsWeb) return null;
    return await DatabaseService().database;
  }

  Future<SharedPreferences> get _prefs async {
    if (!kIsWeb)
      throw UnsupportedError('SharedPreferences only available on web');
    return await SharedPreferences.getInstance();
  }

  // Insert user
  Future<int> insertUser(Map<String, dynamic> userData) async {
    if (kIsWeb) {
      // Web implementation using SharedPreferences
      try {
        final prefs = await _prefs;
        final uid = userData['uid'];
        final userJson = jsonEncode({
          'id': DateTime.now().millisecondsSinceEpoch, // Generate ID for web
          'uid': uid,
          'email': userData['email']?.toLowerCase(),
          'display_name': userData['display_name'],
          'photo_url': userData['photo_url'],
          'auth_provider': userData['auth_provider'] ?? 'email',
          'provider_id': userData['provider_id'],
          'email_verified': userData['email_verified'] ?? 0,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'last_login_at': DateTime.now().toIso8601String(),
          'is_active': 1,
          'preferences': userData['preferences'] ?? '{}',
        });

        await prefs.setString('user_$uid', userJson);
        // Also store in a list for easy retrieval
        List<String> userUids = prefs.getStringList('user_uids') ?? [];
        if (!userUids.contains(uid)) {
          userUids.add(uid);
          await prefs.setStringList('user_uids', userUids);
        }

        return DateTime.now().millisecondsSinceEpoch;
      } catch (e) {
        print('Error inserting user (web): $e');
        return 0;
      }
    } else {
      // Mobile implementation using SQLite
      final db = await _database;
      try {
        final result = await db!.insert('users', {
          'uid': userData['uid'],
          'email': userData['email']?.toLowerCase(),
          'display_name': userData['display_name'],
          'photo_url': userData['photo_url'],
          'auth_provider': userData['auth_provider'] ?? 'email',
          'provider_id': userData['provider_id'],
          'email_verified': userData['email_verified'] ?? 0,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
          'last_login_at': DateTime.now().toIso8601String(),
          'is_active': 1,
          'preferences': userData['preferences'] ?? '{}',
        }, conflictAlgorithm: ConflictAlgorithm.replace);
        return result;
      } catch (e) {
        print('Error inserting user: $e');
        return 0;
      }
    }
  }

  // Get user by Firebase UID
  Future<Map<String, dynamic>?> getUserByUid(String uid) async {
    if (kIsWeb) {
      // Web implementation using SharedPreferences
      try {
        final prefs = await _prefs;
        final userJson = prefs.getString('user_$uid');
        if (userJson != null) {
          return jsonDecode(userJson);
        }
        return null;
      } catch (e) {
        print('Error getting user by UID (web): $e');
        return null;
      }
    } else {
      // Mobile implementation using SQLite
      final db = await _database;
      final List<Map<String, dynamic>> maps = await db!.query(
        'users',
        where: 'uid = ?',
        whereArgs: [uid],
      );
      if (maps.isNotEmpty) {
        return maps.first;
      }
      return null;
    }
  }

  // Get user by email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    if (kIsWeb) {
      // Web implementation using SharedPreferences
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
        print('Error getting user by email (web): $e');
        return null;
      }
    } else {
      // Mobile implementation using SQLite
      final db = await _database;
      final List<Map<String, dynamic>> maps = await db!.query(
        'users',
        where: 'email = ?',
        whereArgs: [email.toLowerCase()],
      );
      if (maps.isNotEmpty) {
        return maps.first;
      }
      return null;
    }
  }

  // Get user by provider ID
  Future<Map<String, dynamic>?> getUserByProviderId(String providerId) async {
    if (kIsWeb) {
      // Web implementation using SharedPreferences
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
        print('Error getting user by provider ID (web): $e');
        return null;
      }
    } else {
      // Mobile implementation using SQLite
      final db = await _database;
      final List<Map<String, dynamic>> maps = await db!.query(
        'users',
        where: 'provider_id = ?',
        whereArgs: [providerId],
      );
      if (maps.isNotEmpty) {
        return maps.first;
      }
      return null;
    }
  }

  // Update user
  Future<int> updateUser(int id, Map<String, dynamic> userData) async {
    if (kIsWeb) {
      // Web implementation using SharedPreferences
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
        print('Error updating user (web): $e');
        return 0;
      }
    } else {
      // Mobile implementation using SQLite
      final db = await _database;
      try {
        final result = await db!.update(
          'users',
          {...userData, 'updated_at': DateTime.now().toIso8601String()},
          where: 'id = ?',
          whereArgs: [id],
        );
        return result;
      } catch (e) {
        print('Error updating user: $e');
        return 0;
      }
    }
  }

  // Update user by UID
  Future<int> updateUserByUid(String uid, Map<String, dynamic> userData) async {
    if (kIsWeb) {
      // Web implementation using SharedPreferences
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
        print('Error updating user by UID (web): $e');
        return 0;
      }
    } else {
      // Mobile implementation using SQLite
      final db = await _database;
      try {
        final result = await db!.update(
          'users',
          {...userData, 'updated_at': DateTime.now().toIso8601String()},
          where: 'uid = ?',
          whereArgs: [uid],
        );
        return result;
      } catch (e) {
        print('Error updating user by UID: $e');
        return 0;
      }
    }
  }

  // Delete user
  Future<int> deleteUser(int id) async {
    if (kIsWeb) {
      // Web implementation using SharedPreferences
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
        print('Error deleting user (web): $e');
        return 0;
      }
    } else {
      // Mobile implementation using SQLite
      final db = await _database;
      try {
        final result = await db!.update(
          'users',
          {'is_active': 0, 'updated_at': DateTime.now().toIso8601String()},
          where: 'id = ?',
          whereArgs: [id],
        );
        return result;
      } catch (e) {
        print('Error deleting user: $e');
        return 0;
      }
    }
  }

  // Get all active users (for admin purposes)
  Future<List<Map<String, dynamic>>> getAllActiveUsers() async {
    if (kIsWeb) {
      // Web implementation using SharedPreferences
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
        print('Error getting all active users (web): $e');
        return [];
      }
    } else {
      // Mobile implementation using SQLite
      final db = await _database;
      return await db!.query(
        'users',
        where: 'is_active = ?',
        whereArgs: [1],
        orderBy: 'created_at DESC',
      );
    }
  }

  // Update last login
  Future<void> updateLastLogin(int userId) async {
    if (kIsWeb) {
      // Web implementation using SharedPreferences
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
        print('Error updating last login (web): $e');
      }
    } else {
      // Mobile implementation using SQLite
      final db = await _database;
      try {
        await db!.update(
          'users',
          {'last_login_at': DateTime.now().toIso8601String()},
          where: 'id = ?',
          whereArgs: [userId],
        );
      } catch (e) {
        print('Error updating last login: $e');
      }
    }
  }

  // Get users by auth provider
  Future<List<Map<String, dynamic>>> getUsersByProvider(String provider) async {
    if (kIsWeb) {
      // Web implementation using SharedPreferences
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
        print('Error getting users by provider (web): $e');
        return [];
      }
    } else {
      // Mobile implementation using SQLite
      final db = await _database;
      return await db!.query(
        'users',
        where: 'auth_provider = ? AND is_active = ?',
        whereArgs: [provider, 1],
        orderBy: 'created_at DESC',
      );
    }
  }
}
