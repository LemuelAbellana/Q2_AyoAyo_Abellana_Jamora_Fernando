# 🚀 Quick Start - Backend Integration

## ⚡ 5-Minute Setup

Follow these steps to get your backend integration running:

### Step 1: Start Backend (1 min)

```bash
# Open terminal in backend directory
cd f:\Downloads\MobileDev_AyoAyo\backend

# Start Laravel server
php artisan serve
```

✅ You should see: `Server started on http://localhost:8000`

### Step 2: Test Backend (30 seconds)

Open a new terminal and run:

```bash
curl http://localhost:8000/api/v1/health
```

✅ Expected response:
```json
{
  "status": "healthy",
  "message": "AyoAyo API is running"
}
```

### Step 3: Enable Backend in Flutter (30 seconds)

Edit `lib/config/api_config.dart` line 25:

```dart
// Change from:
static const bool useBackendApi = false;

// To:
static const bool useBackendApi = true;
```

### Step 4: Run Flutter App (2 min)

```bash
# Navigate to project root
cd f:\Downloads\MobileDev_AyoAyo

# Run for web (recommended for testing)
flutter run -d chrome
```

### Step 5: Test Integration (1 min)

1. **Sign in with Google**
   - Click "Continue with Google"
   - Sign in with your account
   - Watch console logs for: `✅ Backend OAuth sync successful`

2. **Scan a device**
   - Go to "Device Scanner"
   - Upload/take device photos
   - Complete scan
   - Watch console logs for: `✅ Device saved to backend`

3. **Verify in database**
   ```bash
   cd backend
   php artisan tinker
   >>> DB::table('users')->count()
   => 1
   >>> DB::table('device_passports')->count()
   => 1
   >>> exit
   ```

---

## 🎯 Success Checklist

After following the steps above, you should see:

- ✅ Backend running on http://localhost:8000
- ✅ Health check returns `"status": "healthy"`
- ✅ `useBackendApi` set to `true`
- ✅ Flutter app running without errors
- ✅ Google sign-in works
- ✅ Console shows: `✅ Backend OAuth sync successful`
- ✅ Device scanning saves to backend
- ✅ Console shows: `✅ Device saved to backend`
- ✅ Database has user and device records

---

## 🔧 If Something Goes Wrong

### Backend won't start
```bash
# Check PHP version (need 8.1+)
php -v

# Check if port 8000 is in use
netstat -ano | findstr :8000

# Try different port
php artisan serve --port=8001
# Then update Flutter: backendUrl = 'http://localhost:8001/api/v1'
```

### Health check fails
```bash
# Make sure backend is running
php artisan serve

# Check the exact URL
curl http://localhost:8000/api/v1/health

# If using different port:
curl http://localhost:8001/api/v1/health
```

### Flutter compilation errors
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run -d chrome
```

### Database errors
```bash
# Re-run migrations
cd backend
php artisan migrate:fresh

# This will reset the database
```

---

## 📱 Running on Different Platforms

### Web (Recommended for Testing)
```bash
flutter run -d chrome
# Use: http://localhost:8000/api/v1
```

### Windows Desktop
```bash
flutter run -d windows
# Use: http://localhost:8000/api/v1
```

### Android Emulator
```bash
flutter run -d android
# Update backendUrl to: http://10.0.2.2:8000/api/v1
```

### Physical Device
1. Find your PC's IP:
   ```bash
   ipconfig
   # Look for IPv4 Address (e.g., 192.168.1.105)
   ```

2. Update `lib/config/api_config.dart`:
   ```dart
   static const String backendUrl = 'http://192.168.1.105:8000/api/v1';
   ```

3. Make sure phone and PC are on same WiFi

---

## 📊 Console Logs to Watch For

### Successful Backend Connection
```
🏥 Checking backend health
✅ Backend is healthy: AyoAyo API is running
```

### Successful OAuth Sync
```
🔐 Starting OAuth sign-in process for provider: google
✅ OAuth authentication successful for user: your@email.com
🌐 Syncing OAuth with backend API...
🔑 API token set
✅ Backend OAuth sync successful, token set
```

### Successful Device Save
```
💾 Saving device to backend API
💾 Saving device: Apple iPhone 14 Pro
✅ Device saved to backend: 1234567890
```

### Successful Device Load
```
📡 Loading devices from backend
📋 Getting device passports for: google_123456789
✅ Loaded 3 devices from backend
```

---

## 📚 Next Steps

Once you verify everything works:

1. **Read full documentation:**
   - [BACKEND_INTEGRATION_COMPLETE.md](BACKEND_INTEGRATION_COMPLETE.md) - Complete guide
   - [backend/README.md](backend/README.md) - API documentation

2. **Test all features:**
   - Sign in/out
   - Scan multiple devices
   - View device list
   - Delete devices

3. **Explore advanced features:**
   - Image upload
   - Device diagnosis history
   - Value estimations
   - Recommendations

4. **Deploy to production:**
   - Set up production server
   - Configure SSL (HTTPS)
   - Update backend URL
   - Enable rate limiting

---

## 💡 Pro Tips

1. **Keep backend running** - Don't close the terminal running `php artisan serve`

2. **Watch both consoles** - Monitor Flutter console and Laravel logs simultaneously

3. **Use hot reload** - Make changes to Flutter code and hot reload (press `r` in terminal)

4. **Test offline mode** - Stop backend server to verify graceful fallback works

5. **Check database often** - Use `php artisan tinker` to verify data is being saved

---

## 🎉 You're All Set!

Your AyoAyo app is now fully integrated with the Laravel backend.

**What you have:**
- ✅ Complete REST API backend
- ✅ OAuth authentication with Google
- ✅ AI-powered device recognition
- ✅ Cloud storage for device passports
- ✅ Cross-device sync
- ✅ Offline support with graceful fallback

**Ready to build amazing features!** 🚀

For detailed documentation, see [BACKEND_INTEGRATION_COMPLETE.md](BACKEND_INTEGRATION_COMPLETE.md)
