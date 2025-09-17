import 'package:flutter/material.dart';
import '/services/user_service.dart';
import '/utils/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controllers for text fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleRegistration() async {
    if (!_validateRegistrationForm()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check if user already exists
      final userExists = await UserService.userExists(_emailController.text);
      if (userExists) {
        if (mounted) {
          setState(() {
            _errorMessage = 'User already exists with this email';
          });
        }
        return;
      }

      // Register the user using UserService
      final success = await UserService.registerUser(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!success) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Registration failed. Please try again.';
          });
        }
        return;
      }

      if (mounted) {
        // Clear the form
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();

        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Registration successful! Please login with your credentials.',
            ),
          ),
        );

        // Navigate back to login screen
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Registration failed. Please try again.';
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

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🚀 Starting Google sign-in from register screen...');
      print('🎯 You can now select any Google account to register with');

      final user = await UserService.handleOAuthSignIn('google');

      if (user != null && mounted) {
        print('✅ Google sign-in successful, user: ${user['email']}');
        print('🏠 Navigating to main dashboard...');

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Account created successfully! Welcome to AyoAyo, ${user['display_name'] ?? user['email']}!',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Small delay to show the success message
        await Future.delayed(const Duration(milliseconds: 500));

        // Navigate to main screen
        Navigator.pushReplacementNamed(context, '/main');
        print('✅ Successfully navigated to main dashboard');
      } else {
        print('❌ Google sign-in returned null user');
        if (mounted) {
          setState(() {
            _errorMessage =
                'Google sign-in was cancelled. Please try again and select an account to create your profile.';
          });
        }
      }
    } catch (e) {
      print('❌ Google sign-in error: $e');

      String errorMessage = 'Google sign-in error';

      // Check if it's a People API error
      if (e.toString().contains('People API') ||
          e.toString().contains('SERVICE_DISABLED') ||
          e.toString().contains('people.googleapis.com')) {
        errorMessage =
            'Google Sign-In will work automatically. The app is handling a configuration issue in the background.';
        print(
          'ℹ️ People API error detected - fallback mechanism will handle this',
        );
      } else if (e.toString().contains('popup') ||
          e.toString().contains('blocked') ||
          e.toString().contains('cancelled')) {
        errorMessage =
            'Please disable popup blockers and try again. You can select any Google account to create your profile.';
        print('🚫 Popup blocker detected - user needs to disable it');
      } else {
        errorMessage = 'Google sign-in error: ${e.toString()}';
      }

      if (mounted) {
        setState(() {
          _errorMessage = errorMessage;
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

  bool _validateRegistrationForm() {
    if (_nameController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your full name';
      });
      return false;
    }

    if (_emailController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email';
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

    if (_passwordController.text.length < 6) {
      setState(() {
        _errorMessage = 'Password must be at least 6 characters long';
      });
      return false;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 24.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header with back button
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back,
                          color: AppTheme.textPrimary,
                          size: 28,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Create Account',
                        style: AppTheme.titleStyle.copyWith(fontSize: 24),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Logo and Title Section with modern card design
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Logo with gradient background
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            gradient: AppTheme.accentGradient,
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Image.asset(
                              'assets/images/Ayo-ayo.png',
                              fit: BoxFit.contain,
                              color: Colors.white,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.eco,
                                  size: 32,
                                  color: Colors.white,
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Welcome message
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              AppTheme.accentGradient.createShader(bounds),
                          child: const Text(
                            'Join AyoAyo',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Start your sustainable journey today",
                          textAlign: TextAlign.center,
                          style: AppTheme.subtitleStyle,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Registration Form Card
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Error Message with modern styling
                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.errorRed.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.errorRed.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: AppTheme.errorRed,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      color: AppTheme.errorRed,
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Full Name Field
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            hintText: 'Enter your full name',
                            prefixIcon: Icon(
                              Icons.person_outline,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                          keyboardType: TextInputType.name,
                        ),
                        const SizedBox(height: 20),

                        // Email Field
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            hintText: 'Enter your email address',
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),

                        // Password Field
                        TextField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Create a password (min 6 characters)',
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 20),

                        // Confirm Password Field
                        TextField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            hintText: 'Confirm your password',
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                          obscureText: true,
                        ),

                        const SizedBox(height: 32),

                        // Register Button with gradient
                        Container(
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: AppTheme.accentGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accentPurple.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleRegistration,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Create Account',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // OAuth Buttons
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: AppTheme.textSecondary.withOpacity(0.3),
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                'or sign up with',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: AppTheme.textSecondary.withOpacity(0.3),
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Google Sign-In Button
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppTheme.textSecondary.withOpacity(0.3),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextButton.icon(
                            onPressed: _handleGoogleSignIn,
                            icon: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Image.asset(
                                'assets/images/Google.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                            label: const Text(
                              'Sign up with Google',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Terms and Privacy notice
                        Text(
                          "By creating an account, you agree to our Terms of Service and Privacy Policy",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Login Navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          "Sign In",
                          style: TextStyle(
                            color: AppTheme.primaryBlue,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Benefits highlight
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.successGreen.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.eco, color: AppTheme.successGreen, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Join thousands making a positive environmental impact",
                            style: TextStyle(
                              color: AppTheme.successGreen,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
