import 'package:flutter/material.dart';
import 'package:ayoayo/models/device_diagnosis.dart';

class DevicePassport {
  final String id;
  final String userId;
  final String deviceModel;
  final String manufacturer;
  final int yearOfRelease;
  final String operatingSystem;
  final List<String> imageUrls; // Changed from List<File> to List<String>
  final DiagnosisResult lastDiagnosis;

  DevicePassport({
    required this.id,
    required this.userId,
    required this.deviceModel,
    required this.manufacturer,
    required this.yearOfRelease,
    required this.operatingSystem,
    required this.imageUrls,
    required this.lastDiagnosis,
  });

  // Getter for estimated value
  double get estimatedValue => lastDiagnosis.valueEstimation.currentValue;

  // Factory constructor for creating a DevicePassport from a JSON map
  factory DevicePassport.fromJson(Map<String, dynamic> json) {
    return DevicePassport(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      deviceModel: json['deviceModel'] ?? '',
      manufacturer: json['manufacturer'] ?? '',
      yearOfRelease: json['yearOfRelease'] ?? 0,
      operatingSystem: json['operatingSystem'] ?? '',
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      lastDiagnosis: DiagnosisResult.fromJson(json['lastDiagnosis'] ?? {}),
    );
  }

  // Method for converting a DevicePassport to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'deviceModel': deviceModel,
      'manufacturer': manufacturer,
      'yearOfRelease': yearOfRelease,
      'operatingSystem': operatingSystem,
      'imageUrls': imageUrls,
      'lastDiagnosis': lastDiagnosis.toJson(),
    };
  }

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
            if (imageUrls.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8.0),
                  Text(
                    'Device Images:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8.0),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: imageUrls.length,
                      itemBuilder: (context, index) {
                        final imageUrl = imageUrls[index];
                        final isDummyUrl = imageUrl.startsWith(
                          'https://example.com/',
                        );
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: isDummyUrl
                              ? Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey,
                                  ),
                                )
                              : Image.network(
                                  imageUrl,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        width: 100,
                                        height: 100,
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.broken_image,
                                          color: Colors.grey,
                                        ),
                                      ),
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Container(
                                          width: 100,
                                          height: 100,
                                          color: Colors.grey[200],
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              value:
                                                  loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                  : null,
                                            ),
                                          ),
                                        );
                                      },
                                ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16.0),
            Text(
              'Diagnosis Summary:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8.0),
            _buildPassportRow('AI Analysis', lastDiagnosis.aiAnalysis),
            _buildPassportRow(
              'Confidence Score',
              '${(lastDiagnosis.confidenceScore * 100).toStringAsFixed(2)}%',
            ),
            _buildPassportRow(
              'Estimated Value',
              '${lastDiagnosis.valueEstimation.currency}${estimatedValue.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 16.0),
            Text(
              'Health Details:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8.0),
            _buildPassportRow(
              'Screen Condition',
              _formatScreenCondition(
                lastDiagnosis.deviceHealth.screenCondition,
              ),
            ),
            _buildPassportRow(
              'Hardware Condition',
              lastDiagnosis.deviceHealth.hardwareCondition.name,
            ),
            if (lastDiagnosis.deviceHealth.identifiedIssues.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8.0),
                  Text(
                    'Identified Issues:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  ...lastDiagnosis.deviceHealth.identifiedIssues.map(
                    (issue) => Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                      child: Text('- $issue'),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16.0),
            Text(
              'Recommended Actions:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8.0),
            ...lastDiagnosis.recommendations.map(
              (action) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${action.title} (${action.type.name})',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(action.description),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  String _formatScreenCondition(ScreenCondition condition) {
    switch (condition) {
      case ScreenCondition.excellent:
        return 'Excellent';
      case ScreenCondition.good:
        return 'Good';
      case ScreenCondition.fair:
        return 'Fair';
      case ScreenCondition.poor:
        return 'Poor';
      case ScreenCondition.cracked:
        return 'Cracked/Damaged';
      case ScreenCondition.unknown:
        return 'Unknown';
    }
  }

  Widget _buildPassportRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Flexible(child: Text(value, textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}
