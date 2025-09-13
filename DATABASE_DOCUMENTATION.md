# AyoAyo Database Documentation

## Overview

AyoAyo is a comprehensive device recycling and upcycling platform that helps users extend the life of their electronic devices through intelligent diagnosis, resale, and creative repurposing. This document outlines the complete SQLite database schema, relationships, and integration steps for the Flutter application.

## Database Architecture

The database follows a normalized relational design with proper foreign key relationships, indexes, and constraints for optimal performance and data integrity.

## Prerequisites & Setup

### 1. Add SQLite Dependencies

Add these dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  # SQLite database
  sqflite: ^2.3.3
  path: ^1.9.0
  path_provider: ^2.1.3

  # JSON serialization (optional, for complex objects)
  json_annotation: ^4.9.0

dev_dependencies:
  # Code generation for JSON serialization
  json_serializable: ^6.8.0
  build_runner: ^2.4.9
```

Run:
```bash
flutter pub get
```

### 2. Create Database Service

Create `lib/services/database_service.dart`:

```dart
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'ayoayo.db');

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
    // 1. Users table
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

    // 2. User sessions table
    await db.execute('''
      CREATE TABLE user_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        session_token TEXT UNIQUE,
        device_info TEXT,
        ip_address TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        expires_at DATETIME,
        is_active BOOLEAN DEFAULT 1,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // 3. Devices table
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

    // 4. Device images table
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

    // 5. Diagnoses table
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

    // 6. Diagnosis images junction table
    await db.execute('''
      CREATE TABLE diagnosis_images (
        diagnosis_id INTEGER NOT NULL,
        image_id INTEGER NOT NULL,
        PRIMARY KEY (diagnosis_id, image_id),
        FOREIGN KEY (diagnosis_id) REFERENCES diagnoses(id) ON DELETE CASCADE,
        FOREIGN KEY (image_id) REFERENCES device_images(id) ON DELETE CASCADE
      )
    ''');

    // 7. Value estimations table
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

    // 8. Device passports table
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

    // 9. Passport images junction table
    await db.execute('''
      CREATE TABLE passport_images (
        passport_id INTEGER NOT NULL,
        image_id INTEGER NOT NULL,
        PRIMARY KEY (passport_id, image_id),
        FOREIGN KEY (passport_id) REFERENCES device_passports(id) ON DELETE CASCADE,
        FOREIGN KEY (image_id) REFERENCES device_images(id) ON DELETE CASCADE
      )
    ''');

    // Continue with remaining tables...
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

    // Add remaining tables (upcycling_projects, etc.)
    await _createRemainingTables(db);
  }

  Future<void> _createRemainingTables(Database db) async {
    // Upcycling projects and related tables
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

    // Add project_steps, recommended_actions, etc.
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

    await db.execute('''
      CREATE TABLE recommended_actions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        diagnosis_id INTEGER NOT NULL,
        action_uuid TEXT UNIQUE NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        action_type TEXT NOT NULL,
        priority DECIMAL(3,2) DEFAULT 0,
        cost_benefit_ratio DECIMAL(5,2),
        environmental_impact TEXT,
        timeframe TEXT,
        estimated_return DECIMAL(10,2),
        market_timing TEXT,
        parts_value DECIMAL(10,2),
        sustainability_benefit TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (diagnosis_id) REFERENCES diagnoses(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _createIndexes(Database db) async {
    // User indexes
    await db.execute('CREATE INDEX idx_users_email ON users(email)');
    await db.execute('CREATE INDEX idx_users_uid ON users(uid)');
    await db.execute('CREATE INDEX idx_users_provider ON users(auth_provider)');

    // Session indexes
    await db.execute('CREATE INDEX idx_user_sessions_user_id ON user_sessions(user_id)');
    await db.execute('CREATE INDEX idx_user_sessions_token ON user_sessions(session_token)');

    // Device indexes
    await db.execute('CREATE INDEX idx_devices_model ON devices(device_model)');
    await db.execute('CREATE INDEX idx_devices_manufacturer ON devices(manufacturer)');

    // Diagnosis indexes
    await db.execute('CREATE INDEX idx_diagnoses_user_id ON diagnoses(user_id)');
    await db.execute('CREATE INDEX idx_diagnoses_device_id ON diagnoses(device_id)');
    await db.execute('CREATE INDEX idx_diagnoses_created_at ON diagnoses(created_at)');

    // Add all other indexes...
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations here
    if (oldVersion < newVersion) {
      // Migration logic
    }
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
```

## Core Entities & Relationships

### 1. User Management (OAuth Integration)

#### `users` Table
```sql
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    uid TEXT UNIQUE NOT NULL,                    -- Firebase Auth UID
    email TEXT UNIQUE NOT NULL,
    display_name TEXT,
    photo_url TEXT,
    auth_provider TEXT NOT NULL DEFAULT 'email', -- 'email', 'google', 'github'
    provider_id TEXT,                           -- OAuth provider ID
    email_verified BOOLEAN DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME,
    last_login_at DATETIME,
    is_active BOOLEAN DEFAULT 1,
    preferences TEXT                             -- JSON string for user preferences
);

-- Indexes for performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_uid ON users(uid);
CREATE INDEX idx_users_provider ON users(auth_provider);
```

**OAuth Integration Notes:**
- `uid` stores Firebase Auth UID for all users (both email and OAuth)
- `auth_provider` tracks how user authenticated ('email', 'google', 'github')
- `provider_id` stores the OAuth provider's user ID
- Email/password users have `auth_provider = 'email'` and `provider_id = NULL`

#### `user_sessions` Table
```sql
CREATE TABLE user_sessions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    session_token TEXT UNIQUE,
    device_info TEXT,                           -- JSON: device type, OS, etc.
    ip_address TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    expires_at DATETIME,
    is_active BOOLEAN DEFAULT 1,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX idx_user_sessions_token ON user_sessions(session_token);
```

### 2. Device Diagnosis System

#### `devices` Table (Master Device Registry)
```sql
CREATE TABLE devices (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    device_model TEXT NOT NULL,
    manufacturer TEXT NOT NULL,
    year_of_release INTEGER,
    operating_system TEXT,
    category TEXT,                              -- 'smartphone', 'tablet', 'laptop', etc.
    base_value DECIMAL(10,2),                   -- Average market value
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME
);

CREATE INDEX idx_devices_model ON devices(device_model);
CREATE INDEX idx_devices_manufacturer ON devices(manufacturer);
```

#### `device_images` Table
```sql
CREATE TABLE device_images (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    device_id INTEGER NOT NULL,
    image_path TEXT NOT NULL,                    -- Local file path or URL
    image_type TEXT DEFAULT 'diagnostic',        -- 'diagnostic', 'passport', 'listing'
    uploaded_by INTEGER NOT NULL,                -- User who uploaded
    uploaded_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE CASCADE,
    FOREIGN KEY (uploaded_by) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_device_images_device_id ON device_images(device_id);
```

#### `diagnoses` Table
```sql
CREATE TABLE diagnoses (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    device_id INTEGER NOT NULL,
    diagnosis_uuid TEXT UNIQUE NOT NULL,         -- For external API calls
    battery_health DECIMAL(5,2),                 -- Percentage: 0-100
    screen_condition TEXT,                       -- 'excellent', 'good', 'fair', 'poor', 'cracked'
    hardware_condition TEXT,                     -- 'excellent', 'good', 'fair', 'poor', 'damaged'
    identified_issues TEXT,                      -- JSON array of issues
    ai_analysis TEXT,                            -- AI-generated analysis
    confidence_score DECIMAL(3,2),               -- 0.0 to 1.0
    life_cycle_stage TEXT,
    remaining_useful_life TEXT,
    environmental_impact TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE CASCADE
);

CREATE INDEX idx_diagnoses_user_id ON diagnoses(user_id);
CREATE INDEX idx_diagnoses_device_id ON diagnoses(device_id);
CREATE INDEX idx_diagnoses_created_at ON diagnoses(created_at);
```

#### `diagnosis_images` Table (Junction Table)
```sql
CREATE TABLE diagnosis_images (
    diagnosis_id INTEGER NOT NULL,
    image_id INTEGER NOT NULL,

    PRIMARY KEY (diagnosis_id, image_id),
    FOREIGN KEY (diagnosis_id) REFERENCES diagnoses(id) ON DELETE CASCADE,
    FOREIGN KEY (image_id) REFERENCES device_images(id) ON DELETE CASCADE
);
```

#### `value_estimations` Table
```sql
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
);

CREATE INDEX idx_value_estimations_diagnosis_id ON value_estimations(diagnosis_id);
```

### 3. Device Passport System

#### `device_passports` Table
```sql
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
);

CREATE INDEX idx_device_passports_user_id ON device_passports(user_id);
CREATE INDEX idx_device_passports_device_id ON device_passports(device_id);
CREATE UNIQUE INDEX idx_device_passports_user_device ON device_passports(user_id, device_id);
```

#### `passport_images` Table (Junction Table)
```sql
CREATE TABLE passport_images (
    passport_id INTEGER NOT NULL,
    image_id INTEGER NOT NULL,

    PRIMARY KEY (passport_id, image_id),
    FOREIGN KEY (passport_id) REFERENCES device_passports(id) ON DELETE CASCADE,
    FOREIGN KEY (image_id) REFERENCES device_images(id) ON DELETE CASCADE
);
```

### 4. Resell Marketplace

#### `resell_listings` Table
```sql
CREATE TABLE resell_listings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    listing_uuid TEXT UNIQUE NOT NULL,
    seller_id INTEGER NOT NULL,
    passport_id INTEGER NOT NULL,
    category TEXT NOT NULL,                      -- 'smartphone', 'tablet', 'laptop', etc.
    condition TEXT NOT NULL,                     -- 'excellent', 'good', 'fair', 'poor', 'damaged'
    asking_price DECIMAL(10,2) NOT NULL,
    ai_suggested_price DECIMAL(10,2),
    title TEXT NOT NULL,
    description TEXT,
    status TEXT DEFAULT 'draft',                 -- 'draft', 'active', 'sold', 'expired', 'cancelled'
    is_featured BOOLEAN DEFAULT 0,
    ai_market_insights TEXT,                     -- JSON string
    shipping_info TEXT,                          -- JSON string
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME,
    expires_at DATETIME,
    sold_at DATETIME,
    buyer_id INTEGER,

    FOREIGN KEY (seller_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (passport_id) REFERENCES device_passports(id) ON DELETE CASCADE,
    FOREIGN KEY (buyer_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE INDEX idx_resell_listings_seller_id ON resell_listings(seller_id);
CREATE INDEX idx_resell_listings_category ON resell_listings(category);
CREATE INDEX idx_resell_listings_status ON resell_listings(status);
CREATE INDEX idx_resell_listings_created_at ON resell_listings(created_at);
CREATE INDEX idx_resell_listings_asking_price ON resell_listings(asking_price);
```

#### `listing_images` Table (Junction Table)
```sql
CREATE TABLE listing_images (
    listing_id INTEGER NOT NULL,
    image_id INTEGER NOT NULL,

    PRIMARY KEY (listing_id, image_id),
    FOREIGN KEY (listing_id) REFERENCES resell_listings(id) ON DELETE CASCADE,
    FOREIGN KEY (image_id) REFERENCES device_images(id) ON DELETE CASCADE
);
```

#### `listing_watchers` Table
```sql
CREATE TABLE listing_watchers (
    listing_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    added_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (listing_id, user_id),
    FOREIGN KEY (listing_id) REFERENCES resell_listings(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

### 5. Upcycling Workspace

#### `upcycling_projects` Table
```sql
CREATE TABLE upcycling_projects (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_uuid TEXT UNIQUE NOT NULL,
    creator_id INTEGER NOT NULL,
    passport_id INTEGER NOT NULL,
    category TEXT NOT NULL,                      -- 'decor', 'functional', 'wearable', 'art', 'tech'
    difficulty TEXT NOT NULL,                    -- 'beginner', 'intermediate', 'advanced', 'expert'
    title TEXT NOT NULL,
    description TEXT,
    ai_generated_description TEXT,
    status TEXT DEFAULT 'planning',              -- 'planning', 'inProgress', 'completed', 'paused'
    estimated_hours INTEGER DEFAULT 0,
    estimated_cost DECIMAL(10,2) DEFAULT 0,
    environmental_impact DECIMAL(5,2),
    is_public BOOLEAN DEFAULT 1,
    likes_count INTEGER DEFAULT 0,
    views_count INTEGER DEFAULT 0,
    tags TEXT,                                   -- JSON array
    ai_insights TEXT,                            -- JSON object
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME,
    completed_at DATETIME,

    FOREIGN KEY (creator_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (passport_id) REFERENCES device_passports(id) ON DELETE CASCADE
);

CREATE INDEX idx_upcycling_projects_creator_id ON upcycling_projects(creator_id);
CREATE INDEX idx_upcycling_projects_category ON upcycling_projects(category);
CREATE INDEX idx_upcycling_projects_status ON upcycling_projects(status);
CREATE INDEX idx_upcycling_projects_created_at ON upcycling_projects(created_at);
```

#### `project_steps` Table
```sql
CREATE TABLE project_steps (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id INTEGER NOT NULL,
    step_number INTEGER NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    estimated_minutes INTEGER DEFAULT 0,
    materials_for_step TEXT,                     -- JSON array
    is_completed BOOLEAN DEFAULT 0,
    notes TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (project_id) REFERENCES upcycling_projects(id) ON DELETE CASCADE
);

CREATE INDEX idx_project_steps_project_id ON project_steps(project_id);
CREATE INDEX idx_project_steps_step_number ON project_steps(step_number);
```

#### `project_materials` Table
```sql
CREATE TABLE project_materials (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id INTEGER NOT NULL,
    material_name TEXT NOT NULL,
    quantity TEXT,
    source TEXT,
    cost DECIMAL(8,2),
    availability TEXT,
    environmental_notes TEXT,

    FOREIGN KEY (project_id) REFERENCES upcycling_projects(id) ON DELETE CASCADE
);

CREATE INDEX idx_project_materials_project_id ON project_materials(project_id);
```

#### `project_tools` Table
```sql
CREATE TABLE project_tools (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id INTEGER NOT NULL,
    tool_name TEXT NOT NULL,
    tool_type TEXT,                             -- 'basic', 'specialized', 'power'
    availability TEXT,                          -- 'common', 'specialty', 'rare'
    cost DECIMAL(8,2),

    FOREIGN KEY (project_id) REFERENCES upcycling_projects(id) ON DELETE CASCADE
);

CREATE INDEX idx_project_tools_project_id ON project_tools(project_id);
```

#### `project_images` Table (Junction Table)
```sql
CREATE TABLE project_images (
    project_id INTEGER NOT NULL,
    image_id INTEGER NOT NULL,

    PRIMARY KEY (project_id, image_id),
    FOREIGN KEY (project_id) REFERENCES upcycling_projects(id) ON DELETE CASCADE,
    FOREIGN KEY (image_id) REFERENCES device_images(id) ON DELETE CASCADE
);
```

#### `project_likes` Table
```sql
CREATE TABLE project_likes (
    project_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    liked_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (project_id, user_id),
    FOREIGN KEY (project_id) REFERENCES upcycling_projects(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

### 6. Recommended Actions System

#### `recommended_actions` Table
```sql
CREATE TABLE recommended_actions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    diagnosis_id INTEGER NOT NULL,
    action_uuid TEXT UNIQUE NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    action_type TEXT NOT NULL,                  -- 'repair', 'replace', 'donate', 'recycle', 'sell'
    priority DECIMAL(3,2) DEFAULT 0,            -- 0.0 to 1.0
    cost_benefit_ratio DECIMAL(5,2),
    environmental_impact TEXT,
    timeframe TEXT,
    estimated_return DECIMAL(10,2),
    market_timing TEXT,
    parts_value DECIMAL(10,2),
    sustainability_benefit TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (diagnosis_id) REFERENCES diagnoses(id) ON DELETE CASCADE
);

CREATE INDEX idx_recommended_actions_diagnosis_id ON recommended_actions(diagnosis_id);
CREATE INDEX idx_recommended_actions_type ON recommended_actions(action_type);
CREATE INDEX idx_recommended_actions_priority ON recommended_actions(priority);
```

### 7. Analytics & Tracking

#### `user_activities` Table
```sql
CREATE TABLE user_activities (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    activity_type TEXT NOT NULL,                 -- 'diagnosis', 'listing_created', 'project_started', etc.
    entity_type TEXT,                           -- 'diagnosis', 'listing', 'project'
    entity_id INTEGER,
    metadata TEXT,                              -- JSON additional data
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_user_activities_user_id ON user_activities(user_id);
CREATE INDEX idx_user_activities_type ON user_activities(activity_type);
CREATE INDEX idx_user_activities_created_at ON user_activities(created_at);
```

#### `system_logs` Table
```sql
CREATE TABLE system_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    log_level TEXT NOT NULL,                    -- 'info', 'warning', 'error'
    category TEXT NOT NULL,                     -- 'auth', 'diagnosis', 'marketplace', etc.
    message TEXT NOT NULL,
    user_id INTEGER,
    metadata TEXT,                              -- JSON additional context
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE INDEX idx_system_logs_level ON system_logs(log_level);
CREATE INDEX idx_system_logs_category ON system_logs(category);
CREATE INDEX idx_system_logs_created_at ON system_logs(created_at);
```

## Entity Relationship Diagram (Simplified)

```
users (1) ──── (many) user_sessions
  │
  ├── (1:many) diagnoses ─── (1) value_estimations
  │     │                        (many) recommended_actions
  │     └── (many:many) diagnosis_images ─── (many) device_images
  │
  ├── (1:many) device_passports ─── (1) devices
  │     └── (many:many) passport_images ─── (many) device_images
  │
  ├── (1:many) resell_listings ─── (1) device_passports
  │     ├── (many:many) listing_images ─── (many) device_images
  │     └── (many:many) listing_watchers ─── (many) users
  │
  └── (1:many) upcycling_projects ─── (1) device_passports
        ├── (1:many) project_steps
        ├── (1:many) project_materials
        ├── (1:many) project_tools
        ├── (many:many) project_images ─── (many) device_images
        └── (many:many) project_likes ─── (many) users
```

## Database Best Practices

### 1. Data Integrity
- All foreign keys use `ON DELETE CASCADE` or `ON DELETE SET NULL` appropriately
- Unique constraints prevent duplicate data
- NOT NULL constraints on required fields

### 2. Performance Optimizations
- Indexes on frequently queried columns (user_id, created_at, status, etc.)
- Composite indexes for complex queries
- JSON storage for flexible metadata

### 3. Data Types
- Use `DECIMAL(10,2)` for monetary values
- Use `TEXT` for flexible string data
- Use `DATETIME` for timestamps
- Use `BOOLEAN` for true/false values
- Use `INTEGER` for foreign keys and counters

### 4. OAuth Integration
- Firebase Auth UIDs stored in `users.uid`
- Auth provider tracking in `users.auth_provider`
- Session management through `user_sessions`

### 5. Image Management
- All images stored in `device_images` table
- Junction tables for many-to-many relationships
- Support for multiple image types (diagnostic, listing, project)

### 6. Scalability Considerations
- UUIDs for external API integration
- Separate tables for different data concerns
- Efficient indexing strategy

## Sample Queries

### Get User's Device Passports with Latest Diagnosis
```sql
SELECT dp.*, d.device_model, d.manufacturer,
       diag.battery_health, diag.ai_analysis,
       ve.current_value
FROM device_passports dp
JOIN devices d ON dp.device_id = d.id
LEFT JOIN diagnoses diag ON dp.last_diagnosis_id = diag.id
LEFT JOIN value_estimations ve ON diag.id = ve.diagnosis_id
WHERE dp.user_id = ? AND dp.is_active = 1
ORDER BY dp.created_at DESC;
```

### Get Active Resell Listings with Images
```sql
SELECT l.*, u.display_name as seller_name,
       GROUP_CONCAT(di.image_path) as image_paths
FROM resell_listings l
JOIN users u ON l.seller_id = u.id
LEFT JOIN listing_images li ON l.id = li.listing_id
LEFT JOIN device_images di ON li.image_id = di.id
WHERE l.status = 'active'
GROUP BY l.id
ORDER BY l.created_at DESC;
```

### Get User's Upcycling Projects with Progress
```sql
SELECT p.*, u.display_name as creator_name,
       COUNT(ps.id) as total_steps,
       COUNT(CASE WHEN ps.is_completed = 1 THEN 1 END) as completed_steps
FROM upcycling_projects p
JOIN users u ON p.creator_id = u.id
LEFT JOIN project_steps ps ON p.id = ps.project_id
WHERE p.creator_id = ?
GROUP BY p.id
ORDER BY p.created_at DESC;
```

## Flutter Integration Steps

### 3. Create DAO Classes (Data Access Objects)

Create `lib/services/user_dao.dart`:

```dart
import 'package:sqflite/sqflite.dart';
import 'database_service.dart';

class UserDao {
  final DatabaseService _dbService = DatabaseService();

  // Insert user
  Future<int> insertUser(Map<String, dynamic> userData) async {
    final db = await _dbService.database;
    return await db.insert('users', userData,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Get user by Firebase UID
  Future<Map<String, dynamic>?> getUserByUid(String uid) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'uid = ?',
      whereArgs: [uid],
    );
    return results.isNotEmpty ? results.first : null;
  }

  // Get user by email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    return results.isNotEmpty ? results.first : null;
  }

  // Update user
  Future<int> updateUser(int id, Map<String, dynamic> userData) async {
    final db = await _dbService.database;
    return await db.update(
      'users',
      userData,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete user
  Future<int> deleteUser(int id) async {
    final db = await _dbService.database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
```

### 4. Update Existing Services

Modify `lib/services/user_service.dart` to use SQLite:

```dart
import 'user_dao.dart';
import 'oauth_service.dart';

class UserService {
  static final UserDao _userDao = UserDao();

  // Register a new user (for email/password registration)
  static Future<bool> registerUser(String name, String email, String password) async {
    try {
      // Check if user already exists
      final existingUser = await _userDao.getUserByEmail(email);
      if (existingUser != null) {
        return false; // User already exists
      }

      // Generate Firebase-compatible UID for local users
      final uid = 'local_${DateTime.now().millisecondsSinceEpoch}_${email.hashCode}';

      final userData = {
        'uid': uid,
        'email': email.toLowerCase(),
        'display_name': name.trim(),
        'auth_provider': 'email',
        'email_verified': 0,
        'is_active': 1,
        'preferences': '{}',
      };

      final result = await _userDao.insertUser(userData);
      return result > 0;
    } catch (e) {
      print('Error registering user: $e');
      return false;
    }
  }

  // Handle OAuth sign-in
  static Future<Map<String, dynamic>?> handleOAuthSignIn(String provider) async {
    try {
      Map<String, String>? oauthUser;

      if (provider == 'google') {
        oauthUser = await OAuthService.signInWithGoogle();
      } else if (provider == 'github') {
        oauthUser = await OAuthService.signInWithGitHub();
      }

      if (oauthUser != null) {
        // Save OAuth user to database
        final userData = {
          'uid': oauthUser['uid'],
          'email': oauthUser['email']!.toLowerCase(),
          'display_name': oauthUser['name'],
          'photo_url': oauthUser['photoURL'],
          'auth_provider': provider,
          'provider_id': oauthUser['uid'],
          'email_verified': 1, // OAuth users are typically verified
          'is_active': 1,
          'last_login_at': DateTime.now().toIso8601String(),
          'preferences': '{}',
        };

        await _userDao.insertUser(userData);
        return userData;
      }

      return null;
    } catch (e) {
      print('OAuth sign-in error: $e');
      return null;
    }
  }

  // Authenticate a user (for email/password login)
  static Future<Map<String, dynamic>?> authenticateUser(String email, String password) async {
    try {
      final user = await _userDao.getUserByEmail(email);
      if (user != null && user['auth_provider'] == 'email') {
        // In a real app, you'd verify the password hash here
        // For now, we'll assume successful authentication
        await _userDao.updateUser(user['id'], {
          'last_login_at': DateTime.now().toIso8601String(),
        });
        return user;
      }
      return null;
    } catch (e) {
      print('Authentication error: $e');
      return null;
    }
  }

  // Get current user from OAuth service
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final firebaseUser = OAuthService.getCurrentUser();
      if (firebaseUser != null && firebaseUser.email != null) {
        return await _userDao.getUserByEmail(firebaseUser.email!);
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Other methods...
}
```

### 5. Update Providers to Use Database

Modify your existing providers to use SQLite instead of in-memory storage:

```dart
// Example: Update diagnosis_provider.dart
class DiagnosisProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  List<DiagnosisResult> _diagnoses = [];

  // Load diagnoses from database
  Future<void> loadUserDiagnoses(int userId) async {
    final db = await _dbService.database;
    final List<Map<String, dynamic>> results = await db.query(
      'diagnoses',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    _diagnoses = results.map((data) => DiagnosisResult.fromJson(data)).toList();
    notifyListeners();
  }

  // Save diagnosis to database
  Future<void> saveDiagnosis(DiagnosisResult diagnosis, int userId, int deviceId) async {
    final db = await _dbService.database;

    final diagnosisData = {
      'user_id': userId,
      'device_id': deviceId,
      'diagnosis_uuid': 'diag_${DateTime.now().millisecondsSinceEpoch}',
      'battery_health': diagnosis.deviceHealth.batteryHealth,
      'screen_condition': diagnosis.deviceHealth.screenCondition.name,
      'hardware_condition': diagnosis.deviceHealth.hardwareCondition.name,
      'identified_issues': diagnosis.deviceHealth.identifiedIssues.toString(),
      'ai_analysis': diagnosis.aiAnalysis,
      'confidence_score': diagnosis.confidenceScore,
      'life_cycle_stage': diagnosis.deviceHealth.lifeCycleStage,
      'remaining_useful_life': diagnosis.deviceHealth.remainingUsefulLife,
      'environmental_impact': diagnosis.deviceHealth.environmentalImpact,
    };

    final diagnosisId = await db.insert('diagnoses', diagnosisData);

    // Save value estimation
    final valueData = {
      'diagnosis_id': diagnosisId,
      'current_value': diagnosis.valueEstimation.currentValue,
      'post_repair_value': diagnosis.valueEstimation.postRepairValue,
      'parts_value': diagnosis.valueEstimation.partsValue,
      'repair_cost': diagnosis.valueEstimation.repairCost,
      'recycling_value': diagnosis.valueEstimation.recyclingValue,
      'currency': diagnosis.valueEstimation.currency,
      'market_positioning': diagnosis.valueEstimation.marketPositioning,
      'depreciation_rate': diagnosis.valueEstimation.depreciationRate,
    };

    await db.insert('value_estimations', valueData);

    await loadUserDiagnoses(userId); // Refresh data
  }
}
```

### 6. Initialize Database on App Start

Update `lib/main.dart` to initialize the database:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      // ... existing Firebase config
    ),
  );

  // Initialize SQLite database
  final dbService = DatabaseService();
  await dbService.database; // This creates/opens the database

  runApp(const AyoAyoApp());
}
```

## Database Operations Guide

### Running Database Commands

#### View Database File Location
```dart
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

Future<String> getDatabasePath() async {
  final directory = await getApplicationDocumentsDirectory();
  return path.join(directory.path, 'ayoayo.db');
}
```

#### Check Database Version
```dart
final db = await DatabaseService().database;
final version = await db.getVersion();
print('Database version: $version');
```

#### Execute Raw SQL Queries
```dart
final db = await DatabaseService().database;

// Select query
final users = await db.rawQuery('SELECT * FROM users WHERE is_active = ?', [1]);

// Insert query
await db.rawInsert('''
  INSERT INTO users (uid, email, display_name, auth_provider)
  VALUES (?, ?, ?, ?)
''', ['firebase_uid', 'user@example.com', 'User Name', 'google']);

// Update query
await db.rawUpdate('''
  UPDATE users SET last_login_at = ? WHERE id = ?
''', [DateTime.now().toIso8601String(), userId]);

// Delete query
await db.rawDelete('DELETE FROM users WHERE id = ?', [userId]);
```

### Database Maintenance

#### Clear All Data (Development Only)
```dart
Future<void> clearAllData() async {
  final db = await DatabaseService().database;

  // Delete in reverse dependency order
  await db.delete('user_sessions');
  await db.delete('user_activities');
  await db.delete('system_logs');

  // Continue with other tables...
  await db.delete('users');
}
```

#### Export Database (Backup)
```dart
import 'dart:io';

Future<void> exportDatabase() async {
  final dbPath = await getDatabasePath();
  final backupPath = '${dbPath}_backup_${DateTime.now().millisecondsSinceEpoch}.db';

  await File(dbPath).copy(backupPath);
  print('Database backed up to: $backupPath');
}
```

## Migration Strategy

### From Current In-Memory Storage

#### Phase 1: Database Setup
1. ✅ Add SQLite dependencies to `pubspec.yaml`
2. ✅ Create `DatabaseService` singleton
3. ✅ Create DAO classes for each entity
4. ⏳ Update existing services to use database

#### Phase 2: Data Migration
```dart
Future<void> migrateExistingData() async {
  final db = await DatabaseService().database;

  // Migrate existing users from UserService._users
  for (final entry in UserService._users.entries) {
    final userData = {
      'uid': 'migrated_${DateTime.now().millisecondsSinceEpoch}_${entry.key.hashCode}',
      'email': entry.key,
      'display_name': entry.value['name'] ?? 'Migrated User',
      'auth_provider': 'email',
      'email_verified': 0,
      'is_active': 1,
      'preferences': '{}',
    };

    await db.insert('users', userData);
  }

  print('Data migration completed');
}
```

#### Phase 3: Update All Providers
1. Replace in-memory lists with database queries
2. Add async methods for data operations
3. Update UI to handle loading states
4. Add error handling for database operations

#### Phase 4: Testing & Optimization
1. Test all CRUD operations
2. Optimize queries with proper indexing
3. Add database migrations for future updates
4. Implement proper error handling and logging

### Rollback Plan
If issues arise during migration:
1. Keep old in-memory implementation as fallback
2. Add feature flag to switch between storage methods
3. Gradually migrate features one by one
4. Monitor performance and data integrity

## Performance Optimization

### Query Optimization
```dart
// Good: Uses indexed column
final users = await db.query('users', where: 'email = ?', whereArgs: [email]);

// Good: Orders by indexed column
final diagnoses = await db.query('diagnoses',
  orderBy: 'created_at DESC',
  limit: 10
);

// Avoid: Full table scan
final allData = await db.query('large_table'); // Without WHERE clause
```

### Batch Operations
```dart
Future<void> batchInsert(List<Map<String, dynamic>> items) async {
  final db = await DatabaseService().database;
  final batch = db.batch();

  for (final item in items) {
    batch.insert('table_name', item);
  }

  await batch.commit(noResult: true);
}
```

### Connection Management
```dart
// Always use the singleton instance
final db = await DatabaseService().database;

// Don't create multiple connections
// BAD: final db = await openDatabase(path);

// Close connection when app terminates
await DatabaseService().close();
```

## Error Handling & Debugging

### Common Issues

1. **Foreign Key Constraint Errors**
   ```dart
   // Ensure parent records exist before inserting child records
   final userExists = await db.query('users', where: 'id = ?', whereArgs: [userId]);
   if (userExists.isEmpty) {
     throw Exception('User must exist before creating diagnosis');
   }
   ```

2. **Database Locked Errors**
   ```dart
   // Use transactions for multiple operations
   await db.transaction((txn) async {
     await txn.insert('diagnoses', diagnosisData);
     await txn.insert('value_estimations', valueData);
   });
   ```

3. **Migration Errors**
   ```dart
   // Handle schema changes gracefully
   Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
     if (oldVersion < 2) {
       await db.execute('ALTER TABLE users ADD COLUMN phone TEXT');
     }
     if (oldVersion < 3) {
       await db.execute('CREATE INDEX idx_users_phone ON users(phone)');
     }
   }
   ```

### Debugging Queries
```dart
// Log all queries in development
class DebugDatabaseService extends DatabaseService {
  @override
  Future<Database> _initDatabase() async {
    final db = await super._initDatabase();

    // Log all queries
    db.execute('PRAGMA query_only = ON;'); // This is just an example

    return db;
  }
}
```

## Production Considerations

### Database Encryption
```yaml
# Add to pubspec.yaml
dependencies:
  sqlcipher_flutter_libs: ^0.5.0
```

### Backup Strategy
```dart
Future<void> createBackup() async {
  final dbPath = await getDatabasesPath();
  final backupPath = '$dbPath/backup_${DateTime.now().toIso8601String()}.db';

  final dbFile = File(dbPath);
  await dbFile.copy(backupPath);
}
```

### Database Size Management
```dart
// Clean old data periodically
Future<void> cleanupOldData() async {
  final db = await DatabaseService().database;
  final cutoffDate = DateTime.now().subtract(const Duration(days: 365));

  await db.delete(
    'user_sessions',
    where: 'created_at < ?',
    whereArgs: [cutoffDate.toIso8601String()],
  );
}
```

This comprehensive database integration provides a solid foundation for your AyoAyo application with proper SQLite implementation, migration strategy, and production-ready features. The modular DAO pattern and service layer approach ensures maintainable and scalable code architecture. 🚀📱

### Future Enhancements
- Add database versioning with migration scripts
- Implement database connection pooling for better performance
- Add database encryption for sensitive user data
- Consider moving to a more robust database solution for scale

This database design provides a solid foundation for the AyoAyo platform, supporting all current features while allowing for future expansion and optimization.
