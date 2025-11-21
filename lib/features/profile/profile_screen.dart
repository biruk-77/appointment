// File: lib/features/profile/profile_screen.dart

import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import Localization
import '../../app_localizations.dart';

// Import Providers & Utils
import '../../core/providers/auth_provider.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/utils/app_logger.dart';
import '../../core/models/auth/user_model.dart';

// Import Screens
import '../auth/register_screen.dart'; // Added for navigation
import '../payment/payment_history_screen.dart';
import 'edit_profile_screen.dart';

// Import the Animation Engine
import '../../core/animations/ethiopian_background_animations.dart'
    as EthiopianAnimations;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Refresh profile data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.refreshProfile();
    });

    // Setup Entrance Animations
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..forward();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
          ),
        );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    AppLogger.auth('Logging out...');
    await authProvider.logout();
  }

  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final colors = themeProvider.colorScheme;
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: colors.surface, // Fallback
      body: Stack(
        children: [
          // 1. THE REVOLUTIONARY BACKGROUND
          Positioned.fill(
            child: EthiopianAnimations.CalmBackground(
              color1: themeProvider.accentColors['ethiopianGreen']!,
              color2: themeProvider.accentColors['ethiopianYellow']!,
              color3: themeProvider.accentColors['ethiopianRed']!,
              isDarkMode: themeProvider.isDarkMode,
            ),
          ),

          // 2. Gradient Overlay for readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colors.surface.withOpacity(0.3),
                    colors.surface.withOpacity(0.8),
                    colors.surface.withOpacity(0.95),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),

          // 3. Main Content - Scrollable
          SafeArea(
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),

                    // A. Header Section (Avatar & Name)
                    // Now Clickable if Guest
                    SliverToBoxAdapter(
                      child: GestureDetector(
                        onTap: user == null ? _navigateToLogin : null,
                        child: _buildHeroProfile(
                          user,
                          themeProvider,
                          colors,
                          l10n,
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 30)),

                    // B. Account Settings Island
                    SliverToBoxAdapter(
                      child: _buildGlassSection(
                        title: l10n.accountActions,
                        colors: colors,
                        children: [
                          _buildGlassTile(
                            icon: Icons.edit_outlined,
                            title: l10n.updateProfile,
                            color: themeProvider.accentColors['medical']!,
                            // If Guest, go to Login, else Edit Profile
                            onTap: () {
                              if (user == null) {
                                _navigateToLogin();
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const EditProfileScreen(),
                                  ),
                                );
                              }
                            },
                            colors: colors,
                          ),
                          _buildGlassTile(
                            icon: Icons.receipt_long_rounded,
                            title: l10n.payments,
                            color: themeProvider.accentColors['medical']!,
                            onTap: () {
                              if (user == null) {
                                _navigateToLogin();
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const PaymentHistoryScreen(),
                                  ),
                                );
                              }
                            },
                            colors: colors,
                          ),
                        ],
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 20)),

                    // C. Preferences Island
                    SliverToBoxAdapter(
                      child: _buildGlassSection(
                        title: l10n.preferences,
                        colors: colors,
                        children: [
                          _buildGlassTile(
                            icon: themeProvider.isDarkMode
                                ? Icons.light_mode_rounded
                                : Icons.dark_mode_rounded,
                            title: l10n.theme,
                            subtitle: themeProvider.isDarkMode
                                ? 'Dark Mode'
                                : 'Light Mode',
                            color:
                                themeProvider.accentColors['ethiopianYellow']!,
                            onTap: () => themeProvider.toggleTheme(),
                            colors: colors,
                            isToggle: true,
                          ),
                          _buildGlassTile(
                            icon: Icons.translate_rounded,
                            title: l10n.language,
                            color:
                                themeProvider.accentColors['ethiopianGreen']!,
                            onTap: () => _showLanguageDialog(l10n),
                            colors: colors,
                          ),
                        ],
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 20)),

                    // D. Auth Action Zone (Sign In or Sign Out)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildAuthActionButton(
                          l10n,
                          authProvider,
                          themeProvider,
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 40)),

                    // E. Footer
                    SliverToBoxAdapter(
                      child: Center(
                        child: Text(
                          'Absiniya Health v1.0.0',
                          style: TextStyle(
                            color: colors.onSurface.withOpacity(0.3),
                            fontSize: 12,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildHeroProfile(
    UserModel? user,
    ThemeProvider themeProvider,
    ColorScheme colors,
    AppLocalizations l10n,
  ) {
    return Column(
      children: [
        // Animated Avatar Container
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: themeProvider.accentColors['ethiopianGreen']!
                    .withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
            gradient: LinearGradient(
              colors: [
                themeProvider.accentColors['ethiopianGreen']!,
                themeProvider.accentColors['ethiopianYellow']!,
                themeProvider.accentColors['ethiopianRed']!,
              ],
              transform: const GradientRotation(math.pi / 4),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: colors.surface,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: colors.surfaceVariant,
              backgroundImage: user?.profileImageUrl != null
                  ? NetworkImage(user!.profileImageUrl!)
                  : null,
              child: user?.profileImageUrl == null
                  ? (
                        Image.asset(
                            'assets/logo.png',
                            fit: BoxFit.contain,
                            width: 60,
                            height: 60,
                          )
)
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              user?.displayName ?? l10n.guestUser,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: colors.onSurface,
                letterSpacing: 0.5,
              ),
            ),
            // Add a small arrow indicator if Guest
            if (user == null)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: colors.primary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.primary.withOpacity(0.2)),
          ),
          child: Text(
            user?.email ?? l10n.signInToAccessFeatures,
            style: TextStyle(
              fontSize: 13,
              color: colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGlassSection({
    required String title,
    required List<Widget> children,
    required ColorScheme colors,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 10),
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: colors.onSurface.withOpacity(0.5),
                letterSpacing: 1.5,
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: colors.surface.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: colors.onSurface.withOpacity(0.08)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(children: children),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    required ColorScheme colors,
    String? subtitle,
    bool isToggle = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: colors.onSurface.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Handles both Sign In (Green) and Sign Out (Red)
  Widget _buildAuthActionButton(
    AppLocalizations l10n,
    AuthProvider authProvider,
    ThemeProvider themeProvider,
  ) {
    final user = authProvider.user;
    final isGuest = user == null;

    // Green for Sign In, Red for Sign Out
    final mainColor = isGuest
        ? themeProvider.accentColors['ethiopianGreen']!
        : themeProvider.accentColors['error']!;

    final text = isGuest ? 'Sign In / Register' : l10n.signOut;
    final icon = isGuest ? Icons.login_rounded : Icons.logout_rounded;

    return GestureDetector(
      onTap: () {
        if (isGuest) {
          _navigateToLogin();
        } else {
          _showSignOutDialog(l10n, authProvider, themeProvider);
        }
      },
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: mainColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: mainColor.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: mainColor, size: 22),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                color: mainColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UTILS (Dialogs) ---

  void _showLanguageDialog(AppLocalizations l10n) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final colors = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: colors.onSurface.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                l10n.chooseLanguage,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildLangOption('🇺🇸', 'English', 'en', languageProvider),
              _buildLangOption('🇪🇹', 'አማርኛ', 'am', languageProvider),
              _buildLangOption('🇸🇴', 'Soomaali', 'so', languageProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLangOption(
    String flag,
    String name,
    String code,
    LanguageProvider provider,
  ) {
    final isSelected = provider.languageCode == code;
    final colors = Theme.of(context).colorScheme;

    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded, color: colors.primary)
          : null,
      onTap: () {
        provider.setLanguage(code);
        Navigator.pop(context);
      },
    );
  }

  void _showSignOutDialog(
    AppLocalizations l10n,
    AuthProvider auth,
    ThemeProvider theme,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.signOut),
        content: Text(l10n.signOutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: Text(
              l10n.signOut,
              style: TextStyle(color: theme.accentColors['error']),
            ),
          ),
        ],
      ),
    );
  }
}
