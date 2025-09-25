import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'widgets/navigation/main_navigation_wrapper.dart';
import 'utils/app_theme.dart';
import 'providers/diagnosis_provider.dart';
import 'providers/resell_provider.dart';
import 'providers/upcycling_provider.dart';
import 'providers/donation_provider.dart';
import 'providers/device_provider.dart';
import 'config/api_config.dart';
import 'services/database_service.dart';

// Import sqflite for database
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('✅ App starting without Firebase - using simple Google Sign-In');

  // Initialize database factory for mobile platforms only
  if (!kIsWeb) {
    try {
      print('✅ Using native SQLite database');
    } catch (e) {
      print('⚠️ Database initialization failed: $e');
    }
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
        ChangeNotifierProvider(create: (context) => DonationProvider()),
        ChangeNotifierProvider(create: (context) => DeviceProvider()),
      ],
      child: MaterialApp(
        title: 'AYOAYO',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const AppInitializer(), // Use a custom initializer
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/main': (context) => const MainNavigationWrapper(),
        },
        onGenerateRoute: (settings) {
          // Handle dynamic routes with proper navigation state
          if (settings.name == '/resell') {
            return MaterialPageRoute(
              builder: (context) => const MainNavigationWrapper(initialIndex: 1),
              settings: settings,
            );
          }
          if (settings.name == '/upcycle') {
            return MaterialPageRoute(
              builder: (context) => const MainNavigationWrapper(initialIndex: 2),
              settings: settings,
            );
          }
          return null;
        },
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;
  String _initializationStatus = 'Starting app...';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Add timeout to prevent hanging
      await Future.any([
        _performInitialization(),
        Future.delayed(const Duration(seconds: 10)), // 10 second timeout
      ]);
    } catch (e) {
      print('⚠️ App initialization failed: $e');
    } finally {
      // Always navigate to login screen
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  Future<void> _performInitialization() async {
    setState(() {
      _initializationStatus = 'Initializing database...';
    });

    // Initialize database only for non-web platforms with timeout
    if (!kIsWeb) {
      try {
        await Future.any([
          DatabaseService().database,
          Future.delayed(const Duration(seconds: 5)), // 5 second timeout
        ]);
        print('✅ Database initialized successfully');
      } catch (e) {
        print('⚠️ Database initialization failed or timed out: $e');
        // Continue without database - app should still work with reduced functionality
      }
    }

    setState(() {
      _initializationStatus = 'Loading application...';
    });

    // Add a small delay to show the loading state
    await Future.delayed(const Duration(milliseconds: 1000));

    setState(() {
      _isInitialized = true;
      _initializationStatus = 'Ready!';
    });

    // Small delay before navigation
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.phone_android,
                size: 60,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(height: 32),

            // App Name
            Text(
              'AYOAYO',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),

            const SizedBox(height: 16),

            // Tagline
            Text(
              'Mobile Device Life Cycle Platform',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 48),

            // Loading indicator
            const CircularProgressIndicator(),

            const SizedBox(height: 16),

            // Status text
            Text(
              _initializationStatus,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
