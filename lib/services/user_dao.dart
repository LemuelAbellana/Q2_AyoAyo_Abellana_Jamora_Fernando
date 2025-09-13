// Temporary in-memory user storage for basic app display
class UserDao {
  // Simple in-memory storage for now
  static final Map<String, Map<String, dynamic>> _users = {};

  // Insert user
  Future<int> insertUser(Map<String, dynamic> userData) async {
    final email = userData['email'] as String;
    _users[email] = Map<String, dynamic>.from(userData);
    _users[email]!['id'] = _users.length; // Simple ID generation
    return _users[email]!['id'];
  }

  // Get user by Firebase UID
  Future<Map<String, dynamic>?> getUserByUid(String uid) async {
    try {
      return _users.values.firstWhere((user) => user['uid'] == uid);
    } catch (e) {
      return null;
    }
  }

  // Get user by email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    return _users[email.toLowerCase()];
  }

  // Update user
  Future<int> updateUser(int id, Map<String, dynamic> userData) async {
    try {
      final user = _users.values.firstWhere((u) => u['id'] == id);
      user.addAll(userData);
      return 1;
    } catch (e) {
      return 0;
    }
  }

  // Delete user
  Future<int> deleteUser(int id) async {
    try {
      final user = _users.values.firstWhere((u) => u['id'] == id);
      _users.remove(user['email']);
      return 1;
    } catch (e) {
      return 0;
    }
  }

  // Get all active users (for admin purposes)
  Future<List<Map<String, dynamic>>> getAllActiveUsers() async {
    return _users.values.where((user) => user['is_active'] != 0).toList();
  }

  // Update last login
  Future<void> updateLastLogin(int userId) async {
    try {
      final user = _users.values.firstWhere((u) => u['id'] == userId);
      user['last_login_at'] = DateTime.now().toIso8601String();
    } catch (e) {
      // User not found, ignore
    }
  }
}
