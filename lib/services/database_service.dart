import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;
  static SharedPreferences? _prefs;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<dynamic> get database async {
    if (kIsWeb) {
      // For web, use SharedPreferences
      return await _getPrefs();
    } else {
      // For mobile, use SQLite
      if (_database != null) return _database!;
      _database = await _initDatabase();
      return _database!;
    }
  }

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<Database> _initDatabase() async {
    // All platforms use native sqflite

    String path;

    // Use appropriate path based on platform
    if (Platform.isAndroid || Platform.isIOS) {
      // Mobile: use application documents directory
      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      path = join(documentsDirectory.path, 'ayoayo.db');
      print('Database path (Mobile): $path');
    } else {
      // Desktop: try project directory first, then fallback
      try {
        final currentDir = Directory.current;
        final dbDir = Directory(join(currentDir.path, 'database'));
        if (!await dbDir.exists()) {
          await dbDir.create(recursive: true);
        }
        path = join(dbDir.path, 'ayoayo.db');
        print('Database path (Desktop): $path');
      } catch (e) {
        // Fallback for desktop
        Directory documentsDirectory = await getApplicationDocumentsDirectory();
        path = join(documentsDirectory.path, 'ayoayo.db');
        print('Database path (Desktop Fallback): $path');
      }
    }

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Web-compatible methods for SharedPreferences
  Future<List<Map<String, dynamic>>> getWebListings() async {
    final prefs = await _getPrefs();
    final listingsJson = prefs.getStringList('resell_listings') ?? [];
    return listingsJson
        .map((json) => jsonDecode(json) as Map<String, dynamic>)
        .toList();
  }

  Future<void> saveWebListings(List<Map<String, dynamic>> listings) async {
    final prefs = await _getPrefs();
    final listingsJson = listings
        .map((listing) => jsonEncode(listing))
        .toList();
    await prefs.setStringList('resell_listings', listingsJson);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');

    // Create all tables in dependency order
    await _createTables(db);
    await _createIndexes(db);
    await _seedDonations(db);
  }

  Future<void> _seedDonations(Database db) async {
    final now = DateTime.now();

    await db.insert('donations', {
      'id': now.millisecondsSinceEpoch,
      'name': 'John Doe',
      'school': 'University of Example',
      'story':
          'John is a hardworking computer science student who needs a new laptop for his studies. His current device is 6 years old and frequently crashes during important assignments.',
      'email': 'john.doe@example.edu',
      'phone': '+63 917 123 4567',
      'target_amount': 25000,
      'amount_raised': 8500,
      'category': 'Education',
      'status': 'active',
      'created_at': now.subtract(const Duration(days: 14)).toIso8601String(),
      'deadline': now.add(const Duration(days: 30)).toIso8601String(),
      'is_urgent': 0,
      'location': 'Davao City',
      'is_active': 1,
    });

    await db.insert('donations', {
      'id': now.millisecondsSinceEpoch + 1,
      'name': 'Jane Smith',
      'school': 'Example High School',
      'story':
          'Jane is a talented digital art student who needs a new graphics tablet. Her current one broke during a crucial project deadline, and she needs to complete her portfolio for college applications.',
      'email': 'jane.smith@example.hs.edu.ph',
      'phone': '+63 918 234 5678',
      'target_amount': 15000,
      'amount_raised': 12000,
      'category': 'Arts & Design',
      'status': 'active',
      'created_at': now.subtract(const Duration(days: 7)).toIso8601String(),
      'deadline': now.add(const Duration(days: 20)).toIso8601String(),
      'is_urgent': 1,
      'location': 'Mandaluyong City',
      'is_active': 1,
    });

    await db.insert('donations', {
      'id': now.millisecondsSinceEpoch + 2,
      'name': 'Peter Jones',
      'school': 'Another University',
      'story':
          'Peter is a dedicated biology researcher who needs a new microscope for his thesis work. His current equipment is outdated and insufficient for the detailed analysis required for his research.',
      'email': 'peter.jones@research.uni.edu.ph',
      'phone': '+63 919 345 6789',
      'target_amount': 35000,
      'amount_raised': 5200,
      'category': 'Science & Research',
      'status': 'active',
      'created_at': now.subtract(const Duration(days: 21)).toIso8601String(),
      'deadline': now.add(const Duration(days: 45)).toIso8601String(),
      'is_urgent': 0,
      'location': 'Cebu City',
      'is_active': 1,
    });
  }

  Future<void> _createTables(Database db) async {
    // 1. Users table with OAuth support
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uid TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        display_name TEXT,
        photo_url TEXT,
        auth_provider TEXT NOT NULL DEFAULT 'email',
        provider_id TEXT,
        password_hash TEXT,
        email_verified BOOLEAN DEFAULT 0,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME,
        last_login_at DATETIME,
        is_active BOOLEAN DEFAULT 1,
        preferences TEXT
      )
    ''');

    // 2. Devices table
    await db.execute('''
      CREATE TABLE devices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        device_model TEXT NOT NULL,
        manufacturer TEXT NOT NULL,
        year_of_release INTEGER,
        operating_system TEXT,
        category TEXT,
        base_value DECIMAL(10,2),
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME
      )
    ''');

    // 3. Device images table
    await db.execute('''
      CREATE TABLE device_images (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        device_id INTEGER NOT NULL,
        image_path TEXT NOT NULL,
        image_type TEXT DEFAULT 'diagnostic',
        uploaded_by INTEGER NOT NULL,
        uploaded_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE CASCADE,
        FOREIGN KEY (uploaded_by) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // 4. Diagnoses table
    await db.execute('''
      CREATE TABLE diagnoses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        device_id INTEGER NOT NULL,
        diagnosis_uuid TEXT UNIQUE NOT NULL,
        battery_health DECIMAL(5,2),
        screen_condition TEXT,
        hardware_condition TEXT,
        identified_issues TEXT,
        ai_analysis TEXT,
        confidence_score DECIMAL(3,2),
        life_cycle_stage TEXT,
        remaining_useful_life TEXT,
        environmental_impact TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE CASCADE
      )
    ''');

    // 5. Value estimations table
    await db.execute('''
      CREATE TABLE value_estimations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        diagnosis_id INTEGER NOT NULL,
        current_value DECIMAL(10,2),
        post_repair_value DECIMAL(10,2),
        parts_value DECIMAL(10,2),
        repair_cost DECIMAL(10,2),
        recycling_value DECIMAL(10,2),
        currency TEXT DEFAULT 'PHP',
        market_positioning TEXT,
        depreciation_rate TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (diagnosis_id) REFERENCES diagnoses(id) ON DELETE CASCADE
      )
    ''');

    // 6. Device passports table
    await db.execute('''
      CREATE TABLE device_passports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        device_id INTEGER NOT NULL,
        passport_uuid TEXT UNIQUE NOT NULL,
        last_diagnosis_id INTEGER,
        is_active BOOLEAN DEFAULT 1,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE CASCADE,
        FOREIGN KEY (last_diagnosis_id) REFERENCES diagnoses(id) ON DELETE SET NULL
      )
    ''');

    // 7. Resell listings table
    await db.execute('''
      CREATE TABLE resell_listings (
        id TEXT PRIMARY KEY,
        seller_id TEXT NOT NULL,
        device_passport TEXT NOT NULL,
        category TEXT NOT NULL,
        condition TEXT NOT NULL,
        asking_price REAL NOT NULL,
        ai_suggested_price REAL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        location TEXT,
        image_urls TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        sold_at TEXT,
        buyer_id TEXT,
        ai_market_insights TEXT,
        interested_buyers TEXT,
        is_featured INTEGER DEFAULT 0,
        shipping_info TEXT
      )
    ''');

    // 8. Upcycling projects table
    await db.execute('''
      CREATE TABLE upcycling_projects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_uuid TEXT UNIQUE NOT NULL,
        creator_id INTEGER NOT NULL,
        passport_id INTEGER NOT NULL,
        category TEXT NOT NULL,
        difficulty TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        ai_generated_description TEXT,
        status TEXT DEFAULT 'planning',
        estimated_hours INTEGER DEFAULT 0,
        estimated_cost DECIMAL(10,2) DEFAULT 0,
        environmental_impact DECIMAL(5,2),
        is_public BOOLEAN DEFAULT 1,
        likes_count INTEGER DEFAULT 0,
        views_count INTEGER DEFAULT 0,
        tags TEXT,
        ai_insights TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME,
        completed_at DATETIME,
        FOREIGN KEY (creator_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (passport_id) REFERENCES device_passports(id) ON DELETE CASCADE
      )
    ''');

    // 9. Project steps table
    await db.execute('''
      CREATE TABLE project_steps (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        step_number INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        estimated_minutes INTEGER DEFAULT 0,
        materials_for_step TEXT,
        is_completed BOOLEAN DEFAULT 0,
        notes TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (project_id) REFERENCES upcycling_projects(id) ON DELETE CASCADE
      )
    ''');

    // 10. Technicians table
    await db.execute('''
      CREATE TABLE technicians (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        technician_id TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        specialization TEXT NOT NULL,
        location TEXT NOT NULL,
        city TEXT NOT NULL,
        province TEXT NOT NULL,
        rating DECIMAL(2,1) DEFAULT 0,
        experience_years INTEGER DEFAULT 0,
        is_vetted BOOLEAN DEFAULT 0,
        contact_phone TEXT NOT NULL,
        contact_email TEXT UNIQUE NOT NULL,
        profile_image_url TEXT,
        description TEXT,
        skills TEXT,
        certifications TEXT,
        completed_repairs INTEGER DEFAULT 0,
        average_rating DECIMAL(3,2) DEFAULT 0,
        is_available BOOLEAN DEFAULT 1,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME
      )
    ''');

    // 11. Donations table
    await db.execute('''
      CREATE TABLE donations (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        school TEXT NOT NULL,
        story TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        target_amount DECIMAL(10,2),
        amount_raised DECIMAL(10,2) DEFAULT 0,
        category TEXT,
        status TEXT DEFAULT 'active',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME,
        deadline DATETIME,
        is_urgent BOOLEAN DEFAULT 0,
        location TEXT,
        images TEXT,
        is_active BOOLEAN DEFAULT 1
      )
    ''');

    // 12. Device recognition history table
    await db.execute('''
      CREATE TABLE device_recognition_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        device_model TEXT NOT NULL,
        manufacturer TEXT NOT NULL,
        year_of_release INTEGER,
        operating_system TEXT,
        confidence_score DECIMAL(3,2),
        analysis_details TEXT,
        image_paths TEXT,
        recognition_timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
        device_passport_id INTEGER,
        is_saved BOOLEAN DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (device_passport_id) REFERENCES device_passports(id) ON DELETE SET NULL
      )
    ''');
  }

  Future<void> _createIndexes(Database db) async {
    // User indexes
    await db.execute('CREATE INDEX idx_users_email ON users(email)');
    await db.execute('CREATE INDEX idx_users_uid ON users(uid)');
    await db.execute('CREATE INDEX idx_users_provider ON users(auth_provider)');

    // Device indexes
    await db.execute('CREATE INDEX idx_devices_model ON devices(device_model)');
    await db.execute(
      'CREATE INDEX idx_devices_manufacturer ON devices(manufacturer)',
    );

    // Diagnosis indexes
    await db.execute(
      'CREATE INDEX idx_diagnoses_user_id ON diagnoses(user_id)',
    );
    await db.execute(
      'CREATE INDEX idx_diagnoses_device_id ON diagnoses(device_id)',
    );
    await db.execute(
      'CREATE INDEX idx_diagnoses_created_at ON diagnoses(created_at)',
    );

    // Passport indexes
    await db.execute(
      'CREATE INDEX idx_device_passports_user_id ON device_passports(user_id)',
    );
    await db.execute(
      'CREATE INDEX idx_device_passports_device_id ON device_passports(device_id)',
    );

    // Listing indexes
    await db.execute(
      'CREATE INDEX idx_resell_listings_seller_id ON resell_listings(seller_id)',
    );
    await db.execute(
      'CREATE INDEX idx_resell_listings_category ON resell_listings(category)',
    );
    await db.execute(
      'CREATE INDEX idx_resell_listings_status ON resell_listings(status)',
    );
    await db.execute(
      'CREATE INDEX idx_resell_listings_created_at ON resell_listings(created_at)',
    );

    // Project indexes
    await db.execute(
      'CREATE INDEX idx_upcycling_projects_creator_id ON upcycling_projects(creator_id)',
    );
    await db.execute(
      'CREATE INDEX idx_upcycling_projects_category ON upcycling_projects(category)',
    );
    await db.execute(
      'CREATE INDEX idx_upcycling_projects_status ON upcycling_projects(status)',
    );
    await db.execute(
      'CREATE INDEX idx_upcycling_projects_created_at ON upcycling_projects(created_at)',
    );

    // Step indexes
    await db.execute(
      'CREATE INDEX idx_project_steps_project_id ON project_steps(project_id)',
    );
    await db.execute(
      'CREATE INDEX idx_project_steps_step_number ON project_steps(step_number)',
    );

    // Technician indexes
    await db.execute(
      'CREATE INDEX idx_technicians_technician_id ON technicians(technician_id)',
    );
    await db.execute(
      'CREATE INDEX idx_technicians_specialization ON technicians(specialization)',
    );
    await db.execute('CREATE INDEX idx_technicians_city ON technicians(city)');
    await db.execute(
      'CREATE INDEX idx_technicians_province ON technicians(province)',
    );
    await db.execute(
      'CREATE INDEX idx_technicians_is_vetted ON technicians(is_vetted)',
    );
    await db.execute(
      'CREATE INDEX idx_technicians_rating ON technicians(rating)',
    );
    await db.execute(
      'CREATE INDEX idx_technicians_is_available ON technicians(is_available)',
    );

    // Donation indexes
    await db.execute(
      'CREATE INDEX idx_donations_is_active ON donations(is_active)',
    );

    // Device recognition history indexes
    await db.execute(
      'CREATE INDEX idx_device_recognition_user_id ON device_recognition_history(user_id)',
    );
    await db.execute(
      'CREATE INDEX idx_device_recognition_timestamp ON device_recognition_history(recognition_timestamp)',
    );
    await db.execute(
      'CREATE INDEX idx_device_recognition_manufacturer ON device_recognition_history(manufacturer)',
    );
  }

  Future<List<Map<String, dynamic>>> getWebDonations() async {
    final prefs = await _getPrefs();
    final donationsJson = prefs.getStringList('donations') ?? [];
    return donationsJson
        .map((json) => jsonDecode(json) as Map<String, dynamic>)
        .toList();
  }

  Future<void> saveWebDonations(List<Map<String, dynamic>> donations) async {
    final prefs = await _getPrefs();
    final donationsJson = donations
        .map((donation) => jsonEncode(donation))
        .toList();
    await prefs.setStringList('donations', donationsJson);
  }

  Future<List<Map<String, dynamic>>> getWebDevicePassports() async {
    final prefs = await _getPrefs();
    final devicesJson = prefs.getStringList('device_passports') ?? [];
    return devicesJson
        .map((json) => jsonDecode(json) as Map<String, dynamic>)
        .toList();
  }

  Future<void> saveWebDevicePassports(List<Map<String, dynamic>> devices) async {
    final prefs = await _getPrefs();
    final devicesJson = devices
        .map((device) => jsonEncode(device))
        .toList();
    await prefs.setStringList('device_passports', devicesJson);
  }

  Future<List<Map<String, dynamic>>> getDonations() async {
    if (kIsWeb) {
      return await getWebDonations();
    } else {
      final db = await database as Database;
      return await db.query(
        'donations',
        where: 'is_active = ?',
        whereArgs: [1],
      );
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
    if (oldVersion < 2 && newVersion >= 2) {
      // Add device recognition history table
      await db.execute('''
        CREATE TABLE device_recognition_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          device_model TEXT NOT NULL,
          manufacturer TEXT NOT NULL,
          year_of_release INTEGER,
          operating_system TEXT,
          confidence_score DECIMAL(3,2),
          analysis_details TEXT,
          image_paths TEXT,
          recognition_timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
          device_passport_id INTEGER,
          is_saved BOOLEAN DEFAULT 0,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
          FOREIGN KEY (device_passport_id) REFERENCES device_passports(id) ON DELETE SET NULL
        )
      ''');

      // Add indexes for the new table
      await db.execute(
        'CREATE INDEX idx_device_recognition_user_id ON device_recognition_history(user_id)',
      );
      await db.execute(
        'CREATE INDEX idx_device_recognition_timestamp ON device_recognition_history(recognition_timestamp)',
      );
      await db.execute(
        'CREATE INDEX idx_device_recognition_manufacturer ON device_recognition_history(manufacturer)',
      );
    }
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }

  // Utility method to check if database is ready
  Future<bool> isDatabaseReady() async {
    try {
      final db = await database;
      if (kIsWeb) {
        // Web uses SharedPreferences
        return true;
      } else {
        final result = await db.rawQuery('SELECT 1');
        return result.isNotEmpty;
      }
    } catch (e) {
      return false;
    }
  }

  // Upcycling projects methods
  Future<int> saveUpcyclingProject(Map<String, dynamic> project) async {
    if (kIsWeb) {
      return await _saveUpcyclingProjectWeb(project);
    } else {
      return await _saveUpcyclingProjectSQLite(project);
    }
  }

  Future<int> _saveUpcyclingProjectWeb(Map<String, dynamic> project) async {
    final prefs = await _getPrefs();
    final projects = await getUpcyclingProjects();

    // Generate ID for new project
    final newId = DateTime.now().millisecondsSinceEpoch;
    project['id'] = newId;

    projects.add(project);
    final projectsJson = projects.map((p) => jsonEncode(p)).toList();
    await prefs.setStringList('upcycling_projects', projectsJson);

    return newId;
  }

  Future<int> _saveUpcyclingProjectSQLite(Map<String, dynamic> project) async {
    final db = await database as Database;

    return await db.insert('upcycling_projects', {
      'project_uuid': project['project_uuid'] ?? '',
      'creator_id': project['creator_id'] ?? 1,
      'device_passport_id': project['device_passport_id'] ?? 1,
      'title': project['title'] ?? '',
      'description': project['description'] ?? '',
      'difficulty_level': project['difficulty_level'] ?? 'beginner',
      'category': project['category'] ?? 'other',
      'status': project['status'] ?? 'planning',
      'materials_needed': jsonEncode(project['materials_needed'] ?? []),
      'tools_required': jsonEncode(project['tools_required'] ?? []),
      'estimated_hours': project['estimated_hours'] ?? 0,
      'estimated_cost': project['estimated_cost'] ?? 0,
      'tags': jsonEncode(project['tags'] ?? []),
      'ai_insights': jsonEncode(project['ai_insights'] ?? {}),
      'environmental_impact': project['environmental_impact'] ?? 0.0,
      'is_public': project['is_public'] == true ? 1 : 0,
      'likes_count': project['likes_count'] ?? 0,
      'views_count': project['views_count'] ?? 0,
      'created_at': project['created_at'] ?? DateTime.now().toIso8601String(),
      'updated_at': project['updated_at'] ?? DateTime.now().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getUpcyclingProjects({
    String? creatorId,
  }) async {
    if (kIsWeb) {
      return await _getUpcyclingProjectsWeb(creatorId: creatorId);
    } else {
      return await _getUpcyclingProjectsSQLite(creatorId: creatorId);
    }
  }

  Future<List<Map<String, dynamic>>> _getUpcyclingProjectsWeb({
    String? creatorId,
  }) async {
    final prefs = await _getPrefs();
    final projectsJson = prefs.getStringList('upcycling_projects') ?? [];
    final projects = projectsJson
        .map((json) => jsonDecode(json) as Map<String, dynamic>)
        .toList();

    if (creatorId != null) {
      return projects
          .where((p) => p['creator_id']?.toString() == creatorId)
          .toList();
    }

    return projects;
  }

  Future<List<Map<String, dynamic>>> _getUpcyclingProjectsSQLite({
    String? creatorId,
  }) async {
    final db = await database as Database;

    String query = 'SELECT * FROM upcycling_projects';
    List<dynamic> args = [];

    if (creatorId != null) {
      query += ' WHERE creator_id = ?';
      args.add(creatorId);
    }

    query += ' ORDER BY created_at DESC';

    return await db.rawQuery(query, args);
  }

  Future<void> updateUpcyclingProjectStatus(
    String projectId,
    String status,
  ) async {
    if (kIsWeb) {
      await _updateUpcyclingProjectStatusWeb(projectId, status);
    } else {
      await _updateUpcyclingProjectStatusSQLite(projectId, status);
    }
  }

  Future<void> _updateUpcyclingProjectStatusWeb(
    String projectId,
    String status,
  ) async {
    final projects = await getUpcyclingProjects();
    final index = projects.indexWhere((p) => p['id'].toString() == projectId);

    if (index != -1) {
      projects[index]['status'] = status;
      projects[index]['updated_at'] = DateTime.now().toIso8601String();

      final prefs = await _getPrefs();
      final projectsJson = projects.map((p) => jsonEncode(p)).toList();
      await prefs.setStringList('upcycling_projects', projectsJson);
    }
  }

  Future<void> _updateUpcyclingProjectStatusSQLite(
    String projectId,
    String status,
  ) async {
    final db = await database as Database;

    await db.update(
      'upcycling_projects',
      {'status': status, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ? OR project_uuid = ?',
      whereArgs: [projectId, projectId],
    );
  }

  // Device recognition history methods
  Future<int> saveDeviceRecognitionHistory(Map<String, dynamic> recognition) async {
    if (kIsWeb) {
      return await _saveDeviceRecognitionHistoryWeb(recognition);
    } else {
      return await _saveDeviceRecognitionHistorySQLite(recognition);
    }
  }

  Future<int> _saveDeviceRecognitionHistoryWeb(Map<String, dynamic> recognition) async {
    final prefs = await _getPrefs();
    final history = await getDeviceRecognitionHistory();

    final newId = DateTime.now().millisecondsSinceEpoch;
    recognition['id'] = newId;

    history.add(recognition);
    final historyJson = history.map((h) => jsonEncode(h)).toList();
    await prefs.setStringList('device_recognition_history', historyJson);

    return newId;
  }

  Future<int> _saveDeviceRecognitionHistorySQLite(Map<String, dynamic> recognition) async {
    final db = await database as Database;

    return await db.insert('device_recognition_history', {
      'user_id': recognition['user_id'] ?? 1,
      'device_model': recognition['device_model'] ?? '',
      'manufacturer': recognition['manufacturer'] ?? '',
      'year_of_release': recognition['year_of_release'],
      'operating_system': recognition['operating_system'] ?? '',
      'confidence_score': recognition['confidence_score'] ?? 0.0,
      'analysis_details': recognition['analysis_details'] ?? '',
      'image_paths': jsonEncode(recognition['image_paths'] ?? []),
      'recognition_timestamp': recognition['recognition_timestamp'] ?? DateTime.now().toIso8601String(),
      'device_passport_id': recognition['device_passport_id'],
      'is_saved': recognition['is_saved'] == true ? 1 : 0,
    });
  }

  Future<List<Map<String, dynamic>>> getDeviceRecognitionHistory({
    String? userId,
    int? limit,
  }) async {
    if (kIsWeb) {
      return await _getDeviceRecognitionHistoryWeb(userId: userId, limit: limit);
    } else {
      return await _getDeviceRecognitionHistorySQLite(userId: userId, limit: limit);
    }
  }

  Future<List<Map<String, dynamic>>> _getDeviceRecognitionHistoryWeb({
    String? userId,
    int? limit,
  }) async {
    final prefs = await _getPrefs();
    final historyJson = prefs.getStringList('device_recognition_history') ?? [];
    final history = historyJson
        .map((json) => jsonDecode(json) as Map<String, dynamic>)
        .toList();

    if (userId != null) {
      history.removeWhere((h) => h['user_id']?.toString() != userId);
    }

    // Sort by timestamp descending
    history.sort((a, b) =>
        DateTime.parse(b['recognition_timestamp'] ?? '').compareTo(
            DateTime.parse(a['recognition_timestamp'] ?? '')));

    if (limit != null && history.length > limit) {
      return history.take(limit).toList();
    }

    return history;
  }

  Future<List<Map<String, dynamic>>> _getDeviceRecognitionHistorySQLite({
    String? userId,
    int? limit,
  }) async {
    final db = await database as Database;

    String query = 'SELECT * FROM device_recognition_history';
    List<dynamic> args = [];

    if (userId != null) {
      query += ' WHERE user_id = ?';
      args.add(userId);
    }

    query += ' ORDER BY recognition_timestamp DESC';

    if (limit != null) {
      query += ' LIMIT ?';
      args.add(limit);
    }

    return await db.rawQuery(query, args);
  }

  Future<void> updateDeviceRecognitionSaved(int recognitionId, bool isSaved) async {
    if (kIsWeb) {
      await _updateDeviceRecognitionSavedWeb(recognitionId, isSaved);
    } else {
      await _updateDeviceRecognitionSavedSQLite(recognitionId, isSaved);
    }
  }

  Future<void> _updateDeviceRecognitionSavedWeb(int recognitionId, bool isSaved) async {
    final history = await getDeviceRecognitionHistory();
    final index = history.indexWhere((h) => h['id'] == recognitionId);

    if (index != -1) {
      history[index]['is_saved'] = isSaved;

      final prefs = await _getPrefs();
      final historyJson = history.map((h) => jsonEncode(h)).toList();
      await prefs.setStringList('device_recognition_history', historyJson);
    }
  }

  Future<void> _updateDeviceRecognitionSavedSQLite(int recognitionId, bool isSaved) async {
    final db = await database as Database;

    await db.update(
      'device_recognition_history',
      {'is_saved': isSaved ? 1 : 0},
      where: 'id = ?',
      whereArgs: [recognitionId],
    );
  }

  // Get database path for debugging
  Future<String> getDatabasePath() async {
    if (kIsWeb) {
      return 'Web IndexedDB: ayoayo.db';
    } else {
      try {
        // Try project directory first
        final currentDir = Directory.current;
        final dbDir = Directory(join(currentDir.path, 'database'));
        return join(dbDir.path, 'ayoayo.db');
      } catch (e) {
        try {
          Directory documentsDirectory =
              await getApplicationDocumentsDirectory();
          return join(documentsDirectory.path, 'ayoayo.db');
        } catch (e2) {
          return 'Fallback: ayoayo.db';
        }
      }
    }
  }
}
