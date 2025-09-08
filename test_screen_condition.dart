import 'package:ayoayo/services/gemini_diagnosis_service.dart';

void main() {
  print('🧪 Testing Screen Condition Detection Fix...');

  final service = GeminiDiagnosisService();

  final testCases = [
    'broken', // Should detect as CRACKED
    'screen is broken', // Should detect as CRACKED
    'cracked', // Should detect as CRACKED
    'screen cracked', // Should detect as CRACKED
    'shattered', // Should detect as CRACKED
    'display shattered', // Should detect as CRACKED
    'damaged', // Should detect as CRACKED
    'screen damaged', // Should detect as CRACKED
    'destroyed', // Should detect as CRACKED
    'ruined', // Should detect as CRACKED
    'working fine', // Should detect as GOOD
    'perfect condition', // Should detect as EXCELLENT
    'good', // Should detect as GOOD
  ];

  for (final testCase in testCases) {
    print('\n📝 Testing: "$testCase"');
    final result = service.testScreenConditionDetection(
      'Test Device',
      testCase,
      null,
    );
    print('🎯 Result: $result');
  }

  print('\n✅ Screen condition testing complete!');
}
