import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment variables
  try {
    await dotenv.load(fileName: ".env");
    print('✅ Environment variables loaded successfully');
  } catch (e) {
    print('⚠️ Failed to load .env file: $e');
    print('⚠️ Using default configuration values');
  }

  print('✅ App starting with Google Sign-In and Laravel backend');

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
  String _initializationStatus = 'Starting app...';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    setState(() {
      _initializationStatus = 'Initializing...';
    });

    // Add a small delay to show splash screen
    await Future.delayed(const Duration(milliseconds: 1000));

    setState(() {
      _initializationStatus = 'Ready!';
    });

    // Navigate to login screen
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
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
