import 'package:flutter/material.dart';
import '/services/user_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers for text fields for better state management
  final _emailController = TextEditingController(text: 'user@ayoayo.com');
  final _passwordController = TextEditingController(text: 'password123');

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_validateLoginForm()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Simulate login process
      await Future.delayed(const Duration(seconds: 2));

      // Check user credentials using UserService
      final user = UserService.authenticateUser(
        _emailController.text,
        _passwordController.text,
      );

      if (user != null) {
        // Successful login
        if (mounted) {
          // Navigate using named routes
          Navigator.pushReplacementNamed(context, '/main');
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = UserService.userExists(_emailController.text)
                ? 'Invalid password. Please try again.'
                : 'No account found with this email. Please register first.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Login failed. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _validateLoginForm() {
    if (_emailController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email';
      });
      return false;
    }

    if (_passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your password';
      });
      return false;
    }

    if (!RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(_emailController.text)) {
      setState(() {
        _errorMessage = 'Please enter a valid email address';
      });
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo and Title Section
                Column(
                  children: [
                    // Add the Ayo-ayo.png logo
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: Image.asset(
                        'assets/images/Ayo-ayo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.eco,
                            size: 60,
                            color: Colors.blue,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Ayo',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: 'Ayo',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Welcome Back",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                // Error Message
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade700),
                      textAlign: TextAlign.center,
                    ),
                  ),

                if (_errorMessage != null) const SizedBox(height: 16),

                // Login Form Fields
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                    hintText: 'user@ayoayo.com',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                    hintText: 'password123',
                  ),
                  obscureText: true,
                ),

                const SizedBox(height: 24),

                // Login Button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Login'),
                  ),
                ),

                const SizedBox(height: 16),

                // Demo Notice
                const Text(
                  "For demo purposes, you can use the credentials above or register a new account.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),

                const SizedBox(height: 24),

                // Register Navigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text(
                        "Register here",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
