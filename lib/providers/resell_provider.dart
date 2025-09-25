import 'package:flutter/foundation.dart';
import 'package:ayoayo/services/resell_listing_dao.dart';
import 'package:ayoayo/models/resell_listing.dart';
import 'package:ayoayo/models/device_passport.dart';
import 'package:ayoayo/models/device_diagnosis.dart';
import 'package:ayoayo/services/ai_resell_service.dart';

class ResellProvider extends ChangeNotifier {
  final AIResellService _aiService;
  final ResellListingDao _resellListingDao;

  ResellProvider(String apiKey)
    : _aiService = AIResellService(apiKey),
      _resellListingDao = ResellListingDao();

  // State management
  List<ResellListing> _listings = [];
  List<ResellListing> _userListings = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<ResellListing> get listings => _listings;
  List<ResellListing> get userListings => _userListings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Filtered listings
  List<ResellListing> get activeListings => _listings
      .where((listing) => listing.status == ListingStatus.active)
      .toList();

  List<ResellListing> get featuredListings =>
      _listings.where((listing) => listing.isFeatured).toList();

  // Methods
  Future<void> loadListings() async {
    _setLoading(true);
    try {
      _listings = await _resellListingDao.getAllListings();

      // If no listings exist on web, create some sample data
      if (kIsWeb && _listings.isEmpty) {
        await _createSampleListings();
        _listings = await _resellListingDao.getAllListings();
      }

      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load listings: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _createSampleListings() async {
    try {
      // Sample device passports
      final sampleDevices = [
        DevicePassport(
          id: 'sample-device-1',
          userId: 'user-1',
          deviceModel: 'iPhone 13 Pro',
          manufacturer: 'Apple',
          yearOfRelease: 2021,
          operatingSystem: 'iOS 15',
          imageUrls: ['https://via.placeholder.com/300x300?text=iPhone+13+Pro'],
          lastDiagnosis: DiagnosisResult(
            deviceModel: 'iPhone 13 Pro',
            deviceHealth: DeviceHealth(
              screenCondition: ScreenCondition.excellent,
              hardwareCondition: HardwareCondition.excellent,
              identifiedIssues: [],
            ),
            valueEstimation: ValueEstimation(
              currentValue: 25000,
              postRepairValue: 25000,
              partsValue: 0,
              repairCost: 0,
              recyclingValue: 5000,
              currency: 'PHP',
              marketPositioning: 'Good value for money',
              depreciationRate: '15% per year',
            ),
            recommendations: [],
            aiAnalysis: 'Device is in excellent condition',
            confidenceScore: 0.95,
          ),
        ),
        DevicePassport(
          id: 'sample-device-2',
          userId: 'user-2',
          deviceModel: 'Samsung Galaxy S22',
          manufacturer: 'Samsung',
          yearOfRelease: 2022,
          operatingSystem: 'Android 12',
          imageUrls: ['https://via.placeholder.com/300x300?text=Samsung+S22'],
          lastDiagnosis: DiagnosisResult(
            deviceModel: 'Samsung Galaxy S22',
            deviceHealth: DeviceHealth(
              screenCondition: ScreenCondition.good,
              hardwareCondition: HardwareCondition.good,
              identifiedIssues: [],
            ),
            valueEstimation: ValueEstimation(
              currentValue: 22000,
              postRepairValue: 22000,
              partsValue: 0,
              repairCost: 0,
              recyclingValue: 4000,
              currency: 'PHP',
              marketPositioning: 'Competitive pricing',
              depreciationRate: '12% per year',
            ),
            recommendations: [],
            aiAnalysis: 'Device is in good condition',
            confidenceScore: 0.88,
          ),
        ),
      ];

      // Sample listings
      final sampleListings = [
        ResellListing(
          id: 'sample-1',
          sellerId: 'user-1',
          devicePassport: sampleDevices[0],
          category: ListingCategory.smartphone,
          condition: ConditionGrade.excellent,
          askingPrice: 25000,
          aiSuggestedPrice: 23500,
          title: 'iPhone 13 Pro 256GB - Like New Condition',
          description:
              'Barely used iPhone 13 Pro in excellent condition. Comes with original box and all accessories.',
          location: 'Facebook Marketplace',
          imageUrls: ['https://via.placeholder.com/300x300?text=iPhone+13+Pro'],
          status: ListingStatus.active,
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        ResellListing(
          id: 'sample-2',
          sellerId: 'user-2',
          devicePassport: sampleDevices[1],
          category: ListingCategory.smartphone,
          condition: ConditionGrade.good,
          askingPrice: 22000,
          aiSuggestedPrice: 21000,
          title: 'Samsung Galaxy S22 Ultra - Excellent Condition',
          description:
              'Samsung Galaxy S22 Ultra in great condition. Minor scratches on case but screen is perfect. All functions working perfectly.',
          location: 'SM Ecoland',
          imageUrls: ['https://via.placeholder.com/300x300?text=Samsung+S22'],
          status: ListingStatus.active,
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
        ),
      ];

      for (final listing in sampleListings) {
        await _resellListingDao.createListing(listing);
      }
    } catch (e) {
      print('Error creating sample listings: $e');
    }
  }

  Future<void> loadUserListings(String userId) async {
    _setLoading(true);
    try {
      _userListings = await _resellListingDao.getUserListings(userId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load user listings: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createListing({
    required DevicePassport devicePassport,
    required ConditionGrade condition,
    required double askingPrice,
    required String sellerId,
    required String location,
    String? customTitle,
    String? customDescription,
  }) async {
    _setLoading(true);
    try {
      // Generate AI-powered pricing strategy (but use user input for content)
      final pricingStrategy = await _aiService.generatePricingStrategy(
        devicePassport,
        condition,
        askingPrice,
      );

      // Use user-provided title and description, or generate fallback if empty
      final title = customTitle?.trim().isNotEmpty == true
          ? customTitle!
          : '${devicePassport.deviceModel} - ${devicePassport.manufacturer}';

      final description = customDescription?.trim().isNotEmpty == true
          ? customDescription!
          : 'Quality device in ${condition.toString().split('.').last} condition. '
                'Screen: ${devicePassport.lastDiagnosis.deviceHealth.screenCondition.name}, '
                'Hardware: ${devicePassport.lastDiagnosis.deviceHealth.hardwareCondition.name}. '
                'Help reduce e-waste by giving this device a second life!';

      // Create new listing
      final listing = ResellListing(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sellerId: sellerId,
        devicePassport: devicePassport,
        category: _determineCategory(devicePassport.deviceModel),
        condition: condition,
        askingPrice: askingPrice,
        aiSuggestedPrice: pricingStrategy.optimalPrice,
        title: title,
        description: description,
        location: location,
        imageUrls: devicePassport.imageUrls,
        status: ListingStatus.draft,
        createdAt: DateTime.now(),
      );

      await _resellListingDao.createListing(listing);

      // Refresh listings
      await loadListings();
      await loadUserListings(sellerId);

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create listing: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateListingStatus(
    String listingId,
    ListingStatus status,
  ) async {
    _setLoading(true);
    try {
      // Find existing listing
      final existingListing = _listings.firstWhere(
        (listing) => listing.id == listingId,
        orElse: () => _userListings.firstWhere(
          (listing) => listing.id == listingId,
          orElse: () => throw Exception('Listing not found'),
        ),
      );

      // Create updated listing
      final updatedListing = existingListing.copyWith(
        status: status,
        updatedAt: DateTime.now(),
        soldAt: status == ListingStatus.sold ? DateTime.now() : null,
      );

      await _resellListingDao.updateListing(updatedListing);

      // Update local lists
      final index = _listings.indexWhere((listing) => listing.id == listingId);
      if (index != -1) {
        _listings[index] = updatedListing;
      }

      final userIndex = _userListings.indexWhere(
        (listing) => listing.id == listingId,
      );
      if (userIndex != -1) {
        _userListings[userIndex] = updatedListing;
      }

      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update listing status: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> activateListing(String listingId) async {
    return updateListingStatus(listingId, ListingStatus.active);
  }

  Future<bool> deactivateListing(String listingId) async {
    return updateListingStatus(listingId, ListingStatus.draft);
  }

  Future<bool> markListingAsSold(String listingId) async {
    return updateListingStatus(listingId, ListingStatus.sold);
  }

  Future<List<String>> getSalesTips(String listingId) async {
    try {
      final listing = _listings.firstWhere((l) => l.id == listingId);
      return await _aiService.generateSalesTips(listing);
    } catch (e) {
      return [
        'Improve listing photos',
        'Write detailed description',
        'Price competitively',
        'Respond quickly to inquiries',
      ];
    }
  }

  Future<List<BuyerMatch>> findPotentialBuyers(String listingId) async {
    try {
      final listing = _listings.firstWhere((l) => l.id == listingId);
      return await _aiService.findPotentialBuyers(listing);
    } catch (e) {
      return [];
    }
  }

  void searchListings(String query) {
    // In a real app, this would filter listings based on search query
    // For now, we'll just notify listeners to trigger a rebuild
    notifyListeners();
  }

  void filterByCategory(ListingCategory category) {
    // Filter listings by category
    notifyListeners();
  }

  void sortListings(String sortBy) {
    switch (sortBy) {
      case 'price_low':
        _listings.sort((a, b) => a.askingPrice.compareTo(b.askingPrice));
        break;
      case 'price_high':
        _listings.sort((a, b) => b.askingPrice.compareTo(a.askingPrice));
        break;
      case 'newest':
        _listings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'oldest':
        _listings.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
    }
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  ListingCategory _determineCategory(String deviceModel) {
    final model = deviceModel.toLowerCase();
    if (model.contains('iphone') ||
        model.contains('samsung') ||
        model.contains('pixel')) {
      return ListingCategory.smartphone;
    } else if (model.contains('ipad') || model.contains('tablet')) {
      return ListingCategory.tablet;
    } else if (model.contains('macbook') || model.contains('laptop')) {
      return ListingCategory.laptop;
    } else if (model.contains('watch') || model.contains('band')) {
      return ListingCategory.wearable;
    } else {
      return ListingCategory.other;
    }
  }
}
