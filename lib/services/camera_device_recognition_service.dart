import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:ayoayo/config/api_config.dart';
import 'package:ayoayo/services/database_service.dart';
import 'package:ayoayo/services/api_service.dart';

class DeviceRecognitionResult {
  final String deviceModel;
  final String manufacturer;
  final int? yearOfRelease;
  final String operatingSystem;
  final double confidence;
  final String analysisDetails;

  DeviceRecognitionResult({
    required this.deviceModel,
    required this.manufacturer,
    this.yearOfRelease,
    required this.operatingSystem,
    required this.confidence,
    required this.analysisDetails,
  });

  factory DeviceRecognitionResult.fromJson(Map<String, dynamic> json) {
    return DeviceRecognitionResult(
      deviceModel: json['deviceModel'] ?? 'Unknown',
      manufacturer: json['manufacturer'] ?? 'Unknown',
      yearOfRelease: json['yearOfRelease'],
      operatingSystem: json['operatingSystem'] ?? 'Unknown',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      analysisDetails: json['analysisDetails'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceModel': deviceModel,
      'manufacturer': manufacturer,
      'yearOfRelease': yearOfRelease,
      'operatingSystem': operatingSystem,
      'confidence': confidence,
      'analysisDetails': analysisDetails,
    };
  }
}

class CameraDeviceRecognitionService {
  late final String _apiKey;
  late final GenerativeModel _model;
  final DatabaseService _databaseService = DatabaseService();

  CameraDeviceRecognitionService() {
    _apiKey = ApiConfig.geminiApiKey;
    _model = GenerativeModel(
      model: 'gemini-2.0-flash-exp',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.1,
        topK: 32,
        topP: 1.0,
        maxOutputTokens: 2048,
      ),
    );

    if (ApiConfig.isGeminiConfigured) {
      print('✅ Camera Recognition: Gemini 2.0 Flash ready');
    } else {
      print('🎭 Camera Recognition: Demo mode (add API key to enable)');
    }
  }

  Future<DeviceRecognitionResult> recognizeDeviceFromImage(
    File imageFile,
  ) async {
    if (!ApiConfig.isGeminiConfigured) {
      print('📱 Demo mode - Add API key to .env for device recognition');
      return _generateDemoRecognitionResult();
    }

    try {
      final bytes = await imageFile.readAsBytes();

      final prompt = _buildDeviceRecognitionPrompt();

      final response = await _model.generateContent([
        Content.multi([TextPart(prompt), DataPart('image/jpeg', bytes)]),
      ]);

      final analysisText = response.text ?? '';
      return _parseRecognitionResponse(analysisText);
    } catch (e) {
      print('Error recognizing device: $e');
      return _generateFallbackResult(e.toString());
    }
  }

  Future<DeviceRecognitionResult> recognizeDeviceFromImages(
    List<File> imageFiles,
  ) async {
    if (imageFiles.isEmpty) {
      throw ArgumentError('No images provided for device recognition');
    }

    if (!ApiConfig.isGeminiConfigured) {
      print(
        '📱 Demo mode - Add API key to .env for multiple image recognition',
      );
      return _generateDemoRecognitionResult();
    }

    try {
      final prompt = _buildMultiImageRecognitionPrompt();
      final contentParts = <Part>[TextPart(prompt)];

      for (final imageFile in imageFiles.take(4)) {
        final bytes = await imageFile.readAsBytes();
        contentParts.add(DataPart('image/jpeg', bytes));
      }

      final response = await _model.generateContent([
        Content.multi(contentParts),
      ]);

      final analysisText = response.text ?? '';
      return _parseRecognitionResponse(analysisText);
    } catch (e) {
      print('Error recognizing device from multiple images: $e');
      return _generateFallbackResult(e.toString());
    }
  }

  String _buildDeviceRecognitionPrompt() {
    return '''
Analyze this mobile device image and provide detailed device identification information.

Please identify:
1. Device manufacturer (Apple, Samsung, Xiaomi, Huawei, OnePlus, Google, etc.)
2. Exact device model (iPhone 14 Pro, Galaxy S23, etc.)
3. Year of release (if determinable)
4. Operating system (iOS, Android)
5. Confidence level (0.0 to 1.0)

Focus on:
- Logo placement and design
- Camera module arrangement and count
- Physical button placement
- Screen bezels and notch/hole-punch design
- Overall form factor and dimensions
- Color and material finish
- Any visible model text or markings

Please respond in this exact JSON format:
{
  "deviceModel": "exact model name",
  "manufacturer": "manufacturer name",
  "yearOfRelease": 2023,
  "operatingSystem": "iOS or Android",
  "confidence": 0.95,
  "analysisDetails": "detailed explanation of how you identified this device, mentioning specific visual cues and distinguishing features"
}

Be as specific as possible with the model name and provide a confidence score based on how certain you are of the identification.
''';
  }

  String _buildMultiImageRecognitionPrompt() {
    return '''
Analyze these mobile device images from different angles to provide comprehensive device identification.

Using all the provided images, identify:
1. Device manufacturer (Apple, Samsung, Xiaomi, Huawei, OnePlus, Google, etc.)
2. Exact device model (iPhone 14 Pro, Galaxy S23, etc.)
3. Year of release (if determinable)
4. Operating system (iOS, Android)
5. Confidence level (0.0 to 1.0)

Cross-reference details from all images including:
- Front view: screen design, notch/hole-punch, bezels
- Back view: camera module, logo, materials, color
- Side views: button placement, port locations
- Any visible text, model numbers, or regulatory markings

Please respond in this exact JSON format:
{
  "deviceModel": "exact model name",
  "manufacturer": "manufacturer name",
  "yearOfRelease": 2023,
  "operatingSystem": "iOS or Android",
  "confidence": 0.95,
  "analysisDetails": "detailed explanation combining observations from all images, mentioning specific visual cues from different angles that led to this identification"
}

Use multiple images to increase accuracy and confidence in identification.
''';
  }

  DeviceRecognitionResult _parseRecognitionResponse(String response) {
    try {
      final cleanResponse = response
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final jsonStart = cleanResponse.indexOf('{');
      final jsonEnd = cleanResponse.lastIndexOf('}') + 1;

      if (jsonStart != -1 && jsonEnd > jsonStart) {
        final jsonString = cleanResponse.substring(jsonStart, jsonEnd);
        final Map<String, dynamic> jsonData = {};

        final lines = jsonString.split('\n');
        for (final line in lines) {
          if (line.contains(':')) {
            final parts = line.split(':');
            if (parts.length >= 2) {
              final key = parts[0].replaceAll(RegExp(r'["{}\s]'), '');
              final value = parts
                  .sublist(1)
                  .join(':')
                  .replaceAll(RegExp(r'[",\s]*$'), '')
                  .replaceAll(RegExp(r'^[\s"]*'), '');

              if (key.isNotEmpty) {
                switch (key) {
                  case 'yearOfRelease':
                    jsonData[key] = int.tryParse(
                      value.replaceAll(RegExp(r'\D'), ''),
                    );
                    break;
                  case 'confidence':
                    jsonData[key] = double.tryParse(value) ?? 0.7;
                    break;
                  default:
                    jsonData[key] = value;
                }
              }
            }
          }
        }

        return DeviceRecognitionResult.fromJson(jsonData);
      }

      return _extractInfoFromText(response);
    } catch (e) {
      print('Error parsing recognition response: $e');
      return _extractInfoFromText(response);
    }
  }

  DeviceRecognitionResult _extractInfoFromText(String text) {
    final lowerText = text.toLowerCase();

    String manufacturer = 'Unknown';
    String deviceModel = 'Unknown Device';
    String operatingSystem = 'Unknown';
    int? yearOfRelease;

    final manufacturers = {
      'apple': 'Apple',
      'iphone': 'Apple',
      'samsung': 'Samsung',
      'galaxy': 'Samsung',
      'xiaomi': 'Xiaomi',
      'redmi': 'Xiaomi',
      'huawei': 'Huawei',
      'oneplus': 'OnePlus',
      'google': 'Google',
      'pixel': 'Google',
      'oppo': 'OPPO',
      'vivo': 'Vivo',
      'realme': 'Realme',
    };

    for (final entry in manufacturers.entries) {
      if (lowerText.contains(entry.key)) {
        manufacturer = entry.value;
        break;
      }
    }

    if (lowerText.contains('iphone')) {
      operatingSystem = 'iOS';
      final iPhoneModels = [
        'iphone 15 pro max',
        'iphone 15 pro',
        'iphone 15 plus',
        'iphone 15',
        'iphone 14 pro max',
        'iphone 14 pro',
        'iphone 14 plus',
        'iphone 14',
        'iphone 13 pro max',
        'iphone 13 pro',
        'iphone 13 mini',
        'iphone 13',
        'iphone 12 pro max',
        'iphone 12 pro',
        'iphone 12 mini',
        'iphone 12',
      ];

      for (final model in iPhoneModels) {
        if (lowerText.contains(model)) {
          deviceModel = model
              .split(' ')
              .map((word) => word[0].toUpperCase() + word.substring(1))
              .join(' ');
          break;
        }
      }
    } else if (lowerText.contains('galaxy') || lowerText.contains('samsung')) {
      operatingSystem = 'Android';
      final galaxyModels = [
        's24 ultra',
        's24 plus',
        's24',
        's23 ultra',
        's23 plus',
        's23',
        's22 ultra',
        's22 plus',
        's22',
        'note 20 ultra',
        'note 20',
        'a54',
        'a34',
        'a24',
        'a14',
      ];

      for (final model in galaxyModels) {
        if (lowerText.contains(model)) {
          deviceModel = 'Galaxy ${model.toUpperCase()}';
          break;
        }
      }
    } else {
      operatingSystem = 'Android';
    }

    final yearMatches = RegExp(r'\b20(1[5-9]|2[0-4])\b').allMatches(text);
    if (yearMatches.isNotEmpty) {
      yearOfRelease = int.parse(yearMatches.first.group(0)!);
    }

    return DeviceRecognitionResult(
      deviceModel: deviceModel,
      manufacturer: manufacturer,
      yearOfRelease: yearOfRelease,
      operatingSystem: operatingSystem,
      confidence: 0.6,
      analysisDetails: 'Extracted from text analysis: $text',
    );
  }

  DeviceRecognitionResult _generateDemoRecognitionResult() {
    final demoDevices = [
      DeviceRecognitionResult(
        deviceModel: 'iPhone 14 Pro',
        manufacturer: 'Apple',
        yearOfRelease: 2022,
        operatingSystem: 'iOS',
        confidence: 0.92,
        analysisDetails:
            'Demo mode: Identified by distinctive triple camera system with LiDAR, Dynamic Island, and premium build quality typical of iPhone Pro models.',
      ),
      DeviceRecognitionResult(
        deviceModel: 'Galaxy S23 Ultra',
        manufacturer: 'Samsung',
        yearOfRelease: 2023,
        operatingSystem: 'Android',
        confidence: 0.88,
        analysisDetails:
            'Demo mode: Recognized by large camera bump with multiple sensors, S Pen integration, and Samsung branding.',
      ),
      DeviceRecognitionResult(
        deviceModel: 'Xiaomi 13 Pro',
        manufacturer: 'Xiaomi',
        yearOfRelease: 2023,
        operatingSystem: 'Android',
        confidence: 0.85,
        analysisDetails:
            'Demo mode: Identified by Leica camera branding, distinctive rear design, and premium materials.',
      ),
    ];

    return demoDevices[DateTime.now().millisecond % demoDevices.length];
  }

  DeviceRecognitionResult _generateFallbackResult(String error) {
    return DeviceRecognitionResult(
      deviceModel: 'Unknown Device',
      manufacturer: 'Unknown',
      yearOfRelease: null,
      operatingSystem: 'Unknown',
      confidence: 0.1,
      analysisDetails:
          'Recognition failed: $error. Manual identification may be required.',
    );
  }

  Future<String> saveRecognizedDevice(
    DeviceRecognitionResult result,
    String userId,
    List<String> imageUrls,
  ) async {
    try {
      // Use backend API if enabled and user is authenticated
      if (ApiConfig.useBackendApi && ApiService.isAuthenticated) {
        print('💾 Saving device to backend API');

        try {
          final response = await ApiService.saveRecognizedDevice(
            userId: userId,
            deviceModel: result.deviceModel,
            manufacturer: result.manufacturer,
            yearOfRelease: result.yearOfRelease,
            operatingSystem: result.operatingSystem,
            confidence: result.confidence,
            analysisDetails: result.analysisDetails,
            imageUrls: imageUrls,
          );

          final devicePassportId = response['devicePassportId']?.toString();
          if (devicePassportId != null) {
            print('✅ Device saved to backend: $devicePassportId');
            return devicePassportId;
          }
        } catch (e) {
          print('⚠️ Backend save failed, falling back to local storage: $e');
          // Fall through to local save
        }
      }

      // Local SQLite storage (original implementation)
      print('💾 Saving device to local storage');
      final devicePassportData = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'userId': userId,
        'deviceModel': result.deviceModel,
        'manufacturer': result.manufacturer,
        'yearOfRelease': result.yearOfRelease ?? DateTime.now().year,
        'operatingSystem': result.operatingSystem,
        'imageUrls': imageUrls,
        'lastDiagnosis': {
          'aiAnalysis': result.analysisDetails,
          'confidenceScore': result.confidence,
          'deviceHealth': {
            'screenCondition': 'unknown',
            'hardwareCondition': 'unknown',
            'identifiedIssues': [],
            'lifeCycleStage': 'assessment_needed',
            'remainingUsefulLife': 'unknown',
            'environmentalImpact': 'unknown',
          },
          'valueEstimation': {
            'currentValue': _estimateBaseValue(
              result.manufacturer,
              result.deviceModel,
            ),
            'postRepairValue':
                _estimateBaseValue(result.manufacturer, result.deviceModel) *
                1.2,
            'partsValue':
                _estimateBaseValue(result.manufacturer, result.deviceModel) *
                0.4,
            'repairCost': 2000.0,
            'recyclingValue': 500.0,
            'currency': '₱',
            'marketPositioning': 'needs_assessment',
            'depreciationRate': 'standard',
          },
          'recommendations': [
            {
              'title': 'Complete Device Assessment',
              'description':
                  'Schedule a comprehensive diagnosis to determine the exact condition and value of your ${result.manufacturer} ${result.deviceModel}.',
              'type': 'assessment',
              'priority': 0.9,
              'costBenefitRatio': 1.5,
              'environmentalImpact': 'positive',
              'timeframe': 'immediate',
            },
          ],
          'analysisTimestamp': DateTime.now().toIso8601String(),
        },
      };

      await _databaseService.saveWebDevicePassports([devicePassportData]);
      print('✅ Device saved to local storage: ${devicePassportData['id']}');

      return devicePassportData['id'].toString();
    } catch (e) {
      print('❌ Error saving recognized device: $e');
      rethrow;
    }
  }

  double _estimateBaseValue(String manufacturer, String deviceModel) {
    final model = deviceModel.toLowerCase();

    if (manufacturer == 'Apple') {
      if (model.contains('pro max')) return 65000.0;
      if (model.contains('pro')) return 55000.0;
      if (model.contains('plus')) return 45000.0;
      if (model.contains('15')) return 40000.0;
      if (model.contains('14')) return 35000.0;
      if (model.contains('13')) return 30000.0;
      return 25000.0;
    }

    if (manufacturer == 'Samsung') {
      if (model.contains('ultra')) return 50000.0;
      if (model.contains('plus')) return 35000.0;
      if (model.contains('s24') || model.contains('s23')) return 30000.0;
      if (model.contains('note')) return 35000.0;
      if (model.contains('a5') || model.contains('a7')) return 15000.0;
      return 20000.0;
    }

    if (manufacturer == 'Xiaomi') {
      if (model.contains('pro')) return 25000.0;
      if (model.contains('ultra')) return 30000.0;
      return 18000.0;
    }

    return 15000.0;
  }

  Future<bool> validateApiKey() async {
    if (!ApiConfig.isGeminiConfigured) {
      print('⚠️ No API key configured - using demo mode');
      return false;
    }

    try {
      final testResponse = await _model
          .generateContent([Content.text('Test')])
          .timeout(const Duration(seconds: 10));
      print('✅ Gemini 2.0 Flash API validated for camera recognition');
      return testResponse.text != null;
    } catch (e) {
      print('❌ API validation failed: $e');
      return false;
    }
  }
}
