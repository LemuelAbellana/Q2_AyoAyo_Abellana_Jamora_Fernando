import 'local_auth_service.dart';

class DemoAuthService {
  // Create demo Google user data (for when Google Sign-In is not configured)
  static Map<String, dynamic> createDemoGoogleUser(String email) {
    return {
      'uid': 'demo_google_${DateTime.now().millisecondsSinceEpoch}',
      'email': email,
      'display_name': email.split('@')[0],
      'photo_url': '',
      'provider': 'google_demo',
      'provider_id': email,
      'auth_provider': 'google',
      'email_verified': true,
    };
  }

  // Simulate Google Sign-In with demo account selection
  static Future<Map<String, dynamic>?> demoGoogleSignIn() async {
    try {
      print('🎭 Demo Google Sign-In - Simulating account selection...');

      // Simulate user selecting an account
      await Future.delayed(const Duration(milliseconds: 1500));

      // Use a demo email for testing
      final demoEmail = 'demo.user@gmail.com';

      print('✅ Demo Google Sign-In successful: $demoEmail');

      return createDemoGoogleUser(demoEmail);
    } catch (e) {
      print('❌ Demo Google Sign-In error: $e');
      return null;
    }
  }

  // Check if we should use demo mode
  static bool shouldUseDemoMode() {
    // For now, always use demo mode since Google Sign-In configuration is complex
    return true;
  }
}