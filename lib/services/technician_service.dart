import 'package:ayoayo/models/technician.dart';
import 'package:flutter/foundation.dart';

class TechnicianService {
  static final TechnicianService _instance = TechnicianService._internal();

  factory TechnicianService() => _instance;

  TechnicianService._internal();

  // Get all vetted technicians - returns mock data
  Future<List<Technician>> getVettedTechnicians() async {
    print('📊 Returning mock technicians data');
    return _getMockTechnicians();
  }

  // Get technicians with advanced filtering
  Future<List<Technician>> getTechniciansWithFilter({
    String? specialization,
    String? location,
    double? minRating,
    int? minExperience,
    bool? onlyVetted,
    bool? onlyAvailable,
  }) async {
    List<Technician> mockTechnicians = _getMockTechnicians();

        // Apply filters to mock data
        if (specialization != null && specialization.isNotEmpty) {
          mockTechnicians = mockTechnicians.where((tech) =>
              tech.specialization.toLowerCase().contains(specialization.toLowerCase())).toList();
        }

        if (location != null && location.isNotEmpty) {
          mockTechnicians = mockTechnicians.where((tech) =>
              tech.city.toLowerCase().contains(location.toLowerCase()) ||
              tech.province.toLowerCase().contains(location.toLowerCase())).toList();
        }

        if (minRating != null && minRating > 0) {
          mockTechnicians = mockTechnicians.where((tech) => tech.rating >= minRating).toList();
        }

        if (minExperience != null && minExperience > 0) {
          mockTechnicians = mockTechnicians.where((tech) => tech.experienceYears >= minExperience).toList();
        }

        if (onlyVetted == true) {
          mockTechnicians = mockTechnicians.where((tech) => tech.isVetted).toList();
        }

    if (onlyAvailable != false) {
      mockTechnicians = mockTechnicians.where((tech) => tech.isAvailable).toList();
    }

    return mockTechnicians;
  }

  // Get technician by ID
  Future<Technician?> getTechnicianById(int id) async {
    final mockTechnicians = _getMockTechnicians();
    try {
      return mockTechnicians.firstWhere((tech) => tech.id == id);
    } catch (e) {
      debugPrint('Error getting technician by ID: $e');
      return null;
    }
  }

  // Get technician by technician ID
  Future<Technician?> getTechnicianByTechnicianId(String technicianId) async {
    final mockTechnicians = _getMockTechnicians();
    try {
      return mockTechnicians.firstWhere((tech) => tech.technicianId == technicianId);
    } catch (e) {
      debugPrint('Error getting technician by technician ID: $e');
      return null;
    }
  }

  // Add a new technician (mock implementation)
  Future<int> addTechnician(Technician technician) async {
    debugPrint('ℹ️ Add technician - using mock data, not persisted');
    return 1;
  }

  // Update technician information (mock implementation)
  Future<int> updateTechnician(Technician technician) async {
    debugPrint('ℹ️ Update technician - using mock data, not persisted');
    return 1;
  }

  // Delete technician (mock implementation)
  Future<int> deleteTechnician(int id) async {
    debugPrint('ℹ️ Delete technician - using mock data, not persisted');
    return 1;
  }

  // Get technicians who specialize in a specific device type
  Future<List<Technician>> getTechniciansForDeviceType(String deviceType) async {
    final mockTechnicians = _getMockTechnicians();

    // Filter technicians who specialize in the device type
    final List<Technician> technicians = mockTechnicians
        .where((tech) => tech.isAvailable && tech.specializesIn(deviceType))
        .toList();

    // Sort by rating and experience
    technicians.sort((a, b) {
      int ratingCompare = b.rating.compareTo(a.rating);
      if (ratingCompare != 0) return ratingCompare;
      return b.experienceYears.compareTo(a.experienceYears);
    });

    return technicians;
  }

  // Get top-rated technicians (limit results)
  Future<List<Technician>> getTopRatedTechnicians({int limit = 10}) async {
    final mockTechnicians = _getMockTechnicians();

    // Filter available and sort by rating
    final available = mockTechnicians.where((tech) => tech.isAvailable).toList();
    available.sort((a, b) {
      int ratingCompare = b.rating.compareTo(a.rating);
      if (ratingCompare != 0) return ratingCompare;
      return b.completedRepairs.compareTo(a.completedRepairs);
    });

    return available.take(limit).toList();
  }

  // Get technicians by experience level
  Future<List<Technician>> getTechniciansByExperienceLevel(String level) async {
    final mockTechnicians = _getMockTechnicians();

    int minYears = 0;
    int? maxYears;

    switch (level.toLowerCase()) {
      case 'beginner':
        maxYears = 2;
        break;
      case 'intermediate':
        minYears = 2;
        maxYears = 5;
        break;
      case 'experienced':
        minYears = 5;
        maxYears = 10;
        break;
      case 'expert':
        minYears = 10;
        break;
    }

    final filtered = mockTechnicians.where((tech) {
      if (!tech.isAvailable) return false;
      if (tech.experienceYears < minYears) return false;
      if (maxYears != null && tech.experienceYears >= maxYears) return false;
      return true;
    }).toList();

    filtered.sort((a, b) => b.rating.compareTo(a.rating));
    return filtered;
  }

  // Mock technician data for web fallback
  List<Technician> _getMockTechnicians() {
    return [
      Technician(
        id: 1,
        technicianId: 'TECH_001',
        name: 'Juan dela Cruz',
        specialization: 'Smartphones',
        location: 'Metro Manila',
        city: 'Quezon City',
        province: 'Metro Manila',
        rating: 4.8,
        experienceYears: 8,
        isVetted: true,
        contactPhone: '+63 912 345 6789',
        contactEmail: 'juan.delacruz@email.com',
        description: 'Expert smartphone technician with 8 years of experience. Specializes in iPhone and Android repairs.',
        skills: ['iPhone Repair', 'Android Repair', 'Screen Replacement', 'Battery Replacement'],
        certifications: ['Apple Certified Technician', 'Samsung Certified'],
        completedRepairs: 245,
        averageRating: 4.8,
        isAvailable: true,
      ),
      Technician(
        id: 2,
        technicianId: 'TECH_002',
        name: 'Maria Santos',
        specialization: 'Laptops',
        location: 'Cebu City',
        city: 'Cebu City',
        province: 'Cebu',
        rating: 4.6,
        experienceYears: 6,
        isVetted: true,
        contactPhone: '+63 917 456 7890',
        contactEmail: 'maria.santos@email.com',
        description: 'Professional laptop repair specialist with expertise in hardware and software issues.',
        skills: ['Hardware Repair', 'Software Troubleshooting', 'Data Recovery', 'Virus Removal'],
        certifications: ['Microsoft Certified', 'Comptia A+'],
        completedRepairs: 189,
        averageRating: 4.6,
        isAvailable: true,
      ),
      Technician(
        id: 3,
        technicianId: 'TECH_003',
        name: 'Pedro Reyes',
        specialization: 'Tablets & Wearables',
        location: 'Davao City',
        city: 'Davao City',
        province: 'Davao del Sur',
        rating: 4.7,
        experienceYears: 5,
        isVetted: true,
        contactPhone: '+63 918 567 8901',
        contactEmail: 'pedro.reyes@email.com',
        description: 'Specialized in tablet and wearable device repairs. Fast and reliable service in Davao City.',
        skills: ['Tablet Repair', 'Wearable Repair', 'Screen Replacement', 'Water Damage'],
        certifications: ['Google Certified Technician'],
        completedRepairs: 156,
        averageRating: 4.7,
        isAvailable: true,
      ),
    ];
  }

  // Seed initial technician data (not needed for mock implementation)
  Future<void> seedTechnicianData() async {
    debugPrint('ℹ️ Using mock technician data - no seeding needed');
  }
}
