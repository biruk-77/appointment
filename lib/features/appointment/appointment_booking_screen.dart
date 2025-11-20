// File: lib/features/appointment/appointment_booking_screen.dart
// Project Path: C:\Users\biruk\Desktop\absiniya\appointment
// Auto-Header: you feel me
// ----------------------------------------------
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/providers/api_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/utils/app_logger.dart';
import '../auth/auth_wrapper.dart';
import '../payment/payment_screen.dart';

/// Simple appointment booking screen using real backend
class AppointmentBookingScreen extends StatefulWidget {
  final Map<String, dynamic>? service;

  const AppointmentBookingScreen({super.key, this.service});

  @override
  State<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hospitalController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  File? _selectedFile;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Pre-fill hospital if service is provided
    if (widget.service != null) {
      _hospitalController.text =
          widget.service!['description'] ?? 'Medical Service';
    }
  }

  @override
  void dispose() {
    _hospitalController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
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
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );

    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  Future<void> _selectFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      AppLogger.error('Failed to pick file', error: e);
    }
  }

  void _clearFile() {
    setState(() {
      _selectedFile = null;
    });
  }

  Future<void> _bookAppointment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      setState(() {
        _errorMessage = 'Please select both date and time';
      });
      return;
    }

    // Check authentication before booking
    final isAuthenticated = await requireAuthentication(context);
    if (!isAuthenticated) {
      setState(() {
        _errorMessage = 'Authentication required to book appointments';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiProvider = Provider.of<ApiProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Combine date and time
      final dateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      AppLogger.api('ðŸ“… Creating order for ${dateTime.toIso8601String()}');

      // Create order using real backend (not appointment)
      await apiProvider.orders.createOrder(
        serviceId: 1, // Default service ID
        customerId: int.tryParse(authProvider.user?.id.toString() ?? '1') ?? 1,
        description: _hospitalController.text,
        date: _selectedDate?.toIso8601String().split(
          'T',
        )[0], // Format: "2025-11-20"
        dateCount: 1, // Default to 1 day
        file: _selectedFile, // Optional file upload
      );

      AppLogger.success('âœ… Order created successfully');

      if (mounted) {
        // Navigate to payment screen
        final paymentResult = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(
              orderId:
                  int.tryParse(widget.service?['id']?.toString() ?? '1') ?? 1,
              amount:
                  double.tryParse(
                    widget.service?['costPerService']?.toString() ?? '50.0',
                  ) ??
                  50.0,
              orderDescription: _hospitalController.text,
            ),
          ),
        );

        // If payment was successful, go back to home
        if (paymentResult == true && mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      AppLogger.error('âŒ Failed to create appointment', error: e);
      setState(() {
        _errorMessage = 'Failed to book appointment: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
        backgroundColor: const Color(0xFFF5B041),
        foregroundColor: const Color(0xFF2C5F7A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service info if provided
              if (widget.service != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5B041).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF5B041)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Service',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C5F7A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.service!['name'] ?? 'Medical Service',
                        style: theme.textTheme.bodyLarge,
                      ),
                      Text(
                        widget.service!['description'] ?? '',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      if (widget.service!['costPerService'] != null)
                        Text(
                          'Cost: ETB ${widget.service!['costPerService']}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2C5F7A),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Hospital/Clinic field
              Text(
                'Hospital/Clinic',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _hospitalController,
                decoration: const InputDecoration(
                  hintText: 'Enter hospital or clinic name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_hospital),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter hospital name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Date selection
              Text(
                'Select Date',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate != null
                            ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                            : 'Select appointment date',
                        style: TextStyle(
                          color: _selectedDate != null
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Time selection
              Text(
                'Select Time',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectTime,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time),
                      const SizedBox(width: 12),
                      Text(
                        _selectedTime != null
                            ? _selectedTime!.format(context)
                            : 'Select appointment time',
                        style: TextStyle(
                          color: _selectedTime != null
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // File upload (optional)
              Text(
                'Upload Document (Optional)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (_selectedFile == null)
                InkWell(
                  onTap: _selectFile,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.outline,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: theme.colorScheme.surface.withOpacity(0.5),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 40,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tap to upload file',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'PDF, DOC, DOCX, JPG, PNG',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.green.withOpacity(0.1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'File selected',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _selectedFile!.path.split('/').last,
                              style: theme.textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _clearFile,
                        icon: const Icon(Icons.close),
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),

              // Error message
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

              // Book appointment button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _bookAppointment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5B041),
                    foregroundColor: const Color(0xFF2C5F7A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Color(0xFF2C5F7A),
                        )
                      : const Text(
                          'Book Appointment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}





