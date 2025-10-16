import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:ayoayo/config/api_config.dart';
import 'package:ayoayo/services/knowledge_base.dart';

class AIChatbotService {
  late final GenerativeModel _model;
  late final String _apiKey;

  AIChatbotService() {
    _apiKey = ApiConfig.geminiApiKey;
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
      ],
    );
  }

  Future<String> getTechnicianChatbotResponse(String message) async {
    // Check if API key is configured
    if (ApiConfig.useDemoMode || _apiKey == 'YOUR_GEMINI_API_KEY_HERE' || _apiKey.isEmpty) {
      print('🎭 Using demo mode for chatbot - API key not configured');
      return _getDemoResponse(message);
    }

    try {
      print('🤖 Sending message to Gemini AI: ${message.substring(0, message.length > 50 ? 50 : message.length)}...');
      final prompt = _buildChatbotPrompt(message);

      // Add timeout to prevent hanging
      final response = await _model
          .generateContent([Content.text(prompt)])
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timed out after 30 seconds');
            },
          );

      if (response.text != null && response.text!.isNotEmpty) {
        print('✅ Received response from Gemini AI (${response.text!.length} chars)');
        return response.text!;
      } else {
        print('⚠️ Empty response from Gemini AI');
        return "I received your message but couldn't generate a response. Please try rephrasing your question.";
      }
    } on GenerativeAIException catch (e) {
      print('❌ Gemini AI error: ${e.message}');

      // Handle specific Gemini API errors
      if (e.message.contains('API_KEY_INVALID') || e.message.contains('invalid')) {
        return "❌ API Key Error: Your Gemini API key appears to be invalid. Please check your .env file and ensure GEMINI_API_KEY is set correctly.";
      } else if (e.message.contains('QUOTA') || e.message.contains('quota')) {
        return "❌ Quota Exceeded: Your Gemini API quota has been exceeded. Please check your usage at https://makersuite.google.com/";
      } else if (e.message.contains('BLOCKED') || e.message.contains('safety')) {
        return "⚠️ Content Blocked: The request was blocked by safety filters. Please rephrase your question.";
      } else {
        return "❌ AI Service Error: ${e.message}\n\nPlease try again or contact support if the issue persists.";
      }
    } catch (e) {
      print('❌ AI chatbot error: $e');

      // Provide specific error messages based on error type
      final errorStr = e.toString().toLowerCase();

      if (errorStr.contains('timeout')) {
        return "⏱️ Request timed out. The AI service is taking too long to respond. Please try again.";
      } else if (errorStr.contains('socketexception') || errorStr.contains('network') || errorStr.contains('connection')) {
        return "🌐 Network Error: Please check your internet connection and try again.";
      } else if (errorStr.contains('formatexception') || errorStr.contains('json')) {
        return "⚠️ Response Format Error: Received an unexpected response from the AI service. Please try again.";
      } else {
        return "❌ Unexpected Error: ${e.toString().split('\n').first}\n\nPlease try again or check your configuration.";
      }
    }
  }

  String _getDemoResponse(String message) {
    // Provide contextual demo responses based on message content
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('screen') || lowerMessage.contains('display')) {
      return "Demo Mode: For screen issues, typical repair costs range from ₱2,500-₱12,000 depending on the device model. If you're experiencing green lines or touch issues, it's likely a display hardware problem that requires replacement.";
    } else if (lowerMessage.contains('battery')) {
      return "Demo Mode: Battery replacement typically costs ₱1,200-₱2,500 for iPhones and ₱800-₱2,000 for Android devices. If your battery health is below 80%, replacement is recommended.";
    } else if (lowerMessage.contains('water') || lowerMessage.contains('liquid')) {
      return "Demo Mode: Water damage requires immediate attention. Diagnosis and cleaning costs ₱1,500-₱3,000 with no guarantee of repair. Success depends on how quickly the device is addressed.";
    } else if (lowerMessage.contains('value') || lowerMessage.contains('worth') || lowerMessage.contains('price')) {
      return "Demo Mode: Device value depends on model, condition, age, and market demand. For accurate valuation, use our Device Scanner feature with AI-powered assessment.";
    } else {
      return "Demo Mode Active: This is a simulated response. To use real AI-powered assistance, please configure your Gemini API key in the .env file. Visit https://makersuite.google.com/app/apikey to get your free API key.";
    }
  }

  String _buildChatbotPrompt(String message) {
    return '''
    You are an expert mobile device technician. Your role is to answer user questions and provide technical assistance based on the provided knowledge base.

    **Knowledge Base:**
    ${KnowledgeBase.ragData}

    **User's Question:**
    $message

    **Instructions:**
    - Provide a clear and concise answer to the user's question.
    - Use the knowledge base to inform your response.
    - If the question is outside the scope of the knowledge base, politely state that you cannot answer.
    - Do not mention that you are an AI model.
    ''';
  }
}