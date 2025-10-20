// Test if chatbot can actually call Gemini API
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  print('🧪 Testing Gemini API Connection...\n');

  // Load .env file
  try {
    await dotenv.load(fileName: ".env");
    print('✅ .env file loaded');
  } catch (e) {
    print('❌ Failed to load .env: $e');
    exit(1);
  }

  final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';

  print('📝 API Key: ${apiKey.substring(0, 10)}...');
  print('📏 Length: ${apiKey.length} characters');
  print('🔍 Starts with AIza: ${apiKey.startsWith('AIza')}');

  if (apiKey.isEmpty || apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
    print('❌ Invalid API key');
    exit(1);
  }

  print('\n🌐 Testing actual API call...');

  // Make a real API call using curl
  try {
    final result = await Process.run('curl', [
      '-X',
      'POST',
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
      '-H',
      'Content-Type: application/json',
      '-d',
      '{"contents":[{"parts":[{"text":"Say hello"}]}]}',
    ]);

    if (result.exitCode == 0) {
      final output = result.stdout.toString();
      if (output.contains('"text"')) {
        print('✅ API call successful!');
        print('📨 Response preview:');

        // Extract just the text response
        final textMatch = RegExp(r'"text":\s*"([^"]+)"').firstMatch(output);
        if (textMatch != null) {
          print('   AI: ${textMatch.group(1)}');
        }

        print('\n🎉 Your Gemini API key is working correctly!');
        print('✅ The chatbot should work in the app.');
      } else if (output.contains('error')) {
        print('❌ API returned an error:');
        print(output);
      } else {
        print('⚠️  Unexpected response:');
        print(output);
      }
    } else {
      print('❌ curl command failed');
      print('Error: ${result.stderr}');
    }
  } catch (e) {
    print('❌ Failed to test API: $e');
  }
}
