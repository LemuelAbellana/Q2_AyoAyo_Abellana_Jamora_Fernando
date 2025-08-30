import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '/widgets/diagnosis/diagnosis_flow_container.dart';
import '/widgets/home/about_section.dart';
import '/widgets/home/community_hub.dart';
import '/widgets/home/hero_section.dart';
import '/widgets/shared/app_footer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // A GlobalKey is used to identify the diagnosis widget for scrolling.
  final GlobalKey _diagnoseKey = GlobalKey();

  void _scrollToDiagnose() {
    if (_diagnoseKey.currentContext != null) {
      Scrollable.ensureVisible(
        _diagnoseKey.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Ayo',
                style: TextStyle(color: Colors.green),
              ),
              TextSpan(
                text: 'Ayo',
                style: TextStyle(color: Colors.blue),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.logOut),
            tooltip: 'Sign Out',
            onPressed: () {
              // Navigate using named routes
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            HeroSection(onDiagnosePressed: _scrollToDiagnose),
            DiagnosisFlowContainer(diagnoseKey: _diagnoseKey),
            const CommunityHub(),
            const AboutSection(),
            const AppFooter(),
          ],
        ),
      ),
    );
  }
}
