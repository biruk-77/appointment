// File: lib/features/appointments/appointment_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_localizations.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/utils/app_logger.dart';
import '../../core/utils/payment_formatter.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final Map<String, dynamic> appointmentData;

  const AppointmentDetailScreen({super.key, required this.appointmentData});

  @override
  State<AppointmentDetailScreen> createState() =>
      _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  late Map<String, dynamic> _appointmentData;

  @override
  void initState() {
    super.initState();
    _appointmentData = widget.appointmentData;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appointmentDetails),
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(l10n, colors),
            const SizedBox(height: 20),
            _buildInfoSection(l10n, colors),
            const SizedBox(height: 20),
            _buildCustomerSection(l10n, colors),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(AppLocalizations l10n, ColorScheme colors) {
    final status = _appointmentData['status'] ?? 'pending';
    final color = PaymentFormatter.getStatusColor(status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            l10n.status,
            style: TextStyle(color: colors.onSurface.withOpacity(0.6)),
          ),
          const SizedBox(height: 8),
          Text(
            status.toString().toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(AppLocalizations l10n, ColorScheme colors) {
    final appointmentId = _appointmentData['id']?.toString() ?? 'N/A';
    final dateTime = _appointmentData['dateTime'] as String? ?? 'N/A';
    final hospitalName = _appointmentData['hospitalName'] as String? ?? 'N/A';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(
              l10n.appointmentId,
              '#$appointmentId',
              colors,
              Icons.confirmation_number,
            ),
            const Divider(),
            _buildInfoRow(
              l10n.dateTime,
              dateTime,
              colors,
              Icons.calendar_today,
            ),
            const Divider(),
            _buildInfoRow(
              l10n.hospital,
              hospitalName,
              colors,
              Icons.local_hospital,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerSection(AppLocalizations l10n, ColorScheme colors) {
    final customer =
        _appointmentData['customer'] as Map<String, dynamic>? ?? {};
    final customerName = customer['name'] as String? ?? 'N/A';
    final customerPhone = customer['phone'] as String? ?? 'N/A';
    final customerEmail = customer['email'] as String? ?? 'N/A';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.customerInformation,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(l10n.name, customerName, colors, Icons.person),
            const SizedBox(height: 12),
            _buildInfoRow(l10n.phone, customerPhone, colors, Icons.phone),
            const SizedBox(height: 12),
            _buildInfoRow(l10n.email, customerEmail, colors, Icons.email),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    ColorScheme colors,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: colors.primary.withOpacity(0.7)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: colors.onSurface.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
