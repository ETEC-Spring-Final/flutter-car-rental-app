import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vehicle_rental_system/app/theme/app_dimensions.dart';
import 'package:vehicle_rental_system/core/widgets/app_loading.dart';
import 'package:vehicle_rental_system/feature/vehicle/domain/entity/vehicle.dart';
import 'package:vehicle_rental_system/feature/vehicle/presentation/view/vehicle_detail_screen.dart';
import 'package:vehicle_rental_system/feature/vehicle/presentation/widgets/vehicle_card_explore.dart';

class RecommendCars extends StatelessWidget {
  final List<Vehicle> vehicles;

  final bool isLoadMore;

  final VoidCallback onLoadMore;

  final VoidCallback? onFavoriteTap;

  const RecommendCars({
    super.key,
    required this.vehicles,
    required this.isLoadMore,
    required this.onLoadMore,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    if (vehicles.isEmpty) {
      return const SizedBox.shrink();
    }

    final itemCount = vehicles.length + (isLoadMore ? 1 : 0);

    return ListView.builder(
      shrinkWrap: true,

      // IMPORTANT:
      // HomeScreen's CustomScrollView owns vertical scrolling.
      physics: const NeverScrollableScrollPhysics(),

      itemCount: itemCount,

      itemBuilder: (context, index) {
        // ========================================================
        // LOADING MORE
        // ========================================================

        if (index == vehicles.length) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: AppDimensions.space16),
            child: const Center(child: AppLoading()),
          );
        }

        // ========================================================
        // VEHICLE
        // ========================================================

        final vehicle = vehicles[index];

        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: VehicleCardExplore(
            vehicle: vehicle,

            // ====================================================
            // DETAIL
            // ====================================================
            onTap: () {
              log(
                'Recommended: '
                '${vehicle.brand} ${vehicle.model}',
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VehicleDetailScreen(vehicle: vehicle),
                ),
              );
            },

            // ====================================================
            // FAVORITE
            // ====================================================
            onFavoriteTap: () {
              log(
                'Recommended favorite: '
                '${vehicle.brand} ${vehicle.model}',
              );

              onFavoriteTap?.call();
            },
          ),
        );
      },
    );
  }
}
