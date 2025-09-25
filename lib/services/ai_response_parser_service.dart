import 'dart:convert';
import 'package:ayoayo/models/device_diagnosis.dart';
import 'package:ayoayo/services/device_specifications_service.dart';

class AIResponseParserService {
  Future<DiagnosisResult> parseAIResponse(
    String response,
    String deviceModel,
    List<String> imageUrls,
    DeviceSpecification? deviceSpecs,
  ) async {
    try {
      // Clean the response to extract JSON
      String jsonString = response.trim();

      // Remove markdown code blocks if present
      if (jsonString.startsWith('```')) {
        jsonString = jsonString.replaceAll(RegExp(r'```[json]*\n?'), '');
        jsonString = jsonString.replaceAll(RegExp(r'\n```'), '');
      }

      final parsedJson = jsonDecode(jsonString);

      // Check if parsedJson is null or not a Map
      if (parsedJson == null || parsedJson is! Map<String, dynamic>) {
        throw FormatException(
          'Invalid JSON response: expected Map<String, dynamic>, got ${parsedJson.runtimeType}',
        );
      }

      parsedJson['deviceModel'] = deviceModel;
      parsedJson['imageUrls'] = imageUrls; // Add imageUrls to the parsed JSON
      if (deviceSpecs != null) {
        parsedJson['deviceSpecifications'] = deviceSpecs.toJson();
      }

      return DiagnosisResult.fromJson(parsedJson);
    } catch (e) {
      // If parsing fails, return a fallback response
      print('❌ Failed to parse AI response: $e');
      return await _generateFallbackResponse(deviceModel, imageUrls);
    }
  }

  Future<DiagnosisResult> _generateFallbackResponse(
    String deviceModel,
    List<String> imageUrls,
  ) async {
    // Generate a basic fallback response
    final fallbackData = {
      'deviceModel': deviceModel,
      'imageUrls': imageUrls,
      'deviceHealth': {
        'screenCondition': 'unknown',
        'hardwareCondition': 'unknown',
        'identifiedIssues': ['unable_to_analyze'],
        'lifeCycleStage': 'unknown',
        'remainingUsefulLife': 'unknown',
        'environmentalImpact': 'unknown'
      },
      'valueEstimation': {
        'currentValue': 0.0,
        'postRepairValue': 0.0,
        'partsValue': 0.0,
        'repairCost': 0.0,
        'recyclingValue': 0.0,
        'currency': '₱',
        'marketPositioning': 'unknown',
        'depreciationRate': 'unknown'
      },
      'lifeCycleAnalysis': {
        'manufacturingQuality': 'unknown',
        'usageIntensity': 'unknown',
        'maintenanceHistory': 'unknown',
        'failureProbability': 'unknown',
        'sustainabilityScore': 0.0,
        'carbonFootprint': 'unknown'
      },
      'recommendations': [
        {
          'title': 'Manual Assessment Required',
          'description': 'Unable to perform automated analysis. Manual inspection recommended.',
          'type': 'assessment',
          'priority': 1.0,
          'costBenefitRatio': 0.0,
          'environmentalImpact': 'neutral',
          'timeframe': 'immediate'
        }
      ],
      'aiAnalysis': 'Unable to complete automated analysis. Fallback response generated.',
      'confidenceScore': 0.0,
      'analysisTimestamp': DateTime.now().toIso8601String(),
      'recommendationRationale': 'Fallback response due to analysis failure'
    };

    return DiagnosisResult.fromJson(fallbackData);
  }
}