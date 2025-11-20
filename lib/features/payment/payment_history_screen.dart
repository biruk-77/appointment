// File: lib/features/payment/payment_history_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_localizations.dart';
import '../../core/providers/api_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/utils/app_logger.dart';
import '../../core/utils/payment_formatter.dart';

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
          _payments = result['data']['payments'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('Failed to fetch payments', error: e);
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
        title: Text(l10n.payments), // Ensure 'payments' key exists in arb
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
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
          ? Center(
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
                    "No payment history found",
                    style: TextStyle(color: colors.onSurface.withOpacity(0.6)),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _payments.length,
              itemBuilder: (context, index) {
                final payment = _payments[index];
                final amount =
                    double.tryParse(payment['amount']?.toString() ?? '0') ??
                    0.0;
                final status = payment['status'] ?? 'Pending';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: colors.primary.withOpacity(0.1),
                      child: Icon(Icons.attach_money, color: colors.primary),
                    ),
                    title: Text(
                      PaymentFormatter.formatCurrency(amount),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "${payment['paymentMethod'] ?? 'Unknown'} • ${payment['transactionId'] ?? 'N/A'}",
                    ),
                    trailing: Text(
                      status,
                      style: TextStyle(
                        color: PaymentFormatter.getStatusColor(status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
