import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'demo_auth_service.dart';
import '../config/api_config.dart';

class RealGoogleAuth {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
    // For web, we need to pass the client ID explicitly
    clientId: kIsWeb ? ApiConfig.googleOAuthClientId : null,
  );

  static bool _useRealAuth = true; // Set to true to attempt real Google Sign-In

  // Real Google Sign-In with fallback to demo
  static Future<Map<String, dynamic>?> signIn() async {
    if (_useRealAuth) {
      try {
        print('🔐 Attempting real Google Sign-In...');
        print('📊 Platform: web');
        print('📊 Google Sign-In configuration check:');
        print('   - Client ID should be configured in web/index.html');
        print('   - Google Identity Services script should be loaded');

        final result = await _performRealGoogleSignIn();
        if (result != null) {
          print('✅ Real Google Sign-In successful!');
          print('👤 User: ${result['email']}');
          print('📛 Display name: ${result['display_name']}');
          return result;
        }
        print('⚠️ Real Google Sign-In returned null (user may have cancelled)');
        print('🔄 Falling back to demo mode');
      } catch (e, stackTrace) {
        print('❌ Real Google Sign-In error: $e');
        print('📍 Stack trace (first 3 lines):');
        print(stackTrace.toString().split('\n').take(3).join('\n'));

        // Detailed error analysis
        final errorStr = e.toString().toLowerCase();
        if (errorStr.contains('popup')) {
          print('🚫 Popup blocker detected - user needs to allow popups');
        } else if (errorStr.contains('network')) {
          print('🌐 Network error - check internet connection');
        } else if (errorStr.contains('configuration') || errorStr.contains('client')) {
          print('⚙️ Configuration error - check Google OAuth setup');
        }

        print('🔄 Falling back to demo mode due to error');
      }
    } else {
      print('🎭 Real auth disabled, using demo mode directly');
    }

    // Fallback to demo mode
    print('🎭 Using demo Google Sign-In (fallback)');
    print('⚠️ This means real Google authentication is not working');
    print('💡 To fix: Check console errors above for the root cause');
    return await DemoAuthService.demoGoogleSignIn();
  }

  static Future<Map<String, dynamic>?> _performRealGoogleSignIn() async {
    try {
      print('📱 Starting Google Sign-In flow...');

      // Trigger sign-in (don't sign out first on web - causes issues)
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) {
        print('❌ User cancelled Google Sign-In');
        return null;
      }

      print('✅ Google Sign-In successful: ${account.email}');

      // Get authentication details
      final GoogleSignInAuthentication googleAuth = await account.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        print('❌ Failed to get Google authentication tokens');
        return null;
      }

      print('🎫 Got Google authentication tokens');

      return {
        'uid': 'google_${account.id}',
        'email': account.email,
        'display_name': account.displayName ?? account.email.split('@')[0],
        'photo_url': account.photoUrl ?? '',
        'provider': 'google',
        'provider_id': account.id,
        'auth_provider': 'google',
        'email_verified': true,
        'access_token': googleAuth.accessToken,
        'id_token': googleAuth.idToken,
      };
    } catch (e) {
      print('❌ Real Google Sign-In error: $e');

      // Handle specific error types
      if (e.toString().contains('sign_in_canceled')) {
        print('📝 User cancelled the sign-in process');
      } else if (e.toString().contains('sign_in_failed')) {
        print('🔧 Sign-in failed - this might be due to:');
        print('   • Missing or incorrect google-services.json configuration');
        print('   • SHA-1 fingerprint not registered in Google Console');
        print('   • Google Sign-In API not enabled');
        print('   • Package name mismatch');
      } else if (e.toString().contains('network_error')) {
        print('🌐 Network error - check your internet connection');
      }

      throw e; // Re-throw to trigger fallback
    }
  }

  // Force enable/disable real Google Sign-In
  static void setUseRealAuth(bool useReal) {
    _useRealAuth = useReal;
    print(useReal
        ? '🔐 Real Google Sign-In enabled'
        : '🎭 Demo mode enabled');
  }

  // Check if real auth is enabled
  static bool get isRealAuthEnabled => _useRealAuth;

  // Sign out
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      print('✅ Successfully signed out from Google');
    } catch (e) {
      print('❌ Sign out error: $e');
    }
  }

  // Get current user
  static GoogleSignInAccount? get currentUser => _googleSignIn.currentUser;

  // Check if signed in
  static bool get isSignedIn => _googleSignIn.currentUser != null;

  // Disconnect (revoke access)
  static Future<void> disconnect() async {
    try {
      await _googleSignIn.disconnect();
      print('🔌 Disconnected from Google');
    } catch (e) {
      print('❌ Disconnect error: $e');
    }
  }

  // Test Google Sign-In configuration
  static Future<bool> testConfiguration() async {
    try {
      print('🧪 Testing Google Sign-In configuration...');

      // Try to initialize silently
      final GoogleSignInAccount? account = await _googleSignIn.signInSilently();

      if (account != null) {
        print('✅ Found existing signed-in account: ${account.email}');
        await _googleSignIn.signOut(); // Clean up
        return true;
      }

      print('ℹ️ No existing account found (this is normal)');
      print('✅ Google Sign-In configuration appears to be working');
      return true;
    } catch (e) {
      print('❌ Google Sign-In configuration test failed: $e');
      return false;
    }
  }

  // Get detailed error information
  static Future<String> getDiagnosticInfo() async {
    final buffer = StringBuffer();
    buffer.writeln('📊 Google Sign-In Diagnostic Information:');
    buffer.writeln('════════════════════════════════════════');
    buffer.writeln('• Real Auth Enabled: $_useRealAuth');
    buffer.writeln('• Current User: ${_googleSignIn.currentUser?.email ?? 'None'}');
    buffer.writeln('• Is Signed In: ${_googleSignIn.currentUser != null}');

    try {
      final configTest = await testConfiguration();
      buffer.writeln('• Configuration Test: ${configTest ? 'PASSED' : 'FAILED'}');
    } catch (e) {
      buffer.writeln('• Configuration Test: ERROR - $e');
    }

    buffer.writeln('════════════════════════════════════════');
    buffer.writeln('📋 Troubleshooting Steps:');
    buffer.writeln('1. Ensure google-services.json is in android/app/');
    buffer.writeln('2. Check package name matches in google-services.json');
    buffer.writeln('3. Verify SHA-1 fingerprint is registered in Google Console');
    buffer.writeln('4. Enable Google Sign-In API in Google Cloud Console');
    buffer.writeln('5. Clear app data and try again');

    return buffer.toString();
  }
}