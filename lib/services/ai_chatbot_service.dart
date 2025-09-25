import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:ayoayo/config/api_config.dart';
import 'package:ayoayo/services/knowledge_base.dart';

class AIChatbotService {
  static const String _apiKey = ApiConfig.geminiApiKey;
  late final GenerativeModel _model;

  AIChatbotService() {
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
  }

  Future<String> getTechnicianChatbotResponse(String message) async {
    if (ApiConfig.useDemoMode || _apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      return "This is a demo response from the Technician Chatbot.";
    }

    try {
      final prompt = _buildChatbotPrompt(message);
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? "Sorry, I couldn't process your request.";
    } catch (e) {
      return "Sorry, I'm having trouble connecting to the AI service.";
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