import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vehicle_rental_system/app/theme/app_colors.dart';
import 'package:vehicle_rental_system/app/theme/app_dimensions.dart';
import 'package:vehicle_rental_system/core/di/injection_container.dart';
import 'package:vehicle_rental_system/core/widgets/app_back_button.dart';
import 'package:vehicle_rental_system/core/widgets/app_booking_bottom_bar.dart';
import 'package:vehicle_rental_system/core/widgets/app_loading.dart';
import 'package:vehicle_rental_system/feature/booking/domain/entity/additional_service.dart';
import 'package:vehicle_rental_system/feature/booking/domain/usecase/get_additional_services.dart';
import 'package:vehicle_rental_system/feature/vehicle/domain/entity/vehicle.dart';
import 'package:vehicle_rental_system/feature/rental/presentation/view/choose_payment_screen.dart';

class AdditionalServicesScreen extends StatefulWidget {
  final Vehicle vehicle;

  final DateTime pickupDate;
  final DateTime returnDate;

  final TimeOfDay pickupTime;
  final TimeOfDay returnTime;

  final int pickupLocationId;
  final int returnLocationId;

  final String pickupLocation;
  final String returnLocation;

  const AdditionalServicesScreen({
    super.key,
    required this.vehicle,
    required this.pickupDate,
    required this.returnDate,
    required this.pickupTime,
    required this.returnTime,
    required this.pickupLocationId,
    required this.returnLocationId,
    required this.pickupLocation,
    required this.returnLocation,
  });

  @override
  State<AdditionalServicesScreen> createState() =>
      _AdditionalServicesScreenState();
}

class _AdditionalServicesScreenState extends State<AdditionalServicesScreen> {
  // ---------------------------------------------------------------------------
  // SERVICES
  // ---------------------------------------------------------------------------

  List<AdditionalService> _services = const [];
  final Set<int> _selectedIds = {};

  bool _isLoadingServices = true;
  String? _servicesError;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoadingServices = true;
      _servicesError = null;
    });

    final result = await sl<GetAdditionalServices>().call();

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isLoadingServices = false;
          _servicesError = failure.message;
        });
      },
      (services) {
        setState(() {
          _isLoadingServices = false;
          _services = services;
        });
      },
    );
  }

  void _toggle(AdditionalService service, bool selected) {
    setState(() {
      if (selected) {
        _selectedIds.add(service.id);
      } else {
        _selectedIds.remove(service.id);
      }
    });
  }

  AdditionalService? _serviceById(int id) {
    for (final service in _services) {
      if (service.id == id) return service;
    }
    return null;
  }

  Map<String, bool> get selectedServices {
    return {
      for (final service in _services)
        service.name: _selectedIds.contains(service.id),
    };
  }

  List<int> get selectedServiceIds => _selectedIds.toList();

  // ---------------------------------------------------------------------------
  // PRICE CALCULATIONS
  // ---------------------------------------------------------------------------

  int get rentalDays {
    final days = widget.returnDate.difference(widget.pickupDate).inDays;

    return days <= 0 ? 1 : days;
  }

  double get rentalPrice {
    return widget.vehicle.pricePerDay * rentalDays;
  }

  double get servicesPrice {
    double total = 0;

    for (final id in _selectedIds) {
      final service = _serviceById(id);
      if (service != null) {
        total += service.price;
      }
    }

    return total;
  }

  double get totalPrice {
    return rentalPrice + servicesPrice;
  }

  // ---------------------------------------------------------------------------
  // NAVIGATION
  // ---------------------------------------------------------------------------

  void _continueToPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChoosePaymentScreen(
          vehicle: widget.vehicle,
          rentalDays: rentalDays,
          rentalPrice: rentalPrice,
          servicesPrice: servicesPrice,
          totalPrice: totalPrice,
          selectedServices: selectedServices,
          selectedServiceIds: selectedServiceIds,
          pickupDate: widget.pickupDate,
          returnDate: widget.returnDate,
          pickupTime: widget.pickupTime,
          returnTime: widget.returnTime,
          pickUpLocationId: widget.pickupLocationId,
          returnLocationId: widget.returnLocationId,
          pickupLocation: widget.pickupLocation,
          returnLocation: widget.returnLocation,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,

      // -----------------------------------------------------------------------
      // APP BAR
      // -----------------------------------------------------------------------
      appBar: AppBar(
        title: const Text('Additional Services'),
        leading: AppBackButton(),
      ),

      // -----------------------------------------------------------------------
      // BODY
      // -----------------------------------------------------------------------
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),

          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.chipHorizontalPadding,
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),

              //SizedBox(height: 16.h),
              Text(
                'Enhance your rental experience',
                style: theme.textTheme.bodyMedium,
              ),

              SizedBox(height: 4.h),

              Text(
                'Choose optional add-ons.',
                style: theme.textTheme.bodySmall,
              ),

              SizedBox(height: 18.h),

              // -----------------------------------------------------------------
              // ORDER SUMMARY
              // -----------------------------------------------------------------
              _OrderSummary(
                rentalPrice: rentalPrice,
                servicesPrice: servicesPrice,
                totalPrice: totalPrice,
                rentalDays: rentalDays,
              ),

              Divider(),

              SizedBox(height: 16.h),

              // -----------------------------------------------------------------
              // SERVICES
              // -----------------------------------------------------------------
              if (_isLoadingServices)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.h),
                  child: const Center(child: AppLoading()),
                )
              else if (_servicesError != null)
                _ServicesError(message: _servicesError!, onRetry: _loadServices)
              else if (_services.isEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.h),
                  child: Center(
                    child: Text(
                      'No additional services are available right now.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                )
              else
                ..._services.map(
                  (service) => Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: _ServiceTile(
                      service: service,
                      selected: _selectedIds.contains(service.id),
                      onChanged: (value) => _toggle(service, value),
                    ),
                  ),
                ),

              // Space at the bottom so content does not touch
              // the fixed bottom button.
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),

      // -----------------------------------------------------------------------
      // FIXED BOTTOM BUTTON
      // -----------------------------------------------------------------------
      bottomNavigationBar: AppBookingBottomBar(
        label: "Confirm Booking",
        icon: Icons.check_rounded,
        onPressed: _continueToPayment,
        enabled: true,
      ),
    );
  }
}

// =============================================================================
// SERVICES ERROR
// =============================================================================

class _ServicesError extends StatelessWidget {
  const _ServicesError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        children: [
          Icon(
            Icons.extension_off_rounded,
            color: theme.colorScheme.error,
            size: 32.sp,
          ),
          SizedBox(height: 8.h),
          Text(
            'Could not load additional services.',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            message,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
          SizedBox(height: 10.h),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

// =============================================================================
// SERVICE TILE
// =============================================================================

class _ServiceTile extends StatelessWidget {
  final AdditionalService service;
  final bool selected;
  final ValueChanged<bool> onChanged;

  const _ServiceTile({
    required this.service,
    required this.selected,
    required this.onChanged,
  });

  // ---------------------------------------------------------------------------
  // ICON
  // ---------------------------------------------------------------------------

  IconData get icon {
    final name = service.name.toLowerCase();

    if (name.contains('driver')) {
      return Icons.person_add_alt_1_outlined;
    }

    if (name.contains('gps')) {
      return Icons.gps_fixed_rounded;
    }

    if (name.contains('child') || name.contains('seat')) {
      return Icons.child_friendly_outlined;
    }

    if (name.contains('insurance')) {
      return Icons.shield_outlined;
    }

    return Icons.add_circle_outline;
  }

  // ---------------------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final softBorder = theme.brightness == Brightness.dark
        ? AppColors.darkBorder
        : AppColors.borderLight;

    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: () => onChanged(!selected),
        borderRadius: BorderRadius.circular(14.r),

        child: Container(
          padding: EdgeInsets.all(14.w),

          decoration: BoxDecoration(
            color: colors.surface,

            borderRadius: BorderRadius.circular(14.r),

            border: Border.all(
              color: selected ? colors.primary : softBorder,

              width: selected ? 1.5 : 1,
            ),
          ),

          child: Row(
            children: [
              // ---------------------------------------------------------------
              // ICON
              // ---------------------------------------------------------------
              Container(
                width: 42.w,
                height: 42.w,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primaryContainer,
                ),

                child: Icon(icon, color: colors.primary),
              ),

              SizedBox(width: 12.w),

              // ---------------------------------------------------------------
              // SERVICE INFO
              // ---------------------------------------------------------------
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    if (service.description.isNotEmpty) ...[
                      SizedBox(height: 3.h),

                      Text(
                        service.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],

                    SizedBox(height: 3.h),

                    Text(
                      '+\$${service.price.toStringAsFixed(0)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              // ---------------------------------------------------------------
              // CHECKBOX
              // ---------------------------------------------------------------
              Checkbox(
                value: selected,

                onChanged: (value) {
                  onChanged(value ?? false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// ORDER SUMMARY
// =============================================================================

class _OrderSummary extends StatelessWidget {
  final double rentalPrice;
  final double servicesPrice;
  final double totalPrice;
  final int rentalDays;

  const _OrderSummary({
    required this.rentalPrice,
    required this.servicesPrice,
    required this.totalPrice,
    required this.rentalDays,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final softBorder = theme.brightness == Brightness.dark
        ? AppColors.darkBorder
        : AppColors.borderLight;

    return Card(
      elevation: 0,

      color: colors.surfaceContainerLow,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),

        side: BorderSide(color: softBorder),
      ),

      child: Padding(
        padding: EdgeInsets.all(16.w),

        child: Column(
          children: [
            // -----------------------------------------------------------------
            // VEHICLE PRICE
            // -----------------------------------------------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Vehicle ($rentalDays days)',
                  style: theme.textTheme.bodyMedium,
                ),

                Text(
                  '\$${rentalPrice.toStringAsFixed(2)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            SizedBox(height: 10.h),

            // -----------------------------------------------------------------
            // SERVICES PRICE
            // -----------------------------------------------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Additional Services', style: theme.textTheme.bodyMedium),

                Text(
                  '\$${servicesPrice.toStringAsFixed(2)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            SizedBox(height: 4.h),

            const Divider(height: 24),

            // -----------------------------------------------------------------
            // TOTAL
            // -----------------------------------------------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                Text(
                  '\$${totalPrice.toStringAsFixed(2)}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
