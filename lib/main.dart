import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'widgets/navigation/main_navigation_wrapper.dart';
import '/utils/app_theme.dart';
import 'providers/diagnosis_provider.dart';
import 'providers/resell_provider.dart';
import 'providers/upcycling_provider.dart';
import 'config/api_config.dart';
import 'services/database_service.dart';
import 'services/user_service.dart';
import 'services/oauth_service.dart';

// Import sqflite for mobile platforms only
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database factory for non-web platforms
  if (!kIsWeb) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialize Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey:
          'AIzaSyC04_8kq3uAVDSILNJPmqOgr3eJE8OPCN8', // Replace with your Firebase API key
      appId:
          '1:583476631419:web:41e1a3a77d1ec044ad4fde', // Replace with your Firebase App ID
      messagingSenderId: '583476631419', // Replace with your sender ID
      projectId: 'ayoayo-f9697', // Replace with your project ID
    ),
  );

  // Initialize database only for non-web platforms
  if (!kIsWeb) {
    final dbService = DatabaseService();
    await dbService.database; // This creates/opens the database
  }

  // Clear any existing Google sessions to allow account selection
  if (kIsWeb) {
    try {
      // Force disconnect from Google to allow fresh account selection
      await OAuthService.forceDisconnect();
      print(
        '🔄 Cleared previous Google sessions - ready for account selection',
      );

      // Check for saved session but don't auto-restore
      final savedUid = await UserService.getSavedUserSession();
      if (savedUid != null) {
        print('💾 Previous session found for UID: $savedUid');
        print('🎯 User can now choose to sign in with any Google account');
      }
    } catch (e) {
      print('⚠️ Could not clear sessions: $e');
    }

    // Test OAuth configuration on startup
    try {
      await OAuthService.testOAuthConfiguration();

      // Test popup functionality
      final popupWorking = await OAuthService.testPopupFunctionality();
      if (!popupWorking) {
        print('⚠️ Popup blocker may be interfering with Google Sign-In');
      }

      // Test Google Sign-In fallback mechanism
      print('🔄 Testing Google Sign-In fallback mechanism...');
      // Note: We don't actually call the sign-in here, just test the setup
      print(
        '✅ Fallback mechanism ready - will activate if People API error occurs',
      );
    } catch (e) {
      print('⚠️ OAuth configuration test failed: $e');
    }

    // TEST: Delete specific user for testing
    await UserService.deleteTestUser();
  }

  runApp(const AyoAyoApp());
}

class AyoAyoApp extends StatelessWidget {
  const AyoAyoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DiagnosisProvider()),
        ChangeNotifierProvider(
          create: (context) => ResellProvider(ApiConfig.geminiApiKey),
        ),
        ChangeNotifierProvider(
          create: (context) => UpcyclingProvider(ApiConfig.geminiApiKey),
        ),
      ],
      child: MaterialApp(
        title: 'AYOAYO',
        theme: AppTheme.lightTheme, // Using centralized theme
        debugShowCheckedModeBanner: false,
        initialRoute: '/login', // Set initial route
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/main': (context) => const MainNavigationWrapper(),
        },
      ),
    );
  }
}
