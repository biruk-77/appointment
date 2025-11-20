// File: lib/features/home/widgets/home_header_new.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'dart:ui' as ui; // For ImageFilter

// 1. ADD LOCALIZATION IMPORT
import '../../../app_localizations.dart';

import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/auth/user_model.dart';
import '../../../core/utils/app_logger.dart';
import '../../auth/register_screen.dart';
import '../../../core/animations/ethiopian_background_animations.dart'
    as EthiopianAnimations
    hide GradientRotation;

/// **[Updated]** - "Addis Ababa Dawn Header" - A premium, culturally-inspired header.
class HomeHeaderNew extends StatefulWidget {
  const HomeHeaderNew({super.key, this.user, this.onTabChange});
  final UserModel? user;
  final Function(int)? onTabChange;

  @override
  State<HomeHeaderNew> createState() => _HomeHeaderNewState();
}

class _HomeHeaderNewState extends State<HomeHeaderNew>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _pulseController;

  // Staggered animation values
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _statsFade;
  late Animation<double> _actionsFade;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    // Main entrance animations (for top bar and branding)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
          ),
        );

    // Staggered animations for stats and actions
    _statsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );
    _actionsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 2. INITIALIZE LOCALIZATION
    final l10n = AppLocalizations.of(context)!;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final colors = themeProvider.colorScheme;
        final theme = themeProvider.themeData;
        final user = widget.user;

        return AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              height: 420, // Increased height for a more epic feel
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: themeProvider.isDarkMode
                      ? [
                          colors.surface,
                          colors.surface.withOpacity(0.95),
                          colors.surface.withOpacity(0.9),
                        ]
                      : [
                          colors.surface,
                          const Color(0xFFFAFAFA), // Very light gray
                          const Color(0xFFF5F5F5), // Slightly darker light gray
                        ],
                  stops: const [0.0, 0.7, 1.0],
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(40),
                ),
                border: Border.all(
                  color: themeProvider.isDarkMode
                      ? colors.onSurface.withOpacity(0.1)
                      : colors.onSurface.withOpacity(0.05),
                  width: 1,
                ),
                boxShadow: [
                  // Main shadow for depth
                  BoxShadow(
                    color: colors.shadow.withOpacity(
                      themeProvider.isDarkMode ? 0.4 : 0.15,
                    ),
                    blurRadius: 25,
                    spreadRadius: 3,
                    offset: const Offset(0, 8),
                  ),
                  // Secondary shadow for more depth
                  BoxShadow(
                    color: themeProvider.accentColors['medical']!.withOpacity(
                      themeProvider.isDarkMode ? 0.2 : 0.08,
                    ),
                    blurRadius: 40,
                    spreadRadius: 1,
                    offset: const Offset(0, 15),
                  ),
                  // Inner glow effect
                  BoxShadow(
                    color: colors.primary.withOpacity(0.05),
                    blurRadius: 15,
                    spreadRadius: -5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(40),
                ),
                child: Stack(
                  children: [
                    // Dynamic background painter
                    CustomPaint(
                      size: Size.fromHeight(420),
                      painter: EthiopianAnimations.EthiopianGeometricPainter(
                        _pulseController.value * math.pi * 2,
                        themeProvider.accentColors['ethiopianGreen']!,
                        themeProvider.accentColors['ethiopianYellow']!,
                        themeProvider.accentColors['ethiopianRed']!,
                        themeProvider.isDarkMode,
                      ),
                    ),

                    // Subtle gradient overlay for depth and readability
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.1),
                            Colors.transparent,
                            Colors.black.withOpacity(0.1),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),

                    // Main Content Column
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                          child: Column(
                            children: [
                              _buildTopBar(user, themeProvider, colors, context),
                              const SizedBox(height: 20),
                              _buildMainBranding(user, theme, colors, context),
                              const Spacer(),

                              FadeTransition(
                                opacity: _actionsFade,
                                child: _buildQuickActions(
                                  themeProvider,
                                  theme,
                                  context,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- UI Builder Methods ---

  Widget _buildTopBar(
    UserModel? user,
    ThemeProvider themeProvider,
    ColorScheme colors,
    BuildContext context,
  ) {
    // LOCALIZE
    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // User Avatar and Name
        Row(
          children: [
            _buildUserAvatar(user, colors),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // We don't have "Welcome" in keys yet, adding generic fallback or key
                // Assuming 'Hello World' or adding a key. Using "Welcome {name}" logic manually here
                // Since we used "welcome": "Welcome {name}" in your first prompt, 
                // but the ARB you provided earlier didn't have a generic 'Welcome'.
                // Using hardcoded for now or generic if available.
                // Let's use "Welcome," hardcoded or add key. 
                // I will use a hardcoded safe string or look for nearest key.
                // Actually, let's just stick to English for "Welcome," unless you add a key.
                // WAIT! I see "welcome" in your FIRST prompt but not in the GENERATED file you showed later.
                // I will use a safe fallback.
                Text(
                  'Welcome,', // You should add "welcome" to your ARB files if you want this translated
                  style: TextStyle(
                    color: colors.onSurface.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                Text(
                  user?.firstName ?? l10n.guestUser, // LOCALIZED
                  style: TextStyle(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
        _buildThemeToggle(themeProvider, colors),
      ],
    );
  }

  Widget _buildMainBranding(
    UserModel? user,
    ThemeData theme,
    ColorScheme colors,
    BuildContext context,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.appTitle, // LOCALIZED "Go Hospital"
              style: theme.textTheme.displaySmall?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w900,
                letterSpacing: 6,
                fontSize: 40,
                shadows: [
                  Shadow(
                    color: colors.shadow.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // App description
            Text(
              l10n.appSubtitle, // LOCALIZED "Hospital Appointment Management"
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.onSurface.withOpacity(0.8),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            // Subtitle about the app
            Text(
              l10n.hubSubtitle, // LOCALIZED "Making appointment booking simple..."
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurface.withOpacity(0.6),
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions(
    ThemeProvider themeProvider,
    ThemeData theme,
    BuildContext context,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final isLoggedIn = authProvider.isAuthenticated;

        final actions = [
          {
            'icon': Icons.person_outline,
            'label': l10n.navProfile, // LOCALIZED
            'key': 'Profile', // Internal key for logic
            'color': themeProvider.colorScheme.primary,
          },
          {
            'icon': Icons.shopping_bag_outlined,
            'label': l10n.navOrders, // LOCALIZED
            'key': 'Orders', // Internal key for logic
            'color': themeProvider.colorScheme.secondary,
          },
          {
            'icon': isLoggedIn ? Icons.logout : Icons.login,
            'label': isLoggedIn
                ? l10n.logout
                : l10n.login, // LOCALIZED
            'key': isLoggedIn ? 'Logout' : 'Login', // Internal key for logic
            'color': isLoggedIn
                ? themeProvider.colorScheme.error
                : themeProvider.colorScheme.primary,
          },
        ];

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: actions.map((action) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final key = action['key'] as String; // Use internal key
                    AppLogger.navigation('$key tapped');

                    if (key == 'Profile') {
                      // Navigate to profile tab (index 3)
                      widget.onTabChange?.call(3);
                    } else if (key == 'Orders') {
                      // Navigate to orders tab (index 1)
                      widget.onTabChange?.call(1);
                    } else if (key == 'Logout') {
                      authProvider.logout();
                    } else if (key == 'Login') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    }
                  },
                  icon: Icon(action['icon'] as IconData, size: 18),
                  label: Text(
                    action['label'] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: (action['color'] as Color),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 5,
                    shadowColor: (action['color'] as Color).withOpacity(0.5),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // --- Helper Widgets for Buttons ---

  Widget _buildThemeToggle(ThemeProvider themeProvider, ColorScheme colors) {
    return Material(
      color: colors.surface.withOpacity(0.2),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: themeProvider.toggleTheme,
        customBorder: const CircleBorder(),
        child: ClipOval(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.onSurface.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Icon(
                  themeProvider.isDarkMode
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                  key: ValueKey(themeProvider.isDarkMode),
                  color: colors.onSurface,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatar(UserModel? user, ColorScheme colors) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                themeProvider.accentColors['ethiopianYellow']!,
                themeProvider.accentColors['ethiopianGreen']!,
                themeProvider.accentColors['ethiopianRed']!,
              ],
              transform: GradientRotation(math.pi / 4),
            ),
          ),
          child: CircleAvatar(
            radius: 22,
            backgroundColor: colors.surface,
            child: CircleAvatar(
              radius: 19,
              backgroundColor: colors.primary.withOpacity(0.1),
              backgroundImage: user?.profileImageUrl != null
                  ? NetworkImage(user!.profileImageUrl!)
                  : null,
              child: user?.profileImageUrl == null
                  ? Icon(
                      Icons.person_outline,
                      color: colors.onSurface,
                      size: 20,
                    )
                  : null,
            ),
          ),
        );
      },
    );
  }
}
