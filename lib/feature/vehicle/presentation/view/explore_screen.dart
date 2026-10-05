import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vehicle_rental_system/app/theme/app_dimensions.dart';
import 'package:vehicle_rental_system/core/widgets/app_text_field.dart';
import 'package:vehicle_rental_system/feature/home/presentation/widgets/vehicle_section/shimmer_card.dart';
import 'package:vehicle_rental_system/feature/vehicle/domain/entity/vehicle.dart';
import 'package:vehicle_rental_system/feature/vehicle/presentation/bloc/vehicle_bloc.dart';
import 'package:vehicle_rental_system/feature/vehicle/presentation/view/vehicle_detail_screen.dart';
import 'package:vehicle_rental_system/feature/vehicle/presentation/widgets/explore_category_filter.dart';
import 'package:vehicle_rental_system/feature/vehicle/presentation/widgets/vehicle_card_explore.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => ExploreScreenState();
}

class ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController searchController = TextEditingController();

  final FocusNode searchFocusNode = FocusNode();

  int selectedCategory = 0;

  // ------------------------------------------------------------
  // Focus search field
  // ------------------------------------------------------------

  void focusSearch() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      searchFocusNode.requestFocus();
    });
  }

  // ------------------------------------------------------------
  // Init
  // ------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    searchController.addListener(() {
      setState(() {});
    });

    context.read<VehicleBloc>().add(const GetVehicles());
  }

  // ------------------------------------------------------------
  // Filter vehicles
  // ------------------------------------------------------------

  List<Vehicle> _filteredVehicles(List<Vehicle> vehicles) {
    final query = searchController.text.trim().toLowerCase();

    final types = ExploreCategoryFilter.typesForIndex(selectedCategory);

    return vehicles.where((vehicle) {
      // Category filter
      final matchesCategory =
          types == null ||
          types.any((type) => type.toLowerCase() == vehicle.type.toLowerCase());

      // Search filter
      final matchesQuery =
          query.isEmpty ||
          vehicle.brand.toLowerCase().contains(query) ||
          vehicle.model.toLowerCase().contains(query);

      return matchesCategory && matchesQuery;
    }).toList();
  }

  // ------------------------------------------------------------
  // Dispose
  // ------------------------------------------------------------

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();

    super.dispose();
  }

  // ------------------------------------------------------------
  // Refresh
  // ------------------------------------------------------------

  Future<void> refreshData() async {
    context.read<VehicleBloc>().add(const GetVehicles());
  }

  // ------------------------------------------------------------
  // Build
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ======================================================
          // Search bar
          // ======================================================
          SliverAppBar(
            automaticallyImplyLeading: false,

            floating: true,
            snap: true,
            pinned: false,

            elevation: 0,
            scrolledUnderElevation: 0,

            backgroundColor: Theme.of(context).scaffoldBackgroundColor,

            surfaceTintColor: Colors.transparent,

            titleSpacing: 16,
            centerTitle: false,

            title: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: AppTextField(
                contentPadding: const EdgeInsets.only(top: 10, bottom: 10),
                focusNode: searchFocusNode,
                controller: searchController,
                hint: 'Search cars or brands..',
                prefixIcon: Icons.search,
                keyboardType: TextInputType.text,
                onChanged: (value) {
                  setState(() {});

                  log('Search: ${searchController.text}');
                },
              ),
            ),
          ),

          // ======================================================
          // Pull to refresh
          // ======================================================
          CupertinoSliverRefreshControl(
            onRefresh: refreshData,

            refreshTriggerPullDistance: 90,

            refreshIndicatorExtent: 56,

            builder:
                (
                  context,
                  refreshState,
                  pulledExtent,
                  refreshTriggerPullDistance,
                  refreshIndicatorExtent,
                ) {
                  final colorScheme = Theme.of(context).colorScheme;

                  return Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: colorScheme.primary,
                      backgroundColor: colorScheme.primary.withValues(
                        alpha: 0.10,
                      ),
                    ),
                  );
                },
          ),

          // ======================================================
          // Category filter
          // ======================================================
          SliverToBoxAdapter(
            child: ExploreCategoryFilter(
              selectedIndex: selectedCategory,
              onSelected: (index) {
                setState(() {
                  selectedCategory = index;
                });
              },
            ),
          ),

          // ======================================================
          // Vehicle list
          // ======================================================
          BlocBuilder<VehicleBloc, VehicleState>(
            builder: (context, state) {
              // --------------------------------------------------
              // Loading
              // --------------------------------------------------

              if (state is VehicleLoading) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(
                      AppDimensions.chipHorizontalPadding,
                    ),
                    child: Column(
                      children: [
                        const ShimmerCard(),
                        SizedBox(height: 12.h),
                        const ShimmerCard(),
                        SizedBox(height: 12.h),
                        const ShimmerCard(),
                      ],
                    ),
                  ),
                );
              }

              // --------------------------------------------------
              // Error
              // --------------------------------------------------

              if (state is VehicleError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 56.r,
                            color: Theme.of(context).colorScheme.error,
                          ),

                          SizedBox(height: 16.h),

                          Text(
                            'Something went wrong',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),

                          SizedBox(height: 8.h),

                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),

                          SizedBox(height: 16.h),

                          ElevatedButton(
                            onPressed: () {
                              context.read<VehicleBloc>().add(
                                const GetVehicles(),
                              );
                            },
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              // --------------------------------------------------
              // Loaded
              // --------------------------------------------------

              if (state is VehicleLoaded) {
                final filteredVehicles = _filteredVehicles(state.vehicles);

                // ----------------------------------------------
                // No results
                // ----------------------------------------------

                if (filteredVehicles.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 48.h,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 56.r,
                              color: Theme.of(
                                context,
                              ).colorScheme.outline.withValues(alpha: 0.5),
                            ),

                            SizedBox(height: 16.h),

                            Text(
                              'No cars found',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),

                            SizedBox(height: 4.h),

                            Text(
                              'Try a different search or filter.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                // ----------------------------------------------
                // Vehicle list
                // ----------------------------------------------

                return SliverPadding(
                  padding: EdgeInsets.all(AppDimensions.chipHorizontalPadding),
                  sliver: SliverList.builder(
                    itemCount: filteredVehicles.length,
                    itemBuilder: (context, index) {
                      final vehicle = filteredVehicles[index];

                      return VehicleCardExplore(
                        vehicle: vehicle,

                        onTap: () {
                          log(
                            'Selected: '
                            '${vehicle.brand} '
                            '${vehicle.model}',
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  VehicleDetailScreen(vehicle: vehicle),
                            ),
                          );
                        },

                        onFavoriteTap: () {
                          log(
                            'Favorite: '
                            '${vehicle.brand} '
                            '${vehicle.model}',
                          );
                        },
                      );
                    },
                  ),
                );
              }

              // --------------------------------------------------
              // Initial
              // --------------------------------------------------

              return const SliverFillRemaining(
                child: Center(child: Text('No vehicles available')),
              );
            },
          ),
        ],
      ),
    );
  }
}
