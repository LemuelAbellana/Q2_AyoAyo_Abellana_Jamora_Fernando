import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ayoayo/config/api_config.dart';

/// API Service for backend communication
/// Handles all HTTP requests to Laravel backend with proper error handling,
/// authentication, and retry logic
class ApiService {
  static String? _token;
  static const int _timeout = 30; // seconds
  static const int _maxRetries = 3;

  /// Set authentication token for API requests
  static void setToken(String token) {
    _token = token;
    print('🔑 API token set');
  }

  /// Clear authentication token
  static void clearToken() {
    _token = null;
    print('🔑 API token cleared');
  }

  /// Get current token
  static String? get token => _token;

  /// Check if user is authenticated
  static bool get isAuthenticated => _token != null;

  /// Get headers for API requests
  static Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  /// Handle API response and extract data
  static dynamic _handleResponse(http.Response response) {
    print('📡 Response Status: ${response.statusCode}');
    final bodyPreview = response.body.length > 200
        ? '${response.body.substring(0, 200)}...'
        : response.body;
    print('📡 Response Body: $bodyPreview');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        print('⚠️ Failed to parse JSON: $e');
        return {'success': true, 'data': response.body};
      }
    } else if (response.statusCode == 400) {
      final error = _extractError(response.body);
      throw ApiException('Bad Request: $error. The server cannot process the request because it is malformed.', 400);
    } else if (response.statusCode == 401) {
      clearToken();
      throw ApiException('Unauthorized. Please log in again.', 401);
    } else if (response.statusCode == 404) {
      throw ApiException('Resource not found. The backend endpoint may not exist.', 404);
    } else if (response.statusCode >= 500) {
      throw ApiException('Server error. Please try again later.', response.statusCode);
    } else {
      final error = _extractError(response.body);
      throw ApiException(error, response.statusCode);
    }
  }

  /// Extract error message from response
  static String _extractError(String body) {
    try {
      final json = jsonDecode(body);
      return json['message'] ?? json['error'] ?? 'Request failed';
    } catch (e) {
      return 'Request failed';
    }
  }

  /// Make HTTP request with retry logic
  static Future<dynamic> _makeRequest(
    Future<http.Response> Function() requestFn, {
    int retries = 0,
  }) async {
    try {
      final response = await requestFn().timeout(
        Duration(seconds: _timeout),
        onTimeout: () => throw ApiException('Request timeout', 408),
      );
      return _handleResponse(response);
    } catch (e) {
      if (retries < _maxRetries && e is! ApiException) {
        print('🔄 Retry attempt ${retries + 1}/$_maxRetries');
        await Future.delayed(Duration(seconds: 1 + retries));
        return _makeRequest(requestFn, retries: retries + 1);
      }
      rethrow;
    }
  }

  // ============================================================================
  // Authentication Endpoints
  // ============================================================================

  /// Register new user
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    print('📝 Registering user: $email');

    final response = await _makeRequest(() => http.post(
          Uri.parse('${ApiConfig.backendUrl}/auth/register'),
          headers: _getHeaders(includeAuth: false),
          body: jsonEncode({
            'name': name,
            'email': email,
            'password': password,
          }),
        ));

    if (response['token'] != null) {
      setToken(response['token']);
    }

    return response;
  }

  /// Login with email and password
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    print('🔐 Logging in: $email');

    final response = await _makeRequest(() => http.post(
          Uri.parse('${ApiConfig.backendUrl}/auth/login'),
          headers: _getHeaders(includeAuth: false),
          body: jsonEncode({
            'email': email,
            'password': password,
          }),
        ));

    if (response['token'] != null) {
      setToken(response['token']);
    }

    return response;
  }

  /// OAuth sign-in (Google, GitHub, etc.)
  static Future<Map<String, dynamic>> oauthSignIn({
    required String uid,
    required String email,
    required String displayName,
    String? photoUrl,
    required String authProvider,
    required String providerId,
    bool emailVerified = false,
  }) async {
    print('🔐 OAuth sign-in: $authProvider - $email');

    final response = await _makeRequest(() => http.post(
          Uri.parse('${ApiConfig.backendUrl}/auth/oauth-signin'),
          headers: _getHeaders(includeAuth: false),
          body: jsonEncode({
            'uid': uid,
            'email': email,
            'display_name': displayName,
            'photo_url': photoUrl,
            'auth_provider': authProvider,
            'provider_id': providerId,
            'email_verified': emailVerified,
          }),
        ));

    if (response['token'] != null) {
      setToken(response['token']);
    }

    return response;
  }

  /// Get current user information
  static Future<Map<String, dynamic>> getCurrentUser() async {
    print('👤 Getting current user');

    final response = await _makeRequest(() => http.get(
          Uri.parse('${ApiConfig.backendUrl}/auth/user'),
          headers: _getHeaders(),
        ));

    return response;
  }

  /// Logout user
  static Future<void> logout() async {
    print('👋 Logging out');

    try {
      await _makeRequest(() => http.post(
            Uri.parse('${ApiConfig.backendUrl}/auth/logout'),
            headers: _getHeaders(),
          ));
    } finally {
      clearToken();
    }
  }

  // ============================================================================
  // Device Recognition Endpoints
  // ============================================================================

  /// Save recognized device to backend
  static Future<Map<String, dynamic>> saveRecognizedDevice({
    required String userId,
    required String deviceModel,
    required String manufacturer,
    int? yearOfRelease,
    required String operatingSystem,
    required double confidence,
    required String analysisDetails,
    List<String> imageUrls = const [],
  }) async {
    print('💾 Saving device: $manufacturer $deviceModel');

    final response = await _makeRequest(() => http.post(
          Uri.parse('${ApiConfig.backendUrl}/device-recognition/save'),
          headers: _getHeaders(),
          body: jsonEncode({
            'userId': userId,
            'deviceModel': deviceModel,
            'manufacturer': manufacturer,
            'yearOfRelease': yearOfRelease,
            'operatingSystem': operatingSystem,
            'confidence': confidence,
            'analysisDetails': analysisDetails,
            'imageUrls': imageUrls,
          }),
        ));

    return response;
  }

  /// Get device recognition history
  static Future<List<dynamic>> getRecognitionHistory({
    required String userId,
    int limit = 10,
  }) async {
    print('📜 Getting recognition history for: $userId');

    final response = await _makeRequest(() => http.get(
          Uri.parse(
            '${ApiConfig.backendUrl}/device-recognition/history?userId=$userId&limit=$limit',
          ),
          headers: _getHeaders(),
        ));

    return response['data'] ?? [];
  }

  // ============================================================================
  // Device Passport Endpoints
  // ============================================================================

  /// Get all device passports for a user
  static Future<List<dynamic>> getDevicePassports(String userId) async {
    print('📋 Getting device passports for: $userId');

    final response = await _makeRequest(() => http.get(
          Uri.parse('${ApiConfig.backendUrl}/device-passports?userId=$userId'),
          headers: _getHeaders(),
        ));

    return response['data'] ?? [];
  }

  /// Get single device passport by ID
  static Future<Map<String, dynamic>> getDevicePassport(String passportUuid) async {
    print('📄 Getting device passport: $passportUuid');

    final response = await _makeRequest(() => http.get(
          Uri.parse('${ApiConfig.backendUrl}/device-passports/$passportUuid'),
          headers: _getHeaders(),
        ));

    return response['data'] ?? {};
  }

  /// Delete device passport
  static Future<void> deleteDevicePassport(String passportUuid) async {
    print('🗑️ Deleting device passport: $passportUuid');

    await _makeRequest(() => http.delete(
          Uri.parse('${ApiConfig.backendUrl}/device-passports/$passportUuid'),
          headers: _getHeaders(),
        ));
  }

  // ============================================================================
  // Health Check
  // ============================================================================

  /// Check if backend API is reachable
  static Future<bool> healthCheck() async {
    try {
      print('🏥 Checking backend health');

      final response = await http
          .get(Uri.parse('${ApiConfig.backendUrl}/health'))
          .timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Backend is healthy: ${data['message']}');
        return true;
      }

      print('⚠️ Backend returned: ${response.statusCode}');
      return false;
    } catch (e) {
      print('❌ Backend health check failed: $e');
      return false;
    }
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}
