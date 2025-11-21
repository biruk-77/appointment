// File: lib/features/orders/order_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_localizations.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/utils/payment_formatter.dart';

class OrderDetailScreen extends StatefulWidget {
  final Map<String, dynamic> orderData;

  const OrderDetailScreen({super.key, required this.orderData});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late Map<String, dynamic> _orderData;

  @override
  void initState() {
    super.initState();
    _orderData = widget.orderData;
  }

  String _getRelativeDate(String createdAtString) {
    try {
      final createdAt = DateTime.parse(createdAtString);
      final now = DateTime.now();
      final difference = now.difference(createdAt);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return '1 day ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else if (difference.inDays < 30) {
        final weeks = (difference.inDays / 7).floor();
        return '$weeks week${weeks > 1 ? 's' : ''} ago';
      } else {
        final months = (difference.inDays / 30).floor();
        return '$months month${months > 1 ? 's' : ''} ago';
      }
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.orderDetails),
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
            _buildServiceSection(l10n, colors),
            const SizedBox(height: 20),
            _buildDateSection(l10n, colors),
            if (_orderData['file'] != null) ...[
              const SizedBox(height: 20),
              _buildFileSection(l10n, colors),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(AppLocalizations l10n, ColorScheme colors) {
    final status = _orderData['status'] ?? 'pending';
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
            l10n.orderStatus,
            style: TextStyle(color: colors.onSurface.withOpacity(0.6)),
          ),
          const SizedBox(height: 8),
          Text(
            (status.isEmpty ? 'pending' : status).toUpperCase(),
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(
              l10n.orderNumber(_orderData['id']),
              '#${_orderData['id']}',
              colors,
              Icons.confirmation_number,
            ),
            const Divider(),
            _buildInfoRow(
              l10n.description,
              _orderData['description'] ?? 'N/A',
              colors,
              Icons.description,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceSection(AppLocalizations l10n, ColorScheme colors) {
    final service = _orderData['service'] as Map<String, dynamic>? ?? {};
    final serviceDesc = service['description'] as String? ?? 'N/A';
    final dateCount = _orderData['dateCount'] ?? 1;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.serviceInformation,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Service',
              serviceDesc,
              colors,
              Icons.medical_services,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              l10n.duration,
              '$dateCount day${dateCount > 1 ? 's' : ''}',
              colors,
              Icons.calendar_today,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSection(AppLocalizations l10n, ColorScheme colors) {
    final date = _orderData['date'] as String? ?? 'N/A';
    final createdAt = _orderData['createdAt'] as String? ?? '';
    final relativeDate = createdAt.isNotEmpty
        ? _getRelativeDate(createdAt)
        : 'N/A';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow('Service Date', date, colors, Icons.event),
            const SizedBox(height: 12),
            _buildInfoRow(
              l10n.created,
              relativeDate,
              colors,
              Icons.access_time,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileSection(AppLocalizations l10n, ColorScheme colors) {
    final fileUrl = _orderData['fileUrl'] as String?;
    final fileName = _orderData['file'] as String? ?? 'Attachment';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attachment',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            if (fileUrl != null)
              InkWell(
                onTap: () {
                  // Can add image viewer here
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors.primary.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.image, color: colors.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          fileName.split('/').last,
                          style: TextStyle(
                            color: colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.open_in_new, color: colors.primary, size: 18),
                    ],
                  ),
                ),
              ),
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
