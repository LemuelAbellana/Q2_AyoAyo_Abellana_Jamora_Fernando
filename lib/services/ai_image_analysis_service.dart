import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:ayoayo/config/api_config.dart';

class AIImageAnalysisService {
  late final String _apiKey;
  GenerativeModel? _visionModel;

  AIImageAnalysisService() {
    _apiKey = ApiConfig.geminiApiKey;
    try {
      _visionModel = GenerativeModel(
        model: 'gemini-2.0-flash-exp',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.4,
          topK: 32,
          topP: 0.95,
          maxOutputTokens: 2048,
        ),
      );

      if (ApiConfig.isGeminiConfigured) {
        print('✅ Image Analysis: Gemini 2.0 Flash Vision ready');
      } else {
        print('🎭 Image Analysis: Demo mode (add API key to enable)');
      }
    } catch (e) {
      print('⚠️ Failed to initialize Gemini Vision: $e');
    }
  }

  Future<String> analyzeDeviceImages(List<File> images) async {
    // Use demo mode if API not configured or vision model failed to initialize
    if (!ApiConfig.isGeminiConfigured || _visionModel == null) {
      print('📷 Demo mode - Add API key to .env for AI image analysis');
      return _generateDemoAnalysis(images);
    }

    try {
      final analysisResults = <String>[];

      for (int i = 0; i < images.take(3).length; i++) {
        // Analyze up to 3 images for comprehensive coverage
        final image = images[i];

        try {
          final bytes = await image.readAsBytes();
          print('📷 Processing image ${i + 1} (${bytes.length} bytes)');

          // Create enhanced prompt for phone recognition and condition analysis
          final imagePrompt =
              '''
🔍 **MOBILE DEVICE AI RECOGNITION & ANALYSIS - Image ${i + 1}**

You are an expert mobile device identification and assessment AI. Analyze this device image and provide detailed information.

**REQUIRED ANALYSIS:**

1. **DEVICE IDENTIFICATION:**
   - Identify the exact phone model (e.g., "iPhone 14 Pro", "Samsung Galaxy S23", "Google Pixel 7")
   - Determine the manufacturer
   - Estimate the device generation/year if visible
   - Identify color/variant if distinguishable

2. **PHYSICAL CONDITION ASSESSMENT:**
   - Screen condition (cracked, damaged, good, excellent)
   - Body/frame condition
   - Visible wear and tear
   - Any damage to buttons, ports, or camera

3. **VISUAL QUALITY ANALYSIS:**
   - Image clarity and lighting
   - Angles and visibility of key features
   - Any obstructions or reflections

**RESPONSE FORMAT:**
```
📱 **DEVICE IDENTIFICATION:**
Model: [Specific model name]
Manufacturer: [Brand name]
Generation/Year: [Estimated year]
Color/Variant: [Color if visible]
Confidence: [High/Medium/Low]

🔍 **CONDITION ASSESSMENT:**
Screen: [Excellent/Good/Fair/Poor/Cracked]
Body: [Excellent/Good/Fair/Poor/Damaged]
Overall: [Brief summary of condition]

⚠️ **DAMAGE DETECTED:**
[List any visible damage or wear]

💡 **IMAGE QUALITY:**
Clarity: [Excellent/Good/Fair/Poor]
Angle: [Optimal/Good/Suboptimal]
Lighting: [Good/Fair/Poor]

📋 **RECOMMENDATIONS:**
[Any suggestions for better photos or concerns]
```

Analyze the device thoroughly and be as specific as possible with the model identification.
          ''';

          try {
            // Use Gemini Vision API for actual phone recognition
            final response = await _visionModel!.generateContent([
              Content.multi([
                TextPart(imagePrompt),
                DataPart('image/jpeg', bytes),
              ]),
            ]);

            if (response.text != null) {
              final analysisText = response.text!;
              print('🔍 Image ${i + 1} Analysis Result: $analysisText');
              analysisResults.add(
                '📷 **Image ${i + 1} AI Analysis:**\n$analysisText',
              );
            } else {
              analysisResults.add(_generateFallbackAnalysis(i + 1));
            }
          } catch (aiError) {
            print('⚠️ AI Analysis failed for image ${i + 1}: $aiError');
            analysisResults.add(
              _generateFallbackAnalysis(i + 1, aiError.toString()),
            );
          }
        } catch (imageError) {
          print('❌ Error processing image ${i + 1}: $imageError');
          analysisResults.add(
            _generateFallbackAnalysis(i + 1, imageError.toString()),
          );
        }
      }

      // Combine all image analyses with summary
      final combinedAnalysis = StringBuffer();
      combinedAnalysis.writeln('🔬 **GEMINI AI DEVICE RECOGNITION REPORT**\n');
      combinedAnalysis.writeln(analysisResults.join('\n\n---\n\n'));

      // Add enhanced analysis summary
      combinedAnalysis.writeln('\n\n📊 **AI ANALYSIS SUMMARY:**');
      combinedAnalysis.writeln(
        '• Total Images Processed: ${analysisResults.length}',
      );
      combinedAnalysis.writeln('• AI Model: Gemini 2.0 Flash Vision');
      combinedAnalysis.writeln(
        '• Analysis Type: Device Recognition + Condition Assessment',
      );
      combinedAnalysis.writeln(
        '• Capabilities: Phone Model ID, Brand Detection, Damage Assessment',
      );

      return combinedAnalysis.toString();
    } catch (e) {
      print('❌ Image analysis failed: $e');
      return '⚠️ **AI Analysis Failed:** $e\n'
          '📝 **Fallback:** Proceeding with text-based analysis\n'
          '💡 **Tip:** Ensure clear, well-lit photos for best AI recognition\n'
          '🔧 **Error Details:** ${e.toString()}';
    }
  }

  // Generate demo analysis when API is not available
  String _generateDemoAnalysis(List<File> images) {
    final demoResults = <String>[];

    for (int i = 0; i < images.take(3).length; i++) {
      demoResults.add('''
📷 **Image ${i + 1} AI Analysis (Demo Mode):**

📱 **DEVICE IDENTIFICATION:**
Model: iPhone 13 Pro (Demo)
Manufacturer: Apple
Generation/Year: 2021
Color/Variant: Space Gray
Confidence: High

🔍 **CONDITION ASSESSMENT:**
Screen: Good
Body: Good
Overall: Device appears to be in good working condition

⚠️ **DAMAGE DETECTED:**
Minor wear on edges, no significant damage visible

💡 **IMAGE QUALITY:**
Clarity: Good
Angle: Optimal
Lighting: Good

📋 **RECOMMENDATIONS:**
Image quality suitable for assessment. Consider taking additional angles for complete evaluation.
      ''');
    }

    return '''
🔬 **GEMINI AI DEVICE RECOGNITION REPORT (Demo Mode)**

${demoResults.join('\n\n---\n\n')}

📊 **AI ANALYSIS SUMMARY:**
• Total Images Processed: ${images.length}
• AI Model: Gemini 2.0 Flash Vision (Demo Mode)
• Analysis Type: Device Recognition + Condition Assessment

💡 **Enable Real AI Analysis:**
Add your Gemini API key to .env file (see SETUP_API_KEY.md)
    ''';
  }

  // Generate fallback analysis when AI fails
  String _generateFallbackAnalysis(int imageNumber, [String? error]) {
    return '''
📷 **Image $imageNumber Analysis:**

📱 **DEVICE IDENTIFICATION:**
Model: Unable to identify automatically
Manufacturer: Unknown
Generation/Year: Unknown
Color/Variant: Unknown
Confidence: Low

🔍 **CONDITION ASSESSMENT:**
Screen: Unable to assess automatically
Body: Unable to assess automatically
Overall: Manual inspection recommended

⚠️ **ANALYSIS STATUS:**
${error != null ? 'Error: $error' : 'AI recognition failed'}

💡 **RECOMMENDATIONS:**
• Ensure image is clear and well-lit
• Try capturing the device from different angles
• Check internet connection for AI processing
• Consider manual device model entry
    ''';
  }
}
