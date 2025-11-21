// File: lib/features/reservation/reservation_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_localizations.dart';
import '../../core/providers/api_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/utils/app_logger.dart';
import '../auth/login_screen.dart';
import 'reservation_detail_screen.dart';
import 'appointment_detail_screen.dart';

/// Appointments & Reservations Screen - Display user's appointments and reservations
class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late Timer _updateTimer;
  List<Map<String, dynamic>> _appointments = [];
  List<Map<String, dynamic>> _reservations = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAppointments();
    _loadReservations();

    // Update duration every second
    _updateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          // Trigger rebuild to update duration
        });
      }
    });
  }

  Future<void> _loadAppointments() async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
      }

      final apiProvider = Provider.of<ApiProvider>(context, listen: false);

      // Ensure API is initialized
      if (!apiProvider.isInitialized) {
        AppLogger.api('⏳ Waiting for API initialization...');
        await apiProvider.initialize();
      }

      AppLogger.api('📋 Loading my appointments from API');

      // Load appointments from backend using the correct endpoint
      final response = await apiProvider.appointments.getMyAppointments();

      if (mounted) {
        setState(() {
          // Extract appointments data from nested structure
          final data = response['data'] as Map<String, dynamic>? ?? {};
          final appointmentsData = data['appointments'] as List? ?? [];
          _appointments = appointmentsData
              .map((apt) => apt as Map<String, dynamic>)
              .toList();
          _isLoading = false;
        });
      }

      AppLogger.success(
        '✅ Appointments loaded: ${_appointments.length} appointments',
      );
    } catch (e) {
      AppLogger.error('❌ Failed to load appointments', error: e);
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load appointments: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadReservations() async {
    try {
      final apiProvider = Provider.of<ApiProvider>(context, listen: false);

      // Ensure API is initialized
      if (!apiProvider.isInitialized) {
        await apiProvider.initialize();
      }

      AppLogger.api('🏨 Loading reservations from API');

      // Load reservations from backend (customer endpoint)
      final response = await apiProvider.reservations.getMyReservations();

      if (mounted) {
        setState(() {
          // Extract reservations data from nested structure
          final data = response['data'] as Map<String, dynamic>? ?? {};
          final reservationsData = data['reservations'] as List? ?? [];
          _reservations = reservationsData
              .map((res) => res as Map<String, dynamic>)
              .toList();
        });
      }

      AppLogger.success(
        '✅ Reservations loaded: ${_reservations.length} reservations',
      );
    } catch (e) {
      AppLogger.error('❌ Failed to load reservations', error: e);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _updateTimer.cancel();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeString;
    }
  }

  String _formatDuration(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final duration = dateTime.difference(now);

      if (duration.isNegative) {
        return 'Past appointment';
      }

      final days = duration.inDays;
      final hours = duration.inHours % 24;
      final minutes = duration.inMinutes % 60;

      List<String> parts = [];
      if (days > 0) {
        parts.add('$days day${days > 1 ? 's' : ''}');
      }
      if (hours > 0) {
        parts.add('$hours hour${hours > 1 ? 's' : ''}');
      }
      if (minutes > 0) {
        parts.add('$minutes minute${minutes > 1 ? 's' : ''}');
      }

      if (parts.isEmpty) {
        return 'Today';
      }

      return parts.join(' and ');
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, AuthProvider>(
      builder: (context, themeProvider, authProvider, child) {
        final l10n = AppLocalizations.of(context)!;
        final theme = themeProvider.themeData;
        final colors = themeProvider.colorScheme;

        // Check if user is authenticated
        if (!authProvider.isAuthenticated) {
          return Scaffold(
            backgroundColor: colors.surface,
            appBar: AppBar(
              backgroundColor: colors.surface,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: colors.onSurface),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                l10n.appointmentsAndReservations,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline, size: 64, color: colors.primary),
                    const SizedBox(height: 24),
                    Text(
                      l10n.signInToAccessFeatures,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.viewAndManageBookings,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.login),
                      label: Text(l10n.signIn),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: colors.surface,
          appBar: AppBar(
            backgroundColor: colors.surface,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: colors.onSurface),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              l10n.appointmentsAndReservations,
              style: theme.textTheme.titleLarge?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    boxShadow: [
                      BoxShadow(
                        color: colors.shadow.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.yourBookings,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.viewAndManageBookings,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                // Tab Bar
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: colors.outline.withOpacity(0.2),
                      ),
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
                        icon: const Icon(Icons.calendar_today),
                        text: l10n.appointments,
                      ),
                      Tab(
                        icon: const Icon(Icons.hotel),
                        text: l10n.reservations,
                      ),
                    ],
                  ),
                ),

                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Appointments Tab
                      _buildAppointmentsList(themeProvider, colors, theme),
                      // Reservations Tab
                      _buildReservationsList(themeProvider, colors, theme),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppointmentsList(
    ThemeProvider themeProvider,
    ColorScheme colors,
    ThemeData theme,
  ) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      final isAuthError =
          _errorMessage!.contains('401') || _errorMessage!.contains('token');

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isAuthError ? Icons.lock_outline : Icons.wifi_off,
              size: 64,
              color: colors.error,
            ),
            const SizedBox(height: 24),
            Text(
              isAuthError ? 'Sign in again' : 'Check your network',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isAuthError
                  ? 'Your session has expired. Please sign in again.'
                  : 'Please check your internet connection and try again.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _loadAppointments,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeProvider.accentColors['medical'],
                  ),
                ),
                if (isAuthError) ...[
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.login),
                    label: const Text('Sign In'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      );
    }

    if (_appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 64,
              color: colors.onSurface.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text('No appointments yet', style: theme.textTheme.titleMedium),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _appointments.length,
      itemBuilder: (context, index) {
        final appointment = _appointments[index];
        return _buildAppointmentCard(appointment, themeProvider, colors, theme);
      },
    );
  }

  Widget _buildAppointmentCard(
    Map<String, dynamic> appointment,
    ThemeProvider themeProvider,
    ColorScheme colors,
    ThemeData theme,
  ) {
    final status = appointment['status'] as String? ?? 'pending';
    final dateTime = appointment['dateTime'] as String? ?? 'N/A';
    final hospitalName = appointment['hospitalName'] as String? ?? 'Hospital';
    final description = hospitalName;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outline.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          AppLogger.navigation('Appointment tapped: ${appointment['id']}');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AppointmentDetailScreen(appointment: appointment),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Appointment #${appointment['id']}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getStatusColor(status),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Description
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface.withOpacity(0.8),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Date info
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: colors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDateTime(dateTime),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurface.withOpacity(0.6),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDuration(dateTime),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildReservationsList(
    ThemeProvider themeProvider,
    ColorScheme colors,
    ThemeData theme,
  ) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_reservations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hotel,
              size: 64,
              color: colors.onSurface.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text('No reservations yet', style: theme.textTheme.titleMedium),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _reservations.length,
      itemBuilder: (context, index) {
        final reservation = _reservations[index];
        return _buildReservationCard(reservation, themeProvider, colors, theme);
      },
    );
  }

  Widget _buildReservationCard(
    Map<String, dynamic> reservation,
    ThemeProvider themeProvider,
    ColorScheme colors,
    ThemeData theme,
  ) {
    final reservationId = reservation['id']?.toString() ?? 'N/A';
    final date = reservation['date'] as String? ?? 'N/A';
    final startDate = reservation['startDate'] as String? ?? 'N/A';
    final endDate = reservation['endDate'] as String? ?? 'N/A';

    // Extract order information
    final order = reservation['order'] as Map<String, dynamic>? ?? {};
    final orderId = order['id']?.toString() ?? 'N/A';
    final description = order['description'] as String? ?? 'No description';
    final status = order['status']?.toString() ?? 'pending';

    // Get package or service name
    final package = order['package'] as Map<String, dynamic>? ?? {};
    final service = order['service'] as Map<String, dynamic>? ?? {};
    final packageName =
        package['name'] as String? ??
        service['name'] as String? ??
        'Medical Service';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor(status).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          AppLogger.navigation('Reservation tapped: $reservationId');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ReservationDetailScreen(reservation: reservation),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reservation #$reservationId',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Order #$orderId',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(status).withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getStatusColor(status),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Package/Service name
              Text(
                packageName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Description
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurface.withOpacity(0.6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Date info
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: colors.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      date,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                  if (startDate != 'N/A' && endDate != 'N/A')
                    Expanded(
                      child: Text(
                        '$startDate to $endDate',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurface.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Price info (if available)
              if (package.isNotEmpty)
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      size: 16,
                      color: colors.primary.withOpacity(0.7),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Package Price: ',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurface.withOpacity(0.6),
                      ),
                    ),
                    Text(
                      package['price'] ?? '0.00',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              // Tap to view hint
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Tap to view details →',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.primary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
