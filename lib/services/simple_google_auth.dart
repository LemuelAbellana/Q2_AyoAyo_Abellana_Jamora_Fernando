import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class SimpleGoogleAuth {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );

  // Simple Google Sign-In
  static Future<Map<String, dynamic>?> signIn() async {
    try {
      print('🚀 Starting simple Google Sign-In...');

      // Check if already signed in
      GoogleSignInAccount? account = _googleSignIn.currentUser;

      // If not signed in, trigger sign in
      account ??= await _googleSignIn.signIn();

      if (account == null) {
        print('❌ User cancelled Google Sign-In');
        return null;
      }

      print('✅ Google Sign-In successful: ${account.email}');

      return {
        'uid': 'google_${account.id}',
        'email': account.email,
        'display_name': account.displayName ?? account.email.split('@')[0],
        'photo_url': account.photoUrl ?? '',
        'provider': 'google',
        'provider_id': account.id,
        'email_verified': true,
      };
    } catch (e) {
      print('❌ Google Sign-In error: $e');

      // Handle specific errors
      if (e.toString().contains('sign_in_canceled')) {
        print('📝 User cancelled the sign-in process');
        return null;
      } else if (e.toString().contains('network_error')) {
        print('🌐 Network error - check your internet connection');
        return null;
      } else if (e.toString().contains('sign_in_failed')) {
        print('🔧 Sign-in failed - check your Google Services configuration');
        return null;
      }

      return null;
    }
  }

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
}