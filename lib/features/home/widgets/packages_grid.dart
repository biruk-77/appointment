// File: lib/features/home/widgets/packages_grid.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 1. ADD LOCALIZATION IMPORT
import '../../../app_localizations.dart';

import '../../../core/providers/theme_provider.dart';
import '../../../core/utils/app_logger.dart';
import '../../appointment/appointment_booking_screen.dart';

/// Beautiful packages grid widget
/// Displays health packages with enhanced UI and animations
class PackagesGrid extends StatelessWidget {
  const PackagesGrid({super.key, this.packages = const []});

  final List<Map<String, dynamic>> packages;

  @override
  Widget build(BuildContext context) {
    // 2. INITIALIZE LOCALIZATION
    final l10n = AppLocalizations.of(context)!;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.themeData;
        final colors = themeProvider.colorScheme;

        if (packages.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: themeProvider.accentColors['medical']!.withOpacity(
                        0.2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.card_giftcard,
                      color: themeProvider.accentColors['medical'],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.healthPackages, // LOCALIZED
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        l10n.healthPackagesSubtitle, // LOCALIZED
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Packages list
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: packages.length,
                itemBuilder: (context, index) {
                  final package = packages[index];
                  return _PackageCard(
                    package: package,
                    themeProvider: themeProvider,
                    index: index,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PackageCard extends StatefulWidget {
  const _PackageCard({
    required this.package,
    required this.themeProvider,
    required this.index,
  });

  final Map<String, dynamic> package;
  final ThemeProvider themeProvider;
  final int index;

  @override
  State<_PackageCard> createState() => _PackageCardState();
}

class _PackageCardState extends State<_PackageCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    // Stagger animation for each card
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 3. INITIALIZE LOCALIZATION FOR CHILD WIDGET
    final l10n = AppLocalizations.of(context)!;

    final theme = widget.themeProvider.themeData;
    final colors = widget.themeProvider.colorScheme;
    final packageName =
        widget.package['name'] ?? l10n.defaultPackageName; // LOCALIZED fallback

    // Handle price - backend returns as string, convert to double
    final priceValue = widget.package['price'];
    final packagePrice = priceValue is String
        ? double.tryParse(priceValue) ?? 0.0
        : (priceValue is num ? priceValue.toDouble() : 0.0);

    final packageDescription =
        widget.package['detail']?['description'] ??
        widget.package['description'] ??
        l10n.healthPackagesSubtitle; // Use subtitle as fallback
    final packageDuration = widget.package['detail']?['duration'] ?? '2 hours';
    final packageIncludes =
        widget.package['detail']?['includes'] as List<dynamic>? ?? [];

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: () {
          AppLogger.navigation('Package tapped: $packageName');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AppointmentBookingScreen(service: widget.package),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.themeProvider.accentColors['medical']!.withOpacity(0.1),
                widget.themeProvider.accentColors['success']!.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.themeProvider.accentColors['medical']!.withOpacity(
                0.3,
              ),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.themeProvider.accentColors['medical']!
                    .withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                AppLogger.navigation('Package tapped: $packageName');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AppointmentBookingScreen(service: widget.package),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row with name and price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                packageName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    size: 14,
                                    color: colors.onSurface.withOpacity(0.6),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    packageDuration,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colors.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                widget.themeProvider.accentColors['medical']!,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'ETB ${packagePrice.toStringAsFixed(2)}',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Description
                    Text(
                      packageDescription,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurface.withOpacity(0.7),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (packageIncludes.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      // Includes section
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: packageIncludes.take(3).map((item) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: widget
                                  .themeProvider
                                  .accentColors['success']!
                                  .withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 12,
                                  color: widget
                                      .themeProvider
                                      .accentColors['success'],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  item.toString(),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colors.onSurface.withOpacity(0.8),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      if (packageIncludes.length > 3)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            l10n.moreItems(
                              packageIncludes.length - 3,
                            ), // LOCALIZED: "+2 more"
                            style: theme.textTheme.labelSmall?.copyWith(
                              color:
                                  widget.themeProvider.accentColors['medical'],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                    const SizedBox(height: 12),
                    // Book button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          AppLogger.navigation('Booking package: $packageName');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AppointmentBookingScreen(
                                service: widget.package,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              widget.themeProvider.accentColors['medical'],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          l10n.bookNow, // LOCALIZED
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

