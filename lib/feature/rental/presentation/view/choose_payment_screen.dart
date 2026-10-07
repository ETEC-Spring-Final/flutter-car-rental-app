import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vehicle_rental_system/app/router/app_routes.dart';
import 'package:vehicle_rental_system/app/theme/app_colors.dart';
import 'package:vehicle_rental_system/app/theme/app_dimensions.dart';
import 'package:vehicle_rental_system/core/widgets/app_back_button.dart';
import 'package:vehicle_rental_system/core/widgets/app_booking_bottom_bar.dart';
import 'package:vehicle_rental_system/feature/booking/domain/entity/booking.dart';
import 'package:vehicle_rental_system/feature/booking/domain/entity/new_booking_request.dart';
import 'package:vehicle_rental_system/feature/booking/presentation/bloc/booking_bloc.dart';
import 'package:vehicle_rental_system/feature/vehicle/domain/entity/vehicle.dart';
import 'package:vehicle_rental_system/feature/rental/presentation/view/booking_confirmation_screen.dart';

class ChoosePaymentScreen extends StatefulWidget {
  final Vehicle vehicle;

  final int rentalDays;
  final double rentalPrice;
  final double servicesPrice;
  final double totalPrice;

  final Map<String, bool> selectedServices;
  final List<int> selectedServiceIds;

  final DateTime pickupDate;
  final DateTime returnDate;
  final TimeOfDay? pickupTime;
  final TimeOfDay? returnTime;
  final int pickUpLocationId;
  final int returnLocationId;
  final String pickupLocation;
  final String returnLocation;

  const ChoosePaymentScreen({
    super.key,
    required this.vehicle,
    required this.rentalDays,
    required this.rentalPrice,
    required this.servicesPrice,
    required this.totalPrice,
    required this.selectedServices,
    required this.selectedServiceIds,
    required this.pickupDate,
    required this.returnDate,
    this.pickupTime,
    this.returnTime,
    required this.pickUpLocationId,
    required this.returnLocationId,
    required this.pickupLocation,
    required this.returnLocation,
  });

  @override
  State<ChoosePaymentScreen> createState() => _ChoosePaymentScreenState();
}

class _ChoosePaymentScreenState extends State<ChoosePaymentScreen> {
  String selectedPayment = 'KHQR';

  bool _isCreating = false;

  DateTime _combine(DateTime date, TimeOfDay? time) {
    if (time == null) return date;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _payNow() async {
    if (_isCreating) return;
    setState(() => _isCreating = true);

    final startDate = _combine(widget.pickupDate, widget.pickupTime);
    final endDate = _combine(widget.returnDate, widget.returnTime);

    // Stage the rental so the QR payment screen can show what will be paid.
    // The real booking is created on the backend only AFTER the payment has
    // been scanned successfully, so an unpaid/aborted payment never produces
    // a booking -> the vehicle cannot be rented.
    final provisional = Booking(
      id: widget.vehicle.id,
      bookingNumber: 'BOOK-${DateTime.now().millisecondsSinceEpoch}',
      vehicle: widget.vehicle,
      startDate: startDate,
      endDate: endDate,
      totalDays: widget.rentalDays,
      pricePerDay: widget.vehicle.pricePerDay,
      totalPrice: widget.totalPrice,
      pickupLocation: widget.pickupLocation,
      returnLocation: widget.returnLocation,
      status: 'PENDING',
    );

    final paid = await context.push<bool>(
      AppRoutes.payment,
      extra: provisional,
    );

    if (!mounted) return;

    if (paid != true) {
      // Payment was not completed -> keep the booking uncreated.
      setState(() => _isCreating = false);
      return;
    }

    // The QR was scanned successfully. Only now create the real booking; the
    // confirmation screen is shown once the reservation actually exists, so a
    // booking can never be created without a successful payment.
    context.read<BookingBloc>().add(
      CreateBookingEvent(
        NewBookingRequest(
          vehicleId: widget.vehicle.id,
          pickUpLocationId: widget.pickUpLocationId,
          returnLocationId: widget.returnLocationId,
          pickUpDateTime: startDate,
          returnDateTime: endDate,
          serviceIds: widget.selectedServiceIds,
        ),
      ),
    );
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
          paymentMethod: selectedPayment,
          totalPrice: widget.totalPrice,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<BookingBloc, BookingState>(
      listener: (context, state) {
        if (!_isCreating) return;

        if (state is BookingCreated) {
          _openConfirmation(state.booking);
        } else if (state is BookingError) {
          setState(() => _isCreating = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.failure.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Payment Methods'),
          leading: AppBackButton(),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(AppDimensions.cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _VehiclePaymentCard(
                        vehicle: widget.vehicle,
                        rentalDays: widget.rentalDays,
                      ),

                      SizedBox(height: 20.h),

                      Text(
                        'Booking Total',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      SizedBox(height: 4.h),

                      Text(
                        'Includes rental and additional services',
                        style: theme.textTheme.bodySmall,
                      ),

                      SizedBox(height: 6.h),

                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '\$${widget.totalPrice.toStringAsFixed(2)}',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),

                      SizedBox(height: 24.h),

                      Text(
                        'Payment Method',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      SizedBox(height: 12.h),

                      _PaymentMethodTile(
                        value: 'Visa',
                        title: 'Visa •••• 4242',
                        subtitle: 'Expires 12/25',
                        icon: Icons.credit_card_outlined,
                        selected: selectedPayment == 'Visa',
                        onTap: () {
                          setState(() {
                            selectedPayment = 'Visa';
                          });
                        },
                      ),

                      SizedBox(height: 10.h),

                      _PaymentMethodTile(
                        value: 'ABA Pay',
                        title: 'ABA Pay',
                        subtitle: 'Direct mobile banking',
                        icon: Icons.account_balance_outlined,
                        selected: selectedPayment == 'ABA Pay',
                        onTap: () {
                          setState(() {
                            selectedPayment = 'ABA Pay';
                          });
                        },
                      ),

                      SizedBox(height: 10.h),

                      _PaymentMethodTile(
                        value: 'KHQR',
                        title: 'KHQR',
                        subtitle: 'Scan to pay securely',
                        icon: Icons.qr_code_2_rounded,
                        selected: selectedPayment == 'KHQR',
                        onTap: () {
                          setState(() {
                            selectedPayment = 'KHQR';
                          });
                        },
                      ),

                      SizedBox(height: 24.h),

                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.lock_outline_rounded,
                              color: theme.colorScheme.primary,
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Secure & Encrypted Payment',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 3.h),
                                  Text(
                                    'Your payment details are protected.',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Padding(
              //   padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
              //   child: SizedBox(
              //     width: double.infinity,
              //     height: 52.h,
              //     child: ElevatedButton(
              //       onPressed: _payNow,
              //       child: Row(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           const Icon(Icons.lock_outline_rounded),
              //           SizedBox(width: 8.w),
              //           Text('Pay Now \$${widget.totalPrice.toStringAsFixed(0)}'),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
        bottomNavigationBar: AppBookingBottomBar(
          label: _isCreating
              ? 'Creating booking...'
              : 'Pay Now \$${widget.totalPrice.toStringAsFixed(0)}',
          icon: Icons.lock_outline_rounded,
          onPressed: _payNow,
          enabled: !_isCreating,
        ),
      ),
    );
  }
}

class _VehiclePaymentCard extends StatelessWidget {
  final Vehicle vehicle;
  final int rentalDays;

  const _VehiclePaymentCard({required this.vehicle, required this.rentalDays});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(10.w),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: SizedBox(
                width: 80.w,
                height: 65.h,
                child: vehicle.images.isNotEmpty
                    ? Image.network(
                        vehicle.images.first.fileUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return const Icon(Icons.directions_car_outlined);
                        },
                      )
                    : Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.directions_car_outlined,
                          color: theme.colorScheme.onSurfaceVariant,
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
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  SizedBox(height: 4.h),

                  Text(
                    '$rentalDays day rental',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final String value;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.value,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final softBorder = theme.brightness == Brightness.dark
        ? AppColors.darkBorder
        : AppColors.borderLight;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: selected ? theme.colorScheme.primary : softBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: selected ? value : null,
              onChanged: (_) => onTap(),
            ),

            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon),
            ),

            SizedBox(width: 12.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(subtitle, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
