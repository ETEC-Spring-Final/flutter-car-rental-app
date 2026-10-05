import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vehicle_rental_system/feature/home/presentation/widgets/vehicle_section/popular/popular_cars.dart';
import 'package:vehicle_rental_system/feature/rental/presentation/view/rental_details_screen.dart';
import 'package:vehicle_rental_system/feature/vehicle/domain/entity/vehicle.dart';
import 'package:vehicle_rental_system/feature/vehicle/presentation/bloc/vehicle_bloc.dart';
import 'package:vehicle_rental_system/feature/vehicle/presentation/view/vehicle_detail_screen.dart';

class PopularCarsSection extends StatelessWidget {
  final int? selectedBrandId;

  final VoidCallback? onSeeAll;
  final VoidCallback? onFavoriteTap;

  const PopularCarsSection({
    super.key,
    this.selectedBrandId,
    this.onSeeAll,
    this.onFavoriteTap,
  });

  // ============================================================
  // LOAD MORE VEHICLES
  // ============================================================

  void _loadMoreVehicles(BuildContext context) {
    final state = context.read<VehicleBloc>().state;

    // Prevent duplicate pagination requests
    if (state is VehicleLoaded && state.isLoadingMore) {
      return;
    }

    context.read<VehicleBloc>().add(const GetVehicles());
  }

  // ============================================================
  // FILTER VEHICLES BY BRAND
  // ============================================================

  List<Vehicle> _filterByBrand(List<Vehicle> vehicles) {
    if (selectedBrandId == null) {
      return vehicles;
    }

    return vehicles
        .where((vehicle) => vehicle.brandId == selectedBrandId)
        .toList();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VehicleBloc, VehicleState>(
      builder: (context, state) {
        // ========================================================
        // LOADING
        // ========================================================

        if (state is VehicleLoading) {
          return const SizedBox.shrink();
        }

        // ========================================================
        // LOADED
        // ========================================================

        if (state is VehicleLoaded) {
          final filteredVehicles = _filterByBrand(state.vehicles);

          // ======================================================
          // EMPTY
          // ======================================================

          if (filteredVehicles.isEmpty) {
            return const SizedBox.shrink();
          }

          // ======================================================
          // POPULAR CARS
          // ======================================================

          return PopularCars(
            vehicles: filteredVehicles,

            // Pagination
            isLoadMore: state.isLoadingMore,
            onLoadMore: () {
              _loadMoreVehicles(context);
            },

            // See all
            onSeeAll: onSeeAll,

            // Vehicle detail
            onVehicleTap: (vehicle) {
              log(
                'Vehicle tapped: '
                '${vehicle.brand} ${vehicle.model}',
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VehicleDetailScreen(vehicle: vehicle),
                ),
              );
            },

            // Favorite
            onFavoriteTap: onFavoriteTap,

            // Rent
            onRentTap: (vehicle) {
              log(
                'Rent vehicle: '
                '${vehicle.brand} ${vehicle.model}',
              );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RentalDetailsScreen(vehicle: vehicle),
                ),
              );
            },
          );
        }

        // ========================================================
        // ERROR / OTHER
        // ========================================================

        return const SizedBox.shrink();
      },
    );
  }
}
