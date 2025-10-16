# AyoAyo API Quick Reference

## Base URL
```
http://localhost:8000/api/v1
```

## Authentication
All protected endpoints require:
```
Authorization: Bearer {token}
```

---

## 🔐 Authentication Endpoints

### Register User
```http
POST /auth/register
```
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123"
}
```

### Login
```http
POST /auth/login
```
```json
{
  "email": "john@example.com",
  "password": "password123"
}
```

### OAuth Sign-In
```http
POST /auth/oauth-signin
```
```json
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

### Get Current User
```http
GET /auth/user
Authorization: Bearer {token}
```

### Logout
```http
POST /auth/logout
Authorization: Bearer {token}
```

---

## 📱 Device Recognition Endpoints

### Save Recognized Device
```http
POST /device-recognition/save
Authorization: Bearer {token}
```
```json
{
  "userId": "google_1234567890",
  "deviceModel": "iPhone 14 Pro",
  "manufacturer": "Apple",
  "yearOfRelease": 2022,
  "operatingSystem": "iOS",
  "confidence": 0.92,
  "analysisDetails": "Identified by camera system...",
  "imageUrls": ["https://...", "https://..."]
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

### Get Recognition History
```http
GET /device-recognition/history?userId={userId}&limit=10
Authorization: Bearer {token}
```

---

## 📋 Device Passport Endpoints

### List All Devices
```http
GET /device-passports?userId={userId}
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
        "aiAnalysis": "...",
        "confidenceScore": 0.92,
        "deviceHealth": {
          "screenCondition": "unknown",
          "hardwareCondition": "unknown",
          "identifiedIssues": [],
          "lifeCycleStage": "assessment_needed"
        },
        "valueEstimation": {
          "currentValue": 55000.0,
          "currency": "₱"
        }
      }
    }
  ]
}
```

### Get Single Device
```http
GET /device-passports/{passportUuid}
Authorization: Bearer {token}
```

### Delete Device
```http
DELETE /device-passports/{passportUuid}
Authorization: Bearer {token}
```

---

## 🧪 cURL Examples

### Register
```bash
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "password123"
  }'
```

### Login
```bash
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

### Save Device
```bash
curl -X POST http://localhost:8000/api/v1/device-recognition/save \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "userId": "local_1234567890",
    "deviceModel": "iPhone 14 Pro",
    "manufacturer": "Apple",
    "yearOfRelease": 2022,
    "operatingSystem": "iOS",
    "confidence": 0.92,
    "analysisDetails": "Test device",
    "imageUrls": []
  }'
```

### Get Devices
```bash
curl -X GET "http://localhost:8000/api/v1/device-passports?userId=local_1234567890" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

## 📊 Response Codes

| Code | Meaning |
|------|---------|
| 200 | Success |
| 201 | Created |
| 400 | Bad Request |
| 401 | Unauthorized |
| 404 | Not Found |
| 422 | Validation Error |
| 500 | Server Error |

---

## 🔧 Testing with Postman

### Setup
1. Create new collection "AyoAyo API"
2. Add environment variable: `baseUrl` = `http://localhost:8000/api/v1`
3. Add environment variable: `token` = (will be set after login)

### Test Flow
1. Register user → Copy token
2. Set `token` variable in Postman
3. Save device → Copy devicePassportId
4. Get devices → Verify device appears
5. Delete device → Verify removed

---

## 🚀 Quick Start Testing

```bash
# 1. Health Check
curl http://localhost:8000/api/v1/health

# 2. Register
TOKEN=$(curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test","email":"test@test.com","password":"test123"}' \
  | jq -r '.token')

# 3. Get Current User
curl http://localhost:8000/api/v1/auth/user \
  -H "Authorization: Bearer $TOKEN"

# 4. Save Device
curl -X POST http://localhost:8000/api/v1/device-recognition/save \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "userId":"local_test",
    "deviceModel":"iPhone 14 Pro",
    "manufacturer":"Apple",
    "yearOfRelease":2022,
    "operatingSystem":"iOS",
    "confidence":0.92,
    "analysisDetails":"Test",
    "imageUrls":[]
  }'

# 5. Get Devices
curl "http://localhost:8000/api/v1/device-passports?userId=local_test" \
  -H "Authorization: Bearer $TOKEN"
```

---

## 🐛 Common Errors

### "Unauthenticated"
**Solution**: Include `Authorization: Bearer {token}` header

### "User not found"
**Solution**: Ensure userId matches registered user's uid

### "CORS error"
**Solution**: Check `backend/config/cors.php` settings

### "Connection refused"
**Solution**: Ensure backend is running (`php artisan serve`)

---

## 📱 Flutter Integration Snippet

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const baseUrl = 'http://localhost:8000/api/v1';
  static String? _token;

  static void setToken(String token) => _token = token;

  static Future<Map> saveDevice(Map data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/device-recognition/save'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  static Future<List> getDevices(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/device-passports?userId=$userId'),
      headers: {'Authorization': 'Bearer $_token'},
    );
    final data = jsonDecode(response.body);
    return data['data'];
  }
}
```

---

## 📚 Full Documentation
- [README.md](./README.md) - Complete API documentation
- [SETUP.md](./SETUP.md) - Setup instructions
- [../LARAVEL_INTEGRATION_GUIDE.md](../LARAVEL_INTEGRATION_GUIDE.md) - Flutter integration
