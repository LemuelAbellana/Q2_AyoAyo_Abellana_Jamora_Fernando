import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ayoayo/models/device_passport.dart';
import 'package:ayoayo/models/device_diagnosis.dart';
import 'package:ayoayo/services/gemini_diagnosis_service.dart';
import 'package:ayoayo/widgets/diagnosis/device_passport_form.dart';
import 'package:ayoayo/providers/device_provider.dart';

class DevicePassportFormScreen extends StatefulWidget {
  const DevicePassportFormScreen({super.key});

  @override
  State<DevicePassportFormScreen> createState() =>
      DevicePassportFormScreenState();
}

class DevicePassportFormScreenState extends State<DevicePassportFormScreen> {
  final _geminiDiagnosisService = GeminiDiagnosisService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Device Passport')),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: DevicePassportForm(
                onSubmit: _handleSubmit,
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Creating device passport...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit(
    String deviceModel,
    String manufacturer,
    int yearOfRelease,
    List<File> imageFiles,
  ) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Run diagnosis
      final diagnosis = DeviceDiagnosis(
        deviceModel: deviceModel,
        images: imageFiles,
      );

      final diagnosisResult = await _geminiDiagnosisService
          .diagnoseMobileDevice(diagnosis);

      // Create passport
      final passport = DevicePassport(
        id: 'device_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'user_1', // In real app, get from auth
        deviceModel: deviceModel,
        manufacturer: manufacturer,
        yearOfRelease: yearOfRelease,
        operatingSystem: 'Unknown',
        imageUrls: diagnosisResult.imageUrls,
        lastDiagnosis: diagnosisResult,
      );

      if (!mounted) return;

      // Save to database via provider
      await context.read<DeviceProvider>().addDevice(passport);

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$deviceModel added successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back and indicate success
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create device passport: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
