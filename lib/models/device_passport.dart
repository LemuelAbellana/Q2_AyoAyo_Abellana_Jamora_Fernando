import 'package:flutter/material.dart';
import '/models/device_diagnosis.dart';

class DevicePassport {
  final String deviceModel;
  final String manufacturer;
  final int yearOfRelease;
  final String operatingSystem;
  final DiagnosisResult lastDiagnosis;

  DevicePassport({
    required this.deviceModel,
    required this.manufacturer,
    required this.yearOfRelease,
    required this.operatingSystem,
    required this.lastDiagnosis,
  });

  // Add methods to display the passport data in a user-friendly format
  Widget buildPassport(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Device Passport',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16.0),
            _buildPassportRow('Device Model', deviceModel),
            _buildPassportRow('Manufacturer', manufacturer),
            _buildPassportRow('Year of Release', yearOfRelease.toString()),
            _buildPassportRow('Operating System', operatingSystem),
          ],
        ),
      ),
    );
  }

  Widget _buildPassportRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
