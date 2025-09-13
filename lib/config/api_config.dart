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
      '583476631419-CLIENT_ID_HERE.apps.googleusercontent.com';

  // Instructions for setting up Google OAuth:
  // 1. Go to https://console.cloud.google.com/
  // 2. Create/select a project
  // 3. Enable Google+ API and Google Sign-In API
  // 4. Create OAuth 2.0 credentials
  // 5. Add authorized origins: http://localhost:5000 (for development)
  // 6. Add your production domain when deploying
  // 7. Copy the client ID and replace the placeholder above
  // 8. For web: Update the meta tag in web/index.html
  // 9. For mobile: Download google-services.json and place in android/app/
}
