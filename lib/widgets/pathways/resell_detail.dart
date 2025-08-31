import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:ayoayo/models/device_diagnosis.dart';

class ResellDetail extends StatelessWidget {
  final DiagnosisResult? diagnosisResult; // AI diagnostics result

  const ResellDetail({super.key, this.diagnosisResult});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              "Resell Your Device",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              diagnosisResult != null
                  ? "Based on our AI diagnosis, your device is in ${diagnosisResult!.deviceHealth.screenCondition.name} condition with ${diagnosisResult!.deviceHealth.batteryHealth.toStringAsFixed(0)}% battery health. Estimated resell value: \${diagnosisResult!.valueEstimation.currentValue.toStringAsFixed(2)}."
                  : "Get an estimated value for your device and find the best platforms to resell it.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(LucideIcons.tag),
              label: const Text('Start Resell Process'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                // Placeholder for resell logic
                print('Resell button pressed');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Resell feature coming soon!'),
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