class ApiConfig {
  // Replace with your actual Gemini API key
  // Get your key from: https://makersuite.google.com/app/apikey
  static const String geminiApiKey = 'AIzaSyCk6Ybk9etcuUz7n9VFWPrfPuZ4zNil9kQ';

  // For development/testing, you can use a demo mode
  static const bool useDemoMode = false;

  // Demo mode provides realistic but static responses for testing
  static const bool enableImageAnalysis =
      true; // Set to true when API key is configured

  // Google OAuth Configuration
  // For Web: Update the meta tag in web/index.html with your actual client ID
  // For Mobile: Add your google-services.json file to android/app/
  // Get your OAuth client ID from: https://console.cloud.google.com/apis/credentials

  // Example client ID format: "123456789012-abcdefghijklmnopqrstuvwxyz.apps.googleusercontent.com"
  // Set this to your actual Google OAuth client ID for web
  static const String googleOAuthClientId =
      '583476631419-3ar76b3sl0adai5vh0p42c467tn1f3s0.apps.googleusercontent.com';
}
