import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vehicle_rental_system/feature/brand/domain/entity/brand.dart';
import 'package:vehicle_rental_system/feature/brand/presentation/bloc/brand_bloc.dart';
import 'package:vehicle_rental_system/feature/home/presentation/widgets/vehicle_section/empty_vehicles_widget.dart';
import 'package:vehicle_rental_system/feature/home/presentation/widgets/vehicle_section/error_car_widget.dart';
import 'package:vehicle_rental_system/feature/home/presentation/widgets/vehicle_section/recommend/recommend_cars.dart';
import 'package:vehicle_rental_system/feature/home/presentation/widgets/vehicle_section/shimmer_card.dart';
import 'package:vehicle_rental_system/feature/vehicle/domain/entity/vehicle.dart';
import 'package:vehicle_rental_system/feature/vehicle/presentation/bloc/vehicle_bloc.dart';

class RecommendCarsSection extends StatelessWidget {
  final int? selectedBrandId;
  final VoidCallback? onFavoriteTap;

  const RecommendCarsSection({
    super.key,
    this.selectedBrandId,
    this.onFavoriteTap,
  });

  // ============================================================
  // FILTER VEHICLES
  // ============================================================

  List<Vehicle> _filteredVehicles(int? brandId, List<Vehicle> vehicles) {
    if (brandId == null) {
      return vehicles;
    }

    return vehicles.where((vehicle) => vehicle.brandId == brandId).toList();
  }

  // ============================================================
  // GET BRAND NAME
  // ============================================================

  String _selectedBrandName(List<Brand> brands) {
    if (selectedBrandId == null) {
      return 'Cars';
    }

    for (final brand in brands) {
      if (brand.id == selectedBrandId) {
        return brand.name;
      }
    }

    return 'Cars';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VehicleBloc, VehicleState>(
      builder: (context, state) {
        // ========================================================
        // INITIAL LOADING
        // ========================================================

        if (state is VehicleLoading) {
          return Column(
            children: [
              const ShimmerCard(),
              SizedBox(height: 12.h),
              const ShimmerCard(),
            ],
          );
        }

        // ========================================================
        // ERROR
        // ========================================================

        if (state is VehicleError) {
          return ErrorCarWidget(
            message: state.message,
            onRetry: () {
              context.read<VehicleBloc>().add(const GetVehicles());
            },
          );
        }

        // ========================================================
        // LOADED
        // ========================================================

        if (state is VehicleLoaded) {
          final filteredVehicles = _filteredVehicles(
            selectedBrandId,
            state.vehicles,
          );

          // ======================================================
          // EMPTY
          // ======================================================

          if (filteredVehicles.isEmpty) {
            final brandState = context.read<BrandBloc>().state;

            final brands = brandState is BrandsLoaded
                ? brandState.brands
                : const <Brand>[];

            return EmptyVehiclesWidget(brand: _selectedBrandName(brands));
          }

          // ======================================================
          // RECOMMENDED
          // ======================================================

          return RecommendCars(
            vehicles: filteredVehicles,

            // BLoC controls whether spinner is displayed.
            isLoadMore: state.isLoadingMore,

            // HomeScreen will trigger this when needed.
            onLoadMore: () {
              context.read<VehicleBloc>().add(const GetVehicles());
            },

            onFavoriteTap: onFavoriteTap,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
