// File: lib/features/payment/payment_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_localizations.dart';
import '../../core/providers/api_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/utils/app_logger.dart';
import '../../core/utils/payment_formatter.dart';

class PaymentScreen extends StatefulWidget {
  final int orderId;
  final double amount;
  final String? orderDescription;

  const PaymentScreen({
    super.key,
    required this.orderId,
    required this.amount,
    this.orderDescription,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoading = false;
  String _selectedMethod = 'telebirr'; // Default method
  bool _showMoreMethods = false;

  // Payment method mapping table
  static const Map<String, String> _paymentMethodMap = {
    'telebirr': 'Telebirr',
    'tele': 'Telebirr',
    'tele-birr': 'Telebirr',
    'tele birr': 'Telebirr',
    'cbe': 'CBE',
    'cbe-birr': 'CBE',
    'cbebirr': 'CBE',
    'cbe birr': 'CBE',
    'commercial bank of ethiopia (cbe)': 'CBE',
    'commercial bank of ethiopia': 'CBE',
    'commercial bank of ethiopia cbe': 'CBE',
    'hellocash': 'HelloCash',
    'hello-cash': 'HelloCash',
    'hello cash': 'HelloCash',
    'mpesa': 'MPesa',
    'm-pesa': 'MPesa',
    'm pesa': 'MPesa',
    'm_pesa': 'MPesa',
    'bank of abyssinia': 'Abyssinia',
    'abyssinia': 'Abyssinia',
    'awash': 'Awash',
    'awash bank': 'Awash',
    'dashen': 'Dashen',
    'dashen bank': 'Dashen',
    'bunna': 'Bunna',
    'bunna bank': 'Bunna',
    'amhara': 'Amhara',
    'amhara bank': 'Amhara',
    'birhan': 'Birhan',
    'birhan bank': 'Birhan',
    'berhan': 'Berhan',
    'berhan bank': 'Berhan',
    'zamzam': 'ZamZam',
    'zamzam bank': 'ZamZam',
    'yimlu': 'Yimlu',
  };

  final List<Map<String, String>> _paymentMethods = [
    {'id': 'telebirr', 'name': 'Telebirr', 'icon': '📱'},
    {'id': 'cbe', 'name': 'CBE Birr', 'icon': '🏦'},
    {'id': 'hellocash', 'name': 'HelloCash', 'icon': '💳'},
  ];

  final List<Map<String, String>> _allPaymentMethods = [
    {'id': 'telebirr', 'name': 'Telebirr', 'icon': '📱'},
    {'id': 'cbe', 'name': 'CBE', 'icon': '🏦'},
    {'id': 'hellocash', 'name': 'HelloCash', 'icon': '💳'},
    {'id': 'mpesa', 'name': 'MPesa', 'icon': '🌍'},
    {'id': 'abyssinia', 'name': 'Bank of Abyssinia', 'icon': '🏛️'},
    {'id': 'awash', 'name': 'Awash Bank', 'icon': '🏦'},
    {'id': 'dashen', 'name': 'Dashen Bank', 'icon': '🏦'},
    {'id': 'bunna', 'name': 'Bunna Bank', 'icon': '🏦'},
    {'id': 'amhara', 'name': 'Amhara Bank', 'icon': '🏦'},
    {'id': 'birhan', 'name': 'Birhan Bank', 'icon': '🏦'},
    {'id': 'berhan', 'name': 'Berhan Bank', 'icon': '🏦'},
    {'id': 'zamzam', 'name': 'ZamZam Bank', 'icon': '🏦'},
    {'id': 'yimlu', 'name': 'Yimlu', 'icon': '💰'},
  ];

  Future<void> _processPayment() async {
    setState(() => _isLoading = true);

    try {
      final apiProvider = Provider.of<ApiProvider>(context, listen: false);

      AppLogger.payment('Processing payment for Order #${widget.orderId}');

      await apiProvider.payments.createPayment(
        orderId: widget.orderId,
        amount: widget.amount,
        paymentOption: _selectedMethod,
      );

      if (mounted) {
        AppLogger.success('Payment initiated successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment initiated successfully!')),
        );
        // Navigate to payment history screen
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/payment-history',
          (route) => route.isFirst, // Keep only the home screen in the stack
        );
      }
    } catch (e) {
      AppLogger.error('Payment failed', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.colorScheme;

    final displayMethods = _showMoreMethods
        ? _allPaymentMethods
        : _paymentMethods;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.checkout),
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID Display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.primary.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.orderId,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "#${widget.orderId}",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Amount Display
            Center(
              child: Column(
                children: [
                  Text(
                    l10n.totalAmount,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    PaymentFormatter.formatCurrency(widget.amount),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Order Info
            if (widget.orderDescription != null) ...[
              Text(
                l10n.orderDescription,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.onSurface.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(widget.orderDescription!),
              ),
              const SizedBox(height: 24),
            ],

            // Payment Methods
            Text(
              l10n.selectPaymentMethod,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...displayMethods.map(
              (method) => RadioListTile<String>(
                value: method['id']!,
                groupValue: _selectedMethod,
                onChanged: (value) => setState(() => _selectedMethod = value!),
                title: Text(method['name']!),
                secondary: Text(
                  method['icon']!,
                  style: const TextStyle(fontSize: 24),
                ),
                activeColor: colors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: _selectedMethod == method['id']
                        ? colors.primary
                        : colors.onSurface.withOpacity(0.2),
                  ),
                ),
              ),
            ),

            // Show More / Show Less Button
            if (_allPaymentMethods.length > _paymentMethods.length) ...[
              const SizedBox(height: 16),
              Center(
                child: TextButton.icon(
                  onPressed: () =>
                      setState(() => _showMoreMethods = !_showMoreMethods),
                  icon: Icon(
                    _showMoreMethods ? Icons.expand_less : Icons.expand_more,
                    color: colors.primary,
                  ),
                  label: Text(
                    _showMoreMethods ? l10n.showLess : l10n.showMore,
                    style: TextStyle(color: colors.primary),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Pay Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        l10n.payNow,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
