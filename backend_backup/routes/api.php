<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\DeviceRecognitionController;
use App\Http\Controllers\Api\DevicePassportController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
| These routes are designed to integrate seamlessly with the Flutter
| AyoAyo mobile app without requiring any changes to the Dart code.
|
*/

// Public routes (no authentication required)
Route::prefix('v1')->group(function () {

    // Authentication endpoints
    Route::post('/auth/register', [AuthController::class, 'register']);
    Route::post('/auth/login', [AuthController::class, 'login']);
    Route::post('/auth/oauth-signin', [AuthController::class, 'oauthSignIn']);

    // Health check
    Route::get('/health', function () {
        return response()->json([
            'status' => 'ok',
            'message' => 'AyoAyo API is running',
            'version' => '1.0.0',
            'timestamp' => now()->toIso8601String(),
        ]);
    });
});

// Protected routes (authentication required)
Route::prefix('v1')->middleware('auth:sanctum')->group(function () {

    // Auth endpoints
    Route::get('/auth/user', [AuthController::class, 'getCurrentUser']);
    Route::post('/auth/logout', [AuthController::class, 'logout']);

    // Device Recognition endpoints
    Route::post('/device-recognition/save', [DeviceRecognitionController::class, 'saveRecognizedDevice']);
    Route::get('/device-recognition/history', [DeviceRecognitionController::class, 'getRecognitionHistory']);

    // Device Passport endpoints
    Route::get('/device-passports', [DevicePassportController::class, 'index']);
    Route::get('/device-passports/{passportUuid}', [DevicePassportController::class, 'show']);
    Route::delete('/device-passports/{passportUuid}', [DevicePassportController::class, 'destroy']);
});

// Fallback route for undefined endpoints
Route::fallback(function () {
    return response()->json([
        'error' => 'Endpoint not found',
        'message' => 'The requested API endpoint does not exist',
    ], 404);
});
