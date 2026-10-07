import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vehicle_rental_system/app/theme/app_colors.dart';
import 'package:vehicle_rental_system/feature/booking/domain/entity/booking.dart';
import 'package:vehicle_rental_system/feature/booking/domain/entity/new_booking_request.dart';
import 'package:vehicle_rental_system/feature/booking/presentation/bloc/booking_bloc.dart';
import 'package:vehicle_rental_system/feature/payment/presentation/view/payment_screen.dart';
import 'package:vehicle_rental_system/feature/rental/presentation/view/booking_confirmation_screen.dart';
import 'package:vehicle_rental_system/feature/vehicle/domain/entity/vehicle.dart';

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
  String _selectedPaymentMethod = 'khqr';
  bool _isCreatingBooking = false;

  DateTime _combine(DateTime date, TimeOfDay? time) {
    if (time == null) return date;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  NewBookingRequest _buildBookingRequest() {
    return NewBookingRequest(
      vehicleId: widget.vehicle.id,
      pickUpLocationId: widget.pickUpLocationId,
      returnLocationId: widget.returnLocationId,
      pickUpDateTime: _combine(widget.pickupDate, widget.pickupTime),
      returnDateTime: _combine(widget.returnDate, widget.returnTime),
      serviceIds: widget.selectedServiceIds,
    );
  }

  Booking _buildProvisionalBooking() {
    return Booking(
      id: widget.vehicle.id,
      bookingNumber: 'BOOK-${DateTime.now().millisecondsSinceEpoch}',
      vehicle: widget.vehicle,
      startDate: _combine(widget.pickupDate, widget.pickupTime),
      endDate: _combine(widget.returnDate, widget.returnTime),
      totalDays: widget.rentalDays,
      pricePerDay: widget.vehicle.pricePerDay,
      totalPrice: widget.totalPrice,
      pickupLocation: widget.pickupLocation,
      returnLocation: widget.returnLocation,
      status: 'PENDING',
    );
  }

  void _continuePayment() {
    if (_isCreatingBooking) return;

    if (_selectedPaymentMethod == 'khqr') {
      _openQrPayment();
    } else {
      _showCashPaymentDialog();
    }
  }

  void _openQrPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          booking: _buildProvisionalBooking(),
          bookingRequest: _buildBookingRequest(),
          vehicle: widget.vehicle,
          rentalDays: widget.rentalDays,
          pickupDate: widget.pickupDate,
          returnDate: widget.returnDate,
          pickupLocation: widget.pickupLocation,
          returnLocation: widget.returnLocation,
          selectedServices: widget.selectedServices,
          paymentMethod: 'KHQR',
          totalPrice: widget.totalPrice,
        ),
      ),
    );
  }

  void _showCashPaymentDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cash Payment'),
          content: const Text(
            'Please pay the rental amount at the pickup location.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                if (!mounted || _isCreatingBooking) return;

                setState(() => _isCreatingBooking = true);

                context.read<BookingBloc>().add(
                  CreateBookingEvent(_buildBookingRequest()),
                );
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
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
          paymentMethod: 'Cash',
          totalPrice: widget.totalPrice,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingBloc, BookingState>(
      listener: (context, state) {
        if (!_isCreatingBooking) return;

        if (state is BookingCreated) {
          _openConfirmation(state.booking);
        } else if (state is BookingError) {
          setState(() => _isCreatingBooking = false);

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.failure.message)));
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text(
            'Choose Payment',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAmountCard(),
                      SizedBox(height: 28.h),

                      Text(
                        'Payment Method',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      SizedBox(height: 12.h),

                      _buildPaymentMethod(
                        value: 'khqr',
                        title: 'KHQR / Bakong',
                        subtitle: 'Pay securely using KHQR or Bakong',
                        icon: Icons.qr_code_2_rounded,
                      ),

                      SizedBox(height: 12.h),

                      _buildPaymentMethod(
                        value: 'cash',
                        title: 'Cash',
                        subtitle: 'Pay at the vehicle pickup location',
                        icon: Icons.payments_outlined,
                      ),

                      SizedBox(height: 24.h),

                      _buildSecurityInfo(),
                    ],
                  ),
                ),
              ),

              _buildBottomButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        color: Theme.of(context).cardColor,
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Amount',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
          ),
          SizedBox(height: 8.h),
          Text(
            '\$${widget.totalPrice.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 30.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            '${widget.vehicle.brand} ${widget.vehicle.model}'
            ' • ${widget.rentalDays} ${widget.rentalDays == 1 ? 'day' : 'days'}',
            style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final bool isSelected = _selectedPaymentMethod == value;

    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: Theme.of(context).cardColor,
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Colors.grey.withValues(alpha: 0.18),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14.r),
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.08),
              ),
              child: Icon(
                icon,
                size: 26.sp,
                color: isSelected ? AppColors.primary : Colors.grey.shade600,
              ),
            ),

            SizedBox(width: 14.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 8.w),

            Container(
              width: 22.w,
              height: 22.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10.w,
                        height: 10.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityInfo() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        color: Colors.green.withValues(alpha: 0.08),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline_rounded, size: 22.sp, color: Colors.green),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Your payment information is handled securely. '
              'For KHQR/Bakong, scan the QR code using your supported banking app.',
              style: TextStyle(
                fontSize: 12.sp,
                height: 1.5,
                color: Colors.green.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52.h,
        child: ElevatedButton(
          onPressed: _isCreatingBooking ? null : _continuePayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
            elevation: 0,
          ),
          child: _isCreatingBooking
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 22.w,
                      height: 22.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    const Text('Creating booking...'),
                  ],
                )
              : Text(
                  _selectedPaymentMethod == 'khqr'
                      ? 'Continue to Payment'
                      : 'Confirm Payment',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}
