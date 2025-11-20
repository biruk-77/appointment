// File: lib/core/utils/payment_formatter.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentFormatter {
  // Private constructor
  PaymentFormatter._();

  /// Format currency to ETB (e.g., "ETB 1,200.00")
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(symbol: 'ETB ', decimalDigits: 2);
    return formatter.format(amount);
  }

  /// Format a simple date
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  /// Format date with time
  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy hh:mm a').format(date);
  }

  /// Get color based on payment/order status
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'paid':
      case 'confirmed':
        return Colors.green;
      case 'pending':
      case 'processing':
        return Colors.orange;
      case 'failed':
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Get display text for status
  static String formatStatus(String status) {
    if (status.isEmpty) return 'Unknown';
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }
}
