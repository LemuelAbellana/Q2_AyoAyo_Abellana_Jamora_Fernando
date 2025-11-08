import '../utils/enum_helpers.dart';

enum DonationStatus { active, fulfilled, expired, cancelled }

class Donation {
  final int id;
  final String name;
  final String school;
  final String story;
  final String? email;
  final String? phone;
  final double? targetAmount;
  final double? amountRaised;
  final String? category;
  final DonationStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deadline;
  final bool isUrgent;
  final List<String>? images;
  final String? location;

  Donation({
    required this.id,
    required this.name,
    required this.school,
    required this.story,
    this.email,
    this.phone,
    this.targetAmount,
    this.amountRaised,
    this.category,
    this.status = DonationStatus.active,
    this.createdAt,
    this.updatedAt,
    this.deadline,
    this.isUrgent = false,
    this.images,
    this.location,
  });

  // Helper getters
  bool get isActive => status == DonationStatus.active;
  bool get isFulfilled => status == DonationStatus.fulfilled;
  double get progress =>
      targetAmount != null && amountRaised != null && targetAmount! > 0
      ? (amountRaised! / targetAmount!).clamp(0.0, 1.0)
      : 0.0;

  // Create from JSON/map
  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      school: json['school'] ?? '',
      story: json['story'] ?? '',
      email: json['email'],
      phone: json['phone'],
      targetAmount: json['target_amount'] != null
          ? (json['target_amount'] as num).toDouble()
          : null,
      amountRaised: json['amount_raised'] != null
          ? (json['amount_raised'] as num).toDouble()
          : null,
      category: json['category'],
      status: parseEnumWithFallback(
        DonationStatus.values,
        json['status'],
        DonationStatus.active,
      ),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'])
          : null,
      isUrgent: json['is_urgent'] == 1 || json['is_urgent'] == true,
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      location: json['location'],
    );
  }

  // Convert to JSON/map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'school': school,
      'story': story,
      'email': email,
      'phone': phone,
      'target_amount': targetAmount,
      'amount_raised': amountRaised,
      'category': category,
      'status': getEnumName(status),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deadline': deadline?.toIso8601String(),
      'is_urgent': isUrgent,
      'images': images,
      'location': location,
    };
  }

  // Copy with method for updates
  Donation copyWith({
    int? id,
    String? name,
    String? school,
    String? story,
    String? email,
    String? phone,
    double? targetAmount,
    double? amountRaised,
    String? category,
    DonationStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deadline,
    bool? isUrgent,
    List<String>? images,
    String? location,
  }) {
    return Donation(
      id: id ?? this.id,
      name: name ?? this.name,
      school: school ?? this.school,
      story: story ?? this.story,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      targetAmount: targetAmount ?? this.targetAmount,
      amountRaised: amountRaised ?? this.amountRaised,
      category: category ?? this.category,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deadline: deadline ?? this.deadline,
      isUrgent: isUrgent ?? this.isUrgent,
      images: images ?? this.images,
      location: location ?? this.location,
    );
  }
}
