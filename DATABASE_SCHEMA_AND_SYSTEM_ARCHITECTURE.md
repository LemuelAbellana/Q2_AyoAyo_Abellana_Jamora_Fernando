# AyoAyo System - Database Schema & Architecture Documentation

## Table of Contents
1. [System Overview](#system-overview)
2. [Database Schema](#database-schema)
3. [Entity Relationships](#entity-relationships)
4. [System Architecture](#system-architecture)
5. [Data Flow](#data-flow)
6. [API Endpoints](#api-endpoints)
7. [Authentication Flow](#authentication-flow)
8. [Device Recognition Flow](#device-recognition-flow)
9. [Technology Stack](#technology-stack)

---

## System Overview

**AyoAyo** is a mobile device management and diagnostic application that uses AI to recognize, diagnose, and estimate the value of electronic devices. The system consists of:

- **Flutter Mobile App** - Cross-platform mobile application (iOS/Android/Web/Desktop)
- **Laravel Backend API** - RESTful API for data management and synchronization
- **MySQL Database** - Relational database for persistent storage
- **Gemini AI Integration** - Google's AI for device recognition and analysis
- **OAuth Authentication** - Google sign-in for user authentication

### Core Features
- AI-powered device recognition via camera
- Device health diagnostics and condition assessment
- Value estimation for resale, repair, parts, and recycling
- Device passport management (digital device records)
- Cross-device synchronization
- Offline-first architecture with cloud backup

---

## Database Schema

### Overview
The database consists of **8 core tables** that handle user management, device information, diagnostics, and recognition history.

```
Tables:
├── users                         (User accounts & authentication)
├── devices                       (Device catalog/specifications)
├── device_passports             (User-owned devices)
├── diagnoses                    (Health assessments)
├── value_estimations           (Market value calculations)
├── device_images               (Device photos)
├── device_recognition_history  (AI scan history)
└── personal_access_tokens      (Laravel Sanctum auth tokens)
```

---

### 1. users

**Purpose:** Stores user account information and authentication data.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | BIGINT UNSIGNED | PRIMARY KEY, AUTO_INCREMENT | Unique user identifier |
| `uid` | VARCHAR(255) | UNIQUE, NOT NULL, INDEXED | Unique user ID (from OAuth or generated) |
| `email` | VARCHAR(255) | UNIQUE, NOT NULL, INDEXED | User email address |
| `display_name` | VARCHAR(255) | NULLABLE | User's full name |
| `photo_url` | TEXT | NULLABLE | Profile photo URL |
| `auth_provider` | VARCHAR(255) | NOT NULL, DEFAULT 'email', INDEXED | Authentication method (google, email, etc.) |
| `provider_id` | VARCHAR(255) | NULLABLE | OAuth provider's user ID |
| `password_hash` | VARCHAR(255) | NULLABLE | Hashed password (for email auth) |
| `email_verified` | BOOLEAN | NOT NULL, DEFAULT false | Email verification status |
| `last_login_at` | TIMESTAMP | NULLABLE | Last successful login |
| `is_active` | BOOLEAN | NOT NULL, DEFAULT true | Account active status |
| `preferences` | JSON | NULLABLE | User preferences and settings |
| `created_at` | TIMESTAMP | NULLABLE | Account creation timestamp |
| `updated_at` | TIMESTAMP | NULLABLE | Last update timestamp |

**Indexes:**
- Primary: `id`
- Unique: `uid`, `email`
- Index: `auth_provider`

**Sample Data:**
```sql
INSERT INTO users (uid, email, display_name, auth_provider, provider_id)
VALUES ('google_123456789', 'john@example.com', 'John Doe', 'google', '123456789');
```

---

### 2. devices

**Purpose:** Master catalog of device specifications and information.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | BIGINT UNSIGNED | PRIMARY KEY, AUTO_INCREMENT | Unique device identifier |
| `device_model` | VARCHAR(255) | NOT NULL, INDEXED | Device model name (e.g., "iPhone 14 Pro") |
| `manufacturer` | VARCHAR(255) | NOT NULL, INDEXED | Manufacturer name (e.g., "Apple") |
| `year_of_release` | INTEGER | NULLABLE | Release year |
| `operating_system` | VARCHAR(255) | NULLABLE | OS (e.g., "iOS 16", "Android 13") |
| `category` | VARCHAR(255) | NULLABLE | Device category (e.g., "smartphone", "tablet") |
| `base_value` | DECIMAL(10,2) | NULLABLE | Original retail price |
| `created_at` | TIMESTAMP | NULLABLE | Record creation timestamp |
| `updated_at` | TIMESTAMP | NULLABLE | Last update timestamp |

**Indexes:**
- Primary: `id`
- Index: `device_model`, `manufacturer`

**Sample Data:**
```sql
INSERT INTO devices (device_model, manufacturer, year_of_release, operating_system, category, base_value)
VALUES ('iPhone 14 Pro', 'Apple', 2022, 'iOS 16', 'smartphone', 54990.00);
```

---

### 3. device_passports

**Purpose:** Junction table linking users to their owned devices with unique identifiers.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | BIGINT UNSIGNED | PRIMARY KEY, AUTO_INCREMENT | Unique passport identifier |
| `user_id` | BIGINT UNSIGNED | FOREIGN KEY, NOT NULL, INDEXED | References `users.id` |
| `device_id` | BIGINT UNSIGNED | FOREIGN KEY, NOT NULL, INDEXED | References `devices.id` |
| `passport_uuid` | VARCHAR(255) | UNIQUE, NOT NULL | Unique passport identifier |
| `last_diagnosis_id` | BIGINT UNSIGNED | FOREIGN KEY, NULLABLE | References `diagnoses.id` (most recent) |
| `is_active` | BOOLEAN | NOT NULL, DEFAULT true | Device passport active status |
| `created_at` | TIMESTAMP | NULLABLE | Device added timestamp |
| `updated_at` | TIMESTAMP | NULLABLE | Last update timestamp |

**Relationships:**
- `user_id` → `users.id` (CASCADE DELETE)
- `device_id` → `devices.id` (CASCADE DELETE)
- `last_diagnosis_id` → `diagnoses.id` (SET NULL on delete)

**Indexes:**
- Primary: `id`
- Unique: `passport_uuid`
- Index: `user_id`, `device_id`

**Sample Data:**
```sql
INSERT INTO device_passports (user_id, device_id, passport_uuid)
VALUES (1, 1, 'DP-2024-ABC123XYZ');
```

---

### 4. diagnoses

**Purpose:** Stores detailed health diagnostics and condition assessments for devices.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | BIGINT UNSIGNED | PRIMARY KEY, AUTO_INCREMENT | Unique diagnosis identifier |
| `user_id` | BIGINT UNSIGNED | FOREIGN KEY, NOT NULL, INDEXED | References `users.id` |
| `device_id` | BIGINT UNSIGNED | FOREIGN KEY, NOT NULL, INDEXED | References `devices.id` |
| `diagnosis_uuid` | VARCHAR(255) | UNIQUE, NOT NULL | Unique diagnosis identifier |
| `battery_health` | DECIMAL(5,2) | NULLABLE | Battery health percentage (0-100) |
| `screen_condition` | VARCHAR(255) | NULLABLE | Screen condition (Excellent/Good/Fair/Poor) |
| `hardware_condition` | VARCHAR(255) | NULLABLE | Overall hardware condition |
| `identified_issues` | TEXT | NULLABLE | List of detected issues |
| `ai_analysis` | TEXT | NULLABLE | AI-generated analysis report |
| `confidence_score` | DECIMAL(3,2) | NULLABLE | AI confidence (0.00-1.00) |
| `life_cycle_stage` | VARCHAR(255) | NULLABLE | Product lifecycle stage |
| `remaining_useful_life` | VARCHAR(255) | NULLABLE | Estimated remaining lifespan |
| `environmental_impact` | TEXT | NULLABLE | Environmental assessment |
| `created_at` | TIMESTAMP | NULLABLE, INDEXED | Diagnosis timestamp |
| `updated_at` | TIMESTAMP | NULLABLE | Last update timestamp |

**Relationships:**
- `user_id` → `users.id` (CASCADE DELETE)
- `device_id` → `devices.id` (CASCADE DELETE)

**Indexes:**
- Primary: `id`
- Unique: `diagnosis_uuid`
- Index: `user_id`, `device_id`, `created_at`

**Sample Data:**
```sql
INSERT INTO diagnoses (user_id, device_id, diagnosis_uuid, battery_health, screen_condition, confidence_score)
VALUES (1, 1, 'DX-2024-ABC123', 85.50, 'Good', 0.92);
```

---

### 5. value_estimations

**Purpose:** Stores market value calculations and pricing information.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | BIGINT UNSIGNED | PRIMARY KEY, AUTO_INCREMENT | Unique estimation identifier |
| `diagnosis_id` | BIGINT UNSIGNED | FOREIGN KEY, NOT NULL | References `diagnoses.id` |
| `current_value` | DECIMAL(10,2) | NULLABLE | Current resale value |
| `post_repair_value` | DECIMAL(10,2) | NULLABLE | Value after repairs |
| `parts_value` | DECIMAL(10,2) | NULLABLE | Salvage parts value |
| `repair_cost` | DECIMAL(10,2) | NULLABLE | Estimated repair cost |
| `recycling_value` | DECIMAL(10,2) | NULLABLE | Recycling/material value |
| `currency` | VARCHAR(255) | NOT NULL, DEFAULT 'PHP' | Currency code |
| `market_positioning` | VARCHAR(255) | NULLABLE | Market position (premium/mid/budget) |
| `depreciation_rate` | VARCHAR(255) | NULLABLE | Depreciation rate |
| `created_at` | TIMESTAMP | NULLABLE | Estimation timestamp |
| `updated_at` | TIMESTAMP | NULLABLE | Last update timestamp |

**Relationships:**
- `diagnosis_id` → `diagnoses.id` (CASCADE DELETE)

**Indexes:**
- Primary: `id`

**Sample Data:**
```sql
INSERT INTO value_estimations (diagnosis_id, current_value, post_repair_value, repair_cost, currency)
VALUES (1, 35000.00, 42000.00, 5000.00, 'PHP');
```

---

### 6. device_images

**Purpose:** Stores device photos for diagnostics and records.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | BIGINT UNSIGNED | PRIMARY KEY, AUTO_INCREMENT | Unique image identifier |
| `device_id` | BIGINT UNSIGNED | FOREIGN KEY, NOT NULL | References `devices.id` |
| `image_path` | TEXT | NOT NULL | Image storage path/URL |
| `image_type` | VARCHAR(255) | NOT NULL, DEFAULT 'diagnostic' | Image category |
| `uploaded_by` | BIGINT UNSIGNED | FOREIGN KEY, NOT NULL | References `users.id` |
| `uploaded_at` | TIMESTAMP | NOT NULL, DEFAULT CURRENT_TIMESTAMP | Upload timestamp |

**Relationships:**
- `device_id` → `devices.id` (CASCADE DELETE)
- `uploaded_by` → `users.id` (CASCADE DELETE)

**Indexes:**
- Primary: `id`

**Sample Data:**
```sql
INSERT INTO device_images (device_id, image_path, image_type, uploaded_by)
VALUES (1, '/storage/devices/iphone14_front.jpg', 'diagnostic', 1);
```

---

### 7. device_recognition_history

**Purpose:** Tracks all AI recognition attempts and results.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | BIGINT UNSIGNED | PRIMARY KEY, AUTO_INCREMENT | Unique history identifier |
| `user_id` | BIGINT UNSIGNED | FOREIGN KEY, NOT NULL, INDEXED | References `users.id` |
| `device_model` | VARCHAR(255) | NOT NULL | Recognized device model |
| `manufacturer` | VARCHAR(255) | NOT NULL, INDEXED | Recognized manufacturer |
| `year_of_release` | INTEGER | NULLABLE | Recognized release year |
| `operating_system` | VARCHAR(255) | NULLABLE | Recognized OS |
| `confidence_score` | DECIMAL(3,2) | NULLABLE | AI confidence (0.00-1.00) |
| `analysis_details` | TEXT | NULLABLE | Detailed AI analysis |
| `image_paths` | JSON | NULLABLE | Array of image URLs used |
| `recognition_timestamp` | TIMESTAMP | NOT NULL, INDEXED, DEFAULT CURRENT_TIMESTAMP | Scan timestamp |
| `device_passport_id` | BIGINT UNSIGNED | FOREIGN KEY, NULLABLE | References `device_passports.id` (if saved) |
| `is_saved` | BOOLEAN | NOT NULL, DEFAULT false | Whether saved as device passport |

**Relationships:**
- `user_id` → `users.id` (CASCADE DELETE)
- `device_passport_id` → `device_passports.id` (SET NULL on delete)

**Indexes:**
- Primary: `id`
- Index: `user_id`, `recognition_timestamp`, `manufacturer`

**Sample Data:**
```sql
INSERT INTO device_recognition_history (user_id, device_model, manufacturer, confidence_score, is_saved)
VALUES (1, 'iPhone 14 Pro', 'Apple', 0.95, true);
```

---

### 8. personal_access_tokens

**Purpose:** Laravel Sanctum authentication tokens (managed automatically).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | BIGINT UNSIGNED | PRIMARY KEY, AUTO_INCREMENT | Token identifier |
| `tokenable_type` | VARCHAR(255) | NOT NULL | Model type (User) |
| `tokenable_id` | BIGINT UNSIGNED | NOT NULL | User ID |
| `name` | VARCHAR(255) | NOT NULL | Token name |
| `token` | VARCHAR(64) | UNIQUE, NOT NULL | Hashed token value |
| `abilities` | TEXT | NULLABLE | Token permissions |
| `last_used_at` | TIMESTAMP | NULLABLE | Last token usage |
| `expires_at` | TIMESTAMP | NULLABLE | Token expiration |
| `created_at` | TIMESTAMP | NULLABLE | Token creation |
| `updated_at` | TIMESTAMP | NULLABLE | Last update |

---

## Entity Relationships

### ER Diagram

```
┌─────────────────┐
│     users       │
│─────────────────│
│ id (PK)         │◄──┐
│ uid (UK)        │   │
│ email (UK)      │   │
│ display_name    │   │
│ auth_provider   │   │
└─────────────────┘   │
         │            │
         │ 1          │
         │            │
         │ *          │
         ▼            │
┌─────────────────────────┐         ┌──────────────────┐
│  device_passports       │    *    │    devices       │
│─────────────────────────│◄────────┤──────────────────│
│ id (PK)                 │         │ id (PK)          │
│ user_id (FK)            │         │ device_model     │
│ device_id (FK)          │─────────┤ manufacturer     │
│ passport_uuid (UK)      │    1    │ year_of_release  │
│ last_diagnosis_id (FK)  │         │ operating_system │
│ is_active               │         │ category         │
└─────────────────────────┘         │ base_value       │
         │                          └──────────────────┘
         │ 1                                 │
         │                                   │
         │ *                                 │ 1
         ▼                                   │
┌─────────────────────┐                     │ *
│    diagnoses        │                     │
│─────────────────────│                     │
│ id (PK)             │◄────────────────────┘
│ user_id (FK)        │
│ device_id (FK)      │
│ diagnosis_uuid (UK) │
│ battery_health      │
│ screen_condition    │
│ confidence_score    │
└─────────────────────┘
         │ 1
         │
         │ 1
         ▼
┌─────────────────────┐
│ value_estimations   │
│─────────────────────│
│ id (PK)             │
│ diagnosis_id (FK)   │
│ current_value       │
│ post_repair_value   │
│ repair_cost         │
│ recycling_value     │
└─────────────────────┘


┌──────────────────────────────┐
│ device_recognition_history   │
│──────────────────────────────│
│ id (PK)                      │
│ user_id (FK) ────────────────┼─────► users.id
│ device_model                 │
│ manufacturer                 │
│ confidence_score             │
│ device_passport_id (FK)      │───► device_passports.id
│ is_saved                     │
└──────────────────────────────┘


┌──────────────────┐
│ device_images    │
│──────────────────│
│ id (PK)          │
│ device_id (FK)   │──────► devices.id
│ image_path       │
│ uploaded_by (FK) │──────► users.id
└──────────────────┘
```

### Relationship Summary

| Parent Table | Child Table | Relationship | On Delete |
|-------------|-------------|--------------|-----------|
| `users` | `device_passports` | 1:Many | CASCADE |
| `users` | `diagnoses` | 1:Many | CASCADE |
| `users` | `device_recognition_history` | 1:Many | CASCADE |
| `users` | `device_images` | 1:Many | CASCADE |
| `devices` | `device_passports` | 1:Many | CASCADE |
| `devices` | `diagnoses` | 1:Many | CASCADE |
| `devices` | `device_images` | 1:Many | CASCADE |
| `diagnoses` | `value_estimations` | 1:1 | CASCADE |
| `diagnoses` | `device_passports` | 1:Many | SET NULL |
| `device_passports` | `device_recognition_history` | 1:Many | SET NULL |

---

## System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     FLUTTER MOBILE APP                       │
│  (iOS / Android / Web / Windows / macOS / Linux)            │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   UI Layer   │  │   Services   │  │  Providers   │     │
│  │              │  │              │  │              │     │
│  │ • Screens    │  │ • ApiService │  │ • Device     │     │
│  │ • Widgets    │  │ • UserService│  │ • Auth       │     │
│  │ • Navigation │  │ • Camera     │  │ • State Mgmt │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│                            │                                │
│  ┌─────────────────────────┼────────────────────┐          │
│  │     Local Storage       │                    │          │
│  │  ┌─────────────┐   ┌────┴────────┐          │          │
│  │  │   SQLite    │   │   SharedPref │          │          │
│  │  │  (Devices)  │   │   (Tokens)   │          │          │
│  │  └─────────────┘   └──────────────┘          │          │
│  └──────────────────────────────────────────────┘          │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          │ HTTPS / REST API
                          │
┌─────────────────────────▼───────────────────────────────────┐
│                   LARAVEL BACKEND API                        │
│                    (PHP 8.1 / Laravel 10)                    │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ Controllers  │  │   Models     │  │  Middleware  │     │
│  │              │  │              │  │              │     │
│  │ • Auth       │  │ • User       │  │ • Sanctum    │     │
│  │ • Device     │  │ • Device     │  │ • CORS       │     │
│  │ • Diagnosis  │  │ • Diagnosis  │  │ • Logging    │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│                                                              │
│  ┌──────────────────────────────────────────────────┐      │
│  │              Routes (API v1)                      │      │
│  │  /api/v1/auth/*                                  │      │
│  │  /api/v1/device-recognition/*                    │      │
│  │  /api/v1/device-passports/*                      │      │
│  └──────────────────────────────────────────────────┘      │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
                  ┌───────────────┐
                  │ MySQL Database│
                  │   (MariaDB)   │
                  └───────────────┘


┌─────────────────────────────────────────────────────────────┐
│              EXTERNAL SERVICES                               │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────┐           ┌──────────────────┐       │
│  │  Google OAuth    │           │   Gemini AI      │       │
│  │                  │           │                  │       │
│  │ • Authentication │           │ • Image Analysis │       │
│  │ • User Profile   │           │ • Device Recog   │       │
│  └──────────────────┘           └──────────────────┘       │
└─────────────────────────────────────────────────────────────┘
```

### Application Layers

#### 1. Presentation Layer (Flutter)
- **Screens:** User interface components
- **Widgets:** Reusable UI elements
- **Navigation:** Route management

#### 2. Business Logic Layer
- **Providers:** State management (ChangeNotifier pattern)
- **Services:** Business logic and API communication
- **Models:** Data structures and entities

#### 3. Data Layer
- **Local Storage:** SQLite for offline data
- **Remote Storage:** Laravel API for cloud sync
- **Shared Preferences:** Token and settings storage

#### 4. Backend Layer (Laravel)
- **Controllers:** Request handling and response formatting
- **Models:** Database ORM (Eloquent)
- **Middleware:** Authentication, CORS, logging
- **Validation:** Request validation rules

---

## Data Flow

### 1. User Registration & Authentication Flow

```
┌────────────────────────────────────────────────────────────┐
│ Step 1: User clicks "Continue with Google"                 │
└────────────────────┬───────────────────────────────────────┘
                     │
                     ▼
          ┌──────────────────────┐
          │ Google OAuth Service │
          │ (External)           │
          └──────────┬───────────┘
                     │ Returns: uid, email, name, photo
                     ▼
          ┌──────────────────────┐
          │ Flutter App          │
          │ UserService          │
          │ handleOAuthSignIn()  │
          └──────────┬───────────┘
                     │
                     ├─────────────────┐
                     │                 │
                     ▼                 ▼
          ┌──────────────────┐  ┌─────────────┐
          │ Local SQLite     │  │ Backend API │
          │ Save user data   │  │ POST /auth/ │
          │                  │  │ oauth-signin│
          └──────────────────┘  └──────┬──────┘
                                       │
                                       │ Returns: API token
                                       ▼
                            ┌──────────────────────┐
                            │ ApiService.setToken()│
                            │ Store in memory      │
                            └──────────┬───────────┘
                                       │
                                       ▼
                            ┌──────────────────────┐
                            │ User authenticated   │
                            │ Navigate to Home     │
                            └──────────────────────┘
```

**Code Example:**
```dart
// Flutter: lib/services/user_service.dart
Future<void> handleOAuthSignIn(OAuthResult result) async {
  // 1. Save to local SQLite
  await _localDatabase.saveUser(result);

  // 2. Sync with backend if enabled
  if (ApiConfig.useBackendApi) {
    final response = await ApiService.oauthSignIn(
      uid: result.uid,
      email: result.email,
      displayName: result.displayName,
      photoUrl: result.photoUrl,
      authProvider: result.provider,
      providerId: result.providerId,
    );

    // 3. Store API token
    ApiService.setToken(response['token']);
  }
}
```

```php
// Laravel: app/Http/Controllers/Api/AuthController.php
public function oauthSignIn(Request $request) {
    $validated = $request->validate([
        'uid' => 'required|string',
        'email' => 'required|email',
        'display_name' => 'nullable|string',
        'photo_url' => 'nullable|string',
        'auth_provider' => 'required|string',
        'provider_id' => 'required|string',
    ]);

    // Find or create user
    $user = User::firstOrCreate(
        ['email' => $validated['email']],
        $validated
    );

    // Generate token
    $token = $user->createToken('mobile-app')->plainTextToken;

    return response()->json([
        'token' => $token,
        'user' => $user
    ]);
}
```

---

### 2. Device Recognition & Scanning Flow

```
┌────────────────────────────────────────────────────────────┐
│ Step 1: User opens Device Scanner screen                   │
└────────────────────┬───────────────────────────────────────┘
                     │
                     ▼
          ┌──────────────────────┐
          │ User captures photos │
          │ (Front, Back, etc.)  │
          └──────────┬───────────┘
                     │ 2-6 images
                     ▼
          ┌──────────────────────────────┐
          │ CameraDeviceRecognitionService│
          │ recognizeDevice()            │
          └──────────┬───────────────────┘
                     │
                     │ Sends images to AI
                     ▼
          ┌──────────────────────┐
          │ Google Gemini AI     │
          │ (External)           │
          │ Analyzes images      │
          └──────────┬───────────┘
                     │
                     │ Returns: DeviceRecognition result
                     │ {model, manufacturer, year, OS,
                     │  condition, confidence}
                     ▼
          ┌──────────────────────────────┐
          │ User reviews AI results      │
          │ Confirms or edits details    │
          └──────────┬───────────────────┘
                     │
                     │ User clicks "Save Device"
                     ▼
          ┌──────────────────────────────┐
          │ saveRecognizedDevice()       │
          └──────────┬───────────────────┘
                     │
        ┌────────────┴────────────┐
        │                         │
        ▼                         ▼
┌───────────────┐        ┌────────────────────┐
│ Backend API   │        │ Local SQLite       │
│ POST /device- │        │ device_passports   │
│ recognition/  │        │ table              │
│ save          │        └────────────────────┘
└───────┬───────┘
        │
        │ Creates records in:
        │ 1. devices table
        │ 2. device_passports table
        │ 3. device_recognition_history table
        │ 4. diagnoses table (if diagnosis data provided)
        │
        │ Returns: passport_uuid
        ▼
┌──────────────────────┐
│ DeviceProvider       │
│ .loadDevices()       │
│ Refresh device list  │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ UI Updates           │
│ Show device in list  │
│ Navigate to details  │
└──────────────────────┘
```

**Code Example:**
```dart
// Flutter: lib/services/camera_device_recognition_service.dart
Future<String> saveRecognizedDevice(DeviceRecognitionResult result) async {
  // Try backend first if enabled
  if (ApiConfig.useBackendApi && ApiService.isAuthenticated) {
    try {
      final response = await ApiService.saveRecognizedDevice(
        deviceModel: result.model,
        manufacturer: result.manufacturer,
        yearOfRelease: result.yearOfRelease,
        operatingSystem: result.operatingSystem,
        confidenceScore: result.confidence,
        analysisDetails: result.analysisDetails,
        imagePaths: result.imagePaths,
      );
      return response['passport_uuid'];
    } catch (e) {
      print('Backend save failed, falling back to local: $e');
    }
  }

  // Fallback to local SQLite
  return await _localDatabase.saveDevice(result);
}
```

```php
// Laravel: app/Http/Controllers/Api/DeviceRecognitionController.php
public function save(Request $request) {
    $validated = $request->validate([
        'device_model' => 'required|string',
        'manufacturer' => 'required|string',
        'year_of_release' => 'nullable|integer',
        'operating_system' => 'nullable|string',
        'confidence_score' => 'nullable|numeric|min:0|max:1',
        'analysis_details' => 'nullable|string',
        'image_paths' => 'nullable|array',
    ]);

    DB::beginTransaction();
    try {
        // 1. Create or get device
        $device = Device::firstOrCreate([
            'device_model' => $validated['device_model'],
            'manufacturer' => $validated['manufacturer'],
        ], $validated);

        // 2. Create device passport
        $passport = DevicePassport::create([
            'user_id' => auth()->id(),
            'device_id' => $device->id,
            'passport_uuid' => 'DP-' . now()->format('Ymd') . '-' . Str::random(8),
        ]);

        // 3. Record recognition history
        DeviceRecognitionHistory::create([
            'user_id' => auth()->id(),
            'device_model' => $validated['device_model'],
            'manufacturer' => $validated['manufacturer'],
            'confidence_score' => $validated['confidence_score'] ?? null,
            'device_passport_id' => $passport->id,
            'is_saved' => true,
        ]);

        DB::commit();
        return response()->json([
            'success' => true,
            'passport_uuid' => $passport->passport_uuid,
            'device' => $device,
        ]);
    } catch (\Exception $e) {
        DB::rollBack();
        throw $e;
    }
}
```

---

### 3. Device List Loading Flow

```
┌────────────────────────────────────────────────────────────┐
│ User navigates to "My Devices" screen                      │
└────────────────────┬───────────────────────────────────────┘
                     │
                     ▼
          ┌──────────────────────┐
          │ DeviceProvider       │
          │ .loadDevices()       │
          └──────────┬───────────┘
                     │
        ┌────────────┴────────────┐
        │                         │
        ▼                         ▼
┌────────────────┐       ┌────────────────┐
│ Backend API?   │       │ Local SQLite   │
│ Authenticated? │       │ Always loads   │
└────────┬───────┘       └────────────────┘
         │
         │ YES
         ▼
┌────────────────────┐
│ Backend API        │
│ GET /device-       │
│ passports          │
└────────┬───────────┘
         │
         │ Returns: Array of devices with:
         │ - Device info (model, manufacturer)
         │ - Passport UUID
         │ - Last diagnosis
         │ - Creation date
         ▼
┌────────────────────┐
│ Parse & convert    │
│ to Flutter models  │
└────────┬───────────┘
         │
         ▼
┌────────────────────┐
│ Update UI          │
│ Display device list│
│ with cards         │
└────────────────────┘
```

**Backend SQL Query:**
```sql
-- Laravel generates this query
SELECT
    dp.id,
    dp.passport_uuid,
    dp.created_at,
    d.device_model,
    d.manufacturer,
    d.year_of_release,
    d.operating_system,
    diag.battery_health,
    diag.screen_condition,
    diag.hardware_condition
FROM device_passports dp
INNER JOIN devices d ON dp.device_id = d.id
LEFT JOIN diagnoses diag ON dp.last_diagnosis_id = diag.id
WHERE dp.user_id = ?
  AND dp.is_active = 1
ORDER BY dp.created_at DESC;
```

---

### 4. Device Details & Diagnosis Flow

```
┌────────────────────────────────────────────────────────────┐
│ User taps on device card in list                           │
└────────────────────┬───────────────────────────────────────┘
                     │
                     ▼
          ┌──────────────────────┐
          │ Navigate to          │
          │ DeviceDetailsScreen  │
          └──────────┬───────────┘
                     │
                     ▼
          ┌──────────────────────┐
          │ Load full device data│
          └──────────┬───────────┘
                     │
        ┌────────────┴────────────┐
        │                         │
        ▼                         ▼
┌────────────────────┐   ┌────────────────┐
│ GET /device-       │   │ Local SQLite   │
│ passports/{uuid}   │   │ Query by UUID  │
└────────┬───────────┘   └────────────────┘
         │
         │ Returns complete device data:
         │ - Basic info (model, manufacturer, year)
         │ - Latest diagnosis
         │   - Battery health
         │   - Screen condition
         │   - Hardware condition
         │   - Identified issues
         │ - Value estimation
         │   - Current value
         │   - Repair cost
         │   - Parts value
         │ - Device images
         │ - Recognition history
         ▼
┌────────────────────────┐
│ Display in tabs:       │
│ - Overview             │
│ - Diagnostics          │
│ - Value Estimation     │
│ - History              │
└────────────────────────┘
```

---

## API Endpoints

### Base URL
```
Development: http://localhost:8000/api/v1
Production: https://api.ayoayo.com/api/v1
```

### Authentication Endpoints

#### 1. Register User
```
POST /auth/register

Request Body:
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "SecurePass123!"
}

Response (201):
{
  "success": true,
  "token": "1|abc123xyz...",
  "user": {
    "id": 1,
    "uid": "user_abc123",
    "email": "john@example.com",
    "display_name": "John Doe",
    "auth_provider": "email"
  }
}
```

#### 2. Login
```
POST /auth/login

Request Body:
{
  "email": "john@example.com",
  "password": "SecurePass123!"
}

Response (200):
{
  "success": true,
  "token": "2|def456uvw...",
  "user": { ... }
}
```

#### 3. OAuth Sign In (Google)
```
POST /auth/oauth-signin

Headers:
Content-Type: application/json

Request Body:
{
  "uid": "google_123456789",
  "email": "john@gmail.com",
  "display_name": "John Doe",
  "photo_url": "https://lh3.googleusercontent.com/...",
  "auth_provider": "google",
  "provider_id": "123456789"
}

Response (200):
{
  "success": true,
  "token": "3|ghi789rst...",
  "user": {
    "id": 2,
    "uid": "google_123456789",
    "email": "john@gmail.com",
    "display_name": "John Doe",
    "photo_url": "https://...",
    "auth_provider": "google",
    "provider_id": "123456789"
  }
}
```

#### 4. Get Current User
```
GET /auth/user

Headers:
Authorization: Bearer {token}

Response (200):
{
  "success": true,
  "user": { ... }
}
```

#### 5. Logout
```
POST /auth/logout

Headers:
Authorization: Bearer {token}

Response (200):
{
  "success": true,
  "message": "Logged out successfully"
}
```

---

### Device Recognition Endpoints

#### 1. Save Recognized Device
```
POST /device-recognition/save

Headers:
Authorization: Bearer {token}
Content-Type: application/json

Request Body:
{
  "device_model": "iPhone 14 Pro",
  "manufacturer": "Apple",
  "year_of_release": 2022,
  "operating_system": "iOS 16",
  "confidence_score": 0.95,
  "analysis_details": "Device recognized with high confidence...",
  "image_paths": [
    "https://storage.example.com/img1.jpg",
    "https://storage.example.com/img2.jpg"
  ]
}

Response (201):
{
  "success": true,
  "message": "Device recognized and saved successfully",
  "passport_uuid": "DP-20240108-ABC123XY",
  "device": {
    "id": 5,
    "device_model": "iPhone 14 Pro",
    "manufacturer": "Apple",
    "year_of_release": 2022,
    "operating_system": "iOS 16"
  }
}
```

#### 2. Get Recognition History
```
GET /device-recognition/history

Headers:
Authorization: Bearer {token}

Query Parameters:
?limit=20&offset=0&manufacturer=Apple

Response (200):
{
  "success": true,
  "history": [
    {
      "id": 15,
      "device_model": "iPhone 14 Pro",
      "manufacturer": "Apple",
      "confidence_score": 0.95,
      "recognition_timestamp": "2024-01-08T10:30:00Z",
      "is_saved": true,
      "device_passport_id": 5
    },
    ...
  ],
  "pagination": {
    "total": 45,
    "limit": 20,
    "offset": 0
  }
}
```

---

### Device Passport Endpoints

#### 1. Get All Device Passports
```
GET /device-passports

Headers:
Authorization: Bearer {token}

Response (200):
{
  "success": true,
  "devices": [
    {
      "id": 1,
      "passport_uuid": "DP-20240108-ABC123XY",
      "device": {
        "id": 5,
        "device_model": "iPhone 14 Pro",
        "manufacturer": "Apple",
        "year_of_release": 2022,
        "operating_system": "iOS 16"
      },
      "last_diagnosis": {
        "battery_health": 85.5,
        "screen_condition": "Good",
        "hardware_condition": "Excellent",
        "confidence_score": 0.92
      },
      "created_at": "2024-01-08T10:30:00Z"
    },
    ...
  ]
}
```

#### 2. Get Single Device Passport
```
GET /device-passports/{passport_uuid}

Headers:
Authorization: Bearer {token}

Response (200):
{
  "success": true,
  "device_passport": {
    "id": 1,
    "passport_uuid": "DP-20240108-ABC123XY",
    "device": { ... },
    "diagnoses": [
      {
        "id": 3,
        "diagnosis_uuid": "DX-20240108-XYZ789",
        "battery_health": 85.5,
        "screen_condition": "Good",
        "hardware_condition": "Excellent",
        "identified_issues": "Minor scratch on back",
        "ai_analysis": "Overall condition is good...",
        "value_estimation": {
          "current_value": 35000.00,
          "post_repair_value": 42000.00,
          "repair_cost": 5000.00,
          "currency": "PHP"
        },
        "created_at": "2024-01-08T10:30:00Z"
      }
    ],
    "recognition_history": [ ... ],
    "images": [ ... ]
  }
}
```

#### 3. Delete Device Passport
```
DELETE /device-passports/{passport_uuid}

Headers:
Authorization: Bearer {token}

Response (200):
{
  "success": true,
  "message": "Device passport deleted successfully"
}
```

---

### Health Check Endpoint

```
GET /health

No authentication required

Response (200):
{
  "status": "healthy",
  "message": "AyoAyo API is running",
  "timestamp": "2024-01-08T10:30:00Z",
  "version": "1.0.0"
}
```

---

## Authentication Flow

### JWT Token-Based Authentication (Laravel Sanctum)

#### How It Works

1. **User logs in** (OAuth or email/password)
2. **Backend generates token** using Laravel Sanctum
3. **Token sent to Flutter app** in response
4. **Flutter stores token** in memory (`ApiService._token`)
5. **All subsequent requests** include token in `Authorization` header
6. **Backend validates token** via middleware
7. **Token cleared on logout**

#### Token Format
```
Bearer 3|randomstring123abc456def789...
```

#### Token Storage
- **Flutter:** In-memory storage (cleared on app restart)
- **Backend:** `personal_access_tokens` table

#### Token Lifecycle
- **Creation:** On login/registration
- **Validation:** On every protected API request
- **Expiration:** Configurable (default: never expires until logout)
- **Revocation:** On logout or manual revocation

#### Security Features
- HTTPS only in production
- CORS protection
- Token hashing in database
- Automatic token cleanup
- Rate limiting on auth endpoints

---

## Device Recognition Flow

### Gemini AI Integration

#### Process

1. **User captures 2-6 photos** of device
2. **Images sent to Gemini AI** with prompt
3. **AI analyzes images** and identifies:
   - Device model
   - Manufacturer
   - Year of release
   - Operating system
   - Physical condition
   - Confidence score (0-1)
4. **Results returned** as structured JSON
5. **User reviews and confirms** details
6. **Device saved** to database

#### Gemini Prompt Structure
```
Analyze these images of an electronic device and provide:
1. Device model (exact name)
2. Manufacturer
3. Year of release
4. Operating system version
5. Physical condition assessment
6. Any visible damage or issues
7. Confidence level (0-1)

Return as JSON with keys: model, manufacturer, year, os,
condition, issues, confidence
```

#### Confidence Scoring
- **0.90-1.00:** High confidence - clear images, known device
- **0.70-0.89:** Medium confidence - some uncertainty
- **0.50-0.69:** Low confidence - poor images or unknown device
- **0.00-0.49:** Very low confidence - manual review recommended

---

## Technology Stack

### Frontend (Flutter)

| Component | Technology | Version |
|-----------|------------|---------|
| Framework | Flutter | 3.x |
| Language | Dart | 3.x |
| State Management | Provider | ^6.0.0 |
| HTTP Client | http | ^1.1.0 |
| Local Database | sqflite | ^2.3.0 |
| OAuth | google_sign_in | ^6.1.5 |
| Camera | camera | ^0.10.5 |
| AI | google_generative_ai | ^0.2.0 |
| Icons | lucide_icons_flutter | ^1.0.0 |

### Backend (Laravel)

| Component | Technology | Version |
|-----------|------------|---------|
| Framework | Laravel | 10.x |
| Language | PHP | 8.1+ |
| Database | MySQL / MariaDB | 8.0+ / 10.6+ |
| Authentication | Laravel Sanctum | ^3.3 |
| ORM | Eloquent | Built-in |
| HTTP | Guzzle | ^7.2 |

### Database

| Component | Technology | Version |
|-----------|------------|---------|
| RDBMS | MySQL / MariaDB | 8.0+ / 10.6+ |
| Storage Engine | InnoDB | Default |
| Collation | utf8mb4_unicode_ci | Default |

### External Services

| Service | Purpose | Provider |
|---------|---------|----------|
| OAuth | User authentication | Google |
| AI | Device recognition | Google Gemini |

---

## Database Queries Reference

### Common Queries

#### Get all devices for a user
```sql
SELECT
    dp.passport_uuid,
    d.device_model,
    d.manufacturer,
    d.year_of_release,
    diag.battery_health,
    diag.screen_condition
FROM device_passports dp
INNER JOIN devices d ON dp.device_id = d.id
LEFT JOIN diagnoses diag ON dp.last_diagnosis_id = diag.id
WHERE dp.user_id = 1
  AND dp.is_active = 1
ORDER BY dp.created_at DESC;
```

#### Get device with complete diagnosis history
```sql
SELECT
    dp.*,
    d.*,
    diag.diagnosis_uuid,
    diag.battery_health,
    diag.screen_condition,
    diag.hardware_condition,
    diag.ai_analysis,
    ve.current_value,
    ve.repair_cost
FROM device_passports dp
INNER JOIN devices d ON dp.device_id = d.id
LEFT JOIN diagnoses diag ON diag.device_id = d.id AND diag.user_id = dp.user_id
LEFT JOIN value_estimations ve ON ve.diagnosis_id = diag.id
WHERE dp.passport_uuid = 'DP-20240108-ABC123XY'
ORDER BY diag.created_at DESC;
```

#### Get user's recognition history
```sql
SELECT
    drh.device_model,
    drh.manufacturer,
    drh.confidence_score,
    drh.recognition_timestamp,
    drh.is_saved,
    dp.passport_uuid
FROM device_recognition_history drh
LEFT JOIN device_passports dp ON drh.device_passport_id = dp.id
WHERE drh.user_id = 1
ORDER BY drh.recognition_timestamp DESC
LIMIT 20;
```

#### Get device value estimations over time
```sql
SELECT
    diag.created_at AS diagnosis_date,
    ve.current_value,
    ve.post_repair_value,
    ve.repair_cost,
    ve.currency
FROM value_estimations ve
INNER JOIN diagnoses diag ON ve.diagnosis_id = diag.id
INNER JOIN device_passports dp ON diag.device_id = dp.device_id
WHERE dp.passport_uuid = 'DP-20240108-ABC123XY'
ORDER BY diag.created_at ASC;
```

---

## Performance Considerations

### Database Indexes
- All foreign keys are indexed
- Email and UID fields are indexed for fast lookups
- Timestamp fields are indexed for sorting
- Manufacturer fields are indexed for filtering

### Query Optimization
- Use of JOIN instead of multiple queries
- LEFT JOIN for optional relationships
- LIMIT clauses for pagination
- Index hints for complex queries

### Caching Strategy
- Device specifications cached (rarely change)
- User sessions cached in memory
- API responses cached for 5 minutes
- Local SQLite for offline data

### Scalability
- Horizontal scaling via load balancers
- Database replication (master-slave)
- CDN for image storage
- Queue workers for async tasks

---

## Security Measures

### Authentication
- OAuth 2.0 for Google sign-in
- Laravel Sanctum for API tokens
- Password hashing (bcrypt)
- CSRF protection

### Authorization
- User can only access their own data
- Role-based access control (future)
- API rate limiting
- Token expiration

### Data Protection
- HTTPS in production
- SQL injection prevention (prepared statements)
- XSS protection (input sanitization)
- CORS configuration

### Privacy
- GDPR compliance ready
- User data deletion support
- Audit logs for data access
- Encrypted sensitive fields

---

## Backup & Recovery

### Database Backup
```bash
# Daily automated backup
mysqldump -u root -p ayoayo > backup_$(date +%Y%m%d).sql

# Restore from backup
mysql -u root -p ayoayo < backup_20240108.sql
```

### Data Export (User Request)
```sql
-- Export all user data
SELECT * FROM users WHERE id = 1;
SELECT * FROM device_passports WHERE user_id = 1;
SELECT * FROM diagnoses WHERE user_id = 1;
SELECT * FROM device_recognition_history WHERE user_id = 1;
```

---

## Maintenance & Monitoring

### Database Maintenance
```sql
-- Optimize tables
OPTIMIZE TABLE users, devices, device_passports, diagnoses;

-- Check table integrity
CHECK TABLE users, devices;

-- Analyze tables for query optimization
ANALYZE TABLE device_passports, diagnoses;
```

### Monitoring Queries
```sql
-- Active users count
SELECT COUNT(*) FROM users WHERE last_login_at > NOW() - INTERVAL 30 DAY;

-- Total devices scanned
SELECT COUNT(*) FROM device_recognition_history;

-- Average confidence scores
SELECT AVG(confidence_score) FROM device_recognition_history WHERE is_saved = 1;

-- Storage usage
SELECT
    table_name,
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Size (MB)'
FROM information_schema.TABLES
WHERE table_schema = 'ayoayo'
ORDER BY (data_length + index_length) DESC;
```

---

## Future Enhancements

### Planned Features
- [ ] Multi-device comparison
- [ ] Market price tracking
- [ ] Repair shop recommendations
- [ ] Device trade-in marketplace
- [ ] Warranty tracking
- [ ] Insurance integration
- [ ] Device history reports (like CarFax)
- [ ] Push notifications
- [ ] Analytics dashboard
- [ ] Admin panel

### Database Schema Changes
- Add `device_comparisons` table
- Add `market_prices` table with historical data
- Add `repair_shops` table
- Add `warranties` table
- Add `notifications` table
- Add `admin_users` table with permissions

---

## Glossary

**Device Passport:** A unique digital record for each device owned by a user, similar to a vehicle registration.

**Diagnosis:** A health assessment of a device, including battery, screen, and hardware condition.

**Value Estimation:** Calculated market value of a device based on condition, age, and market data.

**Recognition History:** Record of all AI-powered device scans, whether saved or not.

**Confidence Score:** AI's certainty level (0-1) in device identification accuracy.

**Lifecycle Stage:** Current phase of device's life (New, Prime, Mature, End-of-Life).

---

## Contact & Support

For technical support or questions:
- Documentation: This file
- Backend API Docs: [backend/README.md](backend/README.md)
- Integration Guide: [LARAVEL_INTEGRATION_GUIDE.md](LARAVEL_INTEGRATION_GUIDE.md)

---

**Last Updated:** January 2024
**Version:** 1.0.0
**Database Schema Version:** 1.0
