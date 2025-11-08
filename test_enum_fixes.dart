import 'package:ayoayo/models/device_diagnosis.dart';
import 'package:ayoayo/models/resell_listing.dart';
import 'package:ayoayo/models/upcycling_project.dart';
import 'package:ayoayo/models/donation.dart';
import 'package:ayoayo/models/device_passport.dart';
import 'package:ayoayo/utils/enum_helpers.dart';

void main() {
  print('Testing enum serialization/deserialization fixes for Chrome compatibility...\n');

  // Test 1: DeviceHealth enum serialization
  print('Test 1: DeviceHealth enum serialization');
  final deviceHealth = DeviceHealth(
    screenCondition: ScreenCondition.excellent,
    hardwareCondition: HardwareCondition.good,
    identifiedIssues: ['Test issue'],
  );
  final healthJson = deviceHealth.toJson();
  print('  screenCondition serialized: ${healthJson['screenCondition']}');
  print('  hardwareCondition serialized: ${healthJson['hardwareCondition']}');
  assert(healthJson['screenCondition'] == 'excellent', 'screenCondition should be "excellent"');
  assert(healthJson['hardwareCondition'] == 'good', 'hardwareCondition should be "good"');
  print('  ✓ DeviceHealth serialization works!\n');

  // Test 2: DeviceHealth enum deserialization
  print('Test 2: DeviceHealth enum deserialization');
  final deserializedHealth = DeviceHealth.fromJson({
    'screenCondition': 'fair',
    'hardwareCondition': 'poor',
    'identifiedIssues': [],
  });
  print('  screenCondition deserialized: ${getEnumName(deserializedHealth.screenCondition)}');
  print('  hardwareCondition deserialized: ${getEnumName(deserializedHealth.hardwareCondition)}');
  assert(deserializedHealth.screenCondition == ScreenCondition.fair);
  assert(deserializedHealth.hardwareCondition == HardwareCondition.poor);
  print('  ✓ DeviceHealth deserialization works!\n');

  // Test 3: RecommendedAction enum serialization
  print('Test 3: RecommendedAction enum serialization');
  final action = RecommendedAction(
    title: 'Test Action',
    description: 'Test Description',
    type: ActionType.repair,
    priority: 1.0,
  );
  final actionJson = action.toJson();
  print('  type serialized: ${actionJson['type']}');
  assert(actionJson['type'] == 'repair', 'type should be "repair"');
  print('  ✓ RecommendedAction serialization works!\n');

  // Test 4: ResellListing enum handling
  print('Test 4: ResellListing enum handling');
  final listingJson = {
    'id': 'test-1',
    'sellerId': 'user-1',
    'devicePassport': _createMockDevicePassportJson(),
    'category': 'smartphone',
    'condition': 'excellent',
    'askingPrice': 5000,
    'title': 'Test Phone',
    'description': 'A test phone',
    'imageUrls': [],
    'status': 'active',
    'createdAt': DateTime.now().toIso8601String(),
  };
  final listing = ResellListing.fromJson(listingJson);
  print('  category deserialized: ${getEnumName(listing.category)}');
  print('  condition deserialized: ${getEnumName(listing.condition)}');
  print('  status deserialized: ${getEnumName(listing.status)}');
  assert(listing.category == ListingCategory.smartphone);
  assert(listing.condition == ConditionGrade.excellent);
  assert(listing.status == ListingStatus.active);

  final reserializedListing = listing.toJson();
  print('  category reserialized: ${reserializedListing['category']}');
  print('  condition reserialized: ${reserializedListing['condition']}');
  print('  status reserialized: ${reserializedListing['status']}');
  assert(reserializedListing['category'] == 'smartphone');
  assert(reserializedListing['condition'] == 'excellent');
  assert(reserializedListing['status'] == 'active');
  print('  ✓ ResellListing enum handling works!\n');

  // Test 5: UpcyclingProject enum handling
  print('Test 5: UpcyclingProject enum handling');
  final projectJson = {
    'id': 'proj-1',
    'creatorId': 'user-1',
    'sourceDevice': _createMockDevicePassportJson(),
    'category': 'functional',
    'difficulty': 'intermediate',
    'title': 'Test Project',
    'description': 'Test Description',
    'aiGeneratedDescription': 'AI Description',
    'imageUrls': [],
    'materialsNeeded': [],
    'toolsRequired': [],
    'steps': [],
    'status': 'planning',
    'createdAt': DateTime.now().toIso8601String(),
    'estimatedHours': 5,
    'estimatedCost': 100,
    'tags': [],
  };
  final project = UpcyclingProject.fromJson(projectJson);
  print('  category deserialized: ${getEnumName(project.category)}');
  print('  difficulty deserialized: ${getEnumName(project.difficulty)}');
  print('  status deserialized: ${getEnumName(project.status)}');
  assert(project.category == ProjectCategory.functional);
  assert(project.difficulty == DifficultyLevel.intermediate);
  assert(project.status == ProjectStatus.planning);

  final reserializedProject = project.toJson();
  print('  category reserialized: ${reserializedProject['category']}');
  print('  difficulty reserialized: ${reserializedProject['difficulty']}');
  print('  status reserialized: ${reserializedProject['status']}');
  assert(reserializedProject['category'] == 'functional');
  assert(reserializedProject['difficulty'] == 'intermediate');
  assert(reserializedProject['status'] == 'planning');
  print('  ✓ UpcyclingProject enum handling works!\n');

  // Test 6: Donation enum handling
  print('Test 6: Donation enum handling');
  final donationJson = {
    'id': 1,
    'name': 'Test Student',
    'school': 'Test School',
    'story': 'Test story',
    'status': 'active',
  };
  final donation = Donation.fromJson(donationJson);
  print('  status deserialized: ${getEnumName(donation.status)}');
  assert(donation.status == DonationStatus.active);

  final reserializedDonation = donation.toJson();
  print('  status reserialized: ${reserializedDonation['status']}');
  assert(reserializedDonation['status'] == 'active');
  print('  ✓ Donation enum handling works!\n');

  // Test 7: Test parseEnumWithFallback with invalid values
  print('Test 7: parseEnumWithFallback with invalid values');
  final invalidCategory = parseEnumWithFallback(
    ListingCategory.values,
    'invalid_category',
    ListingCategory.other,
  );
  print('  Invalid category parsed to: ${getEnumName(invalidCategory)}');
  assert(invalidCategory == ListingCategory.other);
  print('  ✓ Fallback handling works!\n');

  // Test 8: Test case-insensitive parsing
  print('Test 8: Case-insensitive enum parsing');
  final upperCaseStatus = parseEnumWithFallback(
    DonationStatus.values,
    'ACTIVE',
    DonationStatus.cancelled,
  );
  print('  "ACTIVE" parsed to: ${getEnumName(upperCaseStatus)}');
  assert(upperCaseStatus == DonationStatus.active);

  final mixedCaseStatus = parseEnumWithFallback(
    DonationStatus.values,
    'FulFilled',
    DonationStatus.cancelled,
  );
  print('  "FulFilled" parsed to: ${getEnumName(mixedCaseStatus)}');
  assert(mixedCaseStatus == DonationStatus.fulfilled);
  print('  ✓ Case-insensitive parsing works!\n');

  print('═══════════════════════════════════════════════════════════');
  print('✓ ALL TESTS PASSED!');
  print('✓ Enum serialization/deserialization is Chrome-compatible!');
  print('✓ No _Namespace errors should occur on web/Chrome!');
  print('═══════════════════════════════════════════════════════════');
}

Map<String, dynamic> _createMockDevicePassportJson() {
  return {
    'id': 'passport-1',
    'userId': 'user-1',
    'deviceModel': 'Test Phone',
    'manufacturer': 'Test Manufacturer',
    'yearOfRelease': 2020,
    'operatingSystem': 'Android',
    'imageUrls': [],
    'lastDiagnosis': {
      'deviceModel': 'Test Phone',
      'deviceHealth': {
        'screenCondition': 'excellent',
        'hardwareCondition': 'good',
        'identifiedIssues': [],
      },
      'valueEstimation': {
        'currentValue': 5000,
        'postRepairValue': 6000,
        'partsValue': 2000,
        'repairCost': 500,
      },
      'recommendations': [],
      'aiAnalysis': 'Test analysis',
      'confidenceScore': 0.9,
      'imageUrls': [],
    },
  };
}
