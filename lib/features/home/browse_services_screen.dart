// File: lib/features/home/browse_services_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_localizations.dart';
import '../../core/providers/api_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/utils/app_logger.dart';
import 'widgets/service_grid.dart';
import 'widgets/packages_grid.dart';

class BrowseServicesScreen extends StatefulWidget {
  const BrowseServicesScreen({super.key});

  @override
  State<BrowseServicesScreen> createState() => _BrowseServicesScreenState();
}

class _BrowseServicesScreenState extends State<BrowseServicesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _services = [];
  List<Map<String, dynamic>> _packages = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final apiProvider = Provider.of<ApiProvider>(context, listen: false);

      AppLogger.api('📋 Loading all services and packages');

      final results = await Future.wait([
        apiProvider.medical.getAllServices(limit: 50),
        apiProvider.medical.getAllPackages(limit: 50),
      ]);

      if (mounted) {
        setState(() {
          // Process Services
          final servicesRaw = results[0]['data'];
          if (servicesRaw is List) {
            _services = servicesRaw.cast<Map<String, dynamic>>();
          } else if (servicesRaw is Map && servicesRaw['services'] is List) {
            _services = (servicesRaw['services'] as List)
                .cast<Map<String, dynamic>>();
          }

          // Process Packages
          final packagesRaw = results[1]['data'];
          if (packagesRaw is List) {
            _packages = packagesRaw.cast<Map<String, dynamic>>();
          } else if (packagesRaw is Map && packagesRaw['packages'] is List) {
            _packages = (packagesRaw['packages'] as List)
                .cast<Map<String, dynamic>>();
          }

          _isLoading = false;
        });
      }

      AppLogger.success(
        '✅ Loaded ${_services.length} services and ${_packages.length} packages',
      );
    } catch (e) {
      AppLogger.error('❌ Failed to load services and packages', error: e);
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load data: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final l10n = AppLocalizations.of(context)!;
        final theme = themeProvider.themeData;
        final colors = themeProvider.colorScheme;

        return Scaffold(
          backgroundColor: colors.surface,
          appBar: AppBar(
            backgroundColor: colors.surface,
            foregroundColor: colors.onSurface,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Browse Services & Packages',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Column(
            children: [
              // Tab Bar
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: colors.outline.withOpacity(0.2)),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: colors.primary,
                  unselectedLabelColor: colors.onSurface.withOpacity(0.6),
                  indicatorColor: colors.primary,
                  indicatorWeight: 3,
                  tabs: [
                    Tab(
                      icon: const Icon(Icons.medical_services),
                      text: l10n.services ?? 'Services',
                    ),
                    Tab(
                      icon: const Icon(Icons.card_giftcard),
                      text: l10n.packages ?? 'Packages',
                    ),
                  ],
                ),
              ),
              // Tab Content
              Expanded(
                child: _isLoading
                    ? Center(
                        child: CircularProgressIndicator(color: colors.primary),
                      )
                    : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: colors.error,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              style: theme.textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _loadData,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colors.primary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          // Services Tab
                          _services.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.medical_services,
                                        size: 64,
                                        color: colors.onSurface.withOpacity(
                                          0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No services available',
                                        style: theme.textTheme.titleMedium,
                                      ),
                                    ],
                                  ),
                                )
                              : ServiceGrid(realServices: _services),
                          // Packages Tab
                          _packages.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.card_giftcard,
                                        size: 64,
                                        color: colors.onSurface.withOpacity(
                                          0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No packages available',
                                        style: theme.textTheme.titleMedium,
                                      ),
                                    ],
                                  ),
                                )
                              : PackagesGrid(packages: _packages),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
