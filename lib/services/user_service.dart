import 'oauth_service.dart';
import 'api_service.dart';
import 'package:ayoayo/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User Service - Handles user authentication with Laravel backend only
/// No SQLite database, pure API-driven architecture
class UserService {
  static Map<String, dynamic>? _currentUser;
  static const String _userKey = 'current_user_data';

  // Register a new user (for email/password registration)
  static Future<bool> registerUser(
    String name,
    String email,
    String password,
  ) async {
    try {
      print('👤 Registering user with Laravel backend...');

      if (!ApiConfig.useBackendApi) {
        print('❌ Backend API is disabled in config');
        return false;
      }

      final response = await ApiService.register(
        name: name,
        email: email,
        password: password,
      );

      if (response['user'] != null) {
        _currentUser = response['user'];
        await _saveUserLocally(_currentUser!);
        print('✅ User registration successful: $email');
        return true;
      }

      return false;
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
          print('🔐 Attempting Google OAuth...');
          oauthUserData = await OAuthService.signInWithGoogle();
          break;
        case 'github':
          oauthUserData = await OAuthService.signInWithGitHub();
          break;
        default:
          throw Exception('Unsupported OAuth provider: $provider');
      }

      if (oauthUserData == null) {
        print('❌ OAuth sign-in was cancelled by user');
        return null;
      }

      print('✅ OAuth authentication successful for user: ${oauthUserData['email']}');

      // Sync with backend (optional - fallback to local if it fails)
      if (ApiConfig.useBackendApi) {
        try {
          print('🌐 Syncing OAuth with Laravel backend...');
          final backendResponse = await ApiService.oauthSignIn(
            uid: oauthUserData['uid'],
            email: oauthUserData['email'],
            displayName: oauthUserData['display_name'] ?? '',
            photoUrl: oauthUserData['photo_url'],
            authProvider: provider,
            providerId: oauthUserData['provider_id'] ?? '',
            emailVerified: oauthUserData['email_verified'] ?? false,
          );

          if (backendResponse['user'] != null) {
            _currentUser = backendResponse['user'];
            await _saveUserLocally(_currentUser!);
            print('✅ Backend OAuth sync successful');
            return _currentUser;
          }
        } catch (e) {
          print('⚠️ Backend OAuth sync failed: $e');
          print('📱 Falling back to local-only mode...');
          // Fallback to local storage when backend fails
          _currentUser = oauthUserData;
          await _saveUserLocally(_currentUser!);
          return _currentUser;
        }
      } else {
        print('⚠️ Backend API is disabled - using local OAuth data only');
        _currentUser = oauthUserData;
        await _saveUserLocally(_currentUser!);
        return _currentUser;
      }

      return null;
    } catch (e) {
      print('❌ Error handling OAuth sign-in: $e');
      return null;
    }
  }

  // Authenticate a user (for email/password login)
  static Future<Map<String, dynamic>?> authenticateUser(
    String email,
    String password,
  ) async {
    try {
      print('🔍 Authenticating user with Laravel backend: $email');

      if (!ApiConfig.useBackendApi) {
        print('❌ Backend API is disabled in config');
        return null;
      }

      final response = await ApiService.login(
        email: email,
        password: password,
      );

      if (response['user'] != null) {
        _currentUser = response['user'];
        await _saveUserLocally(_currentUser!);
        print('✅ Authentication successful');
        return _currentUser;
      }

      return null;
    } catch (e) {
      print('❌ Authentication error: $e');
      return null;
    }
  }

  // Get current user
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      // Return cached user if available
      if (_currentUser != null) {
        return _currentUser;
      }

      // Try to load from local storage
      _currentUser = await _loadUserLocally();
      if (_currentUser != null) {
        print('✅ Loaded user from local storage: ${_currentUser!['email']}');
        return _currentUser;
      }

      // Try to get from backend if authenticated
      if (ApiConfig.useBackendApi && ApiService.isAuthenticated) {
        try {
          final response = await ApiService.getCurrentUser();
          if (response['user'] != null) {
            _currentUser = response['user'];
            await _saveUserLocally(_currentUser!);
            return _currentUser;
          }
        } catch (e) {
          print('⚠️ Could not fetch user from backend: $e');
        }
      }

      print('❌ No current user found');
      return null;
    } catch (e) {
      print('❌ Error getting current user: $e');
      return null;
    }
  }

  // Check if user exists (requires backend API)
  static Future<bool> userExists(String email) async {
    if (!ApiConfig.useBackendApi) {
      return false;
    }

    try {
      // This would need a backend endpoint to check if user exists
      // For now, we'll return false and let the login/register flow handle it
      return false;
    } catch (e) {
      return false;
    }
  }

  // Get user by email (requires backend API)
  static Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    if (!ApiConfig.useBackendApi) {
      return null;
    }

    try {
      // This would need a backend endpoint
      return null;
    } catch (e) {
      return null;
    }
  }

  // Sign out user
  static Future<void> signOut() async {
    try {
      // Logout from backend if enabled
      if (ApiConfig.useBackendApi && ApiService.isAuthenticated) {
        try {
          await ApiService.logout();
          print('✅ Backend logout successful');
        } catch (e) {
          print('⚠️ Backend logout failed: $e');
        }
      }

      // Sign out from Google
      await OAuthService.signOut();

      // Clear local data
      _currentUser = null;
      await _clearUserLocally();

      print('✅ User signed out successfully');
    } catch (e) {
      print('❌ Error signing out: $e');
    }
  }

  // Check if user is currently signed in
  static bool get isSignedIn => _currentUser != null || OAuthService.isSignedIn;

  // Test Google OAuth configuration
  static Future<bool> testGoogleOAuthConfiguration() async {
    try {
      print('🧪 Testing Google OAuth configuration...');
      await OAuthService.testOAuthConfiguration();
      return true;
    } catch (e) {
      print('❌ Google OAuth test failed: $e');
      return false;
    }
  }

  // Get Google OAuth diagnostic information
  static Future<String> getGoogleOAuthDiagnostics() async {
    final buffer = StringBuffer();
    buffer.writeln('📊 Google Sign-In Diagnostic Information:');
    buffer.writeln('════════════════════════════════════════');
    buffer.writeln('• Backend API Enabled: ${ApiConfig.useBackendApi}');
    buffer.writeln('• Backend URL: ${ApiConfig.backendUrl}');
    buffer.writeln('• Current User: ${_currentUser?['email'] ?? 'None'}');
    buffer.writeln('• Google Signed In: ${OAuthService.isSignedIn}');
    buffer.writeln('• API Authenticated: ${ApiService.isAuthenticated}');
    buffer.writeln('════════════════════════════════════════');
    return buffer.toString();
  }

  // Force enable/disable real Google OAuth (deprecated - not needed anymore)
  static void setUseRealGoogleAuth(bool useReal) {
    print(useReal ? '🔐 Using real Google Auth' : '⚠️ Demo mode (not available)');
  }

  // Check if real Google OAuth is enabled (always true now)
  static bool get isRealGoogleAuthEnabled => true;

  // Local storage helpers
  static Future<void> _saveUserLocally(Map<String, dynamic> user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = {
        'uid': user['uid'],
        'email': user['email'],
        'display_name': user['display_name'],
        'photo_url': user['photo_url'],
      };
      await prefs.setString(_userKey, userData.toString());
      print('💾 User data saved locally');
    } catch (e) {
      print('⚠️ Could not save user locally: $e');
    }
  }

  static Future<Map<String, dynamic>?> _loadUserLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userKey);
      if (userData != null) {
        // Simple parsing - in production, use proper JSON encoding
        return null; // Simplified for now
      }
      return null;
    } catch (e) {
      print('⚠️ Could not load user locally: $e');
      return null;
    }
  }

  static Future<void> _clearUserLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      print('🗑️ User data cleared locally');
    } catch (e) {
      print('⚠️ Could not clear user locally: $e');
    }
  }

  // Session management (for compatibility)
  static Future<void> saveUserSession(Map<String, dynamic> user) async {
    await _saveUserLocally(user);
  }

  static Future<String?> getSavedUserSession() async {
    final user = await _loadUserLocally();
    return user?['uid'];
  }

  static Future<void> clearUserSession() async {
    await _clearUserLocally();
  }

  // Deprecated methods for compatibility
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    print('⚠️ getAllUsers is deprecated - use backend API instead');
    return [];
  }

  static Future<bool> deleteUserByEmail(String email) async {
    print('⚠️ deleteUserByEmail is deprecated - use backend API instead');
    return false;
  }

  static Future<bool> deleteTestUser() async {
    print('⚠️ deleteTestUser is deprecated');
    return false;
  }

  static Future<Map<String, dynamic>?> switchGoogleAccount() async {
    try {
      print('🔄 Switching Google account...');
      await OAuthService.signOut();
      return await handleOAuthSignIn('google');
    } catch (e) {
      print('❌ Account switch error: $e');
      return null;
    }
  }

  static Stream get authStateChanges => OAuthService.authStateChanges;
}
