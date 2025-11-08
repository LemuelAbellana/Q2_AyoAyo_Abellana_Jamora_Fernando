import '../utils/enum_helpers.dart';

enum DonationStatus { active, fulfilled, expired, cancelled }

enum VerificationStatus { unverified, pending, verified, rejected }

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

  // Verification and History fields
  final VerificationStatus verificationStatus;
  final String? verificationNotes;
  final String? studentIdImage; // Path/URL to student ID image
  final int totalDonationsReceived; // Number of donations received
  final DateTime? lastDonationDate; // Last time they received a donation
  final double totalAmountReceived; // Total amount received historically

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
    this.verificationStatus = VerificationStatus.unverified,
    this.verificationNotes,
    this.studentIdImage,
    this.totalDonationsReceived = 0,
    this.lastDonationDate,
    this.totalAmountReceived = 0.0,
  });

  // Helper getters
  bool get isActive => status == DonationStatus.active;
  bool get isFulfilled => status == DonationStatus.fulfilled;
  bool get isVerified => verificationStatus == VerificationStatus.verified;

  double get progress =>
      targetAmount != null && amountRaised != null && targetAmount! > 0
      ? (amountRaised! / targetAmount!).clamp(0.0, 1.0)
      : 0.0;

  // Calculate days since last donation (returns null if never received)
  int? get daysSinceLastDonation {
    if (lastDonationDate == null) return null;
    return DateTime.now().difference(lastDonationDate!).inDays;
  }

  // Calculate priority score (higher = more priority)
  // Factors: urgency, verification, time since last donation, funding gap
  double get priorityScore {
    double score = 0.0;

    // Verification status (40 points max)
    if (verificationStatus == VerificationStatus.verified) {
      score += 40.0;
    } else if (verificationStatus == VerificationStatus.pending) {
      score += 20.0;
    }

    // Urgency (20 points)
    if (isUrgent) {
      score += 20.0;
    }

    // Time since last donation (20 points max)
    final daysSince = daysSinceLastDonation;
    if (daysSince == null) {
      // Never received donation - highest priority
      score += 20.0;
    } else if (daysSince > 90) {
      score += 20.0;
    } else if (daysSince > 60) {
      score += 15.0;
    } else if (daysSince > 30) {
      score += 10.0;
    } else if (daysSince > 14) {
      score += 5.0;
    }

    // Funding gap (20 points max)
    if (targetAmount != null && amountRaised != null) {
      final gap = 1.0 - progress;
      score += gap * 20.0;
    }

    return score;
  }

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
      verificationStatus: parseEnumWithFallback(
        VerificationStatus.values,
        json['verification_status'],
        VerificationStatus.unverified,
      ),
      verificationNotes: json['verification_notes'],
      studentIdImage: json['student_id_image'],
      totalDonationsReceived: json['total_donations_received'] ?? 0,
      lastDonationDate: json['last_donation_date'] != null
          ? DateTime.parse(json['last_donation_date'])
          : null,
      totalAmountReceived: json['total_amount_received'] != null
          ? (json['total_amount_received'] as num).toDouble()
          : 0.0,
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
      'verification_status': getEnumName(verificationStatus),
      'verification_notes': verificationNotes,
      'student_id_image': studentIdImage,
      'total_donations_received': totalDonationsReceived,
      'last_donation_date': lastDonationDate?.toIso8601String(),
      'total_amount_received': totalAmountReceived,
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
    VerificationStatus? verificationStatus,
    String? verificationNotes,
    String? studentIdImage,
    int? totalDonationsReceived,
    DateTime? lastDonationDate,
    double? totalAmountReceived,
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
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verificationNotes: verificationNotes ?? this.verificationNotes,
      studentIdImage: studentIdImage ?? this.studentIdImage,
      totalDonationsReceived: totalDonationsReceived ?? this.totalDonationsReceived,
      lastDonationDate: lastDonationDate ?? this.lastDonationDate,
      totalAmountReceived: totalAmountReceived ?? this.totalAmountReceived,
    );
  }
}
