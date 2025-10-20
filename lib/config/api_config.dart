import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // Gemini API Key - Loaded from .env file
  // Get your free key from: https://makersuite.google.com/app/apikey
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  // Check if API key is configured
  static bool get isGeminiConfigured {
    final key = geminiApiKey;
    return key.isNotEmpty && key != 'YOUR_GEMINI_API_KEY_HERE';
  }

  // Image analysis enabled when API is configured
  static bool get enableImageAnalysis => isGeminiConfigured;

  // Google OAuth Configuration
  static String get googleOAuthClientId =>
      dotenv.env['GOOGLE_OAUTH_CLIENT_ID'] ?? '';

  // Backend API Configuration
  static bool get useBackendApi =>
      dotenv.env['USE_BACKEND_API']?.toLowerCase() == 'true';

  // Backend URL
  static String get backendUrl =>
      dotenv.env['BACKEND_URL'] ?? 'http://localhost:8000/api/v1';
}
