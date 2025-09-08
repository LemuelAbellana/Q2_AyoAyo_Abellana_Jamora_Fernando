import 'package:flutter/material.dart';
import '/widgets/diagnosis/diagnosis_flow_container.dart';
import '/widgets/home/about_section.dart';
import '/widgets/home/community_hub.dart';
import '/widgets/home/hero_section.dart';
import 'package:ayoayo/screens/device_passport_form_screen.dart';
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DevicePassportFormScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
