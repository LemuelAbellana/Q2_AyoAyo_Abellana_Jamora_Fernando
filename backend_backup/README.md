# AyoAyo Laravel Backend API

## Overview

This Laravel backend is designed to integrate seamlessly with the AyoAyo Flutter mobile application **without requiring any changes to the Dart code**. The API endpoints mirror the exact data structures and flow used by the Flutter app.

## Key Features

- **Zero Flutter Code Changes**: API designed to match existing Flutter data structures
- **RESTful API**: Clean, predictable endpoints
- **Laravel Sanctum Authentication**: Secure token-based authentication
- **Database Migrations**: Complete schema matching Flutter's SQLite structure
- **Eloquent ORM**: Clean, maintainable database models
- **Error Handling**: Comprehensive error responses
- **Logging**: Detailed logging for debugging

## Tech Stack

- **Framework**: Laravel 10.x
- **Authentication**: Laravel Sanctum
- **Database**: MySQL/PostgreSQL
- **PHP Version**: 8.1+

## Installation

### Prerequisites

- PHP 8.1 or higher
- Composer
- MySQL 5.7+ or PostgreSQL 10+
- Node.js & NPM (for asset compilation)

### Step 1: Install Dependencies

```bash
cd backend
composer install
```

### Step 2: Environment Configuration

```bash
cp .env.example .env
php artisan key:generate
```

Edit `.env` file with your database credentials:

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=ayoayo_db
DB_USERNAME=root
DB_PASSWORD=your_password

# Gemini AI Configuration (from Flutter app)
GEMINI_API_KEY=AIzaSyCk6Ybk9etcuUz7n9VFWPrfPuZ4zNil9kQ

# Google OAuth (from Flutter app)
GOOGLE_OAUTH_CLIENT_ID=583476631419-3ar76b3sl0adai5vh0p42c467tn1f3s0.apps.googleusercontent.com
```

### Step 3: Database Setup

```bash
# Create database
mysql -u root -p -e "CREATE DATABASE ayoayo_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# Run migrations
php artisan migrate
```

### Step 4: Start Development Server

```bash
php artisan serve
```

The API will be available at `http://localhost:8000`

## API Endpoints

### Base URL

```
http://localhost:8000/api/v1
```

### Authentication Endpoints

#### 1. Register User
```http
POST /api/v1/auth/register
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "message": "User registered successfully",
  "user": {
    "id": 1,
    "uid": "local_1234567890_abc123",
    "email": "john@example.com",
    "display_name": "John Doe",
    "auth_provider": "local"
  },
  "token": "1|abcdefghijklmnopqrstuvwxyz..."
}
```

#### 2. Login
```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "john@example.com",
  "password": "password123"
}
```

#### 3. OAuth Sign-In
```http
POST /api/v1/auth/oauth-signin
Content-Type: application/json

{
  "uid": "google_1234567890",
  "email": "john@example.com",
  "display_name": "John Doe",
  "photo_url": "https://...",
  "auth_provider": "google",
  "provider_id": "1234567890",
  "email_verified": true
}
```

#### 4. Get Current User
```http
GET /api/v1/auth/user
Authorization: Bearer {token}
```

#### 5. Logout
```http
POST /api/v1/auth/logout
Authorization: Bearer {token}
```

### Device Recognition Endpoints

#### 1. Save Recognized Device
```http
POST /api/v1/device-recognition/save
Authorization: Bearer {token}
Content-Type: application/json

{
  "userId": "google_1234567890",
  "deviceModel": "iPhone 14 Pro",
  "manufacturer": "Apple",
  "yearOfRelease": 2022,
  "operatingSystem": "iOS",
  "confidence": 0.92,
  "analysisDetails": "Identified by distinctive triple camera system...",
  "imageUrls": [
    "https://example.com/image1.jpg",
    "https://example.com/image2.jpg"
  ]
}
```

**Response:**
```json
{
  "success": true,
  "message": "Device saved successfully",
  "devicePassportId": "1234567890",
  "data": {
    "id": 1234567890,
    "deviceModel": "iPhone 14 Pro",
    "manufacturer": "Apple"
  }
}
```

#### 2. Get Recognition History
```http
GET /api/v1/device-recognition/history?userId=google_1234567890&limit=10
Authorization: Bearer {token}
```

### Device Passport Endpoints

#### 1. Get All Device Passports
```http
GET /api/v1/device-passports?userId=google_1234567890
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "1234567890",
      "userId": "google_1234567890",
      "deviceModel": "iPhone 14 Pro",
      "manufacturer": "Apple",
      "yearOfRelease": 2022,
      "operatingSystem": "iOS",
      "imageUrls": ["https://..."],
      "lastDiagnosis": {
        "deviceModel": "iPhone 14 Pro",
        "aiAnalysis": "Device in excellent condition...",
        "confidenceScore": 0.92,
        "deviceHealth": {
          "screenCondition": "unknown",
          "hardwareCondition": "unknown",
          "identifiedIssues": [],
          "lifeCycleStage": "assessment_needed",
          "remainingUsefulLife": "unknown",
          "environmentalImpact": "unknown"
        },
        "valueEstimation": {
          "currentValue": 55000.0,
          "postRepairValue": 66000.0,
          "partsValue": 22000.0,
          "repairCost": 2000.0,
          "recyclingValue": 500.0,
          "currency": "₱",
          "marketPositioning": "needs_assessment",
          "depreciationRate": "standard"
        }
      }
    }
  ]
}
```

#### 2. Get Single Device Passport
```http
GET /api/v1/device-passports/{passportUuid}
Authorization: Bearer {token}
```

#### 3. Delete Device Passport
```http
DELETE /api/v1/device-passports/{passportUuid}
Authorization: Bearer {token}
```

## Flutter Integration

### How It Works Without Code Changes

The API is designed to work with the existing Flutter app by:

1. **Matching Data Structures**: All API responses match the exact format expected by Flutter models
2. **Preserving Field Names**: Uses camelCase as expected by Flutter
3. **Maintaining Flow**: Endpoints follow the same logical flow as local SQLite operations

### Integration Steps for Flutter

#### Option 1: Add Backend Toggle (Recommended)

Add a simple configuration flag to switch between local and remote storage:

```dart
// lib/config/api_config.dart
class ApiConfig {
  static const bool useBackendApi = true; // Set to true to use Laravel backend
  static const String backendUrl = 'http://localhost:8000/api/v1';

  // ... existing config
}
```

#### Option 2: Create HTTP Service Wrapper

Create a service that wraps HTTP calls:

```dart
// lib/services/api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api/v1';
  static String? _token;

  static void setToken(String token) {
    _token = token;
  }

  static Future<Map<String, dynamic>> saveDevice(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/device-recognition/save'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to save device');
    }
  }

  static Future<List<dynamic>> getDevicePassports(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/device-passports?userId=$userId'),
      headers: {
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to fetch devices');
    }
  }
}
```

#### Option 3: Modify Existing Services (Minimal Changes)

Update `camera_device_recognition_service.dart`:

```dart
Future<String> saveRecognizedDevice(
  DeviceRecognitionResult result,
  String userId,
  List<String> imageUrls
) async {
  try {
    // Use backend API if enabled
    if (ApiConfig.useBackendApi) {
      final response = await http.post(
        Uri.parse('${ApiConfig.backendUrl}/device-recognition/save'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${ApiService.token}',
        },
        body: jsonEncode({
          'userId': userId,
          'deviceModel': result.deviceModel,
          'manufacturer': result.manufacturer,
          'yearOfRelease': result.yearOfRelease,
          'operatingSystem': result.operatingSystem,
          'confidence': result.confidence,
          'analysisDetails': result.analysisDetails,
          'imageUrls': imageUrls,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['devicePassportId'];
      } else {
        throw Exception('Failed to save device');
      }
    }

    // Existing local SQLite code
    final devicePassportData = {
      // ... existing code
    };

    await _databaseService.saveWebDevicePassports([devicePassportData]);
    return devicePassportData['id'].toString();
  } catch (e) {
    print('Error saving recognized device: $e');
    rethrow;
  }
}
```

## Database Schema

The Laravel migrations create a database schema that exactly matches the Flutter app's SQLite structure:

- `users` - User accounts with OAuth support
- `devices` - Device information
- `device_images` - Device photos
- `diagnoses` - AI diagnosis results
- `value_estimations` - Device value assessments
- `device_passports` - Digital device passports
- `device_recognition_history` - Recognition history

## Testing the API

### Using cURL

```bash
# Register
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","password":"password123"}'

# Login
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'

# Save device (use token from login response)
curl -X POST http://localhost:8000/api/v1/device-recognition/save \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "userId": "local_1234567890_abc123",
    "deviceModel": "iPhone 14 Pro",
    "manufacturer": "Apple",
    "yearOfRelease": 2022,
    "operatingSystem": "iOS",
    "confidence": 0.92,
    "analysisDetails": "Test device",
    "imageUrls": []
  }'
```

### Using Postman

Import the API collection:
1. Open Postman
2. Import > Raw Text
3. Paste the API endpoints
4. Set up environment variables for `baseUrl` and `token`

## Development

### Running Tests

```bash
php artisan test
```

### Database Management

```bash
# Reset database
php artisan migrate:fresh

# Rollback migrations
php artisan migrate:rollback

# Check migration status
php artisan migrate:status
```

### Logs

Application logs are stored in `storage/logs/laravel.log`

```bash
tail -f storage/logs/laravel.log
```

## Deployment

### Production Checklist

1. Set `APP_ENV=production` in `.env`
2. Set `APP_DEBUG=false` in `.env`
3. Configure proper database credentials
4. Set up HTTPS/SSL certificate
5. Configure CORS for your Flutter app domain
6. Set up proper caching:
   ```bash
   php artisan config:cache
   php artisan route:cache
   php artisan view:cache
   ```
7. Set up queue workers for background jobs
8. Configure proper logging and monitoring

### Server Requirements

- PHP >= 8.1
- MySQL >= 5.7 or PostgreSQL >= 10
- Composer
- Web server (Apache/Nginx)

## Troubleshooting

### CORS Issues

If you encounter CORS errors, ensure `config/cors.php` is properly configured:

```php
'allowed_origins' => ['*'], // Or specify your Flutter app domain
'supports_credentials' => true,
```

### Authentication Errors

Make sure the Authorization header is included:
```
Authorization: Bearer {your_token_here}
```

### Database Connection

Verify database credentials in `.env` and test connection:
```bash
php artisan migrate:status
```

## Support

For issues or questions:
1. Check the logs: `storage/logs/laravel.log`
2. Review API responses for error messages
3. Verify environment configuration

## License

This project is part of the AyoAyo ecosystem.
