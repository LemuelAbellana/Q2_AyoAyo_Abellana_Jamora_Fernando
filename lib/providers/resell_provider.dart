import 'package:flutter/material.dart';
import 'package:ayoayo/models/resell_listing.dart';
import 'package:ayoayo/models/device_passport.dart';
import 'package:ayoayo/services/ai_resell_service.dart';

class ResellProvider extends ChangeNotifier {
  final AIResellService _aiService;

  ResellProvider(String apiKey) : _aiService = AIResellService(apiKey);

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
      // In a real app, this would fetch from a backend API
      // For now, we'll use mock data
      await Future.delayed(const Duration(seconds: 1));
      _listings = _generateMockListings();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load listings: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadUserListings(String userId) async {
    _setLoading(true);
    try {
      // Filter listings by user ID
      _userListings = _listings
          .where((listing) => listing.sellerId == userId)
          .toList();
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
  }) async {
    _setLoading(true);
    try {
      // Generate AI-powered listing content
      final listingContent = await _aiService.generateListingContent(
        devicePassport,
        condition,
      );

      // Generate pricing strategy
      final pricingStrategy = await _aiService.generatePricingStrategy(
        devicePassport,
        condition,
        askingPrice,
      );

      // Create new listing
      final listing = ResellListing(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sellerId: sellerId,
        devicePassport: devicePassport,
        category: _determineCategory(devicePassport.deviceModel),
        condition: condition,
        askingPrice: askingPrice,
        aiSuggestedPrice: pricingStrategy.optimalPrice,
        title: listingContent.title,
        description: listingContent.description,
        imageUrls: devicePassport.imageUrls,
        status: ListingStatus.draft,
        createdAt: DateTime.now(),
      );

      // Add to listings
      _listings.add(listing);
      _userListings.add(listing);

      // Generate market insights
      final marketInsights = await _aiService.analyzeCompetition(
        devicePassport.deviceModel,
        askingPrice,
      );

      // Update listing with insights
      final updatedListing = listing.copyWith(
        aiMarketInsights: {
          'marketPosition': marketInsights.pricePositioning,
          'uniqueAdvantages': marketInsights.uniqueAdvantages,
          'recommendedActions': marketInsights.recommendedActions,
        },
      );

      final index = _listings.indexWhere((l) => l.id == listing.id);
      if (index != -1) {
        _listings[index] = updatedListing;
        final userIndex = _userListings.indexWhere((l) => l.id == listing.id);
        if (userIndex != -1) {
          _userListings[userIndex] = updatedListing;
        }
      }

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
    try {
      final index = _listings.indexWhere((listing) => listing.id == listingId);
      if (index != -1) {
        final updatedListing = _listings[index].copyWith(
          status: status,
          updatedAt: DateTime.now(),
          soldAt: status == ListingStatus.sold ? DateTime.now() : null,
        );

        _listings[index] = updatedListing;

        final userIndex = _userListings.indexWhere(
          (listing) => listing.id == listingId,
        );
        if (userIndex != -1) {
          _userListings[userIndex] = updatedListing;
        }

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Failed to update listing: $e';
      return false;
    }
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

  List<ResellListing> _generateMockListings() {
    // Generate some mock listings for demonstration
    return [
      // Mock listings would be created here
    ];
  }
}

// Extension to copy ResellListing with modifications
extension ResellListingCopyWith on ResellListing {
  ResellListing copyWith({
    String? id,
    String? sellerId,
    DevicePassport? devicePassport,
    ListingCategory? category,
    ConditionGrade? condition,
    double? askingPrice,
    double? aiSuggestedPrice,
    String? title,
    String? description,
    List<String>? imageUrls,
    ListingStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? soldAt,
    String? buyerId,
    Map<String, dynamic>? aiMarketInsights,
    List<String>? interestedBuyers,
    bool? isFeatured,
    Map<String, dynamic>? shippingInfo,
  }) {
    return ResellListing(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      devicePassport: devicePassport ?? this.devicePassport,
      category: category ?? this.category,
      condition: condition ?? this.condition,
      askingPrice: askingPrice ?? this.askingPrice,
      aiSuggestedPrice: aiSuggestedPrice ?? this.aiSuggestedPrice,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      soldAt: soldAt ?? this.soldAt,
      buyerId: buyerId ?? this.buyerId,
      aiMarketInsights: aiMarketInsights ?? this.aiMarketInsights,
      interestedBuyers: interestedBuyers ?? this.interestedBuyers,
      isFeatured: isFeatured ?? this.isFeatured,
      shippingInfo: shippingInfo ?? this.shippingInfo,
    );
  }
}
