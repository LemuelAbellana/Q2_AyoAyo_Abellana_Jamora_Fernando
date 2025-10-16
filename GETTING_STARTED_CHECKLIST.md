# Getting Started Checklist

Follow this checklist to integrate the Laravel backend with your AyoAyo Flutter app.

## 📋 Prerequisites Check

- [ ] PHP 8.1 or higher installed
  ```bash
  php -v
  ```
- [ ] Composer installed
  ```bash
  composer --version
  ```
- [ ] MySQL 5.7+ or MariaDB installed
  ```bash
  mysql --version
  ```
- [ ] Flutter SDK installed
  ```bash
  flutter --version
  ```

---

## 🚀 Backend Setup (10 minutes)

### Step 1: Install Laravel
- [ ] Navigate to backend directory
  ```bash
  cd "f:\Downloads\MobileDev_AyoAyo\backend"
  ```

- [ ] Install dependencies (choose one):
  ```bash
  # If starting fresh:
  composer create-project laravel/laravel . "10.*"

  # OR if files exist:
  composer install
  ```

### Step 2: Configure Environment
- [ ] Copy environment file
  ```bash
  copy .env.example .env
  ```

- [ ] Generate application key
  ```bash
  php artisan key:generate
  ```

- [ ] Edit `.env` file with database credentials:
  ```env
  DB_CONNECTION=mysql
  DB_HOST=127.0.0.1
  DB_PORT=3306
  DB_DATABASE=ayoayo_db
  DB_USERNAME=root
  DB_PASSWORD=your_password
  ```

### Step 3: Create Database
- [ ] Create MySQL database:
  ```bash
  mysql -u root -p -e "CREATE DATABASE ayoayo_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
  ```

  **OR** use phpMyAdmin:
  - Open http://localhost/phpmyadmin
  - Click "New"
  - Database name: `ayoayo_db`
  - Collation: `utf8mb4_unicode_ci`
  - Click "Create"

### Step 4: Run Migrations
- [ ] Run database migrations
  ```bash
  php artisan migrate
  ```

- [ ] Verify migrations succeeded
  ```bash
  php artisan migrate:status
  ```

### Step 5: Start Server
- [ ] Start Laravel development server
  ```bash
  php artisan serve
  ```

- [ ] Keep this terminal open (server must stay running)

### Step 6: Test API
- [ ] Open new terminal
- [ ] Test health endpoint
  ```bash
  curl http://localhost:8000/api/v1/health
  ```

- [ ] Expected response:
  ```json
  {
    "status": "ok",
    "message": "AyoAyo API is running",
    "version": "1.0.0"
  }
  ```

✅ **Backend is now running!**

---

## 📱 Flutter Integration (15 minutes)

### Step 1: Add HTTP Package
- [ ] Open `pubspec.yaml`
- [ ] Add dependency:
  ```yaml
  dependencies:
    http: ^1.1.0
  ```
- [ ] Run:
  ```bash
  flutter pub get
  ```

### Step 2: Create API Service
- [ ] Create file: `lib/services/api_service.dart`
- [ ] Copy code from [LARAVEL_INTEGRATION_GUIDE.md](./LARAVEL_INTEGRATION_GUIDE.md#step-2-create-api-service)

### Step 3: Update API Config
- [ ] Open: `lib/config/api_config.dart`
- [ ] Add these constants:
  ```dart
  // Backend integration flag
  static const bool useBackendApi = true;

  // For local testing
  static const String backendUrl = 'http://localhost:8000/api/v1';

  // For Android emulator, use:
  // static const String backendUrl = 'http://10.0.2.2:8000/api/v1';

  // For physical device, use your computer's IP:
  // static const String backendUrl = 'http://192.168.1.XXX:8000/api/v1';
  ```

### Step 4: Update Recognition Service
- [ ] Open: `lib/services/camera_device_recognition_service.dart`
- [ ] Add import:
  ```dart
  import 'package:ayoayo/services/api_service.dart';
  import 'package:ayoayo/config/api_config.dart';
  ```
- [ ] Modify `saveRecognizedDevice()` method
- [ ] Add backend call before local save (see guide)

### Step 5: Update Device Provider
- [ ] Open: `lib/providers/device_provider.dart`
- [ ] Add import:
  ```dart
  import 'package:ayoayo/services/api_service.dart';
  import 'package:ayoayo/config/api_config.dart';
  ```
- [ ] Modify `loadDevices()` method
- [ ] Add `_loadDevicesFromBackend()` method (see guide)

### Step 6: Update User Service
- [ ] Open: `lib/services/user_service.dart`
- [ ] Add import:
  ```dart
  import 'package:ayoayo/services/api_service.dart';
  import 'package:ayoayo/config/api_config.dart';
  ```
- [ ] Modify `handleOAuthSignIn()` method
- [ ] Add backend OAuth sync (see guide)

✅ **Flutter integration complete!**

---

## 🧪 Testing (10 minutes)

### Test 1: Backend Endpoints
- [ ] Test register:
  ```bash
  curl -X POST http://localhost:8000/api/v1/auth/register \
    -H "Content-Type: application/json" \
    -d '{"name":"Test User","email":"test@example.com","password":"test123"}'
  ```

- [ ] Copy the token from response

- [ ] Test save device (replace YOUR_TOKEN):
  ```bash
  curl -X POST http://localhost:8000/api/v1/device-recognition/save \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer YOUR_TOKEN" \
    -d '{
      "userId":"local_test",
      "deviceModel":"iPhone 14 Pro",
      "manufacturer":"Apple",
      "yearOfRelease":2022,
      "operatingSystem":"iOS",
      "confidence":0.92,
      "analysisDetails":"Test device",
      "imageUrls":[]
    }'
  ```

- [ ] Test get devices:
  ```bash
  curl "http://localhost:8000/api/v1/device-passports?userId=local_test" \
    -H "Authorization: Bearer YOUR_TOKEN"
  ```

### Test 2: Flutter App
- [ ] Start Flutter app
  ```bash
  flutter run
  ```

- [ ] Sign in with Google account

- [ ] Navigate to Device Scanner

- [ ] Take photos or select from gallery

- [ ] Click Analyze

- [ ] Click "Use Result"

- [ ] Verify device appears in device list

### Test 3: Verify Database
- [ ] Open MySQL:
  ```bash
  mysql -u root -p ayoayo_db
  ```

- [ ] Check tables:
  ```sql
  SHOW TABLES;
  ```

- [ ] Check device passports:
  ```sql
  SELECT * FROM device_passports ORDER BY created_at DESC LIMIT 5;
  ```

- [ ] Check devices:
  ```sql
  SELECT * FROM devices ORDER BY created_at DESC LIMIT 5;
  ```

✅ **All tests passing!**

---

## 📊 Verification Checklist

### Backend Verification
- [ ] Laravel server running on port 8000
- [ ] Database `ayoayo_db` exists
- [ ] All 7 migration tables created
- [ ] Health endpoint returns 200 OK
- [ ] Can register new user
- [ ] Can save device via API

### Flutter Verification
- [ ] App builds without errors
- [ ] `useBackendApi` flag set correctly
- [ ] Can sign in with Google
- [ ] Device scanner works
- [ ] Device appears in list after scanning
- [ ] Device syncs to backend (check database)

### Integration Verification
- [ ] OAuth sign-in creates user in Laravel DB
- [ ] Device scan creates records in Laravel DB
- [ ] Device list loads from Laravel API
- [ ] All device data displays correctly

---

## 🔍 Troubleshooting

### Issue: "Connection refused"
**Solution:**
- [ ] Verify backend is running: `php artisan serve`
- [ ] Check URL in `api_config.dart`
- [ ] For Android emulator, use `http://10.0.2.2:8000/api/v1`
- [ ] For physical device, use computer's IP address

### Issue: "SQLSTATE[HY000] [2002]"
**Solution:**
- [ ] Start MySQL service
- [ ] Windows (XAMPP): Start MySQL in control panel
- [ ] Mac: `brew services start mysql`
- [ ] Linux: `sudo systemctl start mysql`

### Issue: "Access denied for user"
**Solution:**
- [ ] Check `.env` file has correct credentials
- [ ] Test MySQL login: `mysql -u root -p`
- [ ] Reset MySQL password if needed

### Issue: "Unauthenticated" error
**Solution:**
- [ ] Ensure OAuth sign-in completed
- [ ] Check `ApiService.setToken()` was called
- [ ] Verify token is included in requests

### Issue: Device not appearing in list
**Solution:**
- [ ] Check Laravel logs: `backend/storage/logs/laravel.log`
- [ ] Verify API call succeeded (200/201 response)
- [ ] Check database has device record
- [ ] Ensure userId matches in request

### Issue: CORS errors
**Solution:**
- [ ] Check `backend/config/cors.php`
- [ ] Ensure `'allowed_origins' => ['*']`
- [ ] Restart Laravel server after config changes

---

## 📚 Documentation Reference

| Document | Purpose | When to Use |
|----------|---------|-------------|
| [SETUP.md](./backend/SETUP.md) | Quick setup guide | First-time setup |
| [README.md](./backend/README.md) | Complete API docs | Understanding APIs |
| [LARAVEL_INTEGRATION_GUIDE.md](./LARAVEL_INTEGRATION_GUIDE.md) | Integration steps | Flutter integration |
| [API_QUICK_REFERENCE.md](./backend/API_QUICK_REFERENCE.md) | API cheat sheet | Quick reference |
| [ARCHITECTURE.md](./ARCHITECTURE.md) | System design | Understanding architecture |
| [BACKEND_INTEGRATION_SUMMARY.md](./BACKEND_INTEGRATION_SUMMARY.md) | Overview | High-level understanding |

---

## 🎯 Success Criteria

You'll know everything is working when:
- ✅ Backend server runs without errors
- ✅ Database has all required tables
- ✅ Can sign in with Google on Flutter app
- ✅ Can scan device and save to backend
- ✅ Device appears in device list
- ✅ Can verify device in MySQL database

---

## 🚀 Next Steps After Setup

### Immediate (Today)
- [ ] Test all API endpoints with Postman
- [ ] Scan multiple devices
- [ ] Verify data consistency

### Short Term (This Week)
- [ ] Add image upload functionality
- [ ] Implement caching
- [ ] Add error handling
- [ ] Test on physical device

### Long Term (This Month)
- [ ] Deploy to production server
- [ ] Set up SSL/HTTPS
- [ ] Configure production database
- [ ] Add monitoring/logging

---

## 🆘 Getting Help

If you encounter issues:

1. **Check Logs**
   - Laravel: `backend/storage/logs/laravel.log`
   - Flutter: Console output

2. **Review Documentation**
   - See reference table above

3. **Verify Prerequisites**
   - PHP, Composer, MySQL versions
   - Network connectivity

4. **Test Components Separately**
   - Test backend APIs with curl
   - Test Flutter with `useBackendApi = false`

---

## ✅ Final Checklist

Before considering setup complete:

- [ ] Backend runs without errors
- [ ] Database accessible
- [ ] All migrations applied
- [ ] API health check passes
- [ ] Flutter app compiles
- [ ] Can authenticate
- [ ] Can scan device
- [ ] Device saves to backend
- [ ] Device loads from backend
- [ ] Data verified in database

**Congratulations! Your Laravel backend is integrated! 🎉**

---

## 📝 Notes

- Keep Laravel server running during development
- Monitor logs in separate terminal
- Use feature flag to toggle between local/remote
- Test frequently after changes

## ⏱️ Estimated Time

- Backend Setup: ~10 minutes
- Flutter Integration: ~15 minutes
- Testing: ~10 minutes
- **Total: ~35 minutes**

Good luck! 🚀
