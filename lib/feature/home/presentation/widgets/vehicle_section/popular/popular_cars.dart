import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vehicle_rental_system/app/theme/app_dimensions.dart';
import 'package:vehicle_rental_system/core/widgets/app_loading.dart';
import 'package:vehicle_rental_system/feature/vehicle/domain/entity/vehicle.dart';
import 'package:vehicle_rental_system/feature/vehicle/presentation/widgets/vehicle_card.dart';

class PopularCars extends StatefulWidget {
  final List<Vehicle> vehicles;

  final VoidCallback? onSeeAll;
  final ValueChanged<Vehicle>? onVehicleTap;
  final VoidCallback? onFavoriteTap;
  final ValueChanged<Vehicle>? onRentTap;

  final bool isLoadMore;
  final VoidCallback onLoadMore;

  const PopularCars({
    super.key,
    required this.vehicles,
    this.onSeeAll,
    this.onVehicleTap,
    this.onFavoriteTap,
    this.onRentTap,
    required this.isLoadMore,
    required this.onLoadMore,
  });

  @override
  State<PopularCars> createState() => _PopularCarsState();
}

class _PopularCarsState extends State<PopularCars> {
  final ScrollController _scrollController = ScrollController();

  // ============================================================
  // SCROLL
  // ============================================================

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;

    if (position.pixels >= position.maxScrollExtent - 200) {
      widget.onLoadMore();
    }
  }

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (widget.vehicles.isEmpty) {
      return const SizedBox.shrink();
    }

    final itemCount = widget.vehicles.length + (widget.isLoadMore ? 1 : 0);

    return SizedBox(
      height: 270.h,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, __) {
          return SizedBox(width: AppDimensions.space14);
        },
        itemBuilder: (context, index) {
          // ======================================================
          // LOADING MORE
          // ======================================================

          if (index == widget.vehicles.length) {
            return const Center(child: AppLoading());
          }

          // ======================================================
          // VEHICLE
          // ======================================================

          final vehicle = widget.vehicles[index];

          return SizedBox(
            width: 280.w,
            child: VehicleCard(
              vehicle: vehicle,

              // ==================================================
              // VEHICLE TAP
              // ==================================================
              onTap: () {
                log(
                  'Vehicle: '
                  '${vehicle.brand} ${vehicle.model}',
                );

                widget.onVehicleTap?.call(vehicle);
              },

              // ==================================================
              // FAVORITE
              // ==================================================
              onFavoriteTap: () {
                widget.onFavoriteTap?.call();
              },

              // ==================================================
              // RENT
              // ==================================================
              onRentTap: () {
                widget.onRentTap?.call(vehicle);
              },
            ),
          );
        },
      ),
    );
  }
}
