// File: lib/features/reservation/reservation_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/api_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/utils/app_logger.dart';

/// Appointments & Reservations Screen - Display user's appointments and reservations
class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
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

      AppLogger.api('📋 Loading appointments from API');

      // Load appointments from backend
      final response = await apiProvider.reservations.getAllReservations(
        limit: 50,
      );

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

      // Load reservations from backend
      final response = await apiProvider.reservations.getAllReservations(
        limit: 50,
      );

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

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.themeData;
        final colors = themeProvider.colorScheme;

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
              'Appointments & Reservations',
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
                        'Your Bookings',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'View and manage your appointments and reservations',
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
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.calendar_today),
                        text: 'Appointments',
                      ),
                      Tab(icon: Icon(Icons.hotel), text: 'Reservations'),
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: colors.error),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAppointments,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeProvider.accentColors['medical'],
              ),
              child: const Text('Retry'),
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
    final startDate = appointment['startDate'] as String? ?? 'N/A';
    final endDate = appointment['endDate'] as String? ?? 'N/A';
    final description =
        appointment['description'] as String? ?? 'No description';

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
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: colors.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Start: $startDate',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: colors.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'End: $endDate',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurface.withOpacity(0.6),
                      ),
                      overflow: TextOverflow.ellipsis,
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
    final status = reservation['status'] as String? ?? 'pending';
    final startDate = reservation['startDate'] as String? ?? 'N/A';
    final endDate = reservation['endDate'] as String? ?? 'N/A';
    final packageName = reservation['packageName'] as String? ?? 'Package';

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
          AppLogger.navigation('Reservation tapped: ${reservation['id']}');
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
                      'Reservation #${reservation['id']}',
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
              // Package name
              Text(
                packageName,
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
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: colors.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'From: $startDate',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: colors.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'To: $endDate',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurface.withOpacity(0.6),
                      ),
                      overflow: TextOverflow.ellipsis,
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
}

