class UserService {
  // Simple in-memory user storage for demo purposes
  static final Map<String, Map<String, String>> _users = {
    'user@ayoayo.com': {
      'name': 'Demo User',
      'email': 'user@ayoayo.com',
      'password': 'password123',
    },
  };

  // Register a new user
  static bool registerUser(String name, String email, String password) {
    final emailKey = email.toLowerCase();

    if (_users.containsKey(emailKey)) {
      return false; // User already exists
    }

    _users[emailKey] = {
      'name': name.trim(),
      'email': email.trim(),
      'password': password, // In real app, hash this!
    };

    return true;
  }

  // Authenticate a user
  static Map<String, String>? authenticateUser(String email, String password) {
    final emailKey = email.toLowerCase();
    final user = _users[emailKey];

    if (user != null && user['password'] == password) {
      return user;
    }

    return null;
  }

  // Check if user exists
  static bool userExists(String email) {
    return _users.containsKey(email.toLowerCase());
  }

  // Get all users (for debugging purposes)
  static Map<String, Map<String, String>> getAllUsers() {
    return Map.unmodifiable(_users);
  }
}
