import 'package:flutter/foundation.dart';
import '../models/donation.dart';
import '../services/database_service.dart';

class DonationProvider with ChangeNotifier {
  List<Donation> _donations = [];
  bool _isLoading = false;
  String? _errorMessage;
  final DatabaseService _dbService = DatabaseService();

  List<Donation> get donations => _donations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  DonationProvider() {
    fetchDonations();
  }

  Future<void> fetchDonations() async {
    _setLoading(true);
    try {
      final donationsMap = await _dbService.getDonations();

      // If no donations exist on web, create some sample data
      if (kIsWeb && donationsMap.isEmpty) {
        await _createSampleDonations();
        final updatedDonations = await _dbService.getDonations();
        _donations = updatedDonations
            .map((donation) => Donation.fromJson(donation))
            .toList();
      } else {
        _donations = donationsMap
            .map((donation) => Donation.fromJson(donation))
            .toList();
      }

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load donations: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _createSampleDonations() async {
    try {
      final now = DateTime.now();
      final sampleDonations = [
        Donation(
          id: now.millisecondsSinceEpoch,
          name: 'John Doe',
          school: 'University of Example',
          story:
              'John is a hardworking computer science student who needs a new laptop for his studies. His current device is 6 years old and frequently crashes during important assignments.',
          email: 'john.doe@example.edu',
          phone: '+63 917 123 4567',
          targetAmount: 25000,
          amountRaised: 8500,
          category: 'Education',
          status: DonationStatus.active,
          createdAt: now.subtract(const Duration(days: 14)),
          deadline: now.add(const Duration(days: 30)),
          isUrgent: false,
          location: 'Davao City',
        ),
        Donation(
          id: now.millisecondsSinceEpoch + 1,
          name: 'Jane Smith',
          school: 'Example High School',
          story:
              'Jane is a talented digital art student who needs a new graphics tablet. Her current one broke during a crucial project deadline, and she needs to complete her portfolio for college applications.',
          email: 'jane.smith@example.hs.edu.ph',
          phone: '+63 918 234 5678',
          targetAmount: 15000,
          amountRaised: 12000,
          category: 'Arts & Design',
          status: DonationStatus.active,
          createdAt: now.subtract(const Duration(days: 7)),
          deadline: now.add(const Duration(days: 20)),
          isUrgent: true,
          location: 'Mandaluyong City',
        ),
        Donation(
          id: now.millisecondsSinceEpoch + 2,
          name: 'Peter Jones',
          school: 'Another University',
          story:
              'Peter is a dedicated biology researcher who needs a new microscope for his thesis work. His current equipment is outdated and insufficient for the detailed analysis required for his research.',
          email: 'peter.jones@research.uni.edu.ph',
          phone: '+63 919 345 6789',
          targetAmount: 35000,
          amountRaised: 5200,
          category: 'Science & Research',
          status: DonationStatus.active,
          createdAt: now.subtract(const Duration(days: 21)),
          deadline: now.add(const Duration(days: 45)),
          isUrgent: false,
          location: 'Cebu City',
        ),
      ];

      final donationsJson = sampleDonations
          .map((donation) => donation.toJson())
          .toList();
      await _dbService.saveWebDonations(donationsJson);
    } catch (e) {
      print('Error creating sample donations: $e');
    }
  }

  

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
