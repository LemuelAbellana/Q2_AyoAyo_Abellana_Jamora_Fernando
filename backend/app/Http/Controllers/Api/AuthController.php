<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{
    /**
     * Register a new user
     * Matches Flutter: user_service.dart -> registerUser()
     */
    public function register(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'name' => 'required|string|max:255',
                'email' => 'required|string|email|max:255|unique:users,email',
                'password' => 'required|string|min:6',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'error' => 'Validation failed',
                    'errors' => $validator->errors(),
                ], 422);
            }

            $validated = $validator->validated();

            // Create user with local auth provider
            $user = User::create([
                'uid' => 'local_' . time() . '_' . uniqid(),
                'email' => $validated['email'],
                'display_name' => $validated['name'],
                'auth_provider' => 'local',
                'password_hash' => Hash::make($validated['password']),
                'email_verified' => false,
                'is_active' => true,
                'preferences' => json_encode([]),
            ]);

            // Create token
            $token = $user->createToken('auth_token')->plainTextToken;

            Log::info('User registered successfully', [
                'user_id' => $user->uid,
                'email' => $user->email,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'User registered successfully',
                'user' => [
                    'id' => $user->id,
                    'uid' => $user->uid,
                    'email' => $user->email,
                    'display_name' => $user->display_name,
                    'photo_url' => $user->photo_url,
                    'auth_provider' => $user->auth_provider,
                    'email_verified' => $user->email_verified,
                ],
                'token' => $token,
            ], 201);
        } catch (\Exception $e) {
            Log::error('Registration error', [
                'error' => $e->getMessage(),
            ]);

            return response()->json([
                'success' => false,
                'error' => 'Registration failed',
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Authenticate user with email and password
     * Matches Flutter: user_service.dart -> authenticateUser()
     */
    public function login(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'email' => 'required|email',
                'password' => 'required|string',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'error' => 'Validation failed',
                    'errors' => $validator->errors(),
                ], 422);
            }

            $validated = $validator->validated();

            // Find user
            $user = User::where('email', $validated['email'])->first();

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'error' => 'Authentication failed',
                    'message' => 'User not found',
                ], 404);
            }

            // Verify password for local accounts
            if ($user->auth_provider === 'local' && $user->password_hash) {
                if (!Hash::check($validated['password'], $user->password_hash)) {
                    return response()->json([
                        'success' => false,
                        'error' => 'Authentication failed',
                        'message' => 'Invalid password',
                    ], 401);
                }
            } else {
                return response()->json([
                    'success' => false,
                    'error' => 'Authentication failed',
                    'message' => 'Wrong authentication provider',
                ], 401);
            }

            // Update last login
            $user->update(['last_login_at' => now()]);

            // Create token
            $token = $user->createToken('auth_token')->plainTextToken;

            Log::info('User logged in successfully', [
                'user_id' => $user->uid,
                'email' => $user->email,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Login successful',
                'user' => [
                    'id' => $user->id,
                    'uid' => $user->uid,
                    'email' => $user->email,
                    'display_name' => $user->display_name,
                    'photo_url' => $user->photo_url,
                    'auth_provider' => $user->auth_provider,
                    'email_verified' => $user->email_verified,
                ],
                'token' => $token,
            ]);
        } catch (\Exception $e) {
            Log::error('Login error', [
                'error' => $e->getMessage(),
            ]);

            return response()->json([
                'success' => false,
                'error' => 'Login failed',
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Handle OAuth sign-in (Google, GitHub, etc.)
     * Matches Flutter: user_service.dart -> handleOAuthSignIn()
     */
    public function oauthSignIn(Request $request)
    {
        try {
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
                    'error' => 'Validation failed',
                    'errors' => $validator->errors(),
                ], 422);
            }

            $validated = $validator->validated();

            // Check if user exists by UID
            $user = User::where('uid', $validated['uid'])->first();

            if ($user) {
                // Update last login
                $user->update(['last_login_at' => now()]);

                Log::info('OAuth user logged in', [
                    'user_id' => $user->uid,
                    'provider' => $validated['auth_provider'],
                ]);
            } else {
                // Check if email exists with different provider
                $existingEmailUser = User::where('email', $validated['email'])->first();

                if ($existingEmailUser) {
                    // Link OAuth account to existing email account
                    $existingEmailUser->update([
                        'uid' => $validated['uid'],
                        'auth_provider' => $validated['auth_provider'],
                        'provider_id' => $validated['provider_id'],
                        'photo_url' => $validated['photo_url'],
                        'display_name' => $validated['display_name'],
                        'email_verified' => $validated['email_verified'] ?? false,
                        'last_login_at' => now(),
                    ]);

                    $user = $existingEmailUser;

                    Log::info('OAuth account linked to existing email', [
                        'user_id' => $user->uid,
                    ]);
                } else {
                    // Create new user
                    $user = User::create([
                        'uid' => $validated['uid'],
                        'email' => $validated['email'],
                        'display_name' => $validated['display_name'],
                        'photo_url' => $validated['photo_url'] ?? null,
                        'auth_provider' => $validated['auth_provider'],
                        'provider_id' => $validated['provider_id'],
                        'email_verified' => $validated['email_verified'] ?? false,
                        'is_active' => true,
                        'preferences' => json_encode([]),
                        'last_login_at' => now(),
                    ]);

                    Log::info('New OAuth user created', [
                        'user_id' => $user->uid,
                        'provider' => $validated['auth_provider'],
                    ]);
                }
            }

            // Create token
            $token = $user->createToken('auth_token')->plainTextToken;

            return response()->json([
                'success' => true,
                'message' => 'OAuth sign-in successful',
                'user' => [
                    'id' => $user->id,
                    'uid' => $user->uid,
                    'email' => $user->email,
                    'display_name' => $user->display_name,
                    'photo_url' => $user->photo_url,
                    'auth_provider' => $user->auth_provider,
                    'provider_id' => $user->provider_id,
                    'email_verified' => $user->email_verified,
                ],
                'token' => $token,
            ]);
        } catch (\Exception $e) {
            Log::error('OAuth sign-in error', [
                'error' => $e->getMessage(),
            ]);

            return response()->json([
                'success' => false,
                'error' => 'OAuth sign-in failed',
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get current user information
     * Matches Flutter: user_service.dart -> getCurrentUser()
     */
    public function getCurrentUser(Request $request)
    {
        try {
            $user = $request->user();

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'error' => 'User not authenticated',
                ], 401);
            }

            return response()->json([
                'success' => true,
                'user' => [
                    'id' => $user->id,
                    'uid' => $user->uid,
                    'email' => $user->email,
                    'display_name' => $user->display_name,
                    'photo_url' => $user->photo_url,
                    'auth_provider' => $user->auth_provider,
                    'email_verified' => $user->email_verified,
                    'preferences' => $user->preferences,
                ],
            ]);
        } catch (\Exception $e) {
            Log::error('Get current user error', [
                'error' => $e->getMessage(),
            ]);

            return response()->json([
                'success' => false,
                'error' => 'Failed to get user',
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Logout user
     */
    public function logout(Request $request)
    {
        try {
            $request->user()->currentAccessToken()->delete();

            return response()->json([
                'success' => true,
                'message' => 'Logged out successfully',
            ]);
        } catch (\Exception $e) {
            Log::error('Logout error', [
                'error' => $e->getMessage(),
            ]);

            return response()->json([
                'success' => false,
                'error' => 'Logout failed',
                'message' => $e->getMessage(),
            ], 500);
        }
    }
}
