import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import '/screens/login_screen.dart';
import '/screens/register_screen.dart';
import '/utils/app_theme.dart';
import 'providers/diagnosis_provider.dart';

void main() {
  runApp(const AyoAyoApp());
}

class AyoAyoApp extends StatelessWidget {
  const AyoAyoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => DiagnosisProvider()),
      ],
      child: MaterialApp(
        title: 'AYOAYO',
        theme: AppTheme.lightTheme, // Using centralized theme
        debugShowCheckedModeBanner: false,
        initialRoute: '/login', // Set initial route
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}
