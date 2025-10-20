import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:ayoayo/config/api_config.dart';
import 'package:ayoayo/services/knowledge_base.dart';

class AIChatbotService {
  late final GenerativeModel _model;
  late final String _apiKey;

  AIChatbotService() {
    _apiKey = ApiConfig.geminiApiKey;
    _model = GenerativeModel(
      model: 'gemini-2.0-flash-exp',
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

    if (ApiConfig.isGeminiConfigured) {
      print('✅ AI Chatbot: Gemini 2.0 Flash ready');
    } else {
      print(
        '🎭 AI Chatbot: Demo mode (add API key to enable Gemini 2.0 Flash)',
      );
    }
  }

  Future<String> getTechnicianChatbotResponse(String message) async {
    // Use demo mode if API key not configured
    if (!ApiConfig.isGeminiConfigured) {
      print(
        '🎭 Demo mode - Add your API key to .env file (see SETUP_API_KEY.md)',
      );
      return _getDemoResponse(message);
    }

    try {
      print('🤖 Gemini 2.0 Flash: Processing message...');
      final prompt = _buildChatbotPrompt(message);

      final response = await _model
          .generateContent([Content.text(prompt)])
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Request timed out'),
          );

      if (response.text?.isNotEmpty ?? false) {
        print('✅ Response received (${response.text!.length} chars)');
        return response.text!;
      }

      return "I received your message but couldn't generate a response. Please try again.";
    } on GenerativeAIException catch (e) {
      print('❌ Gemini API error: ${e.message}');

      if (e.message.contains('API_KEY_INVALID') ||
          e.message.contains('invalid')) {
        return "❌ Invalid API Key. Check your .env file.\nGet a free key: https://makersuite.google.com/app/apikey";
      } else if (e.message.contains('QUOTA')) {
        return "❌ API quota exceeded. Check usage at https://makersuite.google.com/";
      } else if (e.message.contains('BLOCKED')) {
        return "⚠️ Content blocked by safety filters. Please rephrase your question.";
      }
      return "❌ AI Error: ${e.message}";
    } catch (e) {
      print('❌ Error: $e');

      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('timeout')) {
        return "⏱️ Request timed out. Please try again.";
      } else if (errorStr.contains('network') || errorStr.contains('socket')) {
        return "🌐 Network error. Check your internet connection.";
      }
      return "❌ Error: ${e.toString().split('\n').first}";
    }
  }

  String _getDemoResponse(String message) {
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('screen') || lowerMessage.contains('display')) {
      return "📱 For screen issues, typical repair costs: ₱2,500-₱12,000\n\nGreen lines or touch issues usually mean display hardware replacement needed.\n\n💡 Using demo mode - Add your Gemini API key for AI-powered responses!";
    } else if (lowerMessage.contains('battery')) {
      return "🔋 Battery replacement costs:\n• iPhone: ₱1,200-₱2,500\n• Android: ₱800-₱2,000\n\nRecommended if battery health < 80%\n\n💡 Using demo mode - Add your Gemini API key for AI-powered responses!";
    } else if (lowerMessage.contains('water') ||
        lowerMessage.contains('liquid')) {
      return "💧 Water damage needs immediate attention!\n\nDiagnosis + cleaning: ₱1,500-₱3,000\nSuccess depends on how quickly addressed.\n\n💡 Using demo mode - Add your Gemini API key for AI-powered responses!";
    } else if (lowerMessage.contains('value') ||
        lowerMessage.contains('worth') ||
        lowerMessage.contains('price')) {
      return "💰 Device value depends on:\n• Model\n• Condition\n• Age\n• Market demand\n\nUse Device Scanner for AI assessment.\n\n💡 Using demo mode - Add your Gemini API key for AI-powered responses!";
    } else {
      return "🎭 Demo Mode Active\n\nTo enable real AI assistance with Gemini 2.0 Flash:\n\n1. Get free API key: https://makersuite.google.com/app/apikey\n2. Create .env file in project root\n3. Add: GEMINI_API_KEY=your_key_here\n\nSee SETUP_API_KEY.md for details!";
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
