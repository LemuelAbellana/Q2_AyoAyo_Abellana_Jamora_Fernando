import 'user_dao.dart';
// import 'oauth_service.dart'; // Temporarily commented out

class UserService {
  static final UserDao _userDao = UserDao();

  // Register a new user (for email/password registration)
  static Future<bool> registerUser(
    String name,
    String email,
    String password,
  ) async {
    try {
      // Check if user already exists
      final existingUser = await _userDao.getUserByEmail(email);
      if (existingUser != null) {
        return false; // User already exists
      }

      // Generate Firebase-compatible UID for local users
      final uid =
          'local_${DateTime.now().millisecondsSinceEpoch}_${email.hashCode}';

      final userData = {
        'uid': uid,
        'email': email.toLowerCase(),
        'display_name': name.trim(),
        'auth_provider': 'email',
        'email_verified': 0,
        'is_active': 1,
        'preferences': '{}',
      };

      final result = await _userDao.insertUser(userData);
      return result > 0;
    } catch (e) {
      print('Error registering user: $e');
      return false;
    }
  }

  // Handle OAuth sign-in (temporarily disabled)
  static Future<Map<String, dynamic>?> handleOAuthSignIn(
    String provider,
  ) async {
    // OAuth temporarily disabled for basic app display
    print('OAuth sign-in temporarily disabled');
    return null;
  }

  // Authenticate a user (for email/password login)
  static Future<Map<String, dynamic>?> authenticateUser(
    String email,
    String password,
  ) async {
    try {
      final user = await _userDao.getUserByEmail(email);
      if (user != null && user['auth_provider'] == 'email') {
        // In a real app, you'd verify the password hash here
        // For now, we'll assume successful authentication
        await _userDao.updateLastLogin(user['id']);
        return user;
      }
      return null;
    } catch (e) {
      print('Authentication error: $e');
      return null;
    }
  }

  // Get current user (temporarily simplified)
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    // OAuth temporarily disabled for basic app display
    print('getCurrentUser temporarily disabled');
    return null;
  }

  // Check if user exists
  static Future<bool> userExists(String email) async {
    final user = await _userDao.getUserByEmail(email);
    return user != null;
  }

  // Get user by email
  static Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    return await _userDao.getUserByEmail(email);
  }

  // Get all users (for debugging purposes)
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    return await _userDao.getAllActiveUsers();
  }
}
