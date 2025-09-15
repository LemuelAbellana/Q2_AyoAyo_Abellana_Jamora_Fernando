class Technician {
  final int id;
  final String technicianId;
  final String name;
  final String specialization;
  final String location;
  final String city;
  final String province;
  final double rating;
  final int experienceYears;
  final bool isVetted;
  final String contactPhone;
  final String contactEmail;
  final String? profileImageUrl;
  final String description;
  final List<String> skills;
  final List<String> certifications;
  final int completedRepairs;
  final double averageRating;
  final bool isAvailable;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Technician({
    required this.id,
    required this.technicianId,
    required this.name,
    required this.specialization,
    required this.location,
    required this.city,
    required this.province,
    required this.rating,
    required this.experienceYears,
    required this.isVetted,
    required this.contactPhone,
    required this.contactEmail,
    this.profileImageUrl,
    required this.description,
    required this.skills,
    required this.certifications,
    required this.completedRepairs,
    required this.averageRating,
    required this.isAvailable,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor for creating a Technician from a JSON map
  factory Technician.fromJson(Map<String, dynamic> json) {
    return Technician(
      id: json['id'] ?? 0,
      technicianId: json['technician_id'] ?? '',
      name: json['name'] ?? '',
      specialization: json['specialization'] ?? '',
      location: json['location'] ?? '',
      city: json['city'] ?? '',
      province: json['province'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      experienceYears: json['experience_years'] ?? 0,
      isVetted: json['is_vetted'] == 1,
      contactPhone: json['contact_phone'] ?? '',
      contactEmail: json['contact_email'] ?? '',
      profileImageUrl: json['profile_image_url'],
      description: json['description'] ?? '',
      skills: json['skills'] != null
          ? List<String>.from(json['skills'].split(','))
          : [],
      certifications: json['certifications'] != null
          ? List<String>.from(json['certifications'].split(','))
          : [],
      completedRepairs: json['completed_repairs'] ?? 0,
      averageRating: (json['average_rating'] ?? 0).toDouble(),
      isAvailable: json['is_available'] == 1,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  // Method for converting a Technician to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'technician_id': technicianId,
      'name': name,
      'specialization': specialization,
      'location': location,
      'city': city,
      'province': province,
      'rating': rating,
      'experience_years': experienceYears,
      'is_vetted': isVetted ? 1 : 0,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
      'profile_image_url': profileImageUrl,
      'description': description,
      'skills': skills.join(','),
      'certifications': certifications.join(','),
      'completed_repairs': completedRepairs,
      'average_rating': averageRating,
      'is_available': isAvailable ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Helper method to get full location string
  String get fullLocation => '$city, $province';

  // Helper method to check if technician specializes in a specific device type
  bool specializesIn(String deviceType) {
    return specialization.toLowerCase().contains(deviceType.toLowerCase()) ||
           skills.any((skill) => skill.toLowerCase().contains(deviceType.toLowerCase()));
  }

  // Helper method to get display rating as string
  String get ratingDisplay => rating.toStringAsFixed(1);

  // Helper method to get experience level
  String get experienceLevel {
    if (experienceYears < 2) return 'Beginner';
    if (experienceYears < 5) return 'Intermediate';
    if (experienceYears < 10) return 'Experienced';
    return 'Expert';
  }
}
