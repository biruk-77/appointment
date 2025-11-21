// File: lib/features/orders/orders_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_localizations.dart';
import '../../core/providers/api_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/utils/app_logger.dart';
import '../../core/utils/payment_formatter.dart';
import 'order_detail_screen.dart';
import 'order_update_screen.dart';

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

  // Helper to extract the image URL if it exists
  String? _getOrderImageUrl(Map<String, dynamic> order) {
    // 1. Check fileUrl
    final fileUrl = order['fileUrl'];
    if (fileUrl != null && fileUrl.toString().isNotEmpty) {
      return fileUrl.toString();
    }

    // 2. Check file path
    final fileData = order['file'];
    if (fileData != null && fileData.toString().isNotEmpty) {
      return 'https://appointment.shebabingo.com/${fileData.toString()}';
    }

    // 3. Check service image
    final serviceImage = order['service']?['image'];
    if (serviceImage != null && serviceImage.toString().isNotEmpty) {
      return serviceImage.toString();
    }

    return null; // No image found
  }

  Future<void> _fetchOrders() async {
    try {
      final apiProvider = Provider.of<ApiProvider>(context, listen: false);
      final result = await apiProvider.orders.getMyOrders();

      if (mounted) {
        setState(() {
          final data = result['data'];
          if (data != null) {
            if (data is List) {
              _orders = data;
            } else if (data is Map && data['orders'] != null) {
              _orders = data['orders'];
            } else {
              _orders = [];
            }
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
                  final status = order['status'] ?? 'pending';
                  final service =
                      order['service'] as Map<String, dynamic>? ?? {};
                  final serviceDesc =
                      service['description'] as String? ?? 'Service';
                  final dateCount = order['dateCount'] ?? 1;
                  final createdAt = order['createdAt'] as String? ?? '';
                  final imageUrl = _getOrderImageUrl(order);

                  // Helper for date formatting
                  String getRelativeDate(String dateString) {
                    try {
                      final date = DateTime.parse(dateString);
                      final now = DateTime.now();
                      final diff = now.difference(date);
                      if (diff.inDays == 0) return 'Today';
                      if (diff.inDays == 1) return '1 day ago';
                      if (diff.inDays < 7) return '${diff.inDays} days ago';
                      if (diff.inDays < 30) {
                        final weeks = (diff.inDays / 7).floor();
                        return '$weeks week${weeks > 1 ? 's' : ''} ago';
                      }
                      final months = (diff.inDays / 30).floor();
                      return '$months month${months > 1 ? 's' : ''} ago';
                    } catch (e) {
                      return 'N/A';
                    }
                  }

                  // --- CASE 1: ORDER HAS IMAGE (Show Big Expanded Card) ---
                  if (imageUrl != null) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 20),
                      elevation: 4,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OrderDetailScreen(orderData: order),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Big Image
                            SizedBox(
                              height: 160,
                              width: double.infinity,
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: colors.surfaceContainerHighest,
                                  );
                                },
                              ),
                            ),
                            // Details
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        l10n.orderNumber(order['id']),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: colors.onSurface,
                                        ),
                                      ),
                                      _buildStatusBadge(status),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    serviceDesc,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: colors.onSurface.withOpacity(0.8),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 14,
                                        color: colors.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '$dateCount day${dateCount > 1 ? 's' : ''} • ${getRelativeDate(createdAt)}',
                                        style: TextStyle(
                                          color: colors.primary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                OrderUpdateScreen(
                                                  orderId: order['id'] ?? 0,
                                                  orderData: order,
                                                ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(Icons.edit),
                                      label: Text(l10n.edit),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: colors.primary,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // --- CASE 2: NO IMAGE (Show Normal ListTile) ---
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: colors.primary.withOpacity(
                                  0.1,
                                ),
                                child: Icon(
                                  Icons.receipt_long,
                                  color: colors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.orderNumber(order['id']),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      serviceDesc,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: colors.onSurface.withOpacity(
                                          0.7,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildStatusBadge(status),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '$dateCount day${dateCount > 1 ? 's' : ''} • ${getRelativeDate(createdAt)}',
                            style: TextStyle(
                              color: colors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            OrderDetailScreen(orderData: order),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.visibility),
                                  label: Text(l10n.viewDetails),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => OrderUpdateScreen(
                                          orderId: order['id'] ?? 0,
                                          orderData: order,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.edit),
                                  label: Text(l10n.edit),
                                  style: ElevatedButton.styleFrom(
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
                  );
                },
              ),
            ),
    );
  }

  // Helper for status badge to avoid code duplication
  Widget _buildStatusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: PaymentFormatter.getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        (status.isEmpty ? 'pending' : status).toUpperCase(),
        style: TextStyle(
          color: PaymentFormatter.getStatusColor(status),
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}
