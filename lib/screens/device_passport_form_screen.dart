import 'dart:io';
import 'package:flutter/material.dart';
import 'package:ayoayo/models/device_passport.dart';
import 'package:ayoayo/models/device_diagnosis.dart';
import 'package:ayoayo/screens/device_passport_screen.dart';
import 'package:ayoayo/services/gemini_diagnosis_service.dart';
import 'package:ayoayo/widgets/diagnosis/device_passport_form.dart';

class DevicePassportFormScreen extends StatefulWidget {
  const DevicePassportFormScreen({super.key});

  @override
  State<DevicePassportFormScreen> createState() =>
      DevicePassportFormScreenState();
}

class DevicePassportFormScreenState extends State<DevicePassportFormScreen> {
  final _geminiDiagnosisService = GeminiDiagnosisService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Device Passport')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: DevicePassportForm(
            onSubmit:
                (
                  String deviceModel,
                  String manufacturer,
                  int yearOfRelease,
                  List<File> imageFiles,
                ) async {
                  final diagnosis = DeviceDiagnosis(
                    deviceModel: deviceModel,
                    images: imageFiles,
                  );

                  final diagnosisResult = await _geminiDiagnosisService
                      .diagnoseMobileDevice(diagnosis);

                  final passport = DevicePassport(
                    id: 'device_${DateTime.now().millisecondsSinceEpoch}',
                    userId: 'user_1', // In real app, get from auth
                    deviceModel: deviceModel,
                    manufacturer: manufacturer,
                    yearOfRelease: yearOfRelease,
                    operatingSystem: 'Unknown',
                    imageUrls: diagnosisResult
                        .imageUrls, // Use imageUrls from DiagnosisResult
                    lastDiagnosis: diagnosisResult,
                  );

                  if (!context.mounted)
                    return; // Check if widget is still mounted

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DevicePassportScreen(passport: passport),
                    ),
                  );
                },
          ),
        ),
      ),
    );
  }
}
