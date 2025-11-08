import 'package:ayoayo/models/device_passport.dart';
import '../utils/enum_helpers.dart';

enum ListingStatus { draft, active, sold, expired, cancelled }

enum ListingCategory { smartphone, tablet, laptop, wearable, accessory, other }

enum ConditionGrade { excellent, good, fair, poor, damaged }

class ResellListing {
  final String id;
  final String sellerId;
  final DevicePassport devicePassport;
  final ListingCategory category;
  final ConditionGrade condition;
  final double askingPrice;
  final double? aiSuggestedPrice;
  final String title;
  final String description;
  final String? location;
  final List<String> imageUrls;
  final ListingStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? soldAt;
  final String? buyerId;
  final Map<String, dynamic>? aiMarketInsights;
  final List<String>? interestedBuyers;
  final bool isFeatured;
  final Map<String, dynamic>? shippingInfo;

  ResellListing({
    required this.id,
    required this.sellerId,
    required this.devicePassport,
    required this.category,
    required this.condition,
    required this.askingPrice,
    this.aiSuggestedPrice,
    required this.title,
    required this.description,
    this.location,
    required this.imageUrls,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.soldAt,
    this.buyerId,
    this.aiMarketInsights,
    this.interestedBuyers,
    this.isFeatured = false,
    this.shippingInfo,
  });

  factory ResellListing.fromJson(Map<String, dynamic> json) {
    return ResellListing(
      id: json['id'] ?? '',
      sellerId: json['sellerId'] ?? '',
      devicePassport: DevicePassport.fromJson(json['devicePassport'] ?? {}),
      category: parseEnumWithFallback(
        ListingCategory.values,
        json['category'],
        ListingCategory.other,
      ),
      condition: parseEnumWithFallback(
        ConditionGrade.values,
        json['condition'],
        ConditionGrade.good,
      ),
      askingPrice: (json['askingPrice'] ?? 0).toDouble(),
      aiSuggestedPrice: json['aiSuggestedPrice']?.toDouble(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'],
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      status: parseEnumWithFallback(
        ListingStatus.values,
        json['status'],
        ListingStatus.draft,
      ),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      soldAt: json['soldAt'] != null ? DateTime.parse(json['soldAt']) : null,
      buyerId: json['buyerId'],
      aiMarketInsights: json['aiMarketInsights'],
      interestedBuyers: json['interestedBuyers'] != null
          ? List<String>.from(json['interestedBuyers'])
          : null,
      isFeatured: json['isFeatured'] ?? false,
      shippingInfo: json['shippingInfo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sellerId': sellerId,
      'devicePassport': devicePassport.toJson(),
      'category': getEnumName(category),
      'condition': getEnumName(condition),
      'askingPrice': askingPrice,
      'aiSuggestedPrice': aiSuggestedPrice,
      'title': title,
      'description': description,
      'location': location,
      'imageUrls': imageUrls,
      'status': getEnumName(status),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'soldAt': soldAt?.toIso8601String(),
      'buyerId': buyerId,
      'aiMarketInsights': aiMarketInsights,
      'interestedBuyers': interestedBuyers,
      'isFeatured': isFeatured,
      'shippingInfo': shippingInfo,
    };
  }

  // Calculate days since listing was created
  int get daysActive => DateTime.now().difference(createdAt).inDays;

  // Calculate price difference from AI suggestion
  double get priceDifference {
    if (aiSuggestedPrice == null) return 0;
    return askingPrice - aiSuggestedPrice!;
  }

  // Get price difference percentage
  double get priceDifferencePercentage {
    if (aiSuggestedPrice == null || aiSuggestedPrice == 0) return 0;
    return (priceDifference / aiSuggestedPrice!) * 100;
  }

  // Check if price is within optimal range
  bool get isPriceOptimal {
    if (aiSuggestedPrice == null) return true;
    final difference = priceDifferencePercentage.abs();
    return difference <= 15; // Within 15% of AI suggestion
  }

  // Copy with method for updating listings
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
    String? location,
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
      location: location ?? this.location,
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
