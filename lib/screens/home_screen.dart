import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '/widgets/diagnosis/diagnosis_flow_container.dart';
import '/widgets/home/about_section.dart';
import '/widgets/home/community_hub.dart';
import '/widgets/home/hero_section.dart';
import 'package:ayoayo/screens/device_passport_form_screen.dart';
import 'package:ayoayo/screens/technician_finder_screen.dart';
import 'package:ayoayo/widgets/shared/app_footer.dart';

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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'technician_finder',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TechnicianFinderScreen(),
                ),
              );
            },
            tooltip: 'Find Technicians',
            child: const Icon(LucideIcons.search),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'add_device',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DevicePassportFormScreen(),
                ),
              );
            },
            tooltip: 'Add Device',
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
