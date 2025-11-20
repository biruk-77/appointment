// File: lib/features/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import './../../app_localizations.dart'; // ✅ Import Localization

import '../../core/providers/theme_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/api_provider.dart';
import '../../core/utils/app_logger.dart';
import '../../core/extensions/localization_extension.dart'; // Optional helper
import 'widgets/service_grid.dart';
import 'widgets/packages_grid.dart';
import 'widgets/home_header.dart'; // Ensure this matches your file name
import '../orders/orders_screen.dart';
import '../profile/profile_screen.dart';
import '../reservation/reservation_screen.dart';

/// Home screen following WINDSURF AI Rules
/// Provider-first theming, categorized services, appointment booking focus
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  // Real API data state
  List<Map<String, dynamic>> _services = [];
  List<Map<String, dynamic>> _packages = [];
  List<Map<String, dynamic>> _doctors = [];
  List<Map<String, dynamic>> _hospitals = [];
  bool _isLoadingData = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    AppLogger.startup(
      '🏠 [HomeScreen] initState - initializing and loading home data',
    );
    _loadHomeData();
  }

  /// Load real data from API
  Future<void> _loadHomeData() async {
    try {
      if (!mounted) return;

      setState(() {
        _isLoadingData = true;
        _errorMessage = null;
      });

      final apiProvider = Provider.of<ApiProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      AppLogger.api('📋 Loading landing page data...');

      // 1. Define Futures for PUBLIC data
      var futures = <Future<dynamic>>[
        apiProvider.medical.getAllServices(limit: 6),
        apiProvider.medical.getAllPackages(limit: 4),
      ];

      // 2. If Logged In, fetch PRIVATE data (Profile)
      // We DO NOT fetch 'getAllOrders' because that causes 403 (Admin Only)
      if (authProvider.isAuthenticated) {
        futures.add(
          apiProvider.customers.getCustomerProfile().catchError(
            (e) => {'data': null}, // Ignore profile errors silently
          ),
        );
      }

      // 3. Wait for all results
      final results = await Future.wait(futures);

      if (!mounted) return;

      setState(() {
        // Process Services (Index 0)
        final servicesRaw = results[0]['data'];
        if (servicesRaw is List) {
          _services = servicesRaw.cast<Map<String, dynamic>>();
        } else if (servicesRaw is Map && servicesRaw['services'] is List) {
          _services = (servicesRaw['services'] as List)
              .cast<Map<String, dynamic>>();
        }

        // Process Packages (Index 1)
        final packagesRaw = results[1]['data'];
        if (packagesRaw is List) {
          _packages = packagesRaw.cast<Map<String, dynamic>>();
        } else if (packagesRaw is Map && packagesRaw['packages'] is List) {
          _packages = (packagesRaw['packages'] as List)
              .cast<Map<String, dynamic>>();
        }

        // Process Profile (Index 2 - Only if logged in)
        if (results.length > 2 && results[2] != null) {
          final profileData = results[2];
          if (profileData['data'] != null) {
            AppLogger.user('👤 Profile loaded: ${profileData['data']['name']}');
          }
        }

        _isLoadingData = false;
      });

      AppLogger.success('✅ Landing data loaded successfully');
    } catch (e) {
      // Check if it's a 403 error on Services/Packages
      if (e.toString().contains('403')) {
        AppLogger.error('⚠️ API requires login for public data');
        if (mounted) {
          setState(() {
            _errorMessage = "Please login to view services.";
            _isLoadingData = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Connection Error: ${e.toString()}';
            _isLoadingData = false;
          });
        }
        AppLogger.error('❌ Failed to load home data', error: e);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Initialize Localization
    final l10n = AppLocalizations.of(context)!;

    return Consumer3<ThemeProvider, AuthProvider, ApiProvider>(
      builder: (context, themeProvider, authProvider, apiProvider, child) {
        final theme = themeProvider.themeData;
        final colors = themeProvider.colorScheme;

        // Show loading screen if data is loading
        if (_isLoadingData) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    (themeProvider.accentColors['primary'] ?? colors.primary)
                        .withOpacity(0.1),
                    (themeProvider.accentColors['secondary'] ??
                            colors.secondary)
                        .withOpacity(0.1),
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        themeProvider.accentColors['primary'] ?? colors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.loadingData, // ✅ Localized
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colors.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.connectingApi, // ✅ Localized
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Show error screen if there's an error
        if (_errorMessage != null) {
          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    (themeProvider.accentColors['error'] ?? colors.error)
                        .withOpacity(0.1),
                    (themeProvider.accentColors['warning'] ??
                            colors.onErrorContainer)
                        .withOpacity(0.1),
                  ],
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: themeProvider.accentColors['error'],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.connectionFailed, // ✅ Localized
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: themeProvider.accentColors['error'],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _loadHomeData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              themeProvider.accentColors['primary'] ??
                              colors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(l10n.retryConnection), // ✅ Localized
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return Scaffold(
          body: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            children: [
              // Home tab - COMPREHENSIVE LAYOUT WITH ALL 6 WIDGETS
              SafeArea(
                child: RefreshIndicator(
                  onRefresh: _loadHomeData,
                  color: const Color(0xFFF5B041),
                  backgroundColor: Colors.white,
                  child: CustomScrollView(
                    slivers: [
                      // 1. ANIMATED HEADER
                      SliverToBoxAdapter(
                        child: HomeHeaderNew(
                          user: authProvider.user,
                          onTabChange: (index) {
                            setState(() {
                              _currentIndex = index;
                            });
                            _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 20)),

                      // 2. SCHEDULE BANNER
                      SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                themeProvider.accentColors['medical']!
                                    .withOpacity(0.5),
                                themeProvider.accentColors['success']!
                                    .withOpacity(0.5),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: themeProvider.accentColors['medical']!
                                  .withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: themeProvider
                                          .accentColors['medical']!
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.favorite,
                                      color:
                                          themeProvider.accentColors['medical'],
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.scheduleTitle, // ✅ Localized
                                          style: theme.textTheme.titleLarge
                                              ?.copyWith(
                                                color: colors.onSurface,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          l10n.scheduleSubtitle, // ✅ Localized
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: colors.onSurface
                                                    .withOpacity(0.7),
                                                height: 1.3,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SliverToBoxAdapter(child: SizedBox(height: 32)),

                      // 3. SERVICE GRID
                      SliverToBoxAdapter(
                        child: ServiceGrid(realServices: _services),
                      ),

                      const SliverToBoxAdapter(child: SizedBox(height: 32)),

                      // 4. PACKAGES GRID
                      if (_packages.isNotEmpty)
                        SliverToBoxAdapter(
                          child: PackagesGrid(packages: _packages),
                        ),

                      if (_packages.isNotEmpty)
                        const SliverToBoxAdapter(child: SizedBox(height: 32)),

                      // 5. EMERGENCY & SUPPORT SECTION
                      SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                themeProvider.accentColors['error']!
                                    .withOpacity(0.1),
                                themeProvider.accentColors['medical']!
                                    .withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: themeProvider.accentColors['error']!
                                  .withOpacity(0.3),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: themeProvider.accentColors['error']!
                                    .withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: themeProvider
                                          .accentColors['error']!
                                          .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: themeProvider
                                              .accentColors['error']!
                                              .withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.emergency,
                                      color:
                                          themeProvider.accentColors['error'],
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.needHelp, // ✅ Localized
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                color: colors.onSurface,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          l10n.contactSupport, // ✅ Localized
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: colors.onSurface
                                                    .withOpacity(0.7),
                                              ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: themeProvider
                                              .accentColors['error']!
                                              .withOpacity(0.3),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        AppLogger.phone(
                                          'Support contact tapped',
                                        );
                                        _showCallDialog(
                                          context,
                                          '+251951117167',
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            themeProvider.accentColors['error'],
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      icon: const Icon(Icons.phone, size: 16),
                                      label: Text(
                                        l10n.contactBtn, // ✅ Localized
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SliverToBoxAdapter(child: SizedBox(height: 32)),

                      // 6. PROMO SECTION
                      SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                themeProvider.accentColors['info']!.withOpacity(
                                  0.03,
                                ),
                                themeProvider.accentColors['medical']!
                                    .withOpacity(0.03),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: themeProvider.accentColors['info']!
                                  .withOpacity(0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: themeProvider.accentColors['medical']!
                                    .withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          themeProvider
                                              .accentColors['medical']!,
                                          themeProvider.accentColors['info']!,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.calendar_today,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.promoTitle, // ✅ Localized
                                          style: theme.textTheme.headlineSmall
                                              ?.copyWith(
                                                color: colors.onSurface,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          l10n.promoBody, // ✅ Localized
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: colors.onSurface
                                                    .withOpacity(0.8),
                                                height: 1.4,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: themeProvider.accentColors['success']!
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: themeProvider
                                        .accentColors['success']!
                                        .withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color:
                                          themeProvider.accentColors['success'],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        l10n.trustedUsers, // ✅ Localized
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: themeProvider
                                                  .accentColors['success'],
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 20)),
                      // BOTTOM SUPPORT SECTION
                      SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                colors.surface,
                                colors.surface.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: themeProvider.accentColors['medical']!
                                  .withOpacity(0.2),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: themeProvider.accentColors['medical']!
                                    .withOpacity(0.1),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          themeProvider
                                              .accentColors['medical']!,
                                          themeProvider
                                              .accentColors['diaspora']!,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.favorite,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          l10n.hubTitle, // ✅ Localized
                                          style: theme.textTheme.titleLarge
                                              ?.copyWith(
                                                color: colors.onSurface,
                                                fontWeight: FontWeight.bold,
                                              ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          l10n.hubSubtitle, // ✅ Localized
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: colors.onSurface
                                                    .withOpacity(0.8),
                                                height: 1.3,
                                              ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: themeProvider.accentColors['success']!
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: themeProvider
                                        .accentColors['success']!
                                        .withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.calendar_month,
                                      color:
                                          themeProvider.accentColors['success'],
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      l10n.bookAnywhere, // ✅ Localized
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: themeProvider
                                                .accentColors['success'],
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: _buildContactItem(
                                      Icons.phone,
                                      '+251951117167',
                                      themeProvider.accentColors['success']!,
                                      theme,
                                      colors,
                                      context,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildContactItem(
                                      Icons.email,
                                      'support@Go Hospital.et',
                                      themeProvider.accentColors['info']!,
                                      theme,
                                      colors,
                                      context,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _buildContactItem(
                                      Icons.location_on,
                                      l10n.locationCity, // ✅ Localized
                                      themeProvider.accentColors['warning']!,
                                      theme,
                                      colors,
                                      context,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SliverToBoxAdapter(child: SizedBox(height: 100)),
                    ],
                  ),
                ),
              ),

              // Search tab
              // const SearchScreen(),

              // Orders tab
              const OrdersScreen(),

              // Reservations tab
              const ReservationScreen(),

              // Profile tab
              const ProfileScreen(),
            ],
          ),
          bottomNavigationBar: _buildBottomNavigation(
            themeProvider,
            colors,
            context,
          ),
          floatingActionButton: _buildEmergencyFAB(themeProvider, colors),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
        );
      },
    );
  }

  /// Build enhanced contact item with icon container and styling
  Widget _buildContactItem(
    IconData icon,
    String text,
    Color color,
    ThemeData theme,
    ColorScheme colors,
    BuildContext context,
  ) {
    return GestureDetector(
      onTap: () async {
        // If it's a phone number, show call dialog
        if (icon == Icons.phone && text.startsWith('+')) {
          _showCallDialog(context, text);
        }
        // If it's an email, open email client
        else if (icon == Icons.email && text.contains('@')) {
          final Uri launchUri = Uri(scheme: 'mailto', path: text);
          try {
            if (await canLaunchUrl(launchUri)) {
              await launchUrl(launchUri);
              AppLogger.info('📧 Opening email: $text');
            }
          } catch (e) {
            AppLogger.error('❌ Email launch failed', error: e);
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurface.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(
    ThemeProvider themeProvider,
    ColorScheme colors,
    BuildContext context,
  ) {
    final l10n = AppLocalizations.of(context)!; // ✅ Localized
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: colors.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: colors.surface,
        selectedItemColor: themeProvider.accentColors['medical'],
        unselectedItemColor: colors.onSurface.withOpacity(0.6),
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          AppLogger.navigation('Bottom nav tapped: $index');
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: l10n.navHome),
          // BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: l10n.navOrders,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: l10n.navReservations,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: l10n.navProfile,
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyFAB(ThemeProvider themeProvider, ColorScheme colors) {
    return FloatingActionButton(
      onPressed: () {
        AppLogger.navigation('Quick book button pressed');
        // TODO: Handle quick booking
        // _showQuickBookDialog();
      },
      backgroundColor:
          themeProvider.accentColors['primary'], // This is the Green
      foregroundColor: Colors.white, // <--- CHANGE THIS to Colors.white
      child: const Icon(Icons.add, size: 28),
    );
  }

  void _showCallDialog(BuildContext context, String phoneNumber) {
    final l10n = AppLocalizations.of(context)!; // ✅ Localized

    showDialog(
      context: context,
      builder: (context) => Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.phone, color: themeProvider.accentColors['success']),
                const SizedBox(width: 8),
                Text(l10n.callSupportTitle),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.callSupportBody),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: themeProvider.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: themeProvider.colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    phoneNumber,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancelBtn),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
                  try {
                    if (await canLaunchUrl(launchUri)) {
                      await launchUrl(launchUri);
                      AppLogger.info('📞 Calling: $phoneNumber');
                    } else {
                      AppLogger.error('❌ Could not launch phone call');
                    }
                  } catch (e) {
                    AppLogger.error('❌ Phone call failed', error: e);
                  }
                },
                icon: const Icon(Icons.phone),
                label: Text(l10n.callNowBtn),
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeProvider.accentColors['success'],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
