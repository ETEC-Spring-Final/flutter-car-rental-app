import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:vehicle_rental_system/core/constants/app_constants.dart';
import 'package:vehicle_rental_system/core/widgets/app_back_button.dart';
import 'package:vehicle_rental_system/feature/booking/domain/entity/booking.dart';
import 'package:vehicle_rental_system/feature/booking/domain/entity/new_booking_request.dart';
import 'package:vehicle_rental_system/feature/booking/presentation/bloc/booking_bloc.dart';
import 'package:vehicle_rental_system/feature/rental/presentation/bloc/rental_bloc.dart';
import 'package:vehicle_rental_system/feature/rental/presentation/bloc/rental_event.dart';
import 'package:vehicle_rental_system/feature/rental/presentation/bloc/rental_state.dart';
import 'package:vehicle_rental_system/feature/rental/presentation/view/booking_confirmation_screen.dart';
import 'package:vehicle_rental_system/feature/vehicle/domain/entity/vehicle.dart';
import 'package:vehicle_rental_system/feature/vehicle/presentation/bloc/vehicle_bloc.dart';

import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_state.dart';

class PaymentScreen extends StatefulWidget {
  final Booking booking;
  final NewBookingRequest? bookingRequest;

  final Vehicle vehicle;
  final int rentalDays;

  final DateTime pickupDate;
  final DateTime returnDate;

  final String pickupLocation;
  final String returnLocation;

  final Map<String, bool> selectedServices;

  final String paymentMethod;
  final double totalPrice;

  const PaymentScreen({
    super.key,
    required this.booking,
    this.bookingRequest,
    required this.vehicle,
    required this.rentalDays,
    required this.pickupDate,
    required this.returnDate,
    required this.pickupLocation,
    required this.returnLocation,
    required this.selectedServices,
    required this.paymentMethod,
    required this.totalPrice,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  Timer? _timer;

  Timer? _checkTimer;

  int _remainingSeconds = 300;

  String? _qr;
  String? _md5;

  bool _paymentSuccess = false;

  bool _manualCheckRequested = false;

  bool _isCreatingBooking = false;

  @override
  void initState() {
    super.initState();

    context.read<PaymentBloc>().add(
      CreateQrEvent(amount: widget.booking.totalPrice),
    );

    // Fetch the vehicle + rental details from the Spring Boot API.
    context.read<VehicleBloc>().add(GetVehicleById(widget.booking.vehicle.id));

    context.read<RentalBloc>().add(const GetUserRentalsEvent());

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        timer.cancel();
        _checkTimer?.cancel();
        return;
      }

      if (mounted) {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  String get _remainingTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  /// Polls the backend automatically once the QR is generated so the booking
  /// is marked as paid as soon as the user completes the scan in the Bakong
  /// app, without requiring them to tap "Check Payment".
  void _startAutoCheck() {
    _checkTimer?.cancel();

    _checkPayment(auto: true);

    _checkTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _checkPayment(auto: true);
    });
  }

  void _checkPayment({bool auto = false}) {
    if (_md5 == null || _paymentSuccess || _remainingSeconds <= 0) return;

    _manualCheckRequested = !auto;

    context.read<PaymentBloc>().add(CheckPaymentEvent(md5: _md5!));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _checkTimer?.cancel();
    super.dispose();
  }

  void _openConfirmation(Booking booking) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => BookingConfirmationScreen(
          createdBooking: booking,
          initialPaid: true,
          vehicle: widget.vehicle,
          rentalDays: widget.rentalDays,
          pickupDate: widget.pickupDate,
          returnDate: widget.returnDate,
          pickupLocation: widget.pickupLocation,
          returnLocation: widget.returnLocation,
          selectedServices: widget.selectedServices,
          paymentMethod: widget.paymentMethod,
          totalPrice: widget.totalPrice,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MultiBlocListener(
      listeners: [
        BlocListener<PaymentBloc, PaymentState>(
          listener: (context, state) {
            if (state is QrCreated) {
              setState(() {
                _qr = state.response.qr;
                _md5 = state.response.md5;
              });

              _startAutoCheck();
            }

            if (state is PaymentSuccess) {
              final request = widget.bookingRequest;

              setState(() {
                _paymentSuccess = true;
                _isCreatingBooking = request != null;
              });

              _timer?.cancel();
              _checkTimer?.cancel();

              _manualCheckRequested = false;

              if (request == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment successful')),
                );

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) Navigator.of(context).pop(true);
                });

                return;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payment successful. Creating booking...'),
                ),
              );

              // IMPORTANT:
              // Create the real booking ONLY after payment succeeds.
              context.read<BookingBloc>().add(CreateBookingEvent(request));
            }

            if (state is PaymentFailure) {
              if (_manualCheckRequested) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }

              _manualCheckRequested = false;
            }
          },
        ),

        BlocListener<BookingBloc, BookingState>(
          listener: (context, state) {
            if (state is BookingCreated) {
              setState(() {
                _isCreatingBooking = false;
              });

              // Payment screen is replaced by confirmation screen.
              _openConfirmation(state.booking);
            }

            if (state is BookingError) {
              setState(() {
                _isCreatingBooking = false;
              });

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.failure.message)));
            }
          },
        ),
      ],

      child: Scaffold(
        appBar: AppBar(
          leading: AppBackButton(),
          title: const Text('Payment'),
          centerTitle: true,
        ),

        body: BlocBuilder<PaymentBloc, PaymentState>(
          builder: (context, state) {
            if (state is PaymentLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  _buildHeader(theme),

                  SizedBox(height: 20.h),

                  _buildAmount(theme),

                  SizedBox(height: 20.h),

                  _buildQrCard(theme),

                  SizedBox(height: 20.h),

                  _buildDetails(theme),

                  SizedBox(height: 20.h),

                  _buildInstructions(theme),

                  SizedBox(height: 20.h),

                  if (_md5 != null) _buildPaymentId(theme),

                  SizedBox(height: 100.h),
                ],
              ),
            );
          },
        ),

        bottomNavigationBar: _buildBottomButton(theme),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Icon(
          Icons.account_balance_wallet_rounded,
          size: 50.sp,
          color: theme.colorScheme.primary,
        ),

        SizedBox(height: 10.h),

        Text(
          'Pay with Bakong',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: 5.h),

        Text(
          'Scan the QR code using your Bakong app',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildDetails(ThemeData theme) {
    return BlocBuilder<VehicleBloc, VehicleState>(
      builder: (context, vehicleState) {
        final vehicle =
            vehicleState is VehicleLoaded && vehicleState.vehicles.isNotEmpty
            ? vehicleState.vehicles.first
            : widget.booking.vehicle;

        return BlocBuilder<RentalBloc, RentalState>(
          builder: (context, rentalState) {
            return Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailLabel(theme, 'Vehicle'),

                  SizedBox(height: 8.h),

                  Row(
                    children: [
                      if (vehicle.images.isNotEmpty) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.r),
                          child: SizedBox(
                            width: 72.w,
                            height: 56.h,
                            child: Image.network(
                              vehicle.images.first.fileUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Icon(
                                Icons.directions_car_outlined,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${vehicle.brand} ${vehicle.model}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              vehicle.licensePlate,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '\$${vehicle.pricePerDay.toStringAsFixed(0)} /day',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  Divider(height: 24.h),

                  _detailLabel(theme, 'Rental'),

                  SizedBox(height: 8.h),

                  if (rentalState is RentalLoaded &&
                      rentalState.rentals.isNotEmpty)
                    _buildRentalRows(theme, rentalState.rentals)
                  else if (rentalState is RentalLoading)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Center(
                        child: SizedBox(
                          height: 18.w,
                          width: 18.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    )
                  else
                    _buildBookingRows(theme),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRentalRows(ThemeData theme, List rentals) {
    final matching = rentals
        .where((r) => r.vehicleId == widget.booking.vehicle.id)
        .toList();

    final rental = matching.isNotEmpty ? matching.first : rentals.first;

    return Column(
      children: [
        _detailRow(theme, 'Status', rental.status),
        if (rental.pickUpDateTime != null)
          _detailRow(theme, 'Pick-up', _formatDateTime(rental.pickUpDateTime!)),
        if (rental.expectedReturnDateTime != null)
          _detailRow(
            theme,
            'Return',
            _formatDateTime(rental.expectedReturnDateTime!),
          ),
        _detailRow(
          theme,
          'Total',
          '\$${rental.totalPrice.toStringAsFixed(2)}',
          emphasize: true,
        ),
      ],
    );
  }

  Widget _buildBookingRows(ThemeData theme) {
    final booking = widget.booking;

    return Column(
      children: [
        _detailRow(theme, 'Status', booking.status),
        _detailRow(theme, 'Pick-up', _formatDateTime(booking.startDate)),
        _detailRow(theme, 'Return', _formatDateTime(booking.endDate)),
        _detailRow(
          theme,
          'Total',
          '\$${booking.totalPrice.toStringAsFixed(2)}',
          emphasize: true,
        ),
      ],
    );
  }

  String _formatDateTime(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$month/$day/${date.year} • $hour:$minute';
  }

  Widget _detailLabel(ThemeData theme, String text) {
    return Text(
      text.toUpperCase(),
      style: theme.textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 1.1,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
      ),
    );
  }

  Widget _detailRow(
    ThemeData theme,
    String label,
    String value, {
    bool emphasize = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
              color: emphasize
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmount(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        children: [
          Text(
            'Amount to Pay',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),

          SizedBox(height: 5.h),

          Text(
            '\$${widget.booking.totalPrice.toStringAsFixed(2)}',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrCard(ThemeData theme) {
    final expired = _remainingSeconds <= 0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Text(
            expired ? 'QR Code Expired' : 'Scan QR Code',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 15.h),

          if (_qr != null)
            Opacity(
              opacity: expired ? 0.3 : 1,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  QrImageView(
                    data: _qr!,
                    size: 250.w,
                    version: QrVersions.auto,
                    backgroundColor: Colors.white,
                  ),

                  // Bakong logo
                  ClipRRect(
                    borderRadius: BorderRadius.circular(50.r),
                    child: Container(
                      width: 45.w,
                      height: 45.w,
                      padding: EdgeInsets.all(3.w),
                      color: Colors.white,
                      child: Image.asset(
                        AppConstants.bakongIcon,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              height: 250.w,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.blue),
              ),
            ),

          SizedBox(height: 15.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer_outlined, size: 20.sp, color: Colors.blue),

              SizedBox(width: 6.w),

              Text(
                expired ? 'Expired' : 'Expires in $_remainingTime',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How to pay',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 12.h),

          _step(theme, '1', 'Open your Bakong mobile app'),

          _step(theme, '2', 'Scan the QR code above'),

          _step(theme, '3', 'Confirm the payment in your app'),

          _step(theme, '4', 'Tap "Check Payment" below'),
        ],
      ),
    );
  }

  Widget _step(ThemeData theme, String number, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary,
            ),
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          SizedBox(width: 10.w),

          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildPaymentId(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment ID',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),

                SizedBox(height: 5.h),

                Text(
                  _md5!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _md5!));
            },
            icon: const Icon(Icons.copy),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(ThemeData theme) {
    return SafeArea(
      minimum: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 15.h),
      child: SizedBox(
        height: 52.h,
        child: ElevatedButton(
          onPressed:
              _md5 == null ||
                  _paymentSuccess ||
                  _isCreatingBooking ||
                  _remainingSeconds <= 0
              ? null
              : () => _checkPayment(auto: false),

          child: _isCreatingBooking
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text('Creating Booking...'),
                  ],
                )
              : _paymentSuccess
              ? const Text('Payment Completed')
              : const Text('Check Payment'),
        ),
      ),
    );
  }
}
