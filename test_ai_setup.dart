// Quick test script to verify AI setup
// Run with: dart test_ai_setup.dart

import 'dart:io';

void main() async {
  print('🔍 Testing AI Assistant Setup...\n');

  // Check 1: .env file exists
  print('1️⃣ Checking for .env file...');
  final envFile = File('.env');
  if (envFile.existsSync()) {
    print('   ✅ .env file found');

    // Check 2: API key in .env
    print('\n2️⃣ Checking API key configuration...');
    final envContent = await envFile.readAsString();

    if (envContent.contains('GEMINI_API_KEY=')) {
      final lines = envContent.split('\n');
      final apiKeyLine = lines.firstWhere(
        (line) => line.startsWith('GEMINI_API_KEY='),
        orElse: () => '',
      );

      if (apiKeyLine.isNotEmpty) {
        final key = apiKeyLine.split('=')[1].trim();

        if (key.isEmpty || key == 'YOUR_GEMINI_API_KEY_HERE') {
          print('   ❌ API key not configured');
          print('   📝 Replace YOUR_GEMINI_API_KEY_HERE with your actual key');
          print('   🔑 Get your key: https://makersuite.google.com/app/apikey');
        } else if (key.startsWith('AIza')) {
          print('   ✅ API key configured (starts with AIza...)');
          print('   🎉 Your AI Assistant should be working!');
        } else {
          print('   ⚠️  API key found but doesn\'t start with "AIza"');
          print('   💡 Gemini API keys typically start with "AIza"');
        }
      }
    } else {
      print('   ❌ GEMINI_API_KEY not found in .env file');
      print('   📝 Add: GEMINI_API_KEY=your_key_here');
    }
  } else {
    print('   ❌ .env file not found');
    print('   📝 Create .env file in project root');
    print('   📄 See SETUP_API_KEY.md for instructions');
  }

  print('\n3️⃣ Checking pubspec.yaml...');
  final pubspecFile = File('pubspec.yaml');
  if (pubspecFile.existsSync()) {
    final pubspecContent = await pubspecFile.readAsString();

    // Check for required packages
    final hasGeminiPackage = pubspecContent.contains('google_generative_ai:');
    final hasDotenvPackage = pubspecContent.contains('flutter_dotenv:');

    if (hasGeminiPackage && hasDotenvPackage) {
      print('   ✅ Required packages configured');
    } else {
      if (!hasGeminiPackage) {
        print('   ❌ google_generative_ai package missing');
      }
      if (!hasDotenvPackage) {
        print('   ❌ flutter_dotenv package missing');
      }
    }

    // Check if .env is in assets
    if (pubspecContent.contains('- .env')) {
      print('   ✅ .env file in assets');
    } else {
      print('   ⚠️  .env not listed in assets (might be ok if using root)');
    }
  }

  print('\n📊 Summary:');
  print('─' * 50);
  if (envFile.existsSync()) {
    final envContent = await envFile.readAsString();
    if (envContent.contains('GEMINI_API_KEY=')) {
      final lines = envContent.split('\n');
      final apiKeyLine = lines.firstWhere(
        (line) => line.startsWith('GEMINI_API_KEY='),
        orElse: () => '',
      );
      final key = apiKeyLine.split('=').length > 1
          ? apiKeyLine.split('=')[1].trim()
          : '';

      if (key.isNotEmpty &&
          key != 'YOUR_GEMINI_API_KEY_HERE' &&
          key.startsWith('AIza')) {
        print('✅ Setup appears correct! Run the app to test.');
        print('\n🚀 Next steps:');
        print('   1. Run: flutter run');
        print('   2. Check console for: "✅ Gemini 1.5 Flash ready"');
        print('   3. Try the AI Chatbot feature');
      } else {
        print('❌ Setup incomplete - API key needed');
        print('\n📝 Next steps:');
        print('   1. Get key: https://makersuite.google.com/app/apikey');
        print('   2. Edit .env file');
        print('   3. Add: GEMINI_API_KEY=your_actual_key');
        print('   4. Run this test again');
      }
    } else {
      print('❌ Setup incomplete - configure .env file');
    }
  } else {
    print('❌ Setup incomplete - create .env file');
    print('\n📝 Next steps:');
    print('   1. Create .env file in project root');
    print('   2. Add: GEMINI_API_KEY=your_key_here');
    print('   3. Get key: https://makersuite.google.com/app/apikey');
    print('   4. See SETUP_API_KEY.md for detailed guide');
  }
  print('─' * 50);
}
