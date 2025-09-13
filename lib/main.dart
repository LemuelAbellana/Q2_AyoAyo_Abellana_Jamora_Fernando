import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:firebase_core/firebase_core.dart'; // Temporarily commented out
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'widgets/navigation/main_navigation_wrapper.dart';
import '/utils/app_theme.dart';
import 'providers/diagnosis_provider.dart';
import 'providers/resell_provider.dart';
import 'providers/upcycling_provider.dart';
import 'config/api_config.dart';
// import 'services/database_service.dart'; // Temporarily commented out

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (temporarily commented out for basic app display)
  // await Firebase.initializeApp(
  //   options: const FirebaseOptions(
  //     apiKey:
  //         'AIzaSyC04_8kq3uAVDSILNJPmqOgr3eJE8OPCN8', // Replace with your Firebase API key
  //     appId:
  //         '1:583476631419:web:41e1a3a77d1ec044ad4fde', // Replace with your Firebase App ID
  //     messagingSenderId: '583476631419', // Replace with your sender ID
  //     projectId: 'ayoayo-f9697', // Replace with your project ID
  //     authDomain:
  //         'localhost:8080', // Required for Firebase Auth on web (matches dev server port)
  //   ),
  // );

  // Initialize SQLite database (temporarily commented out for basic display)
  // final dbService = DatabaseService();
  // await dbService.database; // This creates/opens the database

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
