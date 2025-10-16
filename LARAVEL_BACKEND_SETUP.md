# Laravel Backend Setup for OAuth Integration

## Overview

The Flutter app now sends OAuth user data to your Laravel backend, which:
1. **Creates or updates the user** in MySQL database
2. **Generates an authentication token** for the user
3. **Returns the user data** back to Flutter
4. **Stores all user information** persistently in Laravel

---

## Required Laravel Endpoint

### Endpoint Details:
```
POST /api/v1/auth/oauth-signin
```

### Request Format (sent by Flutter):
```json
{
  "uid": "google_123456789",
  "email": "user@example.com",
  "display_name": "John Doe",
  "photo_url": "https://lh3.googleusercontent.com/...",
  "auth_provider": "google",
  "provider_id": "123456789",
  "email_verified": true
}
```

### Response Format (expected by Flutter):
```json
{
  "success": true,
  "user": {
    "id": 1,
    "uid": "google_123456789",
    "email": "user@example.com",
    "name": "John Doe",
    "display_name": "John Doe",
    "photo_url": "https://lh3.googleusercontent.com/...",
    "auth_provider": "google",
    "provider_id": "123456789",
    "email_verified_at": "2025-01-15T10:30:00.000000Z",
    "created_at": "2025-01-15T10:30:00.000000Z",
    "updated_at": "2025-01-15T10:30:00.000000Z"
  },
  "token": "1|xyz123abc..."
}
```

---

## Step-by-Step Setup

### Step 1: Create Migration

```bash
php artisan make:migration create_users_table_for_oauth
```

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('uid')->unique(); // Firebase/OAuth UID
            $table->string('email')->unique();
            $table->string('name');
            $table->string('display_name')->nullable();
            $table->string('photo_url')->nullable();
            $table->string('auth_provider')->default('email'); // google, github, email
            $table->string('provider_id')->nullable(); // Provider's user ID
            $table->string('password')->nullable(); // For email/password auth
            $table->timestamp('email_verified_at')->nullable();
            $table->timestamps();
            $table->timestamp('last_login_at')->nullable();
            $table->boolean('is_active')->default(true);
        });
    }

    public function down()
    {
        Schema::dropIfExists('users');
    }
};
```

Run the migration:
```bash
php artisan migrate
```

### Step 2: Install Laravel Sanctum (for token authentication)

```bash
composer require laravel/sanctum
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
php artisan migrate
```

Add to `app/Models/User.php`:
```php
<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens;

    protected $fillable = [
        'uid',
        'email',
        'name',
        'display_name',
        'photo_url',
        'auth_provider',
        'provider_id',
        'password',
        'email_verified_at',
        'last_login_at',
        'is_active',
    ];

    protected $hidden = [
        'password',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'last_login_at' => 'datetime',
        'is_active' => 'boolean',
    ];
}
```

### Step 3: Create Auth Controller

```bash
php artisan make:controller Api/AuthController
```

```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{
    /**
     * Handle OAuth sign-in (Google, GitHub, etc.)
     * Creates or updates user in database
     */
    public function oauthSignIn(Request $request)
    {
        // Validate request
        $validator = Validator::make($request->all(), [
            'uid' => 'required|string',
            'email' => 'required|email',
            'display_name' => 'required|string',
            'photo_url' => 'nullable|string',
            'auth_provider' => 'required|string',
            'provider_id' => 'required|string',
            'email_verified' => 'boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 400);
        }

        try {
            // Find or create user
            $user = User::updateOrCreate(
                ['email' => $request->email],
                [
                    'uid' => $request->uid,
                    'name' => $request->display_name,
                    'display_name' => $request->display_name,
                    'photo_url' => $request->photo_url,
                    'auth_provider' => $request->auth_provider,
                    'provider_id' => $request->provider_id,
                    'email_verified_at' => $request->email_verified ? now() : null,
                    'last_login_at' => now(),
                    'is_active' => true,
                ]
            );

            // Generate API token
            $token = $user->createToken('auth_token')->plainTextToken;

            return response()->json([
                'success' => true,
                'message' => 'OAuth sign-in successful',
                'user' => $user,
                'token' => $token,
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'OAuth sign-in failed',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Register new user (email/password)
     */
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|string|min:6',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 400);
        }

        try {
            $user = User::create([
                'uid' => 'email_' . uniqid(),
                'name' => $request->name,
                'email' => $request->email,
                'password' => Hash::make($request->password),
                'auth_provider' => 'email',
                'is_active' => true,
            ]);

            $token = $user->createToken('auth_token')->plainTextToken;

            return response()->json([
                'success' => true,
                'message' => 'User registered successfully',
                'user' => $user,
                'token' => $token,
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Registration failed',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Login with email/password
     */
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors(),
            ], 400);
        }

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid credentials',
            ], 401);
        }

        $user->update(['last_login_at' => now()]);
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login successful',
            'user' => $user,
            'token' => $token,
        ], 200);
    }

    /**
     * Get current authenticated user
     */
    public function user(Request $request)
    {
        return response()->json([
            'success' => true,
            'user' => $request->user(),
        ], 200);
    }

    /**
     * Logout user
     */
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logged out successfully',
        ], 200);
    }
}
```

### Step 4: Add Routes

In `routes/api.php`:

```php
<?php

use App\Http\Controllers\Api\AuthController;
use Illuminate\Support\Facades\Route;

// API v1 routes
Route::prefix('v1')->group(function () {

    // Public routes (no authentication required)
    Route::prefix('auth')->group(function () {
        Route::post('/register', [AuthController::class, 'register']);
        Route::post('/login', [AuthController::class, 'login']);
        Route::post('/oauth-signin', [AuthController::class, 'oauthSignIn']);
    });

    // Protected routes (authentication required)
    Route::middleware('auth:sanctum')->group(function () {
        Route::prefix('auth')->group(function () {
            Route::get('/user', [AuthController::class, 'user']);
            Route::post('/logout', [AuthController::class, 'logout']);
        });
    });

    // Health check
    Route::get('/health', function () {
        return response()->json([
            'status' => 'ok',
            'message' => 'API is healthy',
            'timestamp' => now(),
        ]);
    });
});
```

### Step 5: Configure CORS

In `config/cors.php`:

```php
<?php

return [
    'paths' => ['api/*'],
    'allowed_methods' => ['*'],
    'allowed_origins' => ['*'], // For development only
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['*'],
    'exposed_headers' => [],
    'max_age' => 0,
    'supports_credentials' => false,
];
```

Make sure CORS middleware is enabled in `app/Http/Kernel.php`:

```php
protected $middleware = [
    // ...
    \Illuminate\Http\Middleware\HandleCors::class,
];
```

### Step 6: Start Laravel Server

```bash
php artisan serve
```

Your API should now be running at: `http://localhost:8000`

---

## Testing the Setup

### Test 1: Health Check

```bash
curl http://localhost:8000/api/v1/health
```

Expected response:
```json
{
  "status": "ok",
  "message": "API is healthy",
  "timestamp": "2025-01-15T10:30:00.000000Z"
}
```

### Test 2: OAuth Sign-In

```bash
curl -X POST http://localhost:8000/api/v1/auth/oauth-signin \
  -H "Content-Type: application/json" \
  -d '{
    "uid": "google_123456789",
    "email": "test@example.com",
    "display_name": "Test User",
    "photo_url": "https://example.com/photo.jpg",
    "auth_provider": "google",
    "provider_id": "123456789",
    "email_verified": true
  }'
```

Expected response:
```json
{
  "success": true,
  "message": "OAuth sign-in successful",
  "user": {
    "id": 1,
    "uid": "google_123456789",
    "email": "test@example.com",
    "name": "Test User",
    ...
  },
  "token": "1|xyz123abc..."
}
```

### Test 3: Check Database

```bash
php artisan tinker
```

```php
>>> \App\Models\User::all();
```

You should see your OAuth user in the database!

---

## Flutter Integration

With the backend running, your Flutter app will:

1. ✅ Authenticate user via Google OAuth
2. ✅ Send user data to Laravel: `POST /api/v1/auth/oauth-signin`
3. ✅ Laravel creates/updates user in MySQL database
4. ✅ Laravel returns user data + auth token
5. ✅ Flutter saves user data locally
6. ✅ User is logged in with persistent session

### Expected Console Output (Flutter):

```
🚀 Starting Google sign-in from login screen...
🔐 Starting OAuth sign-in process for provider: google
✅ Google Sign-In successful: user@example.com
✅ OAuth authentication successful for user: user@example.com
🌐 Syncing OAuth user with Laravel backend...
📤 Creating/updating user in MySQL database...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ User saved to Laravel database successfully!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 Database ID: 1
📧 Email: user@example.com
👤 Name: John Doe
🔐 Provider: google
🔑 Auth Token: ✅ Received
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Troubleshooting

### Issue: "Connection refused"

**Solution:**
- Make sure Laravel is running: `php artisan serve`
- Check `.env` in Flutter: `BACKEND_URL=http://localhost:8000/api/v1`

### Issue: "404 Not Found"

**Solution:**
- Run: `php artisan route:list | grep oauth`
- Verify route exists: `POST api/v1/auth/oauth-signin`
- Clear route cache: `php artisan route:clear`

### Issue: "CORS error"

**Solution:**
- Install: `composer require fruitcake/laravel-cors`
- Configure `config/cors.php` (see Step 5 above)
- Restart Laravel server

### Issue: "Database connection error"

**Solution:**
- Configure `.env` in Laravel project:
  ```
  DB_CONNECTION=mysql
  DB_HOST=127.0.0.1
  DB_PORT=3306
  DB_DATABASE=ayoayo
  DB_USERNAME=root
  DB_PASSWORD=
  ```
- Create database: `CREATE DATABASE ayoayo;`
- Run migrations: `php artisan migrate`

---

## Summary

**What was done:**
1. ✅ Updated Flutter `.env` to enable backend (`USE_BACKEND_API=true`)
2. ✅ Improved OAuth user service with detailed logging
3. ✅ Created complete Laravel backend setup guide

**What you need to do:**
1. Set up Laravel backend using the guide above
2. Run `php artisan serve`
3. Test OAuth sign-in in Flutter app
4. User will be saved to MySQL database automatically!

**Files Updated:**
- `.env` - Enabled backend API
- `lib/services/user_service.dart` - Enhanced OAuth integration with better logging

---

**Ready to test!** Start your Laravel backend and try Google Sign-In! 🚀
