import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple database service using SharedPreferences only
/// Works on all platforms (web, mobile, desktop)
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static SharedPreferences? _prefs;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<SharedPreferences> get database async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Web-compatible methods for SharedPreferences
  Future<List<Map<String, dynamic>>> getWebListings() async {
    final prefs = await database;
    final listingsJson = prefs.getStringList('resell_listings') ?? [];
    return listingsJson
        .map((json) => jsonDecode(json) as Map<String, dynamic>)
        .toList();
  }

  Future<void> saveWebListings(List<Map<String, dynamic>> listings) async {
    final prefs = await database;
    final listingsJson = listings.map((listing) => jsonEncode(listing)).toList();
    await prefs.setStringList('resell_listings', listingsJson);
  }

  Future<List<Map<String, dynamic>>> getWebDonations() async {
    final prefs = await database;
    final donationsJson = prefs.getStringList('donations') ?? [];
    if (donationsJson.isEmpty) {
      // Create sample donations
      final sampleDonations = _createSampleDonations();
      await saveWebDonations(sampleDonations);
      return sampleDonations;
    }
    return donationsJson
        .map((json) => jsonDecode(json) as Map<String, dynamic>)
        .toList();
  }

  Future<void> saveWebDonations(List<Map<String, dynamic>> donations) async {
    final prefs = await database;
    final donationsJson = donations.map((donation) => jsonEncode(donation)).toList();
    await prefs.setStringList('donations', donationsJson);
  }

  Future<List<Map<String, dynamic>>> getWebDevicePassports() async {
    final prefs = await database;
    final devicesJson = prefs.getStringList('device_passports') ?? [];
    return devicesJson
        .map((json) => jsonDecode(json) as Map<String, dynamic>)
        .toList();
  }

  Future<void> saveWebDevicePassports(List<Map<String, dynamic>> devices) async {
    final prefs = await database;
    final devicesJson = devices.map((device) => jsonEncode(device)).toList();
    await prefs.setStringList('device_passports', devicesJson);
  }

  Future<List<Map<String, dynamic>>> getDonations() async {
    return await getWebDonations();
  }

  // Utility method to check if database is ready
  Future<bool> isDatabaseReady() async {
    try {
      await database;
      return true;
    } catch (e) {
      return false;
    }
  }

  // Upcycling projects methods
  Future<int> saveUpcyclingProject(Map<String, dynamic> project) async {
    final prefs = await database;
    final projects = await getUpcyclingProjects();

    // Generate ID for new project
    final newId = DateTime.now().millisecondsSinceEpoch;
    project['id'] = newId;

    projects.add(project);
    final projectsJson = projects.map((p) => jsonEncode(p)).toList();
    await prefs.setStringList('upcycling_projects', projectsJson);

    return newId;
  }

  Future<List<Map<String, dynamic>>> getUpcyclingProjects({String? creatorId}) async {
    final prefs = await database;
    final projectsJson = prefs.getStringList('upcycling_projects') ?? [];
    final projects = projectsJson
        .map((json) => jsonDecode(json) as Map<String, dynamic>)
        .toList();

    if (creatorId != null) {
      return projects
          .where((p) => p['creator_id']?.toString() == creatorId)
          .toList();
    }

    return projects;
  }

  Future<void> updateUpcyclingProjectStatus(String projectId, String status) async {
    final projects = await getUpcyclingProjects();
    final index = projects.indexWhere((p) => p['id'].toString() == projectId);

    if (index != -1) {
      projects[index]['status'] = status;
      projects[index]['updated_at'] = DateTime.now().toIso8601String();

      final prefs = await database;
      final projectsJson = projects.map((p) => jsonEncode(p)).toList();
      await prefs.setStringList('upcycling_projects', projectsJson);
    }
  }

  // Device recognition history methods
  Future<int> saveDeviceRecognitionHistory(Map<String, dynamic> recognition) async {
    final prefs = await database;
    final history = await getDeviceRecognitionHistory();

    final newId = DateTime.now().millisecondsSinceEpoch;
    recognition['id'] = newId;

    history.add(recognition);
    final historyJson = history.map((h) => jsonEncode(h)).toList();
    await prefs.setStringList('device_recognition_history', historyJson);

    return newId;
  }

  Future<List<Map<String, dynamic>>> getDeviceRecognitionHistory({
    String? userId,
    int? limit,
  }) async {
    final prefs = await database;
    final historyJson = prefs.getStringList('device_recognition_history') ?? [];
    final history = historyJson
        .map((json) => jsonDecode(json) as Map<String, dynamic>)
        .toList();

    if (userId != null) {
      history.removeWhere((h) => h['user_id']?.toString() != userId);
    }

    // Sort by timestamp descending
    history.sort((a, b) =>
        DateTime.parse(b['recognition_timestamp'] ?? DateTime.now().toIso8601String()).compareTo(
            DateTime.parse(a['recognition_timestamp'] ?? DateTime.now().toIso8601String())));

    if (limit != null && history.length > limit) {
      return history.take(limit).toList();
    }

    return history;
  }

  Future<void> updateDeviceRecognitionSaved(int recognitionId, bool isSaved) async {
    final history = await getDeviceRecognitionHistory();
    final index = history.indexWhere((h) => h['id'] == recognitionId);

    if (index != -1) {
      history[index]['is_saved'] = isSaved;

      final prefs = await database;
      final historyJson = history.map((h) => jsonEncode(h)).toList();
      await prefs.setStringList('device_recognition_history', historyJson);
    }
  }

  // Donation transactions methods
  Future<List<Map<String, dynamic>>> getDonationTransactions({int? donationId}) async {
    final prefs = await database;
    final transactionsJson = prefs.getStringList('donation_transactions') ?? [];
    var transactions = transactionsJson
        .map((json) => jsonDecode(json) as Map<String, dynamic>)
        .toList();

    if (donationId != null) {
      transactions = transactions.where((t) => t['donation_id'] == donationId).toList();
    }

    // Sort by date descending
    transactions.sort((a, b) {
      final dateA = DateTime.parse(a['transaction_date'] ?? DateTime.now().toIso8601String());
      final dateB = DateTime.parse(b['transaction_date'] ?? DateTime.now().toIso8601String());
      return dateB.compareTo(dateA);
    });

    return transactions;
  }

  Future<int> saveDonationTransaction(Map<String, dynamic> transaction) async {
    final prefs = await database;
    final transactions = await getDonationTransactions();

    final newId = DateTime.now().millisecondsSinceEpoch;
    transaction['id'] = newId;

    transactions.add(transaction);
    final transactionsJson = transactions.map((t) => jsonEncode(t)).toList();
    await prefs.setStringList('donation_transactions', transactionsJson);

    return newId;
  }

  // Donation receipts methods
  Future<List<Map<String, dynamic>>> getDonationReceipts({String? userEmail}) async {
    final prefs = await database;
    final receiptsJson = prefs.getStringList('donation_receipts') ?? [];
    var receipts = receiptsJson
        .map((json) => jsonDecode(json) as Map<String, dynamic>)
        .toList();

    if (userEmail != null) {
      receipts = receipts.where((r) =>
        r['donor_email'] == userEmail || r['recipient_email'] == userEmail
      ).toList();
    }

    return receipts;
  }

  Future<void> saveDonationReceipt(Map<String, dynamic> receipt) async {
    final prefs = await database;
    final receipts = await getDonationReceipts();

    receipts.add(receipt);
    final receiptsJson = receipts.map((r) => jsonEncode(r)).toList();
    await prefs.setStringList('donation_receipts', receiptsJson);
  }

  // Create sample donations
  List<Map<String, dynamic>> _createSampleDonations() {
    final now = DateTime.now();
    return [
      {
        'id': now.millisecondsSinceEpoch,
        'name': 'John Doe',
        'school': 'University of Example',
        'story':
            'John is a hardworking computer science student who needs a new laptop for his studies.',
        'email': 'john.doe@example.edu',
        'phone': '+63 917 123 4567',
        'target_amount': 25000,
        'amount_raised': 8500,
        'category': 'Education',
        'status': 'active',
        'created_at': now.subtract(const Duration(days: 14)).toIso8601String(),
        'deadline': now.add(const Duration(days: 30)).toIso8601String(),
        'is_urgent': 0,
        'location': 'Davao City',
        'is_active': 1,
        'verification_status': 'verified',
        'total_donations_received': 2,
        'last_donation_date': now.subtract(const Duration(days: 5)).toIso8601String(),
        'total_amount_received': 8500,
      },
      {
        'id': now.millisecondsSinceEpoch + 1,
        'name': 'Jane Smith',
        'school': 'Example High School',
        'story':
            'Jane is a talented digital art student who needs a new graphics tablet.',
        'email': 'jane.smith@example.hs.edu.ph',
        'phone': '+63 918 234 5678',
        'target_amount': 15000,
        'amount_raised': 12000,
        'category': 'Arts & Design',
        'status': 'active',
        'created_at': now.subtract(const Duration(days: 7)).toIso8601String(),
        'deadline': now.add(const Duration(days: 20)).toIso8601String(),
        'is_urgent': 1,
        'location': 'Mandaluyong City',
        'is_active': 1,
        'verification_status': 'verified',
        'total_donations_received': 3,
        'last_donation_date': now.subtract(const Duration(days: 2)).toIso8601String(),
        'total_amount_received': 12000,
      },
    ];
  }
}
