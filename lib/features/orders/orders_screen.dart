// File: lib/features/orders/orders_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_localizations.dart';
import '../../core/providers/api_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/utils/app_logger.dart';
import '../../core/utils/payment_formatter.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _isLoading = true;
  List<dynamic> _orders = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      final apiProvider = Provider.of<ApiProvider>(context, listen: false);
      final result = await apiProvider.orders.getMyOrders();

      if (mounted) {
        setState(() {
          // Handle the nested structure: result['data']['orders']
          final data = result['data'];
          if (data != null && data['orders'] != null) {
            _orders = data['orders'];
          } else {
            _orders = [];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('Failed to fetch orders', error: e);
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
        title: Text(l10n.myOrders),
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        automaticallyImplyLeading: false,
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
                      _fetchOrders();
                    },
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            )
          : _orders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: colors.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noOrdersYet,
                    style: TextStyle(color: colors.onSurface.withOpacity(0.6)),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchOrders,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  final order = _orders[index];
                  final status = order['status'] ?? 'Pending';
                  final amount =
                      double.tryParse(order['amount']?.toString() ?? '0') ??
                      0.0;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderDetailScreen(
                              orderId: order['id'].toString(),
                            ),
                          ),
                        );
                      },
                      leading: CircleAvatar(
                        backgroundColor: colors.primary.withOpacity(0.1),
                        child: Icon(Icons.receipt_long, color: colors.primary),
                      ),
                      title: Text(
                        l10n.orderNumber(order['id']),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            order['description'] ?? 'No description',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            PaymentFormatter.formatCurrency(amount),
                            style: TextStyle(
                              color: colors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: PaymentFormatter.getStatusColor(
                            status,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: PaymentFormatter.getStatusColor(status),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
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
