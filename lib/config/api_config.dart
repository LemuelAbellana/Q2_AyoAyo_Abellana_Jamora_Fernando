class ApiConfig {
  // Replace with your actual Gemini API key
  // Get your key from: https://makersuite.google.com/app/apikey
  static const String geminiApiKey = 'AIzaSyCk6Ybk9etcuUz7n9VFWPrfPuZ4zNil9kQ';

  // For development/testing, you can use a demo mode
  static const bool useDemoMode = false;

  // Demo mode provides realistic but static responses for testing
  static const bool enableImageAnalysis =
      true; // Set to true when API key is configured
}
