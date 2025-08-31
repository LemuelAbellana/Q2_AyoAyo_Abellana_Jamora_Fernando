import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:ayoayo/models/device_diagnosis.dart';

class UpcycleDetail extends StatelessWidget {
  final DiagnosisResult? diagnosisResult; // AI diagnostics result

  const UpcycleDetail({super.key, this.diagnosisResult});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.orange[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              "Upcycle Your Device",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              diagnosisResult != null
                  ? "Based on our AI diagnosis, your device is in ${diagnosisResult!.deviceHealth.screenCondition.name} condition with ${diagnosisResult!.deviceHealth.batteryHealth.toStringAsFixed(0)}% battery health. We can suggest upcycling ideas based on its components and identified issues: ${diagnosisResult!.deviceHealth.identifiedIssues.join(', ')}."
                  : "Transform your old device into something new and exciting. We provide ideas and resources for upcycling your device.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(LucideIcons.recycle),
              label: const Text('Start Upcycle Process'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                // Placeholder for upcycle logic
                print('Upcycle button pressed');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Upcycle feature coming soon!'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}