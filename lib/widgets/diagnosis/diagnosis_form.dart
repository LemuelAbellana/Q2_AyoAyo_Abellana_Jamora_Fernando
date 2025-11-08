import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';
import '/widgets/diagnosis/image_upload_placeholder.dart';
import '/providers/diagnosis_provider.dart';
import '/services/camera_device_recognition_service.dart';

class DiagnosisForm extends StatefulWidget {
  const DiagnosisForm({super.key});

  @override
  State<DiagnosisForm> createState() => _DiagnosisFormState();
}

class _DiagnosisFormState extends State<DiagnosisForm> {
  final TextEditingController _deviceConditionController =
      TextEditingController();
  String? _identifiedDevice;
  String? _identifiedSpecs;

  @override
  void dispose() {
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

            // AI Device Identification Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.camera_alt, color: Colors.purple.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'AI Device Scanner',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upload photos of your device and our AI will automatically identify the model and specifications',
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                  if (_identifiedDevice != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
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
                              Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Device Identified: $_identifiedDevice',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                          if (_identifiedSpecs != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _identifiedSpecs!,
                              style: TextStyle(color: Colors.grey[700], fontSize: 12),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
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
              label: 'Upload Device Images for AI Scanning',
              onImagesSelected: (imageFiles) {
                context.read<DiagnosisProvider>().setSelectedImages(imageFiles);
                _performDeviceIdentification(imageFiles);
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

  void _performDeviceIdentification(List<File> imageFiles) async {
    if (imageFiles.isEmpty) return;

    // Show loading state
    if (mounted) {
      setState(() {
        _identifiedDevice = 'Analyzing...';
        _identifiedSpecs = null;
      });
    }

    try {
      // Use real AI service for device recognition
      final recognitionService = CameraDeviceRecognitionService();
      final result = imageFiles.length == 1
          ? await recognitionService.recognizeDeviceFromImage(imageFiles.first)
          : await recognitionService.recognizeDeviceFromImages(imageFiles);

      if (mounted) {
        setState(() {
          _identifiedDevice = result.deviceModel;
          _identifiedSpecs = 'Brand: ${result.manufacturer} • Confidence: ${(result.confidence * 100).toStringAsFixed(0)}% • ${result.operatingSystem}';
        });

        // Set the AI-identified device model in the provider
        context.read<DiagnosisProvider>().setDeviceModel(result.deviceModel);
      }
    } catch (e) {
      // Handle identification error
      if (mounted) {
        setState(() {
          _identifiedDevice = 'Unable to identify device';
          _identifiedSpecs = 'Error: ${e.toString()}';
        });
      }
    }
  }
}
