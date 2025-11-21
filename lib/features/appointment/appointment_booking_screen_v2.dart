// File: lib/features/appointment/appointment_booking_screen_v2.dart
// Complete unified booking screen for services and packages with full localization and theme support

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../app_localizations.dart';
import '../../core/providers/api_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/utils/app_logger.dart';
import '../auth/auth_wrapper.dart';
import '../payment/payment_screen.dart';
import '../appointments/appointment_detail_screen.dart';
import '../appointments/package_appointment_detail_screen.dart';

/// Unified appointment booking screen for both services and packages
class AppointmentBookingScreenV2 extends StatefulWidget {
  final Map<String, dynamic>? service;
  final Map<String, dynamic>? package;
  final String bookingType; // 'service' or 'package'

  const AppointmentBookingScreenV2({
    super.key,
    this.service,
    this.package,
    required this.bookingType,
  });

  @override
  State<AppointmentBookingScreenV2> createState() =>
      _AppointmentBookingScreenV2State();
}

class _AppointmentBookingScreenV2State
    extends State<AppointmentBookingScreenV2> {
  final _formKey = GlobalKey<FormState>();
  final _hospitalController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  File? _selectedFile;
  bool _isLoading = false;
  String? _errorMessage;
  int _dateCount = 1;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    if (widget.bookingType == 'service' && widget.service != null) {
      _hospitalController.text =
          widget.service!['description'] ?? 'Medical Service';
    } else if (widget.bookingType == 'package' && widget.package != null) {
      _hospitalController.text = widget.package!['name'] ?? 'Health Package';
      _descriptionController.text =
          widget.package!['detail']?['description'] ?? '';
    }
  }

  @override
  void dispose() {
    _hospitalController.dispose();
    _descriptionController.dispose();
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

  Future<void> _selectFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png', 'png'],
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

  String _format12Hour(TimeOfDay time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  Future<void> _bookAppointment() async {
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      setState(() {
        _errorMessage =
            l10n.selectBothDateAndTime ?? 'Please select both date and time';
      });
      return;
    }

    final isAuthenticated = await requireAuthentication(context);
    if (!isAuthenticated) {
      setState(() {
        _errorMessage =
            l10n.authenticationRequired ??
            'Authentication required to book appointments';
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

      final dateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      AppLogger.api('📅 Creating order for ${dateTime.toIso8601String()}');

      final orderResponse = await apiProvider.orders.createOrder(
        serviceId: 1,
        customerId: int.tryParse(authProvider.user?.id.toString() ?? '1') ?? 1,
        description: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : _hospitalController.text,
        date: _selectedDate?.toIso8601String().split('T')[0],
        dateCount: _dateCount,
        file: _selectedFile,
      );

      AppLogger.success('✅ Order created successfully');

      final orderId = orderResponse['data']?['id'];

      if (orderId == null) {
        throw Exception('Order created but no ID returned from API');
      }

      // Calculate amount based on type
      double orderAmount = 50.0;

      if (widget.bookingType == 'service' && widget.service != null) {
        final costPerService =
            double.tryParse(
              widget.service!['costPerService']?.toString() ?? '50.0',
            ) ??
            50.0;
        orderAmount = costPerService * _dateCount;
      } else if (widget.bookingType == 'package' && widget.package != null) {
        orderAmount =
            double.tryParse(widget.package!['price']?.toString() ?? '50.0') ??
            50.0;
      }

      AppLogger.info(
        '📦 Order ID: $orderId, Amount: $orderAmount, Type: ${widget.bookingType}',
      );

      if (mounted) {
        final paymentResult = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(
              orderId: orderId as int,
              amount: orderAmount,
              orderDescription: _hospitalController.text,
            ),
          ),
        );

        if (paymentResult == true && mounted) {
          // Navigate to appropriate detail screen
          if (widget.bookingType == 'service') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AppointmentDetailScreen(
                  appointmentData: {
                    'id': orderId,
                    'date': _selectedDate?.toIso8601String(),
                    'time': _selectedTime?.format(context),
                    'status': 'confirmed',
                    'description': _hospitalController.text,
                  },
                ),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PackageAppointmentDetailScreen(
                  appointmentData: {
                    'id': orderId,
                    'date': _selectedDate?.toIso8601String(),
                    'time': _selectedTime?.format(context),
                    'status': 'confirmed',
                    'description': _hospitalController.text,
                  },
                  packageData: widget.package!,
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      AppLogger.error('❌ Failed to create appointment', error: e);
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
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.colorScheme;
    final theme = Theme.of(context);

    final isService = widget.bookingType == 'service';
    final isPackage = widget.bookingType == 'package';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isService ? l10n.bookService : l10n.bookPackage ?? 'Book Package',
        ),
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service/Package Info Card
              if (isService && widget.service != null) ...[
                _buildServiceCard(theme, colors, themeProvider),
                const SizedBox(height: 24),
              ],

              if (isPackage && widget.package != null) ...[
                _buildPackageCard(theme, colors, themeProvider),
                const SizedBox(height: 24),
              ],

              // Hospital/Clinic field
              Text(
                l10n.hospitalClinic ?? 'Hospital/Clinic',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _hospitalController,
                decoration: InputDecoration(
                  hintText:
                      l10n.enterHospitalName ?? 'Enter hospital or clinic name',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.local_hospital),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterHospitalName ??
                        'Please enter hospital name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Description field
              Text(
                l10n.descriptionOptional ?? 'Description (Optional)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText:
                      l10n.enterAppointmentDescription ??
                      'Enter appointment description or notes',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 24),

              // Duration (Days) - Only for services
              if (isService) ...[
                Text(
                  l10n.duration ?? 'Duration (Days)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: colors.outline),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<int>(
                          value: _dateCount,
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: List.generate(30, (i) => i + 1)
                              .map(
                                (day) => DropdownMenuItem(
                                  value: day,
                                  child: Text('$day day${day > 1 ? 's' : ''}'),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _dateCount = value);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // Date selection
              Text(
                l10n.selectDate ?? 'Select Date',
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
                    border: Border.all(color: colors.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate != null
                            ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                            : l10n.selectAppointmentDate ??
                                  'Select appointment date',
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
              const SizedBox(height: 24),

              // Time selection
              Text(
                l10n.selectTime ?? 'Select Time',
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
                    border: Border.all(color: colors.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time),
                      const SizedBox(width: 12),
                      Text(
                        _selectedTime != null
                            ? _format12Hour(_selectedTime!)
                            : l10n.selectAppointmentTime ??
                                  'Select appointment time',
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
              const SizedBox(height: 24),

              // File upload
              Text(
                l10n.uploadDocument ?? 'Upload Document (Optional)',
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
                        color: colors.outline,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: colors.surface.withOpacity(0.5),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 40,
                          color: colors.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.tapToUploadFile ?? 'Tap to upload file',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.supportedFormats ?? 'PDF, DOC, DOCX, JPG, PNG',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurface.withOpacity(0.6),
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
                              l10n.fileSelected ?? 'File selected',
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

              // Book button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _bookAppointment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          l10n.bookNow ?? 'Book Now',
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
      ),
    );
  }

  Widget _buildServiceCard(
    ThemeData theme,
    ColorScheme colors,
    ThemeProvider themeProvider,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.accentColors['medical']!.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeProvider.accentColors['medical']!.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected Service',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.service!['name'] ?? 'Medical Service',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.service!['description'] ?? '',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface.withOpacity(0.7),
            ),
          ),
          if (widget.service!['costPerService'] != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'ETB ${widget.service!['costPerService']}/day',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPackageCard(
    ThemeData theme,
    ColorScheme colors,
    ThemeProvider themeProvider,
  ) {
    final packageIncludes =
        widget.package!['detail']?['includes'] as List<dynamic>? ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeProvider.accentColors['medical']!.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeProvider.accentColors['medical']!.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected Package',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.package!['name'] ?? 'Health Package',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.package!['detail']?['description'] ?? '',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'ETB ${widget.package!['price']}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (packageIncludes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Includes:',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...packageIncludes.take(3).map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.toString(),
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            if (packageIncludes.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '+${packageIncludes.length - 3} more',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
