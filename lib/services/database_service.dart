import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (kIsWeb) {
      // For web, we can't use SQLite directly, so we'll use a mock database
      // The actual data operations will be handled by SharedPreferences
      throw UnsupportedError(
        'SQLite not supported on web. Use web-compatible methods.',
      );
    }
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path;

    if (kIsWeb) {
      // For web, use IndexedDB through sqflite_common_ffi_web
      path = 'ayoayo.db';
      print('Database path (Web): IndexedDB - $path');
    } else {
      // For development/testing, use a local path in project directory
      try {
        // Try to use project directory for easier database inspection
        final currentDir = Directory.current;
        final dbDir = Directory(join(currentDir.path, 'database'));
        if (!await dbDir.exists()) {
          await dbDir.create(recursive: true);
        }
        path = join(dbDir.path, 'ayoayo.db');
        print('Database path (Development): $path');
      } catch (e) {
        // Fallback to application documents directory
        try {
          Directory documentsDirectory =
              await getApplicationDocumentsDirectory();
          path = join(documentsDirectory.path, 'ayoayo.db');
          print('Database path (Documents): $path');
        } catch (e2) {
          // Final fallback
          path = 'ayoayo.db';
          print('Database path (Fallback): $path');
        }
      }
    }

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');

    // Create all tables in dependency order
    await _createTables(db);
    await _createIndexes(db);
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
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        listing_uuid TEXT UNIQUE NOT NULL,
        seller_id INTEGER NOT NULL,
        passport_id INTEGER NOT NULL,
        category TEXT NOT NULL,
        condition TEXT NOT NULL,
        asking_price DECIMAL(10,2) NOT NULL,
        ai_suggested_price DECIMAL(10,2),
        title TEXT NOT NULL,
        description TEXT,
        status TEXT DEFAULT 'draft',
        is_featured BOOLEAN DEFAULT 0,
        ai_market_insights TEXT,
        shipping_info TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME,
        expires_at DATETIME,
        sold_at DATETIME,
        buyer_id INTEGER,
        FOREIGN KEY (seller_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (passport_id) REFERENCES device_passports(id) ON DELETE CASCADE,
        FOREIGN KEY (buyer_id) REFERENCES users(id) ON DELETE SET NULL
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
    await db.execute(
      'CREATE INDEX idx_technicians_city ON technicians(city)',
    );
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
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
    if (oldVersion < newVersion) {
      // Migration logic for future versions
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
      final result = await db.rawQuery('SELECT 1');
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
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
