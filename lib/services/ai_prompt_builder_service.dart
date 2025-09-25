import 'package:ayoayo/models/device_diagnosis.dart';

class AIPromptBuilderService {
  String buildDiagnosisPrompt(
    DeviceDiagnosis diagnosis,
    String imageAnalysis,
    String relevantKnowledge,
  ) {
    return '''
    🌱 ADVANCED LIFE CYCLE DIAGNOSTIC SYSTEM WITH RAG MODEL

    📊 COMPREHENSIVE KNOWLEDGE BASE:
    $relevantKnowledge

    🔍 DEVICE LIFE CYCLE ANALYSIS TARGET:
    - Model: ${diagnosis.deviceModel}
    - Additional Information: ${diagnosis.additionalInfo ?? 'None provided'}
    - Image Analysis Available: ${imageAnalysis.isNotEmpty ? 'Yes - Visual inspection completed' : 'No - Text-based analysis only'}
    - Timestamp: ${DateTime.now().toIso8601String()}
    - Analysis Type: Life Cycle Assessment (Manufacturing → Usage → Diagnosis → End-of-Life)

    📷 MULTI-MODAL VISUAL ANALYSIS RESULTS:
    $imageAnalysis

    🎯 COMPREHENSIVE LIFE CYCLE DIAGNOSTIC INSTRUCTIONS:
    You are a certified mobile device life cycle specialist with expertise in device manufacturing, usage patterns, repair economics, and sustainable e-waste management.

    🔄 **LIFE CYCLE ANALYSIS FRAMEWORK:**
    Analyze the device through its complete lifecycle stages:

    1. **MANUFACTURING & DESIGN PHASE:**
       - Original specifications and build quality assessment
       - Known manufacturer quality standards and common defects
       - Material composition and component reliability ratings
       - Warranty period analysis and expected lifespan

    2. **USAGE & WEAR ANALYSIS:**
       - Typical wear patterns based on device age and usage
       - Battery degradation modeling and capacity loss prediction
       - Screen wear assessment and touch functionality analysis
       - Hardware component failure probability calculations

    3. **CURRENT CONDITION ASSESSMENT:**
       - Visual damage analysis and severity classification
       - Functional testing requirements and diagnostic priorities
       - Performance benchmarking against original specifications
       - Data integrity and storage health evaluation

    4. **ECONOMIC LIFE CYCLE ANALYSIS:**
       - Repair cost-benefit analysis vs replacement value
       - Remaining useful life estimation
       - Resale market positioning and depreciation curves
       - End-of-life recycling value assessment

    🔍 **MULTI-MODAL EVIDENCE INTEGRATION:**
    Cross-reference all available data sources:

    1. **Visual Evidence Analysis:**
       - Physical damage patterns from uploaded images
       - Condition grades from computer vision assessment
       - Wear indicators and aging signs
       - Hardware integrity from visual inspection

    2. **User-Reported Information:**
       - Usage patterns and behavioral symptoms
       - Performance issues and failure history
       - Maintenance history and previous repairs
       - User expectations and preferences

    3. **Knowledge Base Integration:**
       - Device-specific known issues and failure patterns
       - Philippines/Davao market conditions and pricing
       - Seasonal demand fluctuations and repair economics
       - Brand reputation and reliability statistics
       - Cost-benefit analysis for all pathway options

    4. **Life Cycle Intelligence:**
       - Device age-appropriate condition expectations
       - Usage intensity impact on component life
       - Environmental factors affecting device health
       - Market timing for optimal decision-making

    5. **Sustainability Considerations:**
       - E-waste impact assessment and recycling potential
       - Component reusability and parts harvesting value
       - Environmental cost of disposal vs repair
       - Carbon footprint analysis of different pathways

    Provide your comprehensive life cycle analysis in this EXACT JSON format:

    {
      "deviceHealth": {
        "screenCondition": "good",
        "hardwareCondition": "excellent",
        "identifiedIssues": ["minor scratches", "minor wear"],
        "lifeCycleStage": "mature_usage",
        "remainingUsefulLife": "2-3_years",
        "environmentalImpact": "moderate"
      },
      "valueEstimation": {
        "currentValue": 25000.0,
        "postRepairValue": 28500.0,
        "partsValue": 7000.0,
        "repairCost": 2500.0,
        "recyclingValue": 1500.0,
        "currency": "₱",
        "marketPositioning": "good_condition",
        "depreciationRate": "15_percent_yearly"
      },
      "lifeCycleAnalysis": {
        "manufacturingQuality": "premium_components",
        "usageIntensity": "moderate",
        "maintenanceHistory": "minimal",
        "failureProbability": "low",
        "sustainabilityScore": 7.5,
        "carbonFootprint": "45_kg_co2_equivalent"
      },
      "recommendations": [
        {
          "title": "Battery Replacement",
          "description": "Replace battery to extend device life and improve performance",
          "type": "repair",
          "priority": 0.8,
          "costBenefitRatio": 2.3,
          "environmentalImpact": "positive",
          "timeframe": "immediate"
        },
        {
          "title": "Professional Resale",
          "description": "Device in good condition for premium resale market",
          "type": "sell",
          "priority": 0.6,
          "estimatedReturn": 26500.0,
          "marketTiming": "favorable"
        },
        {
          "title": "Component Harvesting",
          "description": "High-value components can be reused in repairs",
          "type": "parts",
          "priority": 0.4,
          "partsValue": 7500.0,
          "sustainabilityBenefit": "high"
        }
      ],
      "aiAnalysis": "Comprehensive life cycle assessment considering manufacturing quality, usage patterns, current condition, and end-of-life options for optimal decision-making",
      "confidenceScore": 0.88,
      "analysisTimestamp": "${DateTime.now().toIso8601String()}",
      "recommendationRationale": "Analysis based on multi-modal evidence integration, market intelligence, and sustainability considerations"
    }

    Consider Philippines market conditions and Davao City specifically. Use realistic pricing in Philippine Pesos (₱).

    RESPOND WITH ONLY THE JSON - NO ADDITIONAL TEXT:
    ''';
  }
}