// File: lib/features/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import '../../core/providers/auth_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/providers/language_provider.dart';
import '../../core/utils/app_logger.dart';
import '../../core/animations/ethiopian_background_animations.dart'
    as EthiopianAnimations
    hide GradientRotation;
import '../home/home_screen.dart';

/// Modern register screen with theme support, localization, and Ethiopian animations
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  late AnimationController _animationController;
  late AnimationController _backgroundController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _backgroundController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      AppLogger.auth(
        '📝 Attempting registration for: ${_emailController.text}',
      );

      final success = await authProvider.registerWithApi(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
      );

      if (success && mounted) {
        AppLogger.auth('✅ Registration successful, navigating to home');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      } else if (mounted) {
        setState(() {
          _errorMessage = authProvider.errorMessage ?? 'Registration failed';
        });
      }
    } catch (e) {
      AppLogger.error('❌ Registration failed', error: e);
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showLanguageDialog(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Choose Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              onTap: () {
                languageProvider.setLanguage('en');
                Navigator.of(dialogContext).pop();
              },
            ),
            ListTile(
              title: const Text('አማርኛ (Amharic)'),
              onTap: () {
                languageProvider.setLanguage('am');
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.themeData;
        final colorScheme = themeProvider.colorScheme;

        return Scaffold(
          body: AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, _) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary.withOpacity(0.1),
                      colorScheme.secondary.withOpacity(0.05),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Animated background
                    CustomPaint(
                      size: Size.infinite,
                      painter: EthiopianAnimations.EthiopianGeometricPainter(
                        _backgroundController.value * math.pi * 2,
                        colorScheme.primary,
                        colorScheme.secondary,
                        colorScheme.tertiary,
                        themeProvider.isDarkMode,
                      ),
                    ),
                    // Content
                    SafeArea(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Theme and Language Buttons
                                Consumer<ThemeProvider>(
                                  builder: (context, themeNotifier, _) => Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      // Theme Toggle Button
                                      IconButton(
                                        onPressed: () {
                                          themeNotifier.toggleTheme();
                                        },
                                        icon: Icon(
                                          themeNotifier.isDarkMode
                                              ? Icons.light_mode_outlined
                                              : Icons.dark_mode_outlined,
                                          color: colorScheme.primary,
                                        ),
                                        tooltip: 'Toggle Theme',
                                      ),
                                      // Language Toggle Button
                                      IconButton(
                                        onPressed: () {
                                          _showLanguageDialog(context);
                                        },
                                        icon: Icon(
                                          Icons.language_outlined,
                                          color: colorScheme.primary,
                                        ),
                                        tooltip: 'Change Language',
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Logo Section - Glassmorphism
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: BackdropFilter(
                                    filter: ui.ImageFilter.blur(
                                      sigmaX: 10,
                                      sigmaY: 10,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: colorScheme.surface.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: colorScheme.onSurface
                                              .withOpacity(0.2),
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 20,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  colorScheme.primary,
                                                  colorScheme.secondary,
                                                ],
                                              ),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: colorScheme.primary
                                                      .withOpacity(0.3),
                                                  blurRadius: 12,
                                                  offset: const Offset(0, 6),
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.health_and_safety,
                                              color: Colors.white,
                                              size: 40,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Go Hospital',
                                            style: theme.textTheme.headlineLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: colorScheme.primary,
                                                  letterSpacing: 1,
                                                ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Healthcare Appointment System',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  color: colorScheme.onSurface
                                                      .withOpacity(0.7),
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Registration Form - Glassmorphism
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: BackdropFilter(
                                    filter: ui.ImageFilter.blur(
                                      sigmaX: 10,
                                      sigmaY: 10,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: colorScheme.surface.withOpacity(
                                          0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: colorScheme.onSurface
                                              .withOpacity(0.2),
                                          width: 1.5,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 20,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: Form(
                                        key: _formKey,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Text(
                                              'Create Account',
                                              style: theme
                                                  .textTheme
                                                  .headlineSmall
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: colorScheme.primary,
                                                  ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Join Go Hospital today',
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                    color: colorScheme.onSurface
                                                        .withOpacity(0.7),
                                                  ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 24),
                                            // Full Name Field
                                            TextFormField(
                                              controller: _nameController,
                                              keyboardType: TextInputType.name,
                                              decoration: InputDecoration(
                                                labelText: 'Full Name',
                                                prefixIcon: Icon(
                                                  Icons.person_outline,
                                                  color: colorScheme.primary,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: BorderSide(
                                                    color: colorScheme.onSurface
                                                        .withOpacity(0.3),
                                                  ),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      borderSide: BorderSide(
                                                        color: colorScheme
                                                            .onSurface
                                                            .withOpacity(0.3),
                                                      ),
                                                    ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      borderSide: BorderSide(
                                                        color:
                                                            colorScheme.primary,
                                                        width: 2,
                                                      ),
                                                    ),
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please enter your full name';
                                                }
                                                if (value.length < 3) {
                                                  return 'Name must be at least 3 characters';
                                                }
                                                return null;
                                              },
                                            ),
                                            const SizedBox(height: 16),
                                            // Email Field
                                            TextFormField(
                                              controller: _emailController,
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              decoration: InputDecoration(
                                                labelText: 'Email Address',
                                                prefixIcon: Icon(
                                                  Icons.email_outlined,
                                                  color: colorScheme.primary,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: BorderSide(
                                                    color: colorScheme.onSurface
                                                        .withOpacity(0.3),
                                                  ),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      borderSide: BorderSide(
                                                        color: colorScheme
                                                            .onSurface
                                                            .withOpacity(0.3),
                                                      ),
                                                    ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      borderSide: BorderSide(
                                                        color:
                                                            colorScheme.primary,
                                                        width: 2,
                                                      ),
                                                    ),
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please enter your email';
                                                }
                                                if (!RegExp(
                                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                                ).hasMatch(value)) {
                                                  return 'Please enter a valid email';
                                                }
                                                return null;
                                              },
                                            ),
                                            const SizedBox(height: 16),
                                            // Phone Field
                                            TextFormField(
                                              controller: _phoneController,
                                              keyboardType: TextInputType.phone,
                                              decoration: InputDecoration(
                                                labelText: 'Phone Number',
                                                prefixIcon: Icon(
                                                  Icons.phone_outlined,
                                                  color: colorScheme.primary,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: BorderSide(
                                                    color: colorScheme.onSurface
                                                        .withOpacity(0.3),
                                                  ),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      borderSide: BorderSide(
                                                        color: colorScheme
                                                            .onSurface
                                                            .withOpacity(0.3),
                                                      ),
                                                    ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      borderSide: BorderSide(
                                                        color:
                                                            colorScheme.primary,
                                                        width: 2,
                                                      ),
                                                    ),
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please enter your phone number';
                                                }
                                                if (value.length < 9) {
                                                  return 'Please enter a valid phone number';
                                                }
                                                return null;
                                              },
                                            ),
                                            const SizedBox(height: 16),
                                            // Password Field
                                            TextFormField(
                                              controller: _passwordController,
                                              obscureText: _obscurePassword,
                                              decoration: InputDecoration(
                                                labelText: 'Password',
                                                prefixIcon: Icon(
                                                  Icons.lock_outline,
                                                  color: colorScheme.primary,
                                                ),
                                                suffixIcon: IconButton(
                                                  icon: Icon(
                                                    _obscurePassword
                                                        ? Icons.visibility_off
                                                        : Icons.visibility,
                                                    color: colorScheme.primary,
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      _obscurePassword =
                                                          !_obscurePassword;
                                                    });
                                                  },
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: BorderSide(
                                                    color: colorScheme.onSurface
                                                        .withOpacity(0.3),
                                                  ),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      borderSide: BorderSide(
                                                        color: colorScheme
                                                            .onSurface
                                                            .withOpacity(0.3),
                                                      ),
                                                    ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      borderSide: BorderSide(
                                                        color:
                                                            colorScheme.primary,
                                                        width: 2,
                                                      ),
                                                    ),
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please enter a password';
                                                }
                                                if (value.length < 6) {
                                                  return 'Password must be at least 6 characters';
                                                }
                                                return null;
                                              },
                                            ),
                                            const SizedBox(height: 16),
                                            // Confirm Password Field
                                            TextFormField(
                                              controller:
                                                  _confirmPasswordController,
                                              obscureText:
                                                  _obscureConfirmPassword,
                                              decoration: InputDecoration(
                                                labelText: 'Confirm Password',
                                                prefixIcon: Icon(
                                                  Icons.lock_outline,
                                                  color: colorScheme.primary,
                                                ),
                                                suffixIcon: IconButton(
                                                  icon: Icon(
                                                    _obscureConfirmPassword
                                                        ? Icons.visibility_off
                                                        : Icons.visibility,
                                                    color: colorScheme.primary,
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      _obscureConfirmPassword =
                                                          !_obscureConfirmPassword;
                                                    });
                                                  },
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: BorderSide(
                                                    color: colorScheme.onSurface
                                                        .withOpacity(0.3),
                                                  ),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      borderSide: BorderSide(
                                                        color: colorScheme
                                                            .onSurface
                                                            .withOpacity(0.3),
                                                      ),
                                                    ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      borderSide: BorderSide(
                                                        color:
                                                            colorScheme.primary,
                                                        width: 2,
                                                      ),
                                                    ),
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please confirm your password';
                                                }
                                                return null;
                                              },
                                            ),
                                            const SizedBox(height: 24),
                                            // Error Message
                                            if (_errorMessage != null) ...[
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  12,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.red.withOpacity(
                                                    0.1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: Colors.red
                                                        .withOpacity(0.3),
                                                  ),
                                                ),
                                                child: Text(
                                                  _errorMessage!,
                                                  style: const TextStyle(
                                                    color: Colors.red,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                            ],
                                            // Register Button
                                            SizedBox(
                                              height: 56,
                                              child: ElevatedButton(
                                                onPressed: _isLoading
                                                    ? null
                                                    : _handleRegister,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      themeProvider.isDarkMode
                                                      ? const Color(0xFF2196F3)
                                                      : colorScheme.primary,
                                                  foregroundColor: Colors.white,
                                                  disabledBackgroundColor:
                                                      Colors.grey[300],
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  elevation: 4,
                                                ),
                                                child: _isLoading
                                                    ? const SizedBox(
                                                        height: 24,
                                                        width: 24,
                                                        child: CircularProgressIndicator(
                                                          strokeWidth: 2.5,
                                                          valueColor:
                                                              AlwaysStoppedAnimation(
                                                                Colors.white,
                                                              ),
                                                        ),
                                                      )
                                                    : const Text(
                                                        'Create Account',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            // Login Link
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  'Already have an account? ',
                                                  style: theme
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        color: Colors.grey[600],
                                                      ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.pushNamed(
                                                      context,
                                                      '/login',
                                                    );
                                                  },
                                                  child: Text(
                                                    'Sign In',
                                                    style: theme
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.copyWith(
                                                          color: colorScheme
                                                              .primary,
                                                          fontWeight:
                                                              FontWeight.bold,
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
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

