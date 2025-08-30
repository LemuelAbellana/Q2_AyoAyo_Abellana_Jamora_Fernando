import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '/widgets/diagnosis/image_upload_placeholder.dart';

class DiagnosisForm extends StatelessWidget {
  final VoidCallback onDiagnose;
  const DiagnosisForm({super.key, required this.onDiagnose});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "1. Start with a Lifecycle Diagnosis",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Let our AI give your device a quick health check-up.",
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Device Model (e.g., iPhone 13)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Expanded(child: ImageUploadPlaceholder(label: "Front")),
                SizedBox(width: 16),
                Expanded(child: ImageUploadPlaceholder(label: "Back")),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(LucideIcons.scanLine),
                label: const Text('Get Initial Estimate'),
                onPressed: onDiagnose,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
