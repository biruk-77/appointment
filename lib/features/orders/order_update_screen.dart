// File: lib/features/orders/order_update_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../app_localizations.dart';
import '../../core/providers/api_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/utils/app_logger.dart';

class OrderUpdateScreen extends StatefulWidget {
  final int orderId;
  final Map<String, dynamic> orderData;

  const OrderUpdateScreen({
    super.key,
    required this.orderId,
    required this.orderData,
  });

  @override
  State<OrderUpdateScreen> createState() => _OrderUpdateScreenState();
}

class _OrderUpdateScreenState extends State<OrderUpdateScreen> {
  late Map<String, dynamic> _orderData;
  final _descriptionController = TextEditingController();
  final _dateCountController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  File? _selectedFile;
  final ImagePicker _imagePicker = ImagePicker();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _dateCount = 1;

  @override
  void initState() {
    super.initState();
    _orderData = widget.orderData;
    _descriptionController.text = _orderData['description'] ?? '';
    _dateCount = _orderData['dateCount'] ?? 1;
    _dateCountController.text = _dateCount.toString();

    // Parse existing date if available
    if (_orderData['date'] != null &&
        _orderData['date'].toString().isNotEmpty) {
      try {
        _selectedDate = DateTime.parse(_orderData['date']);
      } catch (e) {
        AppLogger.error('Failed to parse date', error: e);
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _dateCountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 9, minute: 0),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  String _format12Hour(TimeOfDay time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  Future<void> _pickFile() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      AppLogger.error('Failed to pick file', error: e);
    }
  }

  Future<void> _updateOrder() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final apiProvider = Provider.of<ApiProvider>(context, listen: false);

      AppLogger.api('📝 Updating order: ${widget.orderId}');

      // Format date as ISO string (YYYY-MM-DD)
      final dateString = _selectedDate != null
          ? _selectedDate!.toIso8601String().split('T')[0]
          : null;

      final result = await apiProvider.orders.updateOrder(
        orderId: widget.orderId.toString(),
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
        dateCount: _dateCount > 0 ? _dateCount : null,
        date: dateString,
        file: _selectedFile,
      );

      final l10n = AppLocalizations.of(context)!;
      if (result['success'] == true) {
        AppLogger.success('✅ Order updated successfully');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('✅ Order updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate update
        }
      } else {
        throw Exception(result['message'] ?? 'Failed to update order');
      }
    } catch (e) {
      AppLogger.error('❌ Failed to update order', error: e);
      setState(() {
        _errorMessage = 'Failed to update order: ${e.toString()}';
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
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
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.editOrder),
          backgroundColor: colors.surface,
          foregroundColor: colors.onSurface,
        ),
        body: Center(child: CircularProgressIndicator(color: colors.primary)),
      );
    }

    final serviceName = _orderData['service']?['name'] ?? 'Service';
    final serviceDescription = _orderData['service']?['description'] ?? '';
    final status = _orderData['status'] ?? 'pending';
    final createdAt = _orderData['createdAt'] ?? 'N/A';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editOrder),
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: themeProvider.accentColors['medical']!.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: themeProvider.accentColors['medical']!.withOpacity(
                    0.3,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.serviceInformation,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    serviceName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    serviceDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _getStatusColor(status)),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            color: _getStatusColor(status),
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        createdAt,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Description Field
            Text(
              l10n.description,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter order description or notes',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.description),
                enabled: !_isLoading,
              ),
            ),
            const SizedBox(height: 20),

            // Date Count Field
            Text(
              'Number of Days',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _dateCountController,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _dateCount = int.tryParse(value) ?? 1;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter number of days',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.calendar_today),
                      enabled: !_isLoading,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Date Picker
            Text(
              l10n.selectDate,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _isLoading ? null : _selectDate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: colors.outline),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: colors.primary),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDate != null
                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                          : 'Select appointment date',
                      style: TextStyle(
                        color: _selectedDate != null
                            ? colors.onSurface
                            : colors.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Time Picker
            Text(
              l10n.selectTime,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _isLoading ? null : _selectTime,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: colors.outline),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, color: colors.primary),
                    const SizedBox(width: 12),
                    Text(
                      _selectedTime != null
                          ? _format12Hour(_selectedTime!)
                          : 'Select appointment time',
                      style: TextStyle(
                        color: _selectedTime != null
                            ? colors.onSurface
                            : colors.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // File Picker
            Text(
              'Attachment',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: colors.primary.withOpacity(0.3),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
                color: colors.primary.withOpacity(0.05),
              ),
              child: Column(
                children: [
                  if (_selectedFile != null) ...[
                    Icon(Icons.check_circle, color: Colors.green, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      _selectedFile!.path.split('/').last,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _pickFile,
                      icon: const Icon(Icons.edit),
                      label: const Text('Change File'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ] else ...[
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 48,
                      color: colors.primary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No file selected',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _pickFile,
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Pick File'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Error Message
            if (_errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: Text(l10n.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _updateOrder,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.check),
                    label: Text(_isLoading ? 'Updating...' : 'Update Order'),
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
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
