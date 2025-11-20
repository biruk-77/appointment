// File: lib/features/payment/payment_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/api_provider.dart';
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

  final List<Map<String, String>> _paymentMethods = [
    {'id': 'telebirr', 'name': 'Telebirr', 'icon': '📱'},
    {'id': 'santimpay', 'name': 'SantimPay', 'icon': '💳'},
    {'id': 'cbe', 'name': 'CBE Birr', 'icon': '🏦'},
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
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount Display
            Center(
              child: Column(
                children: [
                  Text(
                    "Total Amount",
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    PaymentFormatter.formatCurrency(widget.amount),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Order Info
            if (widget.orderDescription != null) ...[
              Text(
                "Order Description",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(widget.orderDescription!),
              ),
              const SizedBox(height: 24),
            ],

            // Payment Methods
            Text(
              "Select Payment Method",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ..._paymentMethods.map(
              (method) => RadioListTile<String>(
                value: method['id']!,
                groupValue: _selectedMethod,
                onChanged: (value) => setState(() => _selectedMethod = value!),
                title: Text(method['name']!),
                secondary: Text(
                  method['icon']!,
                  style: const TextStyle(fontSize: 24),
                ),
                activeColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: _selectedMethod == method['id']
                        ? Theme.of(context).primaryColor
                        : Colors.grey.withOpacity(0.3),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Pay Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Pay Now",
                        style: TextStyle(
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
