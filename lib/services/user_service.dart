import 'user_dao.dart';
import 'oauth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class UserService {
  static final UserDao _userDao = UserDao();

  // Register a new user (for email/password registration)
  static Future<bool> registerUser(
    String name,
    String email,
    String password,
  ) async {
    try {
      // Check if user already exists
      final existingUser = await _userDao.getUserByEmail(email);
      if (existingUser != null) {
        return false; // User already exists
      }

      // Generate Firebase-compatible UID for local users
      final uid =
          'local_${DateTime.now().millisecondsSinceEpoch}_${email.hashCode}';

      final userData = {
        'uid': uid,
        'email': email.toLowerCase(),
        'display_name': name.trim(),
        'auth_provider': 'email',
        'email_verified': 0,
        'is_active': 1,
        'preferences': '{}',
      };

      final result = await _userDao.insertUser(userData);
      return result > 0;
    } catch (e) {
      print('Error registering user: $e');
      return false;
    }
  }

  // Handle OAuth sign-in
  static Future<Map<String, dynamic>?> handleOAuthSignIn(
    String provider,
  ) async {
    try {
      print('🔐 Starting OAuth sign-in process for provider: $provider');

      Map<String, dynamic>? oauthUserData;

      // Call the appropriate OAuth service based on provider
      switch (provider.toLowerCase()) {
        case 'google':
          try {
            oauthUserData = await OAuthService.signInWithGoogle();
          } catch (googleError) {
            if (googleError.toString().contains('People API') ||
                googleError.toString().contains('SERVICE_DISABLED')) {
              print(
                '🔄 Falling back to basic Google Sign-In (no People API required)',
              );
              oauthUserData = await OAuthService.signInWithGoogleBasic();
            } else {
              throw googleError;
            }
          }
          break;
        case 'github':
          oauthUserData = await OAuthService.signInWithGitHub();
          break;
        default:
          throw Exception('Unsupported OAuth provider: $provider');
      }

      if (oauthUserData == null) {
        print('❌ OAuth sign-in was cancelled by user');
        return null; // User cancelled sign-in
      }

      print(
        '✅ OAuth authentication successful for user: ${oauthUserData['email']}',
      );

      // Check if user already exists in database
      print('🔍 Checking if user exists in database...');
      final existingUser = await _userDao.getUserByUid(oauthUserData['uid']);

      if (existingUser != null) {
        print('✅ Existing user found, updating last login...');
        // Update last login and return existing user
        await _userDao.updateLastLogin(existingUser['id']);
        await saveUserSession(existingUser); // Save session
        print('✅ User login updated successfully');
        return existingUser;
      }

      print('👤 User not found, checking if email exists...');
      // Check if email already exists with different provider
      final existingEmailUser = await _userDao.getUserByEmail(
        oauthUserData['email'],
      );
      if (existingEmailUser != null) {
        print('📧 Email exists with different provider, linking accounts...');
        // Link the OAuth account to existing email account
        await _userDao.updateUserByUid(oauthUserData['uid'], {
          'auth_provider': provider,
          'provider_id': oauthUserData['provider_id'],
          'photo_url': oauthUserData['photo_url'],
          'display_name': oauthUserData['display_name'],
          'email_verified': oauthUserData['email_verified'] ? 1 : 0,
        });

        final updatedUser = await _userDao.getUserByUid(oauthUserData['uid']);
        if (updatedUser != null) {
          await _userDao.updateLastLogin(updatedUser['id']);
          await saveUserSession(updatedUser); // Save session
          print('✅ Account linked successfully');
          return updatedUser;
        }
      }

      print('🆕 Creating new user in database...');
      // Create new user in database
      final userData = {
        'uid': oauthUserData['uid'],
        'email': oauthUserData['email'],
        'display_name': oauthUserData['display_name'],
        'photo_url': oauthUserData['photo_url'],
        'auth_provider': provider,
        'provider_id': oauthUserData['provider_id'],
        'email_verified': oauthUserData['email_verified'] ? 1 : 0,
        'preferences': '{}',
      };

      print('💾 Inserting user data: $userData');
      final result = await _userDao.insertUser(userData);
      print('📊 Insert result: $result');

      if (result > 0) {
        // Get the newly created user
        final newUser = await _userDao.getUserByUid(oauthUserData['uid']);
        if (newUser != null) {
          await saveUserSession(newUser); // Save session for new user
        }
        print('✅ New user created successfully: ${newUser?['email']}');
        return newUser;
      }

      print('❌ Failed to create new user');
      return null;
    } catch (e) {
      print('Error handling OAuth sign-in: $e');
      return null;
    }
  }

  // Authenticate a user (for email/password login)
  static Future<Map<String, dynamic>?> authenticateUser(
    String email,
    String password,
  ) async {
    try {
      final user = await _userDao.getUserByEmail(email);
      if (user != null && user['auth_provider'] == 'email') {
        // In a real app, you'd verify the password hash here
        // For now, we'll assume successful authentication
        await _userDao.updateLastLogin(user['id']);
        return user;
      }
      return null;
    } catch (e) {
      print('Authentication error: $e');
      return null;
    }
  }

  // Get current user
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      print('🔍 Getting current user...');
      final firebaseUser = OAuthService.getCurrentUser();

      if (firebaseUser != null) {
        print('✅ Firebase user found: ${firebaseUser.email}');
        final user = await _userDao.getUserByUid(firebaseUser.uid);

        if (user != null) {
          print('✅ Database user found: ${user['email']}');
          return user;
        } else {
          print(
            '⚠️ Firebase user exists but not in database, this shouldn\'t happen',
          );
          return null;
        }
      } else {
        print('❌ No Firebase user found');
        return null;
      }
    } catch (e) {
      print('❌ Error getting current user: $e');
      return null;
    }
  }

  // Check if user exists
  static Future<bool> userExists(String email) async {
    final user = await _userDao.getUserByEmail(email);
    return user != null;
  }

  // Get user by email
  static Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    return await _userDao.getUserByEmail(email);
  }

  // Get all users (for debugging purposes)
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    return await _userDao.getAllActiveUsers();
  }

  // Sign out user
  static Future<void> signOut() async {
    try {
      await OAuthService.signOut();
      await clearUserSession(); // Clear saved session
      print('✅ User signed out successfully');
    } catch (e) {
      print('❌ Error signing out: $e');
    }
  }

  // Check if user is currently signed in
  static bool get isSignedIn => OAuthService.isSignedIn;

  // Listen to authentication state changes
  static Stream get authStateChanges => OAuthService.authStateChanges;

  // Session management methods
  static Future<void> saveUserSession(Map<String, dynamic> user) async {
    if (kIsWeb) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('current_user', user['uid']);
        print('💾 User session saved: ${user['email']}');
      } catch (e) {
        print('❌ Error saving user session: $e');
      }
    }
  }

  static Future<String?> getSavedUserSession() async {
    if (kIsWeb) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final uid = prefs.getString('current_user');
        print('📖 Retrieved saved session: ${uid ?? 'none'}');
        return uid;
      } catch (e) {
        print('❌ Error getting saved session: $e');
        return null;
      }
    }
    return null;
  }

  static Future<void> clearUserSession() async {
    if (kIsWeb) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('current_user');
        print('🗑️ User session cleared');
      } catch (e) {
        print('❌ Error clearing user session: $e');
      }
    }
  }
}
