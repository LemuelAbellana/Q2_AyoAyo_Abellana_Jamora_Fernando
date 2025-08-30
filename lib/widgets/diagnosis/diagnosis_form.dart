import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';
import '/widgets/diagnosis/image_upload_placeholder.dart';
import '/providers/diagnosis_provider.dart';

class DiagnosisForm extends StatefulWidget {
  final VoidCallback onDiagnose;
  const DiagnosisForm({super.key, required this.onDiagnose});

  @override
  State<DiagnosisForm> createState() => _DiagnosisFormState();
}

class _DiagnosisFormState extends State<DiagnosisForm> {
  final TextEditingController _deviceModelController = TextEditingController();
  final TextEditingController _additionalInfoController =
      TextEditingController();

  @override
  void dispose() {
    _deviceModelController.dispose();
    _additionalInfoController.dispose();
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
            const Text(
              "1. Start with a Lifecycle Diagnosis",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Let our AI give your device a comprehensive health check-up using advanced image analysis.",
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _deviceModelController,
              decoration: const InputDecoration(
                labelText: 'Device Model (e.g., iPhone 13)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.smartphone),
              ),
              onChanged: (value) {
                context.read<DiagnosisProvider>().setDeviceModel(value);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _additionalInfoController,
              decoration: const InputDecoration(
                labelText: 'Additional Information (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.info_outline),
                hintText: 'Describe any issues or concerns...',
              ),
              maxLines: 3,
              onChanged: (value) {
                context.read<DiagnosisProvider>().setAdditionalInfo(value);
              },
            ),
            const SizedBox(height: 16),
            Consumer<DiagnosisProvider>(
              builder: (context, provider, child) {
                final images = provider.selectedImages;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Device Images (Optional but recommended)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: (images.length < 3)
                            ? images.length + 1
                            : images.length,
                        itemBuilder: (context, index) {
                          if (index < images.length) {
                            return Container(
                              width: 120,
                              margin: const EdgeInsets.only(right: 16),
                              child: ImageUploadPlaceholder(
                                label: 'Image ${index + 1}',
                                selectedImage: images[index],
                                imageBytes: index < provider.imageBytes.length
                                    ? provider.imageBytes[index]
                                    : null,
                              ),
                            );
                          } else {
                            return Container(
                              width: 120,
                              margin: const EdgeInsets.only(right: 16),
                              child: const ImageUploadPlaceholder(
                                label: 'Add Image',
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                );
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
                            if (provider.currentResult != null) {
                              widget.onDiagnose();
                            }
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
