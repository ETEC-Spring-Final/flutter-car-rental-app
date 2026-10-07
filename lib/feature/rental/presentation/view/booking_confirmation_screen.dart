import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vehicle_rental_system/app/router/app_routes.dart';
import 'package:vehicle_rental_system/app/theme/app_dimensions.dart';
import 'package:vehicle_rental_system/core/widgets/app_booking_bottom_bar.dart';
import 'package:vehicle_rental_system/feature/booking/domain/entity/booking.dart';
import 'package:vehicle_rental_system/feature/booking/presentation/bloc/booking_bloc.dart';
import 'package:vehicle_rental_system/feature/vehicle/domain/entity/vehicle.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final VoidCallback? onBookingTap;
  final Booking? createdBooking;
  final bool initialPaid;
  final Vehicle vehicle;
  final int rentalDays;
  final DateTime pickupDate;
  final DateTime returnDate;
  final String pickupLocation;
  final String returnLocation;
  final Map<String, bool> selectedServices;
  final String paymentMethod;
  final double totalPrice;

  const BookingConfirmationScreen({
    super.key,
    this.onBookingTap,
    this.createdBooking,
    this.initialPaid = false,
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
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  bool _qrOpened = false;

  bool _isPaid = false;

  // ---------------------------------------------------------------------------
  // FORMATTERS
  // ---------------------------------------------------------------------------

  List<String> get _selectedServiceNames {
    return widget.selectedServices.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  // ---------------------------------------------------------------------------
  // LIFECYCLE
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _isPaid = widget.initialPaid;

    // Open the QR payment screen automatically once the booking is created,
    // unless the payment already completed before this screen was shown.
    if (!widget.initialPaid) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openQrIfReady());
    }
  }

  // ---------------------------------------------------------------------------
  // ACTIONS
  // ---------------------------------------------------------------------------

  /// Booking produced by [BookingBloc], or null while it is still loading.
  Booking? get _createdBooking {
    if (widget.createdBooking != null) return widget.createdBooking;

    final state = context.read<BookingBloc>().state;
    if (state is BookingCreated) return state.booking;

    // Fall back to an in-memory booking so the QR payment screen can be
    // reached even when the Spring `/bookings` endpoint is not wired up.
    return Booking(
      id: widget.vehicle.id,
      bookingNumber: 'BOOK-${DateTime.now().millisecondsSinceEpoch}',
      vehicle: widget.vehicle,
      startDate: widget.pickupDate,
      endDate: widget.returnDate,
      totalDays: widget.rentalDays,
      pricePerDay: widget.vehicle.pricePerDay,
      totalPrice: widget.totalPrice,
      pickupLocation: widget.pickupLocation,
      returnLocation: widget.returnLocation,
      status: 'PENDING',
    );
  }

  void _openQrIfReady() {
    if (widget.initialPaid) return;

    final booking = _createdBooking;
    if (booking != null) {
      _openQr(booking);
    }
  }

  /// Pushes the QR payment screen (which generates the Bakong QR) exactly once.
  /// When the user completes the scan and payment succeeds, the payment screen
  /// pops back with `true` so the booking is marked as paid.
  void _openQr(Booking? booking) {
    if (!mounted || _qrOpened) return;
    _qrOpened = true;
    context.push(AppRoutes.payment, extra: booking).then((result) {
      if (!mounted) return;
      setState(() {
        if (result == true) _isPaid = true;
        _qrOpened = false;
      });
    });
  }

  void _finish(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  void _viewBookings(BuildContext context) {
    if (!mounted) return;

    // Make sure the booking list reflects the newly created booking, then
    // open the Booking tab inside the main shell so the bottom navigation
    // (Home / Booking / Profile...) stays available.
    context.read<BookingBloc>().add(const LoadBookingsEvent(refresh: true));
    widget.onBookingTap?.call();

    final router = GoRouter.of(context);
    Navigator.of(context).popUntil((route) => route.isFirst);
    router.go(AppRoutes.home, extra: 2);
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final services = _selectedServiceNames;

    return BlocListener<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state is BookingCreated) {
          _openQrIfReady();
        }
      },
      child: Scaffold(
        backgroundColor: colors.surface,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _isPaid
                  ? _SuccessHeader(onDone: () => _finish(context))
                  : _PaymentPromptHeader(onPay: () => _openQr(_createdBooking)),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.chipHorizontalPadding,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _ConfirmationCard(
                    title: _isPaid ? 'Booking Confirmed' : 'Booking Placed',
                    message: _isPaid
                        ? 'Your reservation has been placed successfully. '
                              'A confirmation has been sent to your registered contact.'
                        : 'We received your booking. Complete the QR payment to confirm it.',
                    icon: _isPaid
                        ? Icons.verified_rounded
                        : Icons.schedule_rounded,
                    iconColor: colors.primary,
                  ),
                  SizedBox(height: 14.h),
                  _VehicleSummaryCard(vehicle: widget.vehicle),
                  SizedBox(height: 14.h),
                  _TripDetailsCard(
                    rentalDays: widget.rentalDays,
                    pickupDate: widget.pickupDate,
                    returnDate: widget.returnDate,
                    pickupLocation: widget.pickupLocation,
                    returnLocation: widget.returnLocation,
                  ),
                  SizedBox(height: 14.h),
                  _PaymentSummaryCard(
                    paymentMethod: widget.paymentMethod,
                    totalPrice: widget.totalPrice,
                    isPaid: _isPaid,
                  ),
                  if (!_isPaid) ...[
                    SizedBox(height: 14.h),
                    _QrPaymentCard(onTap: () => _openQr(_createdBooking)),
                  ],
                  if (services.isNotEmpty) ...[
                    SizedBox(height: 14.h),
                    _ServicesCard(services: services),
                  ],
                  SizedBox(height: 20.h),
                ]),
              ),
            ),
          ],
        ),
        bottomNavigationBar: AppBookingBottomBar(
          label: _isPaid ? 'View My Bookings' : 'Pay Now',
          icon: _isPaid ? Icons.receipt_long_rounded : Icons.qr_code_2_rounded,
          onPressed: _isPaid
              ? () => _viewBookings(context)
              : () => _openQr(_createdBooking),
        ),
      ),
    );
  }
}

// =============================================================================
// SUCCESS HEADER
// =============================================================================

class _SuccessHeader extends StatelessWidget {
  const _SuccessHeader({required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 60.h, 20.w, 32.h),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32.r),
          bottomRight: Radius.circular(32.r),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_rounded,
              size: 56.sp,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Thank You!',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Your booking is complete',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PAYMENT PROMPT HEADER (shown until the user completes the QR scan)
// =============================================================================

class _PaymentPromptHeader extends StatelessWidget {
  const _PaymentPromptHeader({required this.onPay});

  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 60.h, 20.w, 32.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primary, colors.tertiary],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32.r),
          bottomRight: Radius.circular(32.r),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.qr_code_2_rounded,
              size: 56.sp,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Almost There!',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Complete the QR payment to confirm your booking',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          SizedBox(height: 18.h),
          FilledButton.icon(
            onPressed: onPay,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: colors.primary,
            ),
            icon: const Icon(Icons.qr_code_scanner_rounded),
            label: const Text('Pay Now'),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// CONFIRMATION CARD
// =============================================================================

class _ConfirmationCard extends StatelessWidget {
  const _ConfirmationCard({
    required this.title,
    required this.message,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(color: colors.outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 22.sp, color: iconColor),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SECTION CARD WRAPPER
// =============================================================================

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(color: colors.outline),
      ),
      child: child,
    );
  }
}

// =============================================================================
// SECTION TITLE
// =============================================================================

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 17.sp, color: colors.primary),
        ),
        SizedBox(width: 10.w),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// VEHICLE SUMMARY CARD
// =============================================================================

class _VehicleSummaryCard extends StatelessWidget {
  const _VehicleSummaryCard({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return _SectionCard(
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: SizedBox(
              width: 76.w,
              height: 62.h,
              child: Image.network(
                //vehicle.images.isNotEmpty ? vehicle.images.first : '',
                vehicle.images.isNotEmpty ? vehicle.images.first.fileUrl : '',
                fit: BoxFit.cover,
                errorBuilder: (_, _, e) => Container(
                  color: colors.surfaceContainerHighest,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.directions_car_rounded,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${vehicle.brand} ${vehicle.model}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.local_taxi_rounded,
                      size: 14.sp,
                      color: colors.onSurfaceVariant,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${vehicle.type} • ${vehicle.yearOfManufacture}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  vehicle.licensePlate,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// TRIP DETAILS CARD
// =============================================================================

class _TripDetailsCard extends StatelessWidget {
  const _TripDetailsCard({
    required this.rentalDays,
    required this.pickupDate,
    required this.returnDate,
    required this.pickupLocation,
    required this.returnLocation,
  });

  final int rentalDays;
  final DateTime pickupDate;
  final DateTime returnDate;
  final String pickupLocation;
  final String returnLocation;

  String _format(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(icon: Icons.route_rounded, title: 'Trip Details'),
          SizedBox(height: 16.h),
          _InfoRow(
            icon: Icons.event_available_rounded,
            label: 'Rental Duration',
            value: '$rentalDays ${rentalDays == 1 ? 'day' : 'days'}',
          ),
          SizedBox(height: 14.h),
          _InfoRow(
            icon: Icons.logout_rounded,
            label: 'Pick-up',
            value: '${_format(pickupDate)} • $pickupLocation',
          ),
          SizedBox(height: 14.h),
          _InfoRow(
            icon: Icons.login_rounded,
            label: 'Return',
            value: '${_format(returnDate)} • $returnLocation',
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PAYMENT SUMMARY CARD
// =============================================================================

class _PaymentSummaryCard extends StatelessWidget {
  const _PaymentSummaryCard({
    required this.paymentMethod,
    required this.totalPrice,
    required this.isPaid,
  });

  final String paymentMethod;
  final double totalPrice;
  final bool isPaid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(icon: Icons.payments_rounded, title: 'Payment'),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                paymentMethod,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '\$${totalPrice.toStringAsFixed(2)}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: (isPaid ? colors.primary : colors.error).withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPaid
                        ? Icons.check_circle_rounded
                        : Icons.schedule_rounded,
                    size: 14.sp,
                    color: isPaid ? colors.primary : colors.error,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    isPaid ? 'Paid' : 'Payment Pending',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isPaid ? colors.primary : colors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// QR PAYMENT CARD
// =============================================================================

class _QrPaymentCard extends StatelessWidget {
  const _QrPaymentCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(AppDimensions.cardPadding),
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          border: Border.all(color: colors.primary.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: colors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.qr_code_2_rounded,
                size: 24.sp,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bakong QR Payment',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Generate a KHQR code to complete payment',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: colors.primary),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// SERVICES CARD
// =============================================================================

class _ServicesCard extends StatelessWidget {
  const _ServicesCard({required this.services});

  final List<String> services;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.miscellaneous_services_rounded,
            title: 'Additional Services',
          ),
          SizedBox(height: 14.h),
          ...services.map(
            (service) => Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 16.sp,
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      service,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// INFO ROW
// =============================================================================

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18.sp, color: colors.primary),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
