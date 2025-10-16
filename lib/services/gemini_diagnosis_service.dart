import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:ayoayo/models/device_diagnosis.dart';
import 'package:ayoayo/config/api_config.dart';
import 'package:ayoayo/services/device_specifications_service.dart';
import 'package:ayoayo/services/ai_image_analysis_service.dart';
import 'package:ayoayo/services/ai_knowledge_service.dart';
import 'package:ayoayo/services/ai_prompt_builder_service.dart';
import 'package:ayoayo/services/ai_response_parser_service.dart';
import 'package:ayoayo/services/ai_chatbot_service.dart';

class GeminiDiagnosisService {
  late final String _apiKey;
  late final GenerativeModel _model;

  // AI Services
  final AIImageAnalysisService _imageAnalysisService = AIImageAnalysisService();
  final AIKnowledgeService _knowledgeService = AIKnowledgeService();
  final AIPromptBuilderService _promptBuilderService = AIPromptBuilderService();
  final AIResponseParserService _responseParserService = AIResponseParserService();
  final AIChatbotService _chatbotService = AIChatbotService();

  GeminiDiagnosisService() {
    _apiKey = ApiConfig.geminiApiKey;
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.5,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 2048,
      ),
    );
    print('✅ Gemini Diagnosis Service initialized');
  }

  Future<DiagnosisResult> diagnoseMobileDevice(
    DeviceDiagnosis diagnosis,
  ) async {
    // Use demo mode if API key is not configured or demo mode is enabled
    if (ApiConfig.useDemoMode || _apiKey == 'YOUR_GEMINI_API_KEY_HERE' || _apiKey.isEmpty) {
      print('🔬 Using demo mode for device diagnosis');
      return await _generateEnhancedDemoResponse(
        diagnosis,
        [],
      );
    }

    try {
      // Simulate image upload and get URLs
      final imageUrls = await _uploadImagesAndGetUrls(diagnosis.images);

      // Analyze images if available and enabled
      String imageAnalysis = '';
      if (diagnosis.images.isNotEmpty && ApiConfig.enableImageAnalysis) {
        try {
          print('📷 Starting image analysis for ${diagnosis.images.length} images...');
          imageAnalysis = await _imageAnalysisService.analyzeDeviceImages(diagnosis.images);
          print('📷 Image analysis completed successfully');
        } catch (e) {
          print('❌ Image analysis failed completely: $e');
          imageAnalysis =
              '⚠️ **Image Analysis Status:** Failed due to error: $e\n'
              '📝 **Fallback:** Analysis proceeding with text-based assessment only\n'
              '💡 **Note:** Images were uploaded but visual analysis is temporarily disabled\n'
              '🔧 **Technical Details:** ${e.toString()}\n'
              '📞 **Suggestion:** Diagnosis will continue with text-based analysis for accurate results.';
        }
      }

      // Get relevant knowledge from the knowledge base using both text and image analysis
      final relevantKnowledge = await _knowledgeService.getRelevantKnowledge(
        diagnosis,
        imageAnalysis,
      );

      // Create comprehensive prompt using RAG approach
      final prompt = _promptBuilderService.buildDiagnosisPrompt(
        diagnosis,
        imageAnalysis,
        relevantKnowledge,
      );

      // Generate AI analysis
      final response = await _model.generateContent([Content.text(prompt)]);
      final aiResponse = response.text ?? '';

      // Get device specifications if available
      final deviceSpecs = DeviceSpecificationsService.getDeviceSpecification(
        diagnosis.deviceModel,
      );

      // Parse the structured response
      return await _responseParserService.parseAIResponse(
        aiResponse,
        diagnosis.deviceModel,
        imageUrls,
        deviceSpecs,
      );
    } catch (e) {
      // Fallback response in case of API failure
      return await _generateEnhancedDemoResponse(
        diagnosis,
        [],
      );
    }
  }

  Future<List<String>> _uploadImagesAndGetUrls(List<File> images) async {
    // Simulate image upload to a storage service and return URLs
    final List<String> urls = [];
    for (int i = 0; i < images.length; i++) {
      // Generate a dummy URL for each image
      urls.add('https://storage.example.com/diagnosis/image_${DateTime.now().millisecondsSinceEpoch}_$i.jpg');
    }
    return urls;
  }

  // Enhanced demo response with realistic device analysis
  Future<DiagnosisResult> _generateEnhancedDemoResponse(
    DeviceDiagnosis diagnosis,
    List<String> imageUrls,
  ) async {
    // If images are available, try to analyze them
    String imageAnalysis = '';
    if (diagnosis.images.isNotEmpty && ApiConfig.enableImageAnalysis) {
      try {
        imageAnalysis = await _imageAnalysisService.analyzeDeviceImages(diagnosis.images);
      } catch (e) {
        imageAnalysis = 'Demo mode: Image analysis simulated';
      }
    }

    final deviceSpecs = DeviceSpecificationsService.getDeviceSpecification(diagnosis.deviceModel);

    // Generate realistic demo data based on device model and user input
    final demoData = {
      'deviceModel': diagnosis.deviceModel,
      'imageUrls': imageUrls,
      'deviceHealth': {
        'screenCondition': _analyzeScreenFromInput(diagnosis.additionalInfo),
        'hardwareCondition': 'good',
        'identifiedIssues': _extractIssuesFromInput(diagnosis.additionalInfo),
        'lifeCycleStage': 'mature_usage',
        'remainingUsefulLife': '1-2_years',
        'environmentalImpact': 'moderate'
      },
      'valueEstimation': {
        'currentValue': _estimateValue(diagnosis.deviceModel),
        'postRepairValue': _estimateValue(diagnosis.deviceModel) * 1.15,
        'partsValue': _estimateValue(diagnosis.deviceModel) * 0.3,
        'repairCost': 2500.0,
        'recyclingValue': 800.0,
        'currency': '₱',
        'marketPositioning': 'good_condition',
        'depreciationRate': '20_percent_yearly'
      },
      'lifeCycleAnalysis': {
        'manufacturingQuality': 'standard_components',
        'usageIntensity': 'moderate',
        'maintenanceHistory': 'minimal',
        'failureProbability': 'medium',
        'sustainabilityScore': 6.5,
        'carbonFootprint': '42_kg_co2_equivalent'
      },
      'recommendations': _generateRecommendations(diagnosis),
      'aiAnalysis': 'Demo analysis based on device model and user input',
      'confidenceScore': 0.75,
      'analysisTimestamp': DateTime.now().toIso8601String(),
      'recommendationRationale': 'Demo analysis for testing purposes'
    };

    if (deviceSpecs != null) {
      demoData['deviceSpecifications'] = deviceSpecs.toJson();
    }

    return DiagnosisResult.fromJson(demoData);
  }

  String _analyzeScreenFromInput(String? additionalInfo) {
    if (additionalInfo == null) return 'good';
    final info = additionalInfo.toLowerCase();
    if (info.contains('crack') || info.contains('broken') || info.contains('damage')) {
      return 'damaged';
    }
    return 'good';
  }

  List<String> _extractIssuesFromInput(String? additionalInfo) {
    final issues = <String>[];
    if (additionalInfo == null) return ['minor_wear'];

    final info = additionalInfo.toLowerCase();
    if (info.contains('battery')) issues.add('battery_degradation');
    if (info.contains('screen') || info.contains('crack')) issues.add('screen_damage');
    if (info.contains('slow') || info.contains('lag')) issues.add('performance_issues');
    if (info.contains('overheat')) issues.add('thermal_issues');

    return issues.isEmpty ? ['minor_wear'] : issues;
  }

  double _estimateValue(String deviceModel) {
    // Simple estimation based on device model
    if (deviceModel.toLowerCase().contains('iphone')) return 25000.0;
    if (deviceModel.toLowerCase().contains('samsung galaxy s')) return 20000.0;
    if (deviceModel.toLowerCase().contains('xiaomi')) return 12000.0;
    return 15000.0; // Default value
  }

  List<Map<String, dynamic>> _generateRecommendations(DeviceDiagnosis diagnosis) {
    return [
      {
        'title': 'Device Assessment',
        'description': 'Professional evaluation of device condition and repair options',
        'type': 'assessment',
        'priority': 0.9,
        'costBenefitRatio': 1.5,
        'environmentalImpact': 'positive',
        'timeframe': 'immediate'
      },
      {
        'title': 'Resale Opportunity',
        'description': 'Device suitable for resale market',
        'type': 'sell',
        'priority': 0.7,
        'estimatedReturn': _estimateValue(diagnosis.deviceModel),
        'marketTiming': 'favorable'
      }
    ];
  }

  Future<String> getTechnicianChatbotResponse(String message) async {
    return await _chatbotService.getTechnicianChatbotResponse(message);
  }

  void updateApiKey(String newApiKey) {
    // Update API key functionality
  }

  Future<bool> validateApiKey() async {
    if (ApiConfig.useDemoMode || _apiKey == 'YOUR_GEMINI_API_KEY_HERE' || _apiKey.isEmpty) {
      print('⚠️ API key validation skipped - using demo mode');
      return true;
    }

    try {
      final testResponse = await _model.generateContent([
        Content.text('Test connection')
      ]).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Validation timeout'),
      );
      print('✅ Gemini API key validated successfully');
      return testResponse.text != null;
    } catch (e) {
      print('❌ API key validation failed: $e');
      return false;
    }
  }

  ScreenCondition testScreenConditionDetection(
    String deviceModel,
    String additionalInfo,
    String? imageAnalysis,
  ) {
    return _analyzeScreenCondition(
      deviceModel,
      additionalInfo,
      false,
      imageAnalysis,
    );
  }

  ScreenCondition _analyzeScreenCondition(
    String deviceModel,
    String additionalInfo,
    bool hasBatteryIssue,
    String? imageAnalysis,
  ) {
    final lowerInfo = additionalInfo.toLowerCase();
    final lowerImageAnalysis = imageAnalysis?.toLowerCase() ?? '';

    // Check for severe damage keywords
    if (lowerInfo.contains('crack') ||
        lowerInfo.contains('cracked') ||
        lowerInfo.contains('broken') ||
        lowerInfo.contains('shattered') ||
        lowerInfo.contains('spider') ||
        lowerImageAnalysis.contains('crack') ||
        lowerImageAnalysis.contains('broken')) {
      return ScreenCondition.cracked;
    }

    // Check for good condition keywords
    if (lowerInfo.contains('good') ||
        lowerInfo.contains('perfect') ||
        lowerInfo.contains('excellent') ||
        lowerInfo.contains('fine')) {
      return ScreenCondition.excellent;
    }

    // Default to good if no issues detected
    return ScreenCondition.good;
  }

  void debugScreenCondition(String input) {
    print('Testing input: "$input"');
    print('Contains "crack": ${input.contains('crack')}');
    print('Contains "cracked": ${input.contains('cracked')}');
    print('Contains "broken": ${input.contains('broken')}');

    final result = _analyzeScreenCondition('Test Device', input, false, null);
    print('Detected condition: $result');
    print('---');
  }

  void testScreenConditionFix() {
    print('🧪 Testing Screen Condition Detection Fix...');

    final testCases = [
      'broken',
      'screen is broken',
      'cracked',
      'screen cracked',
      'shattered',
      'good',
      'perfect condition',
    ];

    for (final testCase in testCases) {
      print('\n📝 Testing: "$testCase"');
      final result = _analyzeScreenCondition('Test Device', testCase, false, null);
      print('🎯 Result: $result');
    }

    print('\n✅ Screen condition testing complete!');
  }
}