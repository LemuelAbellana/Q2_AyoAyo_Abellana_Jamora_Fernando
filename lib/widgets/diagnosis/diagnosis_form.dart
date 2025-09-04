import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';
import '/widgets/diagnosis/image_upload_placeholder.dart';
import '/providers/diagnosis_provider.dart';

class DiagnosisForm extends StatefulWidget {
  const DiagnosisForm({super.key});

  @override
  State<DiagnosisForm> createState() => _DiagnosisFormState();
}

class _DiagnosisFormState extends State<DiagnosisForm> {
  final TextEditingController _deviceModelController = TextEditingController();
  final TextEditingController _manufacturerController = TextEditingController();
  final TextEditingController _yearOfReleaseController =
      TextEditingController();
  final TextEditingController _operatingSystemController =
      TextEditingController();
  final TextEditingController _deviceConditionController =
      TextEditingController();

  @override
  void dispose() {
    _deviceModelController.dispose();
    _manufacturerController.dispose();
    _yearOfReleaseController.dispose();
    _operatingSystemController.dispose();
    _deviceConditionController.dispose();
    super.dispose();
  }

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
            Row(
              children: [
                const Icon(Icons.eco, color: Colors.green, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "1. Start with a Life Cycle Diagnosis",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.science, color: Colors.green.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Advanced AI Life Cycle Assessment',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Our AI analyzes your device\'s entire lifecycle from manufacturing to current condition, providing comprehensive insights for repair, resale, or recycling decisions.',
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green.shade600,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Multi-modal analysis (visual + data)',
                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green.shade600,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Life cycle intelligence & market insights',
                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green.shade600,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Sustainable e-waste solutions',
                        style: TextStyle(color: Colors.grey[700], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Device Passport Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.assignment, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text(
                        'Device Passport',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create a comprehensive device profile for accurate diagnosis',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Device Information Fields
            TextField(
              controller: _deviceModelController,
              decoration: const InputDecoration(
                labelText: 'Device Model *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.smartphone),
                hintText: 'e.g., iPhone 13, Samsung Galaxy S22',
              ),
              onChanged: (value) {
                context.read<DiagnosisProvider>().setDeviceModel(value);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _manufacturerController,
              decoration: const InputDecoration(
                labelText: 'Manufacturer',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.factory),
                hintText: 'e.g., Apple, Samsung, Xiaomi',
              ),
              onChanged: (value) {
                context.read<DiagnosisProvider>().setManufacturer(value);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _yearOfReleaseController,
              decoration: const InputDecoration(
                labelText: 'Year of Release',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.calendar_today),
                hintText: 'e.g., 2022',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                context.read<DiagnosisProvider>().setYearOfRelease(value);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _operatingSystemController,
              decoration: const InputDecoration(
                labelText: 'Operating System',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.android),
                hintText: 'e.g., iOS 16, Android 13',
              ),
              onChanged: (value) {
                context.read<DiagnosisProvider>().setOperatingSystem(value);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _deviceConditionController,
              decoration: const InputDecoration(
                labelText: 'Current Condition (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.health_and_safety),
                hintText: 'Describe device condition, issues, or concerns...',
              ),
              maxLines: 3,
              onChanged: (value) {
                context.read<DiagnosisProvider>().setAdditionalInfo(value);
              },
            ),
            const SizedBox(height: 16),
            ImageUploadPlaceholder(
              label: 'Upload Device Images',
              onImagesSelected: (imageFiles) {
                context.read<DiagnosisProvider>().setSelectedImages(imageFiles);
              },
            ),
            const SizedBox(height: 24),
            Consumer<DiagnosisProvider>(
              builder: (context, provider, child) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: provider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(LucideIcons.scanLine),
                    label: Text(
                      provider.isLoading ? 'Analyzing...' : 'Get AI Diagnosis',
                    ),
                    onPressed: provider.canStartDiagnosis && !provider.isLoading
                        ? () async {
                            await provider.startDiagnosis();
                            if (provider.currentResult != null) {}
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor:
                          provider.canStartDiagnosis && !provider.isLoading
                          ? Colors.blue
                          : Colors.grey,
                    ),
                  ),
                );
              },
            ),
            Consumer<DiagnosisProvider>(
              builder: (context, provider, child) {
                if (provider.error != null) {
                  return Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade600),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            provider.error!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
