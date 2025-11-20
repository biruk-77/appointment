// File: lib/features/orders/order_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_localizations.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/providers/api_provider.dart';
import '../../core/utils/app_logger.dart';
import '../../core/utils/payment_formatter.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _orderData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
  }

  Future<void> _fetchOrderDetails() async {
    try {
      final apiProvider = Provider.of<ApiProvider>(context, listen: false);
      // Fetch specific order details
      final response = await apiProvider.orders.getOrderById(widget.orderId);
      
      if (mounted) {
        setState(() {
          _orderData = response['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('Failed to load order details', error: e);
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: colors.primary))
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: colors.error),
                      const SizedBox(height: 16),
                      Text(_errorMessage!),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _errorMessage = null;
                          });
                          _fetchOrderDetails();
                        },
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusCard(l10n, colors),
                      const SizedBox(height: 20),
                      _buildInfoSection(l10n, colors),
                      const SizedBox(height: 20),
                      _buildTotalSection(l10n, colors),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatusCard(AppLocalizations l10n, ColorScheme colors) {
    final status = _orderData?['status'] ?? 'Unknown';
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoRow(l10n.orderNumber(widget.orderId), '#${widget.orderId}', colors),
            const Divider(),
            _buildInfoRow(
              l10n.orderDate, 
              _orderData?['createdAt'] != null 
                ? PaymentFormatter.formatDate(DateTime.parse(_orderData!['createdAt']))
                : 'N/A',
              colors
            ),
             const Divider(),
            _buildInfoRow(
              "Description", 
              _orderData?['description'] ?? 'N/A', 
              colors
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: colors.onSurface.withOpacity(0.6))),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: colors.onSurface)),
        ],
      ),
    );
  }

  Widget _buildTotalSection(AppLocalizations l10n, ColorScheme colors) {
    final amount = double.tryParse(_orderData?['amount']?.toString() ?? '0') ?? 0.0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.totalAmount,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          Text(
            PaymentFormatter.formatCurrency(amount),
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}