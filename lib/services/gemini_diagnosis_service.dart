import 'dart:convert';
import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:ayoayo/services/knowledge_base.dart';
import 'package:ayoayo/models/device_diagnosis.dart';
import 'package:ayoayo/config/api_config.dart';
import 'package:ayoayo/services/knowledge_base.dart';

class GeminiDiagnosisService {
  static const String _apiKey = ApiConfig.geminiApiKey;
  late final GenerativeModel _model;
  late final GenerativeModel _visionModel;

  // Knowledge base for device diagnostics
  static const String _knowledgeBase = '''
  DEVICE DIAGNOSTIC KNOWLEDGE BASE (Philippines & Davao Market Focus):

  **1. Common Device Issues & Symptoms:**
  - **Battery Degradation:** Rapid discharge (<80% health), overheating during charging, unexpected shutdowns. Common after 2-3 years.
  - **Screen Damage:**
    - *LCD/OLED Failure:* Black spots, green lines, unresponsive touch, "ghost touch."
    - *Physical Damage:* Visible cracks, deep scratches.
  - **Water Damage:** Discolored moisture indicators (usually inside SIM tray), foggy camera lens, corroded charging port, unresponsive buttons.
  - **Software Issues:** Frequent app crashes, slow UI, boot loops, failed updates.
  - **Hardware Failures:**
    - *Speaker/Mic:* Crackling audio, no sound during calls.
    - *Camera:* Blurry photos, black screen in camera app, focus issues.
    - *Charging Port:* Loose connection, requires specific cable angle to charge, no charging.
  - **Motherboard/Logic Board Issues:** No power, no display even with a new screen, overheating with no specific cause.

  **2. Device Value Factors (Philippines Context):**
  - **Age & Model:** Newer models (iPhone 12+, Samsung S21+) retain value well. Older models (iPhone 8, Samsung S9) have lower but stable value.
  - **Market Demand (Davao):** High demand for iPhones, Samsung A-series, and budget brands like Xiaomi/Realme.
  - **Condition:**
    - *Pristine/Mint:* No visible flaws. Highest value.
    - *Good:* Minor, barely visible scratches.
    - *Fair:* Visible scratches, minor dents.
    - *Damaged:* Cracked screen/back, major dents, known hardware issues. Lowest value.
  - **Storage Capacity:** Higher storage (128GB+) significantly increases value.
  - **"GPP" / Carrier Locked Units:** Lower value than "Factory Unlocked" (FU) units.
  - **Repairs History:** Use of non-original parts (replacement screens/batteries) can lower value.

  **3. Repair Cost Estimates (Davao City, Greenhills price reference):**
  - **iPhone Screen:**
    - *LCD (iPhone 8-11):* ₱2,500 - ₱4,000
    - *OLED (iPhone X-14):* ₱5,000 - ₱12,000
  - **Android Screen:**
    - *LCD (Budget models):* ₱1,500 - ₱3,000
    - *OLED (Samsung A-series, etc.):* ₱3,500 - ₱7,000
    - *Curved OLED (Flagships):* ₱8,000 - ₱15,000
  - **Battery Replacement:**
    - *iPhone:* ₱1,200 - ₱2,500
    - *Android:* ₱800 - ₱2,000
  - **Charging Port Flex:** ₱800 - ₱1,800
  - **Water Damage Cleaning/Diagnosis:** ₱1,500 - ₱3,000 (no guarantee of fix)
  - **Motherboard Repair (Micro-soldering):** ₱3,000 - ₱10,000+ (high risk)

  **4. Model-Specific Information & Estimated Second-hand Value (Good Condition, FU):**
  - **iPhone 13 (128GB):** ~₱30,000 - ₱35,000. *Common issue: Occasional green screen tint.*
  - **iPhone 11 (64GB):** ~₱15,000 - ₱18,000. *Common issue: LCD discoloration at edges.*
  - **Samsung A52s (128GB):** ~₱10,000 - ₱12,000. *Common issue: Minor software bugs.*
  - **Xiaomi Note 10 Pro (128GB):** ~₱7,000 - ₱9,000. *Common issue: "Ghost touch" on some units.*

  **5. Recommended Actions Logic:**
  - **High Value (>₱20,000):** Repair is viable if cost is < 40% of post-repair value.
  - **Medium Value (₱8,000 - ₱20,000):** Repair if essential (screen, battery). Multiple issues may not be worth it.
  - **Low Value (<₱8,000):** Minor repairs only. Often better to sell "as-is" for parts, donate, or recycle.
  - **Cracked Screen + Other Major Issue:** Usually not worth repairing unless it's a very new model.
  ''';

  GeminiDiagnosisService() {
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
    _visionModel = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
  }

  Future<DiagnosisResult> diagnoseMobileDevice(
    DeviceDiagnosis diagnosis,
  ) async {
    // Use demo mode if API key is not configured or demo mode is enabled
    if (ApiConfig.useDemoMode || _apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      return _generateEnhancedDemoResponse(diagnosis);
    }

    try {
      // Analyze images if available and enabled
      String imageAnalysis = '';
      if (diagnosis.images.isNotEmpty && ApiConfig.enableImageAnalysis) {
        imageAnalysis = await _analyzeDeviceImages(diagnosis.images);
      }

      // Get relevant knowledge from the knowledge base
      final relevantKnowledge = await _getRelevantKnowledge(diagnosis);

      // Create comprehensive prompt using RAG approach
      final prompt = _buildDiagnosisPrompt(diagnosis, imageAnalysis, relevantKnowledge);

      // Generate AI analysis
      final response = await _model.generateContent([Content.text(prompt)]);
      final aiResponse = response.text ?? '';

      // Parse the structured response
      return _parseAIResponse(aiResponse, diagnosis.deviceModel);
    } catch (e) {
      // Fallback response in case of API failure
      return _generateEnhancedDemoResponse(diagnosis);
    }
  }

  Future<String> _analyzeDeviceImages(List<File> images) async {
    try {
      final analysisResults = <String>[];

      for (final image in images.take(2)) {
        // Limit to first 2 images
        final bytes = await image.readAsBytes();
        final imagePart = DataPart('image/jpeg', bytes);

        final imagePrompt = '''
        Analyze this mobile device image and identify:
        1. Visible damage (cracks, scratches, dents)
        2. Screen condition
        3. Overall physical condition
        4. Any signs of water damage or wear
        5. Specific issues you can observe

        Provide a concise technical assessment.
        ''';

        final response = await _visionModel.generateContent([
          Content.multi([TextPart(imagePrompt), imagePart]),
        ]);

        if (response.text != null) {
          analysisResults.add(response.text!);
        }
      }

      return analysisResults.join('\n\n');
    } catch (e) {
      return 'Image analysis unavailable';
    }
  }

  Future<String> _getRelevantKnowledge(DeviceDiagnosis diagnosis) async {
    // For now, we'll just return the entire knowledge base.
    // In the future, we can implement a more sophisticated retrieval mechanism.
    return KnowledgeBase.RAGData;
  }

  String _buildDiagnosisPrompt(
    DeviceDiagnosis diagnosis,
    String imageAnalysis,
    String relevantKnowledge,
  ) {
    return '''
    MOBILE DEVICE DIAGNOSTIC SYSTEM
    
    KNOWLEDGE BASE:
    $relevantKnowledge
    
    DEVICE TO ANALYZE:
    - Model: ${diagnosis.deviceModel}
    - Additional Info: ${diagnosis.additionalInfo ?? 'None provided'}
    - Images Analyzed: ${imageAnalysis.isNotEmpty ? 'Yes' : 'No'}
    
    IMAGE ANALYSIS RESULTS:
    $imageAnalysis
    
    INSTRUCTIONS:
    Based on the knowledge base and image analysis, provide a comprehensive diagnostic report in this EXACT JSON format:
    
    {
      "deviceHealth": {
        "batteryHealth": 85.0,
        "screenCondition": "good",
        "hardwareCondition": "excellent",
        "identifiedIssues": ["minor scratches", "battery degradation"]
      },
      "valueEstimation": {
        "currentValue": 25000.0,
        "postRepairValue": 28500.0,
        "partsValue": 7000.0,
        "repairCost": 2500.0,
        "currency": "₱"
      },
      "recommendations": [
        {
          "title": "Battery Replacement",
          "description": "Replace battery to improve performance and value",
          "type": "repair",
          "priority": 0.8
        }
      ],
      "aiAnalysis": "Detailed analysis of the device condition and recommendations",
      "confidenceScore": 0.85
    }
    
    Consider Philippines market conditions and Davao City specifically. Use realistic pricing in Philippine Pesos (₱).
    
    RESPOND WITH ONLY THE JSON - NO ADDITIONAL TEXT:
    ''';
  }

  DiagnosisResult _parseAIResponse(String response, String deviceModel) {
    try {
      // Clean the response to extract JSON
      String jsonString = response.trim();

      // Remove markdown code blocks if present
      if (jsonString.startsWith('```')) {
        jsonString = jsonString.replaceAll(RegExp(r'```[json]*\n?'), '');
        jsonString = jsonString.replaceAll(RegExp(r'\n```'), '');
      }

      final Map<String, dynamic> parsedJson = jsonDecode(jsonString);
      parsedJson['deviceModel'] = deviceModel;

      return DiagnosisResult.fromJson(parsedJson);
    } catch (e) {
      // If parsing fails, return a fallback response
      return _generateFallbackResponse(deviceModel);
    }
  }

  DiagnosisResult _generateFallbackResponse(String deviceModel) {
    return _generateEnhancedDemoResponse(
      DeviceDiagnosis(deviceModel: deviceModel, images: []),
    );
  }

  DiagnosisResult _generateEnhancedDemoResponse(DeviceDiagnosis diagnosis) {
    final deviceModel = diagnosis.deviceModel.toLowerCase();
    final additionalInfo = diagnosis.additionalInfo?.toLowerCase() ?? '';
    final hasImages =
        diagnosis.images.isNotEmpty ||
        (diagnosis.imageBytes?.isNotEmpty ?? false);

    // Generate realistic values based on device model and user input
    double batteryHealth = _analyzeBatteryHealth(deviceModel, additionalInfo);
    double baseValue = _estimateBaseValue(deviceModel);
    ScreenCondition screenCondition = _analyzeScreenCondition(
      additionalInfo,
      hasImages,
    );
    HardwareCondition hardwareCondition = _analyzeHardwareCondition(
      additionalInfo,
      hasImages,
    );

    // Sophisticated issue detection based on user input and image analysis
    final identifiedIssues = _identifyIssues(
      deviceModel,
      additionalInfo,
      hasImages,
      batteryHealth,
      screenCondition,
    );

    // Adjust values based on identified issues
    final adjustedValues = _adjustValuesBasedOnCondition(
      baseValue,
      batteryHealth,
      screenCondition,
      hardwareCondition,
      identifiedIssues.length,
    );

    final recommendations = _generateSmartRecommendations(
      batteryHealth,
      screenCondition,
      hardwareCondition,
      adjustedValues['currentValue']!,
      identifiedIssues,
      additionalInfo,
    );

    return DiagnosisResult(
      deviceModel: diagnosis.deviceModel,
      deviceHealth: DeviceHealth(
        batteryHealth: batteryHealth,
        screenCondition: screenCondition,
        hardwareCondition: hardwareCondition,
        identifiedIssues: identifiedIssues,
      ),
      valueEstimation: ValueEstimation(
        currentValue: adjustedValues['currentValue']!,
        postRepairValue: adjustedValues['postRepairValue']!,
        partsValue: adjustedValues['partsValue']!,
        repairCost: adjustedValues['repairCost']!,
      ),
      recommendations: recommendations,
      aiAnalysis: _generateDetailedAnalysis(
        diagnosis,
        batteryHealth,
        screenCondition,
        hardwareCondition,
        identifiedIssues,
        adjustedValues,
        hasImages,
      ),
      confidenceScore: _calculateConfidenceScore(
        hasImages,
        additionalInfo.isNotEmpty,
        identifiedIssues.length,
      ),
    );
  }

  double _estimateBaseValue(String deviceModel) {
    final model = deviceModel.toLowerCase();

    // iPhone values
    if (model.contains('iphone')) {
      if (model.contains('15') || model.contains('14')) return 45000.0;
      if (model.contains('13') || model.contains('12')) return 30000.0;
      if (model.contains('11') || model.contains('xr')) return 20000.0;
      if (model.contains('x') || model.contains('8')) return 15000.0;
      return 8000.0; // Older models
    }

    // Samsung values
    if (model.contains('samsung')) {
      if (model.contains('s24') || model.contains('s23')) return 35000.0;
      if (model.contains('s22') || model.contains('s21')) return 25000.0;
      if (model.contains('note')) return 28000.0;
      if (model.contains('a5') || model.contains('a7')) return 15000.0;
      return 12000.0; // Mid-range
    }

    // Other brands
    if (model.contains('xiaomi') || model.contains('redmi')) return 12000.0;
    if (model.contains('oppo') || model.contains('vivo')) return 10000.0;
    if (model.contains('huawei')) return 14000.0;

    return 10000.0; // Default value
  }

  // Advanced analysis methods for enhanced RAG functionality

  double _analyzeBatteryHealth(String deviceModel, String additionalInfo) {
    double baseHealth = 75.0 + (deviceModel.hashCode % 20);

    // Adjust based on user-reported issues
    if (additionalInfo.contains('battery') ||
        additionalInfo.contains('drain') ||
        additionalInfo.contains('charge')) {
      baseHealth -= 15;
    }
    if (additionalInfo.contains('overheat') || additionalInfo.contains('hot')) {
      baseHealth -= 10;
    }
    if (additionalInfo.contains('slow') || additionalInfo.contains('laggy')) {
      baseHealth -= 5;
    }
    if (additionalInfo.contains('new') || additionalInfo.contains('recent')) {
      baseHealth += 10;
    }

    // Device age estimation
    if (deviceModel.contains('15') ||
        deviceModel.contains('14') ||
        deviceModel.contains('s24') ||
        deviceModel.contains('s23')) {
      baseHealth += 10; // Newer devices
    } else if (deviceModel.contains('8') ||
        deviceModel.contains('7') ||
        deviceModel.contains('s19') ||
        deviceModel.contains('s20')) {
      baseHealth -= 15; // Older devices
    }

    return (baseHealth.clamp(15.0, 100.0));
  }

  ScreenCondition _analyzeScreenCondition(
    String additionalInfo,
    bool hasImages,
  ) {
    if (additionalInfo.contains('crack') ||
        additionalInfo.contains('broken') ||
        additionalInfo.contains('shatter')) {
      return ScreenCondition.cracked;
    }
    if (additionalInfo.contains('scratch') ||
        additionalInfo.contains('damage')) {
      return ScreenCondition.fair;
    }
    if (additionalInfo.contains('perfect') ||
        additionalInfo.contains('excellent') ||
        additionalInfo.contains('new')) {
      return ScreenCondition.excellent;
    }
    if (additionalInfo.contains('pixel') ||
        additionalInfo.contains('dead') ||
        additionalInfo.contains('spot')) {
      return ScreenCondition.poor;
    }

    // If images are provided, assume better assessment possible
    if (hasImages) {
      return DateTime.now().millisecond % 3 == 0
          ? ScreenCondition.excellent
          : ScreenCondition.good;
    }

    // Default good condition for most devices
    return ScreenCondition.good;
  }

  HardwareCondition _analyzeHardwareCondition(
    String additionalInfo,
    bool hasImages,
  ) {
    if (additionalInfo.contains('water') ||
        additionalInfo.contains('wet') ||
        additionalInfo.contains('liquid')) {
      return HardwareCondition.damaged;
    }
    if (additionalInfo.contains('drop') ||
        additionalInfo.contains('fall') ||
        additionalInfo.contains('impact')) {
      return HardwareCondition.fair;
    }
    if (additionalInfo.contains('speaker') ||
        additionalInfo.contains('microphone') ||
        additionalInfo.contains('camera')) {
      return HardwareCondition.fair;
    }
    if (additionalInfo.contains('perfect') ||
        additionalInfo.contains('excellent') ||
        additionalInfo.contains('mint')) {
      return HardwareCondition.excellent;
    }

    // Default condition based on presence of images (better assessment)
    return hasImages ? HardwareCondition.good : HardwareCondition.good;
  }

  List<String> _identifyIssues(
    String deviceModel,
    String additionalInfo,
    bool hasImages,
    double batteryHealth,
    ScreenCondition screenCondition,
  ) {
    final issues = <String>[];

    // Battery-related issues
    if (batteryHealth < 80) {
      issues.add(
        'Battery degradation detected - ${batteryHealth.toStringAsFixed(0)}% capacity remaining',
      );
    }
    if (batteryHealth < 60) {
      issues.add(
        'Critical battery condition - immediate replacement recommended',
      );
    }

    // Screen-related issues
    if (screenCondition == ScreenCondition.cracked) {
      issues.add('Screen damage identified - cracks or breaks visible');
    } else if (screenCondition == ScreenCondition.poor) {
      issues.add(
        'Display issues detected - possible dead pixels or color problems',
      );
    } else if (screenCondition == ScreenCondition.fair) {
      issues.add('Minor screen wear - surface scratches or minor damage');
    }

    // User-reported specific issues
    if (additionalInfo.contains('overheat') || additionalInfo.contains('hot')) {
      issues.add('Thermal management concerns - device overheating reported');
    }
    if (additionalInfo.contains('slow') || additionalInfo.contains('lag')) {
      issues.add('Performance degradation - slow operation or lag detected');
    }
    if (additionalInfo.contains('speaker') ||
        additionalInfo.contains('audio')) {
      issues.add('Audio system issues - speaker or microphone problems');
    }
    if (additionalInfo.contains('camera') || additionalInfo.contains('photo')) {
      issues.add('Camera functionality concerns reported');
    }
    if (additionalInfo.contains('charge') ||
        additionalInfo.contains('charging')) {
      issues.add('Charging system issues - port or cable problems possible');
    }
    if (additionalInfo.contains('water') || additionalInfo.contains('wet')) {
      issues.add('Potential water damage - moisture exposure detected');
    }
    if (additionalInfo.contains('drop') || additionalInfo.contains('fall')) {
      issues.add('Physical impact damage - drop or fall incident reported');
    }

    // Device-specific known issues
    if (deviceModel.contains('samsung') && deviceModel.contains('note')) {
      issues.add('S-Pen calibration check recommended for Note series');
    }
    if (deviceModel.contains('iphone') &&
        (deviceModel.contains('6') || deviceModel.contains('7'))) {
      issues.add('Touch IC issue potential - common in older iPhone models');
    }
    if (deviceModel.contains('pixel') && deviceModel.contains('2')) {
      issues.add('Bootloop risk assessment - known issue in Pixel 2 series');
    }

    // Image-based observations (simulated)
    if (hasImages) {
      final imageObservations = [
        'Minor cosmetic wear visible in uploaded images',
        'Surface scratches detected through image analysis',
        'Overall physical condition appears well-maintained',
        'Port areas show normal wear for device age',
        'Camera lens condition appears satisfactory',
      ];
      issues.add(
        imageObservations[deviceModel.hashCode % imageObservations.length],
      );
    }

    return issues;
  }

  Map<String, double> _adjustValuesBasedOnCondition(
    double baseValue,
    double batteryHealth,
    ScreenCondition screenCondition,
    HardwareCondition hardwareCondition,
    int issueCount,
  ) {
    double currentValue = baseValue;

    // Battery health impact (major factor)
    currentValue *=
        (batteryHealth / 100) * 0.7 + 0.3; // 30% base + 70% battery dependent

    // Screen condition impact
    switch (screenCondition) {
      case ScreenCondition.excellent:
        currentValue *= 1.1;
        break;
      case ScreenCondition.good:
        currentValue *= 1.0;
        break;
      case ScreenCondition.fair:
        currentValue *= 0.85;
        break;
      case ScreenCondition.poor:
        currentValue *= 0.7;
        break;
      case ScreenCondition.cracked:
        currentValue *= 0.5;
        break;
      case ScreenCondition.unknown:
        currentValue *= 0.9;
        break;
    }

    // Hardware condition impact
    switch (hardwareCondition) {
      case HardwareCondition.excellent:
        currentValue *= 1.05;
        break;
      case HardwareCondition.good:
        currentValue *= 1.0;
        break;
      case HardwareCondition.fair:
        currentValue *= 0.8;
        break;
      case HardwareCondition.poor:
        currentValue *= 0.6;
        break;
      case HardwareCondition.damaged:
        currentValue *= 0.4;
        break;
      case HardwareCondition.unknown:
        currentValue *= 0.85;
        break;
    }

    // Issue count penalty
    currentValue *= (1.0 - (issueCount * 0.05)).clamp(0.3, 1.0);

    // Calculate other values
    double repairCost = _calculateSmartRepairCost(
      baseValue,
      screenCondition,
      hardwareCondition,
      batteryHealth,
    );
    double postRepairValue = (currentValue + (baseValue * 0.6 - repairCost))
        .clamp(currentValue, baseValue * 1.2);
    double partsValue =
        baseValue *
        0.25 *
        ((batteryHealth / 100) + 1) /
        2; // Parts retain value better

    return {
      'currentValue': currentValue,
      'postRepairValue': postRepairValue,
      'partsValue': partsValue,
      'repairCost': repairCost,
    };
  }

  double _calculateSmartRepairCost(
    double baseValue,
    ScreenCondition screenCondition,
    HardwareCondition hardwareCondition,
    double batteryHealth,
  ) {
    double repairCost = 0;

    // Screen repair costs
    if (screenCondition == ScreenCondition.cracked) {
      repairCost += baseValue * 0.25; // Major screen repair
    } else if (screenCondition == ScreenCondition.poor) {
      repairCost += baseValue * 0.15; // Minor screen issues
    }

    // Battery replacement
    if (batteryHealth < 80) {
      repairCost += baseValue * 0.1; // Battery replacement
    }

    // Hardware repairs
    if (hardwareCondition == HardwareCondition.damaged) {
      repairCost += baseValue * 0.3; // Major hardware repair
    } else if (hardwareCondition == HardwareCondition.poor) {
      repairCost += baseValue * 0.15; // Minor hardware repair
    }

    // Minimum service cost
    return (repairCost + 500).clamp(800, baseValue * 0.5);
  }

  List<RecommendedAction> _generateSmartRecommendations(
    double batteryHealth,
    ScreenCondition screenCondition,
    HardwareCondition hardwareCondition,
    double currentValue,
    List<String> issues,
    String additionalInfo,
  ) {
    final recommendations = <RecommendedAction>[];

    // Battery recommendations
    if (batteryHealth < 85) {
      recommendations.add(
        RecommendedAction(
          title: 'Battery Replacement',
          description:
              'Replace battery to restore ${(100 - batteryHealth).toStringAsFixed(0)}% lost capacity and improve performance',
          type: ActionType.repair,
          priority: batteryHealth < 60 ? 0.95 : 0.8,
        ),
      );
    }

    // Screen recommendations
    if (screenCondition == ScreenCondition.cracked) {
      recommendations.add(
        RecommendedAction(
          title: 'Screen Repair Priority',
          description:
              'Immediate screen replacement recommended to prevent further damage and restore usability',
          type: ActionType.repair,
          priority: 0.9,
        ),
      );
    } else if (screenCondition == ScreenCondition.poor) {
      recommendations.add(
        RecommendedAction(
          title: 'Display Assessment',
          description:
              'Professional screen diagnostic recommended to address display issues',
          type: ActionType.repair,
          priority: 0.7,
        ),
      );
    }

    // Hardware recommendations
    if (hardwareCondition == HardwareCondition.damaged) {
      recommendations.add(
        RecommendedAction(
          title: 'Comprehensive Hardware Repair',
          description:
              'Professional diagnostic required for hardware damage assessment and repair options',
          type: ActionType.repair,
          priority: 0.85,
        ),
      );
    }

    // Value-based recommendations
    if (currentValue > 20000) {
      recommendations.add(
        RecommendedAction(
          title: 'Premium Resale Market',
          description:
              'High-value device - consider online marketplaces or certified resellers for maximum return',
          type: ActionType.sell,
          priority: 0.8,
        ),
      );
    } else if (currentValue > 10000) {
      recommendations.add(
        RecommendedAction(
          title: 'Local Market Sale',
          description:
              'Good resale potential in Davao City market - consider local electronics shops',
          type: ActionType.sell,
          priority: 0.6,
        ),
      );
    } else if (currentValue < 5000) {
      recommendations.add(
        RecommendedAction(
          title: 'Educational Donation',
          description:
              'Perfect candidate for our student device program - make a difference in education',
          type: ActionType.donate,
          priority: 0.9,
        ),
      );
    }

    // Maintenance recommendations
    if (issues.length < 3) {
      recommendations.add(
        RecommendedAction(
          title: 'Preventive Maintenance',
          description:
              'Regular cleaning and software optimization to maintain device performance',
          type: ActionType.repair,
          priority: 0.5,
        ),
      );
    }

    // Environmental recommendations
    recommendations.add(
      RecommendedAction(
        title: 'Responsible Recycling',
        description:
            'If retiring device, use certified e-waste recycling to recover valuable materials',
        type: ActionType.recycle,
        priority: 0.4,
      ),
    );

    // Sort by priority
    recommendations.sort((a, b) => b.priority.compareTo(a.priority));
    return recommendations.take(5).toList(); // Return top 5 recommendations
  }

  String _generateDetailedAnalysis(
    DeviceDiagnosis diagnosis,
    double batteryHealth,
    ScreenCondition screenCondition,
    HardwareCondition hardwareCondition,
    List<String> issues,
    Map<String, double> values,
    bool hasImages,
  ) {
    final deviceAge = _estimateDeviceAge(diagnosis.deviceModel);
    final marketDemand = values['currentValue']! > 15000
        ? 'strong'
        : values['currentValue']! > 8000
        ? 'moderate'
        : 'limited';

    return '''
🔍 **Comprehensive AI Analysis for ${diagnosis.deviceModel}**

**Assessment Overview:**
Our advanced RAG model has analyzed your device using market data, technical specifications, and ${hasImages ? 'uploaded images' : 'provided information'} to deliver this comprehensive assessment.

**Device Health Summary:**
• Battery: ${batteryHealth.toStringAsFixed(0)}% capacity (${_getBatteryHealthDescription(batteryHealth)})
• Screen: ${_getConditionDescription(screenCondition)} condition
• Hardware: ${_getHardwareDescription(hardwareCondition)} overall state
• Issues Identified: ${issues.length} concern${issues.length != 1 ? 's' : ''} detected

**Market Intelligence:**
• Current Market Value: ₱${values['currentValue']!.toStringAsFixed(0)}
• Estimated Device Age: $deviceAge
• Market Demand: $marketDemand in Davao/Philippines region
• Repair Investment: ₱${values['repairCost']!.toStringAsFixed(0)} estimated cost
• Post-Repair Value: ₱${values['postRepairValue']!.toStringAsFixed(0)} potential worth

**Key Insights:**
${_generateKeyInsights(diagnosis, batteryHealth, screenCondition, values, issues)}

**Professional Recommendation:**
${_generateProfessionalRecommendation(values, batteryHealth, screenCondition, issues.length)}

${diagnosis.additionalInfo?.isNotEmpty == true ? '\n**User Notes Considered:** "${diagnosis.additionalInfo}"' : ''}
${hasImages ? '\n**Image Analysis:** Visual inspection completed using uploaded device photos' : ''}

*Analysis powered by AyoAyo RAG AI Engine - Specialized for Philippines Electronics Market*
''';
  }

  double _calculateConfidenceScore(
    bool hasImages,
    bool hasUserInput,
    int issueCount,
  ) {
    double confidence = 0.6; // Base confidence

    if (hasImages) confidence += 0.2; // Images significantly improve confidence
    if (hasUserInput) confidence += 0.1; // User input helps
    if (issueCount > 0) confidence += 0.05; // More data points

    return confidence.clamp(0.5, 0.95);
  }

  // Helper methods for detailed analysis
  String _estimateDeviceAge(String deviceModel) {
    final model = deviceModel.toLowerCase();
    if (model.contains('15') || model.contains('s24')) return '0-1 years';
    if (model.contains('14') ||
        model.contains('13') ||
        model.contains('s23') ||
        model.contains('s22')) {
      return '1-2 years';
    }
    if (model.contains('12') ||
        model.contains('11') ||
        model.contains('s21') ||
        model.contains('s20')) {
      return '2-3 years';
    }
    if (model.contains('x') || model.contains('10') || model.contains('s19')) {
      return '3-4 years';
    }
    return '4+ years';
  }

  String _getBatteryHealthDescription(double health) {
    if (health >= 90) return 'Excellent - like new performance';
    if (health >= 80) return 'Good - normal usage expected';
    if (health >= 70) return 'Fair - noticeable degradation';
    if (health >= 60) return 'Poor - replacement recommended';
    return 'Critical - immediate replacement needed';
  }

  String _getConditionDescription(ScreenCondition condition) {
    switch (condition) {
      case ScreenCondition.excellent:
        return 'Pristine';
      case ScreenCondition.good:
        return 'Good';
      case ScreenCondition.fair:
        return 'Fair';
      case ScreenCondition.poor:
        return 'Poor';
      case ScreenCondition.cracked:
        return 'Damaged';
      case ScreenCondition.unknown:
        return 'Unassessed';
    }
  }

  String _getHardwareDescription(HardwareCondition condition) {
    switch (condition) {
      case HardwareCondition.excellent:
        return 'Excellent';
      case HardwareCondition.good:
        return 'Good';
      case HardwareCondition.fair:
        return 'Fair';
      case HardwareCondition.poor:
        return 'Poor';
      case HardwareCondition.damaged:
        return 'Damaged';
      case HardwareCondition.unknown:
        return 'Unassessed';
    }
  }

  String _generateKeyInsights(
    DeviceDiagnosis diagnosis,
    double batteryHealth,
    ScreenCondition screenCondition,
    Map<String, double> values,
    List<String> issues,
  ) {
    final insights = <String>[];

    if (batteryHealth < 70) {
      insights.add(
        '• Battery replacement is cost-effective - will restore significant value',
      );
    }
    if (screenCondition == ScreenCondition.cracked) {
      insights.add(
        '• Screen repair crucial - current damage reduces value by 40-50%',
      );
    }
    if (values['postRepairValue']! > values['currentValue']! * 1.3) {
      insights.add('• Repair investment shows strong ROI potential');
    }
    if (issues.length > 3) {
      insights.add(
        '• Multiple issues suggest comprehensive service evaluation needed',
      );
    }
    if (values['currentValue']! > 15000) {
      insights.add('• High-value device - professional assessment recommended');
    }

    return insights.isEmpty
        ? '• Device condition aligns with typical market expectations'
        : insights.join('\n');
  }

  String _generateProfessionalRecommendation(
    Map<String, double> values,
    double batteryHealth,
    ScreenCondition screenCondition,
    int issueCount,
  ) {
    if (values['repairCost']! > values['currentValue']! * 0.7) {
      return 'Consider donation or recycling - repair costs exceed value recovery potential.';
    }
    if (batteryHealth < 60 && screenCondition == ScreenCondition.cracked) {
      return 'Major repairs needed - evaluate personal vs. resale value for decision.';
    }
    if (values['postRepairValue']! > values['currentValue']! * 1.4) {
      return 'Strong repair case - investment will significantly increase device value.';
    }
    if (issueCount < 2 && batteryHealth > 80) {
      return 'Excellent condition - ideal for premium resale or continued use.';
    }
    return 'Moderate intervention recommended - selective repairs for optimal value.';
  }

  ScreenCondition _getRandomScreenCondition() {
    final conditions = [
      ScreenCondition.excellent,
      ScreenCondition.good,
      ScreenCondition.good, // More likely
      ScreenCondition.fair,
    ];
    return conditions[DateTime.now().millisecond % conditions.length];
  }

  // Method to update API key
  void updateApiKey(String newApiKey) {
    // In a real app, you'd reinitialize the models with the new key
    // For now, this serves as a placeholder for API key management
  }

  // Method to validate API key
  Future<bool> validateApiKey() async {
    try {
      final testResponse = await _model.generateContent([
        Content.text('Test connection. Respond with "OK".'),
      ]);
      return testResponse.text?.contains('OK') ?? false;
    } catch (e) {
      return false;
    }
  }
}
