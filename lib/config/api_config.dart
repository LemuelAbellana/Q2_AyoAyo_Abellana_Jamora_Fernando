import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // Gemini API Key - Now loaded from .env file
  // Get your key from: https://makersuite.google.com/app/apikey
  static String get geminiApiKey =>
      dotenv.env['GEMINI_API_KEY'] ?? 'YOUR_GEMINI_API_KEY_HERE';

  // For development/testing, you can use a demo mode
  static const bool useDemoMode = false;

  // Demo mode provides realistic but static responses for testing
  static const bool enableImageAnalysis =
      true; // Set to true when API key is configured

  // Google OAuth Configuration - Now loaded from .env file
  // For Web: Update the meta tag in web/index.html with your actual client ID
  // For Mobile: Add your google-services.json file to android/app/
  // Get your OAuth client ID from: https://console.cloud.google.com/apis/credentials
  static String get googleOAuthClientId =>
      dotenv.env['GOOGLE_OAUTH_CLIENT_ID'] ??
      'YOUR_GOOGLE_OAUTH_CLIENT_ID_HERE';

  // Backend API Configuration - Now loaded from .env file
  // Set to true to use Laravel backend, false to use local SQLite only
  static bool get useBackendApi =>
      dotenv.env['USE_BACKEND_API']?.toLowerCase() == 'true';

  // Backend URL - Now loaded from .env file
  // For Web/Desktop: http://localhost:8000/api/v1
  // For Android Emulator: http://10.0.2.2:8000/api/v1
  // For iOS Simulator: http://localhost:8000/api/v1
  // For Physical Device: http://YOUR_PC_IP:8000/api/v1
  static String get backendUrl =>
      dotenv.env['BACKEND_URL'] ?? 'http://localhost:8000/api/v1';
}
