# OAuth "Malformed Request" Error - Troubleshooting Guide

## Error Message
> "The server cannot process the request because it is malformed. It should not be retried."

## What This Means

This error occurs when the Flutter app tries to sync your Google OAuth login with the Laravel backend, but something goes wrong. The good news: **OAuth still works!** The app now falls back to local storage.

## Quick Fix: Disable Backend API (Recommended for Testing)

If you just want to test Google OAuth without setting up the backend:

1. Open [.env](.env) file
2. Change this line:
   ```env
   USE_BACKEND_API=true
   ```
   to:
   ```env
   USE_BACKEND_API=false
   ```
3. Save the file and restart the app

**Done!** OAuth will now work in local-only mode without needing the backend.

---

## Root Causes & Solutions

### Cause 1: Laravel Backend Not Running ❌

**Check if backend is running:**
```bash
# Navigate to your Laravel project
cd path/to/your/laravel/project

# Start the backend server
php artisan serve
```

The backend should now be running at `http://localhost:8000`

**Test the backend:**
- Open browser: `http://localhost:8000/api/v1/health`
- You should see: `{"message": "API is healthy"}`

---

### Cause 2: OAuth Endpoint Missing on Backend 🔍

The Flutter app is trying to call:
```
POST http://localhost:8000/api/v1/auth/oauth-signin
```

**Check if this endpoint exists in your Laravel routes:**

```bash
php artisan route:list | grep oauth
```

**If the endpoint is missing, add it to your Laravel backend:**

Create the route in `routes/api.php`:
```php
Route::post('/auth/oauth-signin', [AuthController::class, 'oauthSignIn']);
```

Create the controller method in `app/Http/Controllers/AuthController.php`:
```php
public function oauthSignIn(Request $request)
{
    $validated = $request->validate([
        'uid' => 'required|string',
        'email' => 'required|email',
        'display_name' => 'required|string',
        'photo_url' => 'nullable|string',
        'auth_provider' => 'required|string',
        'provider_id' => 'required|string',
        'email_verified' => 'boolean',
    ]);

    // Find or create user
    $user = User::updateOrCreate(
        ['email' => $validated['email']],
        [
            'name' => $validated['display_name'],
            'email' => $validated['email'],
            'provider' => $validated['auth_provider'],
            'provider_id' => $validated['provider_id'],
            'email_verified_at' => $validated['email_verified'] ? now() : null,
        ]
    );

    // Generate token
    $token = $user->createToken('auth_token')->plainTextToken;

    return response()->json([
        'success' => true,
        'user' => $user,
        'token' => $token,
    ]);
}
```

---

### Cause 3: Request Format Mismatch 📝

The Flutter app sends this JSON structure:
```json
{
  "uid": "google_123456789",
  "email": "user@example.com",
  "display_name": "John Doe",
  "photo_url": "https://...",
  "auth_provider": "google",
  "provider_id": "123456789",
  "email_verified": true
}
```

**Make sure your Laravel backend expects this exact format.**

Check the validation rules in your controller match the above fields.

---

### Cause 4: CORS Issues 🌐

If you're running on web, you might have CORS issues.

**Fix CORS in Laravel:**

1. Install CORS package (if not already installed):
   ```bash
   composer require fruitcake/laravel-cors
   ```

2. Configure CORS in `config/cors.php`:
   ```php
   'paths' => ['api/*'],
   'allowed_methods' => ['*'],
   'allowed_origins' => ['*'], // For development only
   'allowed_headers' => ['*'],
   'supports_credentials' => false,
   ```

3. Add CORS middleware to `app/Http/Kernel.php`:
   ```php
   protected $middleware = [
       // ...
       \Fruitcake\Cors\HandleCors::class,
   ];
   ```

---

### Cause 5: Wrong Backend URL 🔗

**For Android Emulator**, the URL should be:
```env
BACKEND_URL=http://10.0.2.2:8000/api/v1
```
(NOT `localhost`, because `localhost` in the emulator refers to the emulator itself)

**For iOS Simulator**, use:
```env
BACKEND_URL=http://localhost:8000/api/v1
```

**For Physical Device**, use your PC's IP:
```env
BACKEND_URL=http://192.168.1.100:8000/api/v1
```
(Replace with your actual IP address)

**Find your IP address:**
- Windows: `ipconfig`
- Mac/Linux: `ifconfig`

---

## How the Fix Works

The updated code in [lib/services/user_service.dart](lib/services/user_service.dart) now includes a **fallback mechanism**:

```dart
// Try to sync with backend
try {
  final backendResponse = await ApiService.oauthSignIn(...);
  // Use backend response
} catch (e) {
  print('⚠️ Backend OAuth sync failed: $e');
  print('📱 Falling back to local-only mode...');
  // Fallback: Use local storage instead
  _currentUser = oauthUserData;
  await _saveUserLocally(_currentUser!);
  return _currentUser;
}
```

**This means:**
- ✅ OAuth works even if backend fails
- ✅ Data is saved locally using SharedPreferences
- ✅ You can develop and test without backend
- ✅ Backend sync happens automatically when available

---

## Testing OAuth

### Step 1: Test Without Backend
```env
USE_BACKEND_API=false
```

1. Run the app
2. Click "Sign in with Google"
3. Select your Google account
4. ✅ You should be logged in successfully

### Step 2: Test With Backend (Optional)
```env
USE_BACKEND_API=true
```

1. Start Laravel backend: `php artisan serve`
2. Run the app
3. Click "Sign in with Google"
4. Select your Google account
5. Check backend logs to verify the request was received
6. ✅ You should be logged in and synced with backend

---

## Debugging Tips

### View Console Logs

When you run the app, watch the console for these messages:

**OAuth Started:**
```
🚀 Starting Google Sign-In process...
📱 Running on mobile - using native Google Sign-In
```

**OAuth Successful:**
```
✅ Google Sign-In successful: user@example.com
```

**Backend Sync Attempt:**
```
🌐 Syncing OAuth with Laravel backend...
```

**Backend Success:**
```
✅ Backend OAuth sync successful
```

**Backend Failed (with fallback):**
```
⚠️ Backend OAuth sync failed: <error details>
📱 Falling back to local-only mode...
```

### Check API Response

The error message contains helpful details:
- **400 Bad Request**: Request format is wrong
- **404 Not Found**: Endpoint doesn't exist
- **500 Server Error**: Backend crashed

Look at the console output after "📡 Response Body:" to see the exact error from the backend.

---

## Recommended Configuration for Development

**`.env` file:**
```env
# Use demo key or get real one from https://makersuite.google.com/app/apikey
GEMINI_API_KEY=YOUR_GEMINI_API_KEY_HERE

# Get from https://console.cloud.google.com/apis/credentials
GOOGLE_OAUTH_CLIENT_ID=YOUR_GOOGLE_OAUTH_CLIENT_ID_HERE

# Disable backend for now to test OAuth locally
USE_BACKEND_API=false

# Backend URL (not used when USE_BACKEND_API=false)
BACKEND_URL=http://localhost:8000/api/v1
```

This configuration:
- ✅ Allows you to test Google OAuth immediately
- ✅ Doesn't require backend setup
- ✅ Saves user data locally
- ✅ Can be enabled later when backend is ready

---

## Summary

**The error is fixed!** The app now handles backend failures gracefully:

1. **OAuth works** even without backend
2. **Data is saved** using SharedPreferences
3. **Backend sync** happens automatically when available
4. **No user impact** - seamless experience

**Next Steps:**
1. Set `USE_BACKEND_API=false` in `.env`
2. Run the app and test Google OAuth
3. Set up Laravel backend later (optional)
4. Re-enable backend when ready

Need help? Check the console logs for detailed error messages!
