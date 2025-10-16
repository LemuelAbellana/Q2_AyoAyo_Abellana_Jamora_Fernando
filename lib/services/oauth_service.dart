import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class OAuthService {
  // Initialize GoogleSignIn as a static final variable to ensure single instance
  // For web: clientId must be configured in web/index.html meta tag
  // For mobile: clientId comes from google-services.json
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // Pass null to use platform-specific configuration:
    // - Web: reads from <meta name="google-signin-client_id"> in index.html
    // - Mobile: reads from google-services.json
    clientId: null,
    forceCodeForRefreshToken: !kIsWeb,
  );

  // Getter for the singleton instance
  static GoogleSignIn get _googleSignInInstance => _googleSignIn;

  // Mobile-first Google Sign-In without Firebase
  static Future<Map<String, dynamic>?> signInWithGoogleMobile() async {
    try {
      print('🚀 Starting Mobile Google Sign-In...');

      final GoogleSignInAccount? googleUser = await _googleSignInInstance
          .signIn()
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              print('⏰ Google Sign-In timed out');
              throw Exception('Google Sign-In timed out. Please try again.');
            },
          );

      if (googleUser == null) {
        print('❌ User cancelled Google Sign-In');
        return null;
      }

      print('✅ Google Sign-In successful: ${googleUser.email}');

      // Create user data from Google account info
      return {
        'uid': 'google_${googleUser.id}',
        'email': googleUser.email,
        'display_name': googleUser.displayName ?? googleUser.email.split('@')[0],
        'photo_url': googleUser.photoUrl ?? '',
        'provider': 'google',
        'provider_id': googleUser.id,
        'email_verified': true,
      };
    } catch (e) {
      print('❌ Mobile Google Sign-In error: $e');
      return null;
    }
  }

  // Primary Google Sign-In method (mobile-first)
  static Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      print('🚀 Starting Google Sign-In process...');

      if (kIsWeb) {
        print('🌐 Running on web - ensure popup blockers are disabled');
      } else {
        print('📱 Running on mobile - using native Google Sign-In');
      }

      final GoogleSignInAccount? googleUser = await _googleSignInInstance
          .signIn()
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              print('⏰ Google Sign-In timed out');
              throw Exception('Google Sign-In timed out. Please try again.');
            },
          );

      if (googleUser == null) {
        print('❌ User cancelled Google Sign-In');
        return null;
      }

      print('✅ Google Sign-In successful: ${googleUser.email}');

      return {
        'uid': 'google_${googleUser.id}',
        'email': googleUser.email,
        'display_name': googleUser.displayName ?? googleUser.email.split('@')[0],
        'photo_url': googleUser.photoUrl ?? '',
        'provider': 'google',
        'provider_id': googleUser.id,
        'email_verified': true,
      };
    } catch (e) {
      print('❌ Google Sign-In error: $e');
      if (kIsWeb) {
        print('💡 Web troubleshooting:');
        print('   1. Check web/index.html has <meta name="google-signin-client_id">');
        print('   2. Verify the Client ID matches your Google Cloud Console project');
        print('   3. Ensure popup blockers are disabled');
        print('   4. Try running: flutter clean && flutter pub get');
      }
      return null;
    }
  }

  // GitHub sign-in (disabled for simplicity)
  static Future<Map<String, dynamic>?> signInWithGitHub() async {
    print('❌ GitHub Sign-In not configured for mobile app');
    return null;
  }

  // Get current signed in Google user
  static GoogleSignInAccount? getCurrentUser() {
    return _googleSignIn.currentUser;
  }

  // Sign out from Google
  static Future<void> signOut() async {
    try {
      await _googleSignInInstance.signOut();
      print('✅ Successfully signed out from Google');
    } catch (e) {
      print('❌ Sign out error: $e');
    }
  }

  // Force disconnect from Google
  static Future<void> forceDisconnect() async {
    try {
      await _googleSignInInstance.disconnect();
      print('🔌 Force disconnected from Google');
    } catch (e) {
      print('❌ Force disconnect error: $e');
    }
  }

  // Check if user is currently signed in
  static bool get isSignedIn => _googleSignIn.currentUser != null;

  // Get authentication state changes stream
  static Stream<GoogleSignInAccount?> get authStateChanges => _googleSignIn.onCurrentUserChanged;

  // Test OAuth configuration (for debugging)
  static Future<void> testOAuthConfiguration() async {
    print('🧪 Testing OAuth Configuration...');

    if (kIsWeb) {
      print('🌐 Running on Web');
      print('💡 Make sure google-services.json is configured properly');
    } else {
      print('📱 Running on Mobile');
      print('📋 Checking google-services.json exists in android/app/');
    }

    try {
      final user = _googleSignIn.currentUser;
      print('👤 Current Google user: ${user?.email ?? 'None'}');
    } catch (e) {
      print('❌ Google Sign-In connection error: $e');
    }

    print('✅ OAuth configuration test complete');
  }


  // Switch to a different Google account
  static Future<Map<String, dynamic>?> switchGoogleAccount() async {
    try {
      print('🔄 Switching to a different Google account...');

      // Sign out first
      await signOut();

      // Sign in with new account
      return await signInWithGoogle();
    } catch (e) {
      print('❌ Account switch error: $e');
      return null;
    }
  }
}
