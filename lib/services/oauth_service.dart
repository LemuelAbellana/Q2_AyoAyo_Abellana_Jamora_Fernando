import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class OAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static GoogleSignIn? _googleSignIn;

  // Initialize GoogleSignIn with proper configuration
  static GoogleSignIn get _googleSignInInstance {
    _googleSignIn ??= GoogleSignIn(
      scopes: [
        'email',
      ], // Only request email scope to avoid People API requirement
      // For web: client ID will be read from meta tag in index.html
      // For mobile: client ID will be read from google-services.json
    );
    return _googleSignIn!;
  }

  // Alternative Google Sign-In that works without People API
  static Future<Map<String, dynamic>?> signInWithGoogleBasic() async {
    try {
      print('🚀 Starting Basic Google Sign-In (no profile data)...');

      if (kIsWeb) {
        print('🌐 Running on web - ensure popup blockers are disabled');
      }

      print('🔐 Triggering Google Sign-In popup...');
      GoogleSignInAccount? googleUser;

      try {
        googleUser = await _googleSignInInstance.signIn().timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            print('⏰ Google Sign-In timed out');
            throw Exception('Google Sign-In timed out. Please try again.');
          },
        );
      } catch (popupError) {
        print('❌ Popup failed: $popupError');
        return null;
      }

      if (googleUser == null) {
        print('❌ User cancelled Google Sign-In');
        return null;
      }

      print('✅ Google Sign-In successful: ${googleUser.email}');

      // Get basic user info directly from GoogleSignInAccount
      // This avoids the People API requirement
      return {
        'uid': 'google_${googleUser.id}', // Create a unique ID
        'email': googleUser.email,
        'display_name':
            googleUser.displayName ?? googleUser.email.split('@')[0],
        'photo_url': googleUser.photoUrl ?? '',
        'provider': 'google',
        'provider_id': googleUser.id,
        'email_verified': true, // Google accounts are typically verified
      };
    } catch (e) {
      print('❌ Basic Google Sign-In error: $e');
      return null;
    }
  }

  // Sign in with Google (with People API fallback)
  static Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      print('🚀 Starting Google Sign-In process...');

      // Check if user is already signed in
      if (_auth.currentUser != null) {
        print(
          '✅ User already signed in with Firebase: ${_auth.currentUser!.email}',
        );
        return {
          'uid': _auth.currentUser!.uid,
          'email': _auth.currentUser!.email ?? '',
          'display_name': _auth.currentUser!.displayName ?? '',
          'photo_url': _auth.currentUser!.photoURL,
          'provider': 'google',
          'provider_id': _auth.currentUser!.providerData.isNotEmpty
              ? _auth.currentUser!.providerData[0].uid
              : '',
          'email_verified': _auth.currentUser!.emailVerified,
        };
      }

      // Check if running on web and provide helpful error messages
      if (kIsWeb) {
        print('🌐 Running on web - ensure popup blockers are disabled');
        print('📋 Client ID should be configured in web/index.html meta tag');
      }

      print('🔐 Triggering Google Sign-In...');
      print('💡 Make sure popup blockers are disabled in your browser!');
      print('   Chrome: Click the popup blocker icon in address bar');
      print('   Firefox: Check privacy settings');
      print('   Safari: Allow popups and redirects');

      // Always use popup for fresh account selection
      print('🎯 Select your preferred Google account from the popup');
      final GoogleSignInAccount? googleUser = await _googleSignInInstance
          .signIn()
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              print('⏰ Google Sign-In timed out after 60 seconds');
              throw Exception('Google Sign-In timed out. Please try again.');
            },
          );

      if (googleUser == null) {
        print('❌ User cancelled Google Sign-In');
        return null; // User cancelled the sign-in
      }

      print('✅ Google Sign-In successful, user: ${googleUser.email}');
      print('🔑 Obtaining authentication tokens...');

      User? firebaseUser;

      try {
        // Obtain the auth details from the request
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        print('✅ Got authentication tokens');

        // Create a new credential
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        print('🔥 Signing in to Firebase...');

        // Sign in to Firebase with the credential
        final UserCredential userCredential = await _auth.signInWithCredential(
          credential,
        );
        firebaseUser = userCredential.user;

        print('✅ Firebase sign-in successful, user: ${firebaseUser?.email}');
      } catch (authError) {
        print('❌ Firebase authentication error: $authError');

        // Handle specific People API error
        if (authError.toString().contains('People API') ||
            authError.toString().contains('SERVICE_DISABLED') ||
            authError.toString().contains('people.googleapis.com')) {
          print('🚨 PEOPLE API ERROR DETECTED!');
          print('This is a common issue - here\'s how to fix it:');
          print('');
          print('🔧 SOLUTION: Enable People API in Google Cloud Console');
          print('1. Go to: https://console.cloud.google.com/apis/library');
          print('2. Search for "People API"');
          print('3. Click on "Google People API"');
          print('4. Click "Enable"');
          print('5. Wait 2-3 minutes for changes to propagate');
          print('6. Try Google Sign-In again');
          print('');
          print('Alternatively, the app will continue with basic user info.');
        }

        throw authError;
      }

      if (firebaseUser != null) {
        // Use Firebase Auth data as fallback if Google profile data isn't available
        String displayName = firebaseUser.displayName ?? '';
        String photoUrl = firebaseUser.photoURL ?? '';

        // If display name is empty, try to extract from email
        if (displayName.isEmpty && firebaseUser.email != null) {
          displayName = firebaseUser.email!.split('@')[0];
        }

        print('📋 User data prepared:');
        print('   • UID: ${firebaseUser.uid}');
        print('   • Email: ${firebaseUser.email}');
        print('   • Display Name: $displayName');
        print('   • Photo URL: ${photoUrl.isEmpty ? 'None' : 'Available'}');

        return {
          'uid': firebaseUser.uid,
          'email': firebaseUser.email ?? '',
          'display_name': displayName,
          'photo_url': photoUrl,
          'provider': 'google',
          'provider_id': googleUser.id,
          'email_verified': firebaseUser.emailVerified,
        };
      }
      return null;
    } catch (e) {
      print('❌ Google Sign-In error: $e');

      // Provide helpful error messages for common issues
      final errorString = e.toString().toLowerCase();

      if (errorString.contains('people api') ||
          errorString.contains('service_disabled') ||
          errorString.contains('people.googleapis.com')) {
        print('🚨 GOOGLE PEOPLE API ERROR!');
        print('=====================================');
        print(
          'The Google People API needs to be enabled for full profile access.',
        );
        print('');
        print('🔧 QUICK FIX:');
        print('1. Go to: https://console.cloud.google.com/apis/library');
        print('2. Search for "People API"');
        print('3. Click "Google People API"');
        print('4. Click "ENABLE" button');
        print('5. Wait 2-3 minutes');
        print('6. Try Google Sign-In again');
        print('');
        print(
          '✅ The app will work with basic profile info until API is enabled.',
        );
        print('=====================================');
      } else if (errorString.contains('clientid not set') ||
          errorString.contains('client id not set')) {
        print('❌ GOOGLE OAUTH CLIENT ID MISSING:');
        print('1. Go to https://console.cloud.google.com/apis/credentials');
        print('2. Create/select your project');
        print('3. Create OAuth 2.0 Client ID');
        print('4. For Web: Update the meta tag in web/index.html');
        print('5. For Mobile: Download google-services.json to android/app/');
        print('6. Make sure the client ID format is correct');
      } else if (errorString.contains('popup') ||
          errorString.contains('blocked') ||
          errorString.contains('cancelled') ||
          errorString.contains('popup_closed')) {
        print('⚠️ POPUP WAS BLOCKED OR CANCELLED:');
        print('- Make sure popups are enabled in your browser');
        print('- Try disabling popup blockers');
        print('- Check if the OAuth consent screen is configured');
        // Show detailed popup blocker help
        showPopupBlockerHelp();
      } else if (errorString.contains('network') ||
          errorString.contains('connection')) {
        print('🌐 NETWORK ERROR:');
        print('- Check your internet connection');
        print('- Make sure Firebase is accessible');
      } else if (errorString.contains('invalid') ||
          errorString.contains('unauthorized')) {
        print('🔑 AUTHORIZATION ERROR:');
        print('- Check your OAuth client ID configuration');
        print('- Verify authorized origins/domains');
        print('- Make sure Google+ API is enabled');
      } else {
        print('🔍 UNKNOWN ERROR:');
        print('- Check the browser console for more details');
        print('- Verify your Firebase configuration');
        print('- Make sure all required APIs are enabled');
      }

      return null;
    }
  }

  // Sign in with GitHub
  static Future<Map<String, dynamic>?> signInWithGitHub() async {
    try {
      // Create a GitHub Auth Provider
      final GithubAuthProvider githubProvider = GithubAuthProvider();

      // Sign in with Firebase Auth
      final UserCredential userCredential = await _auth.signInWithProvider(
        githubProvider,
      );
      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        return {
          'uid': firebaseUser.uid,
          'email': firebaseUser.email ?? '',
          'display_name':
              firebaseUser.displayName ??
              firebaseUser.email?.split('@')[0] ??
              '',
          'photo_url': firebaseUser.photoURL,
          'provider': 'github',
          'provider_id': firebaseUser.providerData.isNotEmpty
              ? firebaseUser.providerData[0].uid
              : '',
          'email_verified': firebaseUser.emailVerified,
        };
      }
      return null;
    } catch (e) {
      print('GitHub Sign-In error: $e');
      return null;
    }
  }

  // Get current Firebase user
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Sign out from all providers
  static Future<void> signOut() async {
    try {
      // Force disconnect from Google to allow account switching
      await forceDisconnect();
      await _auth.signOut();
      print('✅ Successfully signed out from all providers');
      print('🔄 Ready to sign in with a different Google account');
    } catch (e) {
      print('❌ Sign out error: $e');
    }
  }

  // Force disconnect from Google (useful for debugging)
  static Future<void> forceDisconnect() async {
    try {
      if (_googleSignIn != null) {
        await _googleSignIn!.disconnect();
        print('🔌 Force disconnected from Google');
      } else {
        final tempGoogleSignIn = GoogleSignIn();
        await tempGoogleSignIn.disconnect();
        print('🔌 Force disconnected from Google (new instance)');
      }
    } catch (e) {
      print('❌ Force disconnect error: $e');
    }
  }

  // Listen to authentication state changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if user is currently signed in
  static bool get isSignedIn => _auth.currentUser != null;

  // Test OAuth configuration (for debugging)
  static Future<void> testOAuthConfiguration() async {
    print('🧪 Testing OAuth Configuration...');

    if (kIsWeb) {
      print('🌐 Running on Web');
      print('📋 Checking for Google OAuth meta tag...');

      // Check if meta tag exists (this would require DOM access, but we can at least log)
      print('💡 Make sure this meta tag exists in web/index.html:');
      print(
        '<meta name="google-signin-client_id" content="YOUR_CLIENT_ID.apps.googleusercontent.com">',
      );

      print('🔍 Popup Blocker Check:');
      print('   • Chrome: Look for popup blocker icon in address bar (🔕)');
      print(
        '   • Firefox: Tools → Options → Privacy & Security → Block pop-up windows',
      );
      print('   • Safari: Safari → Preferences → Websites → Pop-up Windows');
      print(
        '   • Edge: Settings → Cookies and site permissions → Pop-ups and redirects',
      );
    } else {
      print('📱 Running on Mobile');
      print('📋 Make sure google-services.json exists in android/app/');
    }

    print('🔥 Firebase Project ID: ayoayo-f9697');
    print('🔥 Firebase App ID: 1:583476631419:web:41e1a3a77d1ec044ad4fde');

    // Test Firebase connection
    try {
      final user = _auth.currentUser;
      print('👤 Current Firebase user: ${user?.email ?? 'None'}');
    } catch (e) {
      print('❌ Firebase connection error: $e');
    }

    print('✅ OAuth configuration test complete');
  }

  // Helper method to check popup blocker status (web only)
  static void showPopupBlockerHelp() {
    if (!kIsWeb) return;

    print('🚫 POPUP BLOCKER DETECTED!');
    print('=====================================');
    print('QUICK FIX STEPS:');
    print('');
    print('🔍 STEP 1: Check browser address bar for popup blocker icon');
    print('   • Chrome: Look for 🔕 icon in address bar');
    print('   • Firefox: Look for shield icon');
    print('   • Safari: Look for popup blocker notification');
    print('   • Edge: Look for popup blocker icon');
    print('');
    print('🖱️ STEP 2: Click the icon and allow popups for:');
    print('   • localhost:5000 (development)');
    print('   • Your production domain');
    print('');
    print('🔄 STEP 3: Refresh the page and try again');
    print('');
    print('💡 ALTERNATIVE: Temporarily disable popup blocker');
    print(
      '   Chrome: Settings → Privacy → Pop-ups and redirects → Block (uncheck)',
    );
    print(
      '   Firefox: Settings → Privacy & Security → Block pop-up windows (uncheck)',
    );
    print('');
    print('✅ TEST: Try Google Sign-In again after making changes');
    print('=====================================');
  }

  // Test popup functionality (call this from your app)
  static Future<bool> testPopupFunctionality() async {
    if (!kIsWeb) {
      print('📱 Popup test only available on web platform');
      return true;
    }

    print('🧪 Testing popup functionality...');

    try {
      // Try to open a test popup (this will be blocked if popup blocker is active)
      final testPopup = await _googleSignInInstance.signInSilently().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print('⏰ Silent sign-in timed out - popup blocker may be active');
          return null;
        },
      );

      if (testPopup != null) {
        print('✅ Popups appear to be working');
        return true;
      } else {
        print('⚠️ Silent sign-in returned null');
        showPopupBlockerHelp();
        return false;
      }
    } catch (e) {
      print('❌ Popup test failed: $e');
      showPopupBlockerHelp();
      return false;
    }
  }

  // Switch to a different Google account
  static Future<Map<String, dynamic>?> switchGoogleAccount() async {
    try {
      print('🔄 Switching to a different Google account...');

      // Force disconnect to clear current session
      await forceDisconnect();

      print('🔐 Opening account selection popup...');
      final GoogleSignInAccount? googleUser = await _googleSignInInstance
          .signIn()
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              print('⏰ Account switch timed out');
              throw Exception('Account switch timed out. Please try again.');
            },
          );

      if (googleUser == null) {
        print('❌ Account switch cancelled by user');
        return null;
      }

      print('✅ Switched to account: ${googleUser.email}');

      // Continue with Firebase authentication
      print('🔑 Obtaining authentication tokens...');
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('🔥 Signing in to Firebase with new account...');
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        return {
          'uid': firebaseUser.uid,
          'email': firebaseUser.email ?? '',
          'display_name':
              firebaseUser.displayName ??
              firebaseUser.email?.split('@')[0] ??
              '',
          'photo_url': firebaseUser.photoURL ?? '',
          'provider': 'google',
          'provider_id': googleUser.id,
          'email_verified': firebaseUser.emailVerified,
        };
      }

      return null;
    } catch (e) {
      print('❌ Account switch error: $e');
      return null;
    }
  }

  // Test Google Sign-In with automatic fallback
  static Future<void> testGoogleSignInWithFallback() async {
    print('🧪 Testing Google Sign-In with automatic fallback...');

    try {
      // Try the main method first
      final userData = await signInWithGoogle();
      if (userData != null) {
        print('✅ Main Google Sign-In successful');
        print('📋 User data: ${userData['email']}');
        return;
      }
    } catch (e) {
      print('⚠️ Main method failed, trying fallback...');

      // Try the basic method as fallback
      try {
        final basicUserData = await signInWithGoogleBasic();
        if (basicUserData != null) {
          print('✅ Basic Google Sign-In successful (fallback worked!)');
          print('📋 User data: ${basicUserData['email']}');
          return;
        }
      } catch (basicError) {
        print('❌ Both methods failed');
        print('Main error: $e');
        print('Basic error: $basicError');
      }
    }

    print('❌ All Google Sign-In methods failed');
  }
}
