import 'user_dao.dart';
import 'oauth_service.dart';
import 'simple_google_auth.dart';
import 'local_auth_service.dart';
import 'demo_auth_service.dart';
import 'real_google_auth.dart';
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
      print('👤 Starting user registration...');

      // Validate input
      if (!LocalAuthService.isValidEmail(email)) {
        print('❌ Invalid email format: $email');
        return false;
      }

      if (!LocalAuthService.isValidPassword(password)) {
        print('❌ Invalid password (must be at least 6 characters)');
        return false;
      }

      // Check if user already exists
      final existingUser = await _userDao.getUserByEmail(email);
      if (existingUser != null) {
        print('❌ User already exists with email: $email');
        return false;
      }

      // Create user data with hashed password
      final userData = LocalAuthService.createUserData(
        name: name,
        email: email,
        password: password,
      );

      print('💾 Inserting user data into database...');
      final result = await _userDao.insertUser(userData);

      if (result > 0) {
        print('✅ User registration successful: $email');
        return true;
      } else {
        print('❌ Database insertion failed');
        return false;
      }
    } catch (e) {
      print('❌ Error registering user: $e');
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
          // Use real Google Sign-In with demo fallback
          print('🔐 Attempting real Google OAuth...');
          oauthUserData = await RealGoogleAuth.signIn();
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
      print('🔍 Authenticating user: $email');

      final user = await _userDao.getUserByEmail(email);
      if (user == null) {
        print('❌ User not found: $email');
        return null;
      }

      // Check if this is a local account with password
      if (user['auth_provider'] == 'local' && user['password_hash'] != null) {
        // Verify password
        if (LocalAuthService.verifyPassword(password, user['password_hash'])) {
          print('✅ Password authentication successful');
          await _userDao.updateLastLogin(user['id']);
          return user;
        } else {
          print('❌ Invalid password');
          return null;
        }
      } else if (user['auth_provider'] == 'email') {
        // Legacy users without password hash - allow login
        print('⚠️ Legacy user login (no password hash)');
        await _userDao.updateLastLogin(user['id']);
        return user;
      } else {
        print('❌ User exists but wrong auth provider: ${user['auth_provider']}');
        return null;
      }
    } catch (e) {
      print('❌ Authentication error: $e');
      return null;
    }
  }

  // Get current user
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      print('🔍 Getting current user...');
      final googleUser = RealGoogleAuth.currentUser;

      if (googleUser != null) {
        print('✅ Google user found: ${googleUser.email}');
        final uid = 'google_${googleUser.id}';
        final user = await _userDao.getUserByUid(uid);

        if (user != null) {
          print('✅ Database user found: ${user['email']}');
          return user;
        } else {
          print('⚠️ Google user exists but not in database, this shouldn\'t happen');
          return null;
        }
      } else {
        print('❌ No Google user found');
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
      await RealGoogleAuth.signOut();
      await clearUserSession(); // Clear saved session
      print('✅ User signed out successfully');
      print('🔄 Ready to sign in with any Google account');
    } catch (e) {
      print('❌ Error signing out: $e');
    }
  }

  // Switch to a different Google account
  static Future<Map<String, dynamic>?> switchGoogleAccount() async {
    try {
      print('🔄 Switching Google account...');

      // Sign out first, then sign in again
      await RealGoogleAuth.signOut();
      final userData = await RealGoogleAuth.signIn();

      if (userData != null) {
        print('✅ Account switched successfully: ${userData['email']}');

        // Check if this user exists in database
        final existingUser = await _userDao.getUserByUid(userData['uid']);

        if (existingUser != null) {
          print('✅ Existing user found, updating session');
          await _userDao.updateLastLogin(existingUser['id']);
          await saveUserSession(existingUser);
          return existingUser;
        } else {
          print('👤 New account detected, creating database entry');
          // Create new user entry for this account
          final result = await _userDao.insertUser(userData);
          if (result > 0) {
            final newUser = await _userDao.getUserByUid(userData['uid']);
            if (newUser != null) {
              await saveUserSession(newUser);
              print('✅ New account registered in database');
              return newUser;
            }
          }
        }
      }

      return null;
    } catch (e) {
      print('❌ Account switch error: $e');
      return null;
    }
  }

  // Delete user by email (for testing/admin purposes)
  static Future<bool> deleteUserByEmail(String email) async {
    try {
      print('🗑️ Attempting to delete user: $email');
      final result = await _userDao.deleteUserByEmail(email);
      return result > 0;
    } catch (e) {
      print('❌ Error deleting user: $e');
      return false;
    }
  }

  // Helper method to delete specific test user
  static Future<bool> deleteTestUser() async {
    const testEmail = 'lemuelabellana1@gmail.com';
    return await deleteUserByEmail(testEmail);
  }

  // Check if user is currently signed in
  static bool get isSignedIn => RealGoogleAuth.isSignedIn;

  // Listen to authentication state changes (disabled for simple auth)
  static Stream get authStateChanges => const Stream.empty();

  // Test Google OAuth configuration
  static Future<bool> testGoogleOAuthConfiguration() async {
    try {
      print('🧪 Testing Google OAuth configuration...');
      return await RealGoogleAuth.testConfiguration();
    } catch (e) {
      print('❌ Google OAuth test failed: $e');
      return false;
    }
  }

  // Get Google OAuth diagnostic information
  static Future<String> getGoogleOAuthDiagnostics() async {
    return await RealGoogleAuth.getDiagnosticInfo();
  }

  // Force enable/disable real Google OAuth (for testing)
  static void setUseRealGoogleAuth(bool useReal) {
    RealGoogleAuth.setUseRealAuth(useReal);
  }

  // Check if real Google OAuth is enabled
  static bool get isRealGoogleAuthEnabled => RealGoogleAuth.isRealAuthEnabled;

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
