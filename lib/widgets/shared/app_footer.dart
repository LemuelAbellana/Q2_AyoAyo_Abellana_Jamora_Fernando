import 'package:flutter/material.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.grey[800],
      child: const Center(
        child: Text(
          "© 2025 AyoAyo. Made with ❤️ in Davao City.",
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}
