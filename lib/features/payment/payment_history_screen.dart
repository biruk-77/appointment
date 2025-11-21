// File: lib/features/payment/payment_history_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_localizations.dart';
import '../../core/providers/api_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/utils/app_logger.dart';
import '../../core/utils/payment_formatter.dart';
import 'payment_detail_screen.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  bool _isLoading = true;
  List<dynamic> _payments = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPayments();
  }

  Future<void> _fetchPayments() async {
    try {
      final apiProvider = Provider.of<ApiProvider>(context, listen: false);
      // Fetch payments (backend filters by user token)
      final result = await apiProvider.payments.getAllPayments();

      if (mounted) {
        setState(() {
          final data = result['data'];
          if (data != null) {
            if (data is List) {
              _payments = data;
            } else if (data is Map && data['payments'] != null) {
              _payments = data['payments'];
            } else {
              _payments = [];
            }
          } else {
            _payments = [];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('Failed to fetch payments', error: e);
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load payments: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _verifyPayment(String reference, BuildContext context) async {
    try {
      final apiProvider = Provider.of<ApiProvider>(context, listen: false);

      AppLogger.api('🔍 Verifying payment: $reference');

      // Call verify payment API
      final result = await apiProvider.payments.verifyPayment(reference);

      final l10n = AppLocalizations.of(context)!;
      if (result['success'] == true) {
        AppLogger.success('✅ Payment verified successfully');

        // Refresh payments list
        await _fetchPayments();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Payment verified successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception(result['message'] ?? 'Verification failed');
      }
    } catch (e) {
      AppLogger.error('❌ Payment verification failed', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
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
        title: Text(l10n.payments),
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
                _errorMessage = null;
              });
              _fetchPayments();
            },
            tooltip: 'Refresh payments',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: colors.primary))
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: colors.error, size: 48),
                  const SizedBox(height: 16),
                  Text(_errorMessage!),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _errorMessage = null;
                      });
                      _fetchPayments();
                    },
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            )
          : _payments.isEmpty
          ? RefreshIndicator(
              onRefresh: () async {
                await _fetchPayments();
              },
              color: colors.primary,
              child: Center(
                child: ListView(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.payment,
                            size: 64,
                            color: colors.onSurface.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No payment history found',
                            style: TextStyle(
                              color: colors.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                await _fetchPayments();
              },
              color: colors.primary,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _payments.length,
                itemBuilder: (context, index) {
                  final payment = _payments[index];
                  final amount =
                      double.tryParse(payment['amount']?.toString() ?? '0') ??
                      0.0;
                  final status = payment['status'] ?? 'pending';
                  final reference = payment['reference'] ?? 'N/A';
                  final method = payment['paymentMethod'] ?? 'Unknown';
                  final createdAt = payment['createdAt'] ?? 'N/A';
                  final order = payment['order'] as Map<String, dynamic>? ?? {};

                  return GestureDetector(
                    onTap: () {
                      AppLogger.navigation('Payment tapped: $reference');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PaymentDetailScreen(paymentData: payment),
                        ),
                      );
                    },
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: PaymentFormatter.getStatusColor(
                              status,
                            ).withOpacity(0.3),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header: Amount and Status
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          PaymentFormatter.formatCurrency(
                                            amount,
                                          ),
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: colors.primary,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${l10n.orderNumber(order['id'] ?? 'N/A')}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: colors.onSurface
                                                    .withOpacity(0.6),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: PaymentFormatter.getStatusColor(
                                        status,
                                      ).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: PaymentFormatter.getStatusColor(
                                          status,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      status.toUpperCase(),
                                      style: TextStyle(
                                        color: PaymentFormatter.getStatusColor(
                                          status,
                                        ),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Details Row 1
                              Row(
                                children: [
                                  Icon(
                                    Icons.payment,
                                    size: 16,
                                    color: colors.primary.withOpacity(0.7),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      method,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ),
                                  Icon(
                                    Icons.receipt,
                                    size: 16,
                                    color: colors.primary.withOpacity(0.7),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      reference,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Details Row 2
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 16,
                                    color: colors.primary.withOpacity(0.7),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      createdAt,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ),
                                  if (order['description'] != null)
                                    Expanded(
                                      child: Text(
                                        order['description'],
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: colors.onSurface
                                                  .withOpacity(0.6),
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Action Row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      l10n.tapToViewDetails,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: colors.primary,
                                            fontStyle: FontStyle.italic,
                                          ),
                                    ),
                                  ),
                                  if (status != 'completed')
                                    SizedBox(
                                      height: 32,
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          _verifyPayment(reference, context);
                                        },
                                        icon: const Icon(
                                          Icons.check_circle,
                                          size: 16,
                                        ),
                                        label: Text(l10n.verify),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 4,
                                          ),
                                          backgroundColor: colors.primary,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
