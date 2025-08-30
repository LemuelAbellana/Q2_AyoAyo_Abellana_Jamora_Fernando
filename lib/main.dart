import 'package:flutter/material.dart';
import '/screens/home_screen.dart';
import '/screens/login_screen.dart';
import '/utils/app_theme.dart';

void main() {
  runApp(const MaayoPasaApp());
}

class MaayoPasaApp extends StatelessWidget {
  const MaayoPasaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MaayoPasa',
      theme: AppTheme.lightTheme, // Using centralized theme
      debugShowCheckedModeBanner: false,
      initialRoute: '/login', // Set initial route
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
