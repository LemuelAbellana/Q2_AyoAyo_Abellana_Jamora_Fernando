import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/donation.dart';
import '../models/donation_transaction.dart';
import '../models/donation_receipt.dart';
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
          verificationStatus: VerificationStatus.verified,
          totalDonationsReceived: 2,
          lastDonationDate: now.subtract(const Duration(days: 5)),
          totalAmountReceived: 8500,
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
          verificationStatus: VerificationStatus.verified,
          totalDonationsReceived: 3,
          lastDonationDate: now.subtract(const Duration(days: 2)),
          totalAmountReceived: 12000,
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
          verificationStatus: VerificationStatus.pending,
          totalDonationsReceived: 1,
          lastDonationDate: now.subtract(const Duration(days: 15)),
          totalAmountReceived: 5200,
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

  // Process a donation and generate receipts
  Future<DonationReceipt?> processDonation({
    required int donationId,
    required String donorName,
    required String donorEmail,
    String? donorPhone,
    required double amount,
    String? notes,
  }) async {
    try {
      _setLoading(true);

      // Find the donation
      final donationIndex = _donations.indexWhere((d) => d.id == donationId);
      if (donationIndex == -1) {
        _errorMessage = 'Donation not found';
        return null;
      }

      final donation = _donations[donationIndex];

      // Create transaction
      final transactionId = DateTime.now().millisecondsSinceEpoch;
      final receiptNumber = DonationTransaction.generateReceiptNumber(donationId, transactionId);

      final transaction = DonationTransaction(
        id: transactionId,
        donationId: donationId,
        donorName: donorName,
        donorEmail: donorEmail,
        donorPhone: donorPhone,
        amount: amount,
        transactionDate: DateTime.now(),
        status: TransactionStatus.completed,
        receiptNumber: receiptNumber,
        notes: notes,
      );

      // Save transaction
      await _dbService.saveDonationTransaction(transaction.toJson());

      // Create receipt
      final receipt = DonationReceipt(
        receiptNumber: receiptNumber,
        donationId: donationId,
        transactionId: transactionId,
        issueDate: DateTime.now(),
        donorName: donorName,
        donorEmail: donorEmail,
        recipientName: donation.name,
        recipientSchool: donation.school,
        recipientEmail: donation.email ?? '',
        amount: amount,
        purpose: donation.story,
      );

      // Save receipt
      await _dbService.saveDonationReceipt(receipt.toJson());

      // Update donation with new amounts and history
      final updatedDonation = donation.copyWith(
        amountRaised: (donation.amountRaised ?? 0.0) + amount,
        totalDonationsReceived: donation.totalDonationsReceived + 1,
        lastDonationDate: DateTime.now(),
        totalAmountReceived: donation.totalAmountReceived + amount,
        updatedAt: DateTime.now(),
      );

      // Update in list
      _donations[donationIndex] = updatedDonation;

      // Save updated donations
      final donationsJson = _donations.map((d) => d.toJson()).toList();
      await _dbService.saveWebDonations(donationsJson);

      _errorMessage = null;
      notifyListeners();

      return receipt;
    } catch (e) {
      _errorMessage = 'Failed to process donation: $e';
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Get donation history for a specific donation
  Future<List<DonationTransaction>> getDonationHistory(int donationId) async {
    try {
      final transactionsMap = await _dbService.getDonationTransactions(donationId: donationId);
      return transactionsMap
          .map((t) => DonationTransaction.fromJson(t))
          .toList();
    } catch (e) {
      _errorMessage = 'Failed to load donation history: $e';
      return [];
    }
  }

  // Get receipts for a user
  Future<List<DonationReceipt>> getUserReceipts(String userEmail) async {
    try {
      final receiptsMap = await _dbService.getDonationReceipts(userEmail: userEmail);
      return receiptsMap
          .map((r) => DonationReceipt.fromJson(r))
          .toList();
    } catch (e) {
      _errorMessage = 'Failed to load receipts: $e';
      return [];
    }
  }

  // Get donations sorted by priority
  List<Donation> get donationsByPriority {
    final sortedDonations = List<Donation>.from(_donations);
    sortedDonations.sort((a, b) => b.priorityScore.compareTo(a.priorityScore));
    return sortedDonations;
  }

  // Get only verified donations
  List<Donation> get verifiedDonations {
    return _donations.where((d) => d.isVerified).toList();
  }

  // Submit a new donation request
  Future<bool> submitDonationRequest({
    required String studentName,
    required String studentEmail,
    required String school,
    required String story,
    String? phone,
    required double targetAmount,
    required String category,
    String? location,
    bool isUrgent = false,
  }) async {
    try {
      _setLoading(true);

      final newDonation = Donation(
        id: DateTime.now().millisecondsSinceEpoch,
        name: studentName,
        school: school,
        story: story,
        email: studentEmail,
        phone: phone,
        targetAmount: targetAmount,
        amountRaised: 0.0,
        category: category,
        status: DonationStatus.active,
        createdAt: DateTime.now(),
        deadline: DateTime.now().add(const Duration(days: 60)),
        isUrgent: isUrgent,
        location: location,
        verificationStatus: VerificationStatus.unverified,
        totalDonationsReceived: 0,
        totalAmountReceived: 0.0,
      );

      _donations.add(newDonation);

      final donationsJson = _donations.map((d) => d.toJson()).toList();
      await _dbService.saveWebDonations(donationsJson);

      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to submit donation request: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Confirm receipt of donation (for recipients)
  Future<bool> confirmReceipt(int transactionId, String recipientEmail) async {
    try {
      final transactions = await _dbService.getDonationTransactions();
      final transactionIndex = transactions.indexWhere((t) => t['id'] == transactionId);

      if (transactionIndex == -1) {
        _errorMessage = 'Transaction not found';
        return false;
      }

      final transaction = DonationTransaction.fromJson(transactions[transactionIndex]);

      // Find the donation to verify recipient email
      final donation = _donations.firstWhere((d) => d.id == transaction.donationId);
      if (donation.email != recipientEmail) {
        _errorMessage = 'Unauthorized: Email does not match recipient';
        return false;
      }

      // Update transaction with confirmation
      final updatedTransaction = transaction.copyWith(
        recipientConfirmed: true,
        recipientConfirmedAt: DateTime.now(),
      );

      transactions[transactionIndex] = updatedTransaction.toJson();

      // Save back to database
      final prefs = await _dbService.database;
      final transactionsJson = transactions.map((t) => jsonEncode(t)).toList();
      await prefs.setStringList('donation_transactions', transactionsJson);

      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to confirm receipt: $e';
      return false;
    }
  }

  // Get pending confirmations for a recipient
  Future<List<DonationTransaction>> getPendingConfirmations(String recipientEmail) async {
    try {
      final allTransactions = await getDonationHistory(0); // Get all
      final recipientDonations = _donations.where((d) => d.email == recipientEmail).map((d) => d.id).toList();

      return allTransactions.where((t) =>
        recipientDonations.contains(t.donationId) && !t.recipientConfirmed
      ).toList();
    } catch (e) {
      _errorMessage = 'Failed to load pending confirmations: $e';
      return [];
    }
  }
}
