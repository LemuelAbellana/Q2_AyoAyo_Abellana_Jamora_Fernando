import 'package:ayoayo/models/technician.dart';
import 'package:ayoayo/services/database_service.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class TechnicianService {
  static final TechnicianService _instance = TechnicianService._internal();
  static DatabaseService get _dbService => DatabaseService();

  factory TechnicianService() => _instance;

  TechnicianService._internal();

  // Get all vetted technicians
  Future<List<Technician>> getVettedTechnicians() async {
    try {
      if (kIsWeb) {
        print('🌐 Using mock data for web platform');
        return _getMockTechnicians();
      }

      final db = await _dbService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'technicians',
        where: 'is_vetted = ? AND is_available = ?',
        whereArgs: [1, 1],
        orderBy: 'rating DESC, completed_repairs DESC',
      );

      final technicians = List.generate(maps.length, (i) {
        return Technician.fromJson(maps[i]);
      });

      print('📊 Found ${technicians.length} vetted technicians in database');
      return technicians;
    } catch (e) {
      print('❌ Error getting vetted technicians: $e');
      // For web or when database fails, return mock data
      print('🔄 Falling back to mock data');
      return _getMockTechnicians();
    }
  }

  // Get technicians by specialization
  Future<List<Technician>> getTechniciansBySpecialization(String specialization) async {
    try {
      final db = await _dbService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'technicians',
        where: 'specialization LIKE ? AND is_available = ?',
        whereArgs: ['%$specialization%', 1],
        orderBy: 'rating DESC',
      );

      return List.generate(maps.length, (i) {
        return Technician.fromJson(maps[i]);
      });
    } catch (e) {
      print('Error getting technicians by specialization: $e');
      return [];
    }
  }

  // Get technicians by location (city or province)
  Future<List<Technician>> getTechniciansByLocation(String location) async {
    try {
      final db = await _dbService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'technicians',
        where: '(city LIKE ? OR province LIKE ? OR location LIKE ?) AND is_available = ?',
        whereArgs: ['%$location%', '%$location%', '%$location%', 1],
        orderBy: 'rating DESC',
      );

      return List.generate(maps.length, (i) {
        return Technician.fromJson(maps[i]);
      });
    } catch (e) {
      print('Error getting technicians by location: $e');
      return [];
    }
  }

  // Get technicians by rating (minimum rating)
  Future<List<Technician>> getTechniciansByRating(double minRating) async {
    try {
      final db = await _dbService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'technicians',
        where: 'rating >= ? AND is_available = ?',
        whereArgs: [minRating, 1],
        orderBy: 'rating DESC',
      );

      return List.generate(maps.length, (i) {
        return Technician.fromJson(maps[i]);
      });
    } catch (e) {
      print('Error getting technicians by rating: $e');
      return [];
    }
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
    try {
      // For web, use mock data filtering
      if (kIsWeb) {
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

      final db = await _dbService.database;

      List<String> whereConditions = [];
      List<dynamic> whereArgs = [];

      // Add filters dynamically
      if (specialization != null && specialization.isNotEmpty) {
        whereConditions.add('specialization LIKE ?');
        whereArgs.add('%$specialization%');
      }

      if (location != null && location.isNotEmpty) {
        whereConditions.add('(city LIKE ? OR province LIKE ? OR location LIKE ?)');
        whereArgs.addAll(['%$location%', '%$location%', '%$location%']);
      }

      if (minRating != null && minRating > 0) {
        whereConditions.add('rating >= ?');
        whereArgs.add(minRating);
      }

      if (minExperience != null && minExperience > 0) {
        whereConditions.add('experience_years >= ?');
        whereArgs.add(minExperience);
      }

      if (onlyVetted == true) {
        whereConditions.add('is_vetted = ?');
        whereArgs.add(1);
      }

      if (onlyAvailable != false) {
        whereConditions.add('is_available = ?');
        whereArgs.add(1);
      }

      String whereClause = whereConditions.isNotEmpty ? whereConditions.join(' AND ') : '';

      final List<Map<String, dynamic>> maps = await db.query(
        'technicians',
        where: whereClause.isNotEmpty ? whereClause : null,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: 'rating DESC, completed_repairs DESC',
      );

      return List.generate(maps.length, (i) {
        return Technician.fromJson(maps[i]);
      });
    } catch (e) {
      print('Error getting technicians with filter: $e');
      // Return filtered mock data as fallback
      return _getMockTechnicians();
    }
  }

  // Get technician by ID
  Future<Technician?> getTechnicianById(int id) async {
    try {
      final db = await _dbService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'technicians',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return Technician.fromJson(maps.first);
      }
      return null;
    } catch (e) {
      print('Error getting technician by ID: $e');
      return null;
    }
  }

  // Get technician by technician ID
  Future<Technician?> getTechnicianByTechnicianId(String technicianId) async {
    try {
      final db = await _dbService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'technicians',
        where: 'technician_id = ?',
        whereArgs: [technicianId],
      );

      if (maps.isNotEmpty) {
        return Technician.fromJson(maps.first);
      }
      return null;
    } catch (e) {
      print('Error getting technician by technician ID: $e');
      return null;
    }
  }

  // Add a new technician
  Future<int> addTechnician(Technician technician) async {
    try {
      final db = await _dbService.database;
      final data = technician.toJson();
      data.remove('id'); // Remove id for auto-increment
      data['updated_at'] = DateTime.now().toIso8601String();

      return await db.insert('technicians', data);
    } catch (e) {
      print('Error adding technician: $e');
      return 0;
    }
  }

  // Update technician information
  Future<int> updateTechnician(Technician technician) async {
    try {
      final db = await _dbService.database;
      final data = technician.toJson();
      data['updated_at'] = DateTime.now().toIso8601String();

      return await db.update(
        'technicians',
        data,
        where: 'id = ?',
        whereArgs: [technician.id],
      );
    } catch (e) {
      print('Error updating technician: $e');
      return 0;
    }
  }

  // Delete technician
  Future<int> deleteTechnician(int id) async {
    try {
      final db = await _dbService.database;
      return await db.delete(
        'technicians',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting technician: $e');
      return 0;
    }
  }

  // Get technicians who specialize in a specific device type
  Future<List<Technician>> getTechniciansForDeviceType(String deviceType) async {
    try {
      final db = await _dbService.database;

      // Get all available technicians first
      final List<Map<String, dynamic>> maps = await db.query(
        'technicians',
        where: 'is_available = ?',
        whereArgs: [1],
      );

      // Filter technicians who specialize in the device type
      final List<Technician> technicians = [];
      for (final map in maps) {
        final technician = Technician.fromJson(map);
        if (technician.specializesIn(deviceType)) {
          technicians.add(technician);
        }
      }

      // Sort by rating and experience
      technicians.sort((a, b) {
        int ratingCompare = b.rating.compareTo(a.rating);
        if (ratingCompare != 0) return ratingCompare;
        return b.experienceYears.compareTo(a.experienceYears);
      });

      return technicians;
    } catch (e) {
      print('Error getting technicians for device type: $e');
      return [];
    }
  }

  // Get top-rated technicians (limit results)
  Future<List<Technician>> getTopRatedTechnicians({int limit = 10}) async {
    try {
      final db = await _dbService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'technicians',
        where: 'is_available = ?',
        whereArgs: [1],
        orderBy: 'rating DESC, completed_repairs DESC',
        limit: limit,
      );

      return List.generate(maps.length, (i) {
        return Technician.fromJson(maps[i]);
      });
    } catch (e) {
      print('Error getting top-rated technicians: $e');
      return [];
    }
  }

  // Get technicians by experience level
  Future<List<Technician>> getTechniciansByExperienceLevel(String level) async {
    try {
      final db = await _dbService.database;

      String whereClause;
      switch (level.toLowerCase()) {
        case 'beginner':
          whereClause = 'experience_years < 2 AND is_available = 1';
          break;
        case 'intermediate':
          whereClause = 'experience_years >= 2 AND experience_years < 5 AND is_available = 1';
          break;
        case 'experienced':
          whereClause = 'experience_years >= 5 AND experience_years < 10 AND is_available = 1';
          break;
        case 'expert':
          whereClause = 'experience_years >= 10 AND is_available = 1';
          break;
        default:
          whereClause = 'is_available = 1';
      }

      final List<Map<String, dynamic>> maps = await db.query(
        'technicians',
        where: whereClause,
        orderBy: 'rating DESC',
      );

      return List.generate(maps.length, (i) {
        return Technician.fromJson(maps[i]);
      });
    } catch (e) {
      print('Error getting technicians by experience level: $e');
      return [];
    }
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

  // Seed initial technician data
  Future<void> seedTechnicianData() async {
    try {
      // Skip seeding for web since we use mock data
      if (kIsWeb) {
        print('Web platform detected - using mock technician data');
        return;
      }

      final db = await _dbService.database;

      // Check if technicians already exist
      final existingCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM technicians'),
      );

      if (existingCount != null && existingCount > 0) {
        print('Technician data already exists, skipping seed');
        return;
      }

      // Sample technician data
      final technicians = [
        {
          'technician_id': 'TECH_001',
          'name': 'Juan dela Cruz',
          'specialization': 'Smartphones',
          'location': 'Metro Manila',
          'city': 'Quezon City',
          'province': 'Metro Manila',
          'rating': 4.8,
          'experience_years': 8,
          'is_vetted': 1,
          'contact_phone': '+63 912 345 6789',
          'contact_email': 'juan.delacruz@email.com',
          'profile_image_url': null,
          'description': 'Expert smartphone technician with 8 years of experience. Specializes in iPhone and Android repairs.',
          'skills': 'iPhone Repair,Android Repair,Screen Replacement,Battery Replacement',
          'certifications': 'Apple Certified Technician,Samsung Certified',
          'completed_repairs': 245,
          'average_rating': 4.8,
          'is_available': 1,
        },
        {
          'technician_id': 'TECH_002',
          'name': 'Maria Santos',
          'specialization': 'Laptops',
          'location': 'Cebu City',
          'city': 'Cebu City',
          'province': 'Cebu',
          'rating': 4.6,
          'experience_years': 6,
          'is_vetted': 1,
          'contact_phone': '+63 917 456 7890',
          'contact_email': 'maria.santos@email.com',
          'profile_image_url': null,
          'description': 'Professional laptop repair specialist with expertise in hardware and software issues.',
          'skills': 'Hardware Repair,Software Troubleshooting,Data Recovery,Virus Removal',
          'certifications': 'Microsoft Certified,Comptia A+',
          'completed_repairs': 189,
          'average_rating': 4.6,
          'is_available': 1,
        },
        {
          'technician_id': 'TECH_003',
          'name': 'Pedro Reyes',
          'specialization': 'Tablets & Wearables',
          'location': 'Davao City',
          'city': 'Davao City',
          'province': 'Davao del Sur',
          'rating': 4.7,
          'experience_years': 5,
          'is_vetted': 1,
          'contact_phone': '+63 918 567 8901',
          'contact_email': 'pedro.reyes@email.com',
          'profile_image_url': null,
          'description': 'Specialized in tablet and wearable device repairs. Fast and reliable service in Davao City.',
          'skills': 'Tablet Repair,Wearable Repair,Screen Replacement,Water Damage',
          'certifications': 'Google Certified Technician',
          'completed_repairs': 156,
          'average_rating': 4.7,
          'is_available': 1,
        },
        {
          'technician_id': 'TECH_004',
          'name': 'Ana Gonzales',
          'specialization': 'Gaming Consoles',
          'location': 'Makati',
          'city': 'Makati',
          'province': 'Metro Manila',
          'rating': 4.9,
          'experience_years': 7,
          'is_vetted': 1,
          'contact_phone': '+63 919 678 9012',
          'contact_email': 'ana.gonzales@email.com',
          'profile_image_url': null,
          'description': 'Gaming console expert with extensive knowledge of PlayStation, Xbox, and Nintendo systems.',
          'skills': 'PlayStation Repair,Xbox Repair,Nintendo Repair,Controller Repair',
          'certifications': 'Sony Certified,Xbox Authorized',
          'completed_repairs': 203,
          'average_rating': 4.9,
          'is_available': 1,
        },
        {
          'technician_id': 'TECH_005',
          'name': 'Carlos Mendoza',
          'specialization': 'Desktop Computers',
          'location': 'Baguio City',
          'city': 'Baguio City',
          'province': 'Benguet',
          'rating': 4.5,
          'experience_years': 9,
          'is_vetted': 1,
          'contact_phone': '+63 920 789 0123',
          'contact_email': 'carlos.mendoza@email.com',
          'profile_image_url': null,
          'description': 'Desktop computer specialist with deep knowledge of hardware components and custom builds.',
          'skills': 'PC Building,Hardware Upgrade,Motherboard Repair,Custom Cooling',
          'certifications': 'Intel Certified,AMD Certified',
          'completed_repairs': 278,
          'average_rating': 4.5,
          'is_available': 1,
        },
      ];

      // Insert technicians into database
      for (final technicianData in technicians) {
        await db.insert('technicians', technicianData);
      }

      print('Successfully seeded ${technicians.length} technicians');
    } catch (e) {
      print('Error seeding technician data: $e');
    }
  }
}
