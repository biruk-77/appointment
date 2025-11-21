// File: lib/features/home/widgets/service_grid.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 1. ADD LOCALIZATION IMPORT
import '../../../app_localizations.dart';

import '../../../core/providers/theme_provider.dart';
import '../../../core/utils/app_logger.dart';
import '../../appointment/appointment_booking_screen_v2.dart';

/// Service model for home screen
class ServiceItem {
  const ServiceItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
    this.isSpecial = false,
  });

  final String title;
  final IconData icon;
  final Color color;
  final String route;
  final bool isSpecial;
}

/// Service grid widget following WINDSURF AI Rules
/// Provider-first theming, accessible medical services
class ServiceGrid extends StatelessWidget {
  const ServiceGrid({super.key, this.realServices = const []});

  final List<Map<String, dynamic>> realServices;

  List<ServiceItem> _getServices(
    ThemeProvider themeProvider,
    AppLocalizations l10n,
  ) {
    List<ServiceItem> services = [];

    // Add real backend services first
    for (var realService in realServices) {
      services.add(
        ServiceItem(
          title:
              realService['name'] ?? l10n.serviceMedical, // LOCALIZED fallback
          icon: _getServiceIcon(realService['name'] ?? ''),
          color: themeProvider.getServiceItemColor(),
          route: '/service/${realService['id']}',
        ),
      );
    }

    // Add only the Call us service - remove all other static services
    services.add(
      ServiceItem(
        title: l10n.serviceCallUs, // LOCALIZED
        icon: Icons.phone,
        color: themeProvider.getServiceItemColor(
          isSpecial: true,
        ), // Special dark teal color for Call us
        route: '/call',
        isSpecial: true,
      ),
    );

    return services;
  }

  IconData _getServiceIcon(String serviceName) {
    final name = serviceName.toLowerCase();

    // Smart icon mapping - automatically handles ANY service you add to backend
    if (name.contains('doctor') ||
        name.contains('consultation') ||
        name.contains('medical')) {
      return Icons.medical_information;
    } else if (name.contains('hotel') ||
        name.contains('accommodation') ||
        name.contains('room')) {
      return Icons.hotel;
    } else if (name.contains('transport') ||
        name.contains('taxi') ||
        name.contains('car') ||
        name.contains('bus')) {
      return Icons.directions_car;
    } else if (name.contains('emergency') || name.contains('ambulance')) {
      return Icons.emergency;
    } else if (name.contains('lab') ||
        name.contains('test') ||
        name.contains('diagnostic')) {
      return Icons.biotech;
    } else if (name.contains('pharmacy') ||
        name.contains('medicine') ||
        name.contains('drug')) {
      return Icons.medication;
    } else if (name.contains('surgery') || name.contains('operation')) {
      return Icons.healing;
    } else if (name.contains('nurse') || name.contains('nursing')) {
      return Icons.local_hospital;
    } else if (name.contains('food') ||
        name.contains('meal') ||
        name.contains('catering')) {
      return Icons.restaurant;
    } else if (name.contains('cleaning') || name.contains('housekeeping')) {
      return Icons.cleaning_services;
    } else if (name.contains('therapy') || name.contains('rehabilitation')) {
      return Icons.accessibility;
    } else if (name.contains('equipment') || name.contains('device')) {
      return Icons.medical_services;
    } else {
      // Default icon for ANY new service
      return Icons.health_and_safety;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 2. INITIALIZE LOCALIZATION
    final l10n = AppLocalizations.of(context)!;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        // Pass l10n to helper
        final services = _getServices(themeProvider, l10n);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9, // Slightly taller to prevent overflow
            ),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return _ServiceCard(
                service: service,
                themeProvider: themeProvider,
              );
            },
          ),
        );
      },
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service, required this.themeProvider});

  final ServiceItem service;
  final ThemeProvider themeProvider;

  @override
  Widget build(BuildContext context) {
    final theme = themeProvider.themeData;
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () {
        AppLogger.navigation('Service tapped: ${service.title}');
        _handleServiceTap(context, l10n);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: service.color, // Use the exact service color
          borderRadius: BorderRadius.circular(
            20,
          ), // More rounded like your image
          boxShadow: [
            BoxShadow(
              color: service.color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _handleServiceTap(context, l10n),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Service icon - no background container, direct icon
                  Icon(
                    service.icon,
                    size: 32, // Larger icon like in your image
                    color: Colors.white,
                  ),

                  const SizedBox(height: 8),

                  // Service title
                  Text(
                    service.title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12, // Slightly larger text
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleServiceTap(BuildContext context, AppLocalizations l10n) {
    // Handle backend service routes
    if (service.route.startsWith('/service/')) {
      AppLogger.api(
        'ðŸ“… Navigating to appointment booking for service: ${service.title}',
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AppointmentBookingScreenV2(
            service: {
              'id': service.route.split('/').last,
              'name': service.title,
              'description': 'Medical consultation service',
              'costPerService': 50.00,
            },
            bookingType: 'service',
          ),
        ),
      );
      return;
    }

    // Handle static service routes
    switch (service.route) {
      case '/hospitals':
        AppLogger.hospital('Navigating to hospitals');
        _showComingSoon(context, 'Hospitals', l10n);
        break;
      case '/doctors':
        AppLogger.user('Navigating to doctors');
        _showComingSoon(context, 'Doctors', l10n);
        break;
      case '/diagnostics':
        AppLogger.hospital('Navigating to diagnostics');
        _showComingSoon(context, 'Diagnostics', l10n);
        break;
      case '/pharmacies':
        AppLogger.hospital('Navigating to pharmacies');
        _showComingSoon(context, 'Pharmacies', l10n);
        break;
      case '/call':
        AppLogger.phone('Initiating call service');
        _showCallDialog(context, l10n);
        break;
      case '/order-medicine':
        AppLogger.hospital('Navigating to medicine orders');
        _showComingSoon(context, 'Medicine Orders', l10n);
        break;
      default:
        AppLogger.warning('Unknown service route: ${service.route}');
    }
  }

  void _showComingSoon(
    BuildContext context,
    String serviceName,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(service.icon, color: service.color),
            const SizedBox(width: 8),
            Text(l10n.comingSoonTitle(serviceName)), // LOCALIZED
          ],
        ),
        content: Text(l10n.comingSoonMessage(serviceName)), // LOCALIZED
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.ok), // LOCALIZED (Assuming "OK" exists)
          ),
        ],
      ),
    );
  }

  void _showCallDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.phone, color: Colors.green),
            const SizedBox(width: 8),
            Text(l10n.callCenterTitle), // LOCALIZED
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.callCenterBody), // LOCALIZED
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.phone),
              title: Text(l10n.emergencyTitle), // LOCALIZED
              subtitle: Text(l10n.emergencySubtitle), // LOCALIZED
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: const Icon(Icons.support_agent),
              title: Text(l10n.supportTitle), // LOCALIZED
              subtitle: Text(l10n.supportSubtitle), // LOCALIZED
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancelBtn), // LOCALIZED
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              AppLogger.phone('Support call initiated');
            },
            child: Text(l10n.callSupportBtn), // LOCALIZED
          ),
        ],
      ),
    );
  }
}
