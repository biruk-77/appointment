// File: lib/features/profile/profile_screen.dart
// Project Path: C:\Users\biruk\Desktop\absiniya\appointment
// Auto-Header: you feel me
// ----------------------------------------------
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import the generated localization file
import '../../app_localizations.dart';

// Import your project's providers and utilities
import '../../core/providers/auth_provider.dart';
import '../../core/providers/language_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/utils/app_logger.dart';

/// A completely redesigned profile screen with a modern UI/UX featuring a
/// custom-shaped header, a frosted-glass effect, and a grid-based menu.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // --- State and Methods (unchanged logic) ---

  @override
  void initState() {
    super.initState();
    // Refresh profile data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.refreshProfile();
    });
  }

  Future<void> _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    AppLogger.auth('ðŸšª Logging out...');
    await authProvider.logout();
    AppLogger.success('âœ… Logged out successfully');
  }

  // --- Build Method ---

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final colors = themeProvider.colorScheme;
    final user = authProvider.user;

    // Menu items defined here for clarity
    final List<_MenuItem> accountItems = [
      _MenuItem(
        icon: Icons.person_outline,
        color: themeProvider.accentColors['medical']!,
        title: l10n.personalInformation,
        onTap: () => _showFeatureComingSoon(l10n, l10n.personalInformation),
      ),
      _MenuItem(
        icon: Icons.medical_information_outlined,
        color: themeProvider.accentColors['medical']!,
        title: l10n.medicalRecords,
        onTap: () => _showFeatureComingSoon(l10n, l10n.medicalRecords),
      ),
    ];

    final List<_MenuItem> preferenceItems = [
      _MenuItem(
        icon: themeProvider.isDarkMode
            ? Icons.light_mode_outlined
            : Icons.dark_mode_outlined,
        color: themeProvider.accentColors['primary']!,
        title: l10n.theme,
        onTap: () => themeProvider.toggleTheme(),
      ),
      _MenuItem(
        icon: Icons.language_outlined,
        color: themeProvider.accentColors['primary']!,
        title: l10n.language,
        onTap: () => _showLanguageDialog(l10n),
      ),
    ];

    final List<_MenuItem> supportItems = [
      _MenuItem(
        icon: Icons.help_outline,
        color: themeProvider.accentColors['info']!,
        title: l10n.helpAndFaq,
        onTap: () => _showFeatureComingSoon(l10n, l10n.helpAndFaq),
      ),
      _MenuItem(
        icon: Icons.info_outline,
        color: themeProvider.accentColors['info']!,
        title: l10n.aboutGoHospital,
        onTap: () => _showFeatureComingSoon(l10n, l10n.aboutGoHospital),
      ),
      _MenuItem(
        icon: Icons.logout,
        color: themeProvider.accentColors['error']!,
        title: l10n.signOut,
        isDestructive: true,
        onTap: () => _showSignOutDialog(l10n, authProvider, themeProvider),
      ),
    ];

    return Scaffold(
      backgroundColor: colors.surface,
      body: Stack(
        children: [
          // The main scrollable content
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 280), // Space for the header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(l10n.accountActions, colors),
                      _buildMenuItemsGrid(accountItems),
                      const SizedBox(height: 24),
                      _buildSectionTitle(l10n.preferences, colors),
                      _buildMenuItemsGrid(preferenceItems),
                      const SizedBox(height: 24),
                      _buildSectionTitle(l10n.support, colors),
                      _buildMenuItemsGrid(supportItems),
                      const SizedBox(height: 40),
                      _buildAppFooter(l10n, colors),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // The custom header, which stays fixed at the top
          _buildProfileHeader(l10n, user, themeProvider),
        ],
      ),
    );
  }

  // --- UI Helper Widgets ---

  Widget _buildProfileHeader(
    AppLocalizations l10n,
    dynamic user,
    ThemeProvider themeProvider,
  ) {
    final colors = themeProvider.colorScheme;
    final headerColor = themeProvider.accentColors['ethiopianGreen']!;

    return ClipPath(
      clipper: WaveClipper(),
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [headerColor, Color.lerp(headerColor, Colors.black, 0.4)!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // --- User Info with Frosted Glass Effect ---
            Positioned(
              bottom: 80,
              left: 24,
              right: 24,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.onSecondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colors.onSecondary.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 40), // Space for the avatar
                        Text(
                          user?.displayName ?? l10n.guestUser,
                          style: TextStyle(
                            color: colors.onSecondary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? l10n.signInToAccessFeatures,
                          style: TextStyle(
                            color: colors.onSecondary.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // --- Overlapping Profile Avatar ---

            // --- Top Title ---
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Text(
                l10n.profileTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.onSecondary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: colors.onSurface.withOpacity(0.6),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildMenuItemsGrid(List<_MenuItem> items) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Adjust the number of columns
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0, // Makes items square
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return _MenuGridItem(item: items[index]);
      },
    );
  }

  Widget _buildAppFooter(AppLocalizations l10n, ColorScheme colors) {
    return Column(
      children: [
        Text(
          l10n.goHospitalManagementSystem,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colors.onSurface.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.copyright,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colors.onSurface.withOpacity(0.4),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // --- Dialogs (unchanged logic) ---
  void _showLanguageDialog(AppLocalizations l10n) {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final colors = themeProvider.colorScheme;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.chooseLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // English Button
            _buildLanguageButton(
              context: dialogContext,
              flag: 'ðŸ‡¬ðŸ‡§',
              language: 'English',
              languageCode: 'en',
              languageProvider: languageProvider,
              colors: colors,
            ),
            const SizedBox(height: 8),
            // Amharic Button
            _buildLanguageButton(
              context: dialogContext,
              flag: 'ðŸ‡ªðŸ‡¹',
              language: 'áŠ áˆ›áˆ­áŠ› (Amharic)',
              languageCode: 'am',
              languageProvider: languageProvider,
              colors: colors,
            ),
            const SizedBox(height: 8),
            // Somali Button
            _buildLanguageButton(
              context: dialogContext,
              flag: 'ðŸ‡¸ðŸ‡´',
              language: 'Somali (Soomaali)',
              languageCode: 'so',
              languageProvider: languageProvider,
              colors: colors,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageButton({
    required BuildContext context,
    required String flag,
    required String language,
    required String languageCode,
    required LanguageProvider languageProvider,
    required ColorScheme colors,
  }) {
    return ElevatedButton(
      onPressed: () {
        languageProvider.setLanguage(languageCode);
        Navigator.of(context).pop();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary.withOpacity(0.1),
        foregroundColor: colors.primary,
        side: BorderSide(color: colors.primary, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(flag, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Text(
            language,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(
    AppLocalizations l10n,
    AuthProvider authProvider,
    ThemeProvider themeProvider,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.signOut),
        content: Text(l10n.signOutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: themeProvider.accentColors['error'],
              foregroundColor: themeProvider.colorScheme.onError,
            ),
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );
  }

  void _showFeatureComingSoon(AppLocalizations l10n, String featureName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(featureName),
        content: Text(l10n.featureComingSoonMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }
}

/// A simple data class for menu items.
class _MenuItem {
  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  _MenuItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });
}

/// A custom widget for each item in the menu grid.
class _MenuGridItem extends StatelessWidget {
  final _MenuItem item;

  const _MenuGridItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.colorScheme;
    final titleColor = item.isDestructive ? item.color : colors.onSurface;

    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        shadowColor: colors.shadow.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: colors.surface,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: item.color.withOpacity(0.1),
              child: Icon(item.icon, color: item.color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              item.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: titleColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom clipper for the wave-like header background.
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 50); // Start from bottom-left
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 30);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );
    var secondControlPoint = Offset(size.width * 3 / 4, size.height - 60);
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );
    path.lineTo(size.width, 0); // Go to top-right
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}





