import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vehicle_rental_system/app/router/app_routes.dart';

import 'package:vehicle_rental_system/app/theme/app_colors.dart';
import 'package:vehicle_rental_system/app/theme/app_dimensions.dart';
import 'package:vehicle_rental_system/app/theme/app_size.dart';
import 'package:vehicle_rental_system/core/widgets/app_notification.dart';
import 'package:vehicle_rental_system/core/widgets/app_text_field.dart';
import 'package:vehicle_rental_system/core/widgets/brand_chips_shimmer.dart';
import 'package:vehicle_rental_system/core/widgets/shimmer_card.dart';
import 'package:vehicle_rental_system/feature/brand/presentation/bloc/brand_bloc.dart';

import 'package:vehicle_rental_system/feature/home/presentation/widgets/animated_greeting.dart';
import 'package:vehicle_rental_system/feature/home/presentation/widgets/home_banner_slider.dart';
import 'package:vehicle_rental_system/feature/home/presentation/widgets/home_loading_skeleton.dart';
import 'package:vehicle_rental_system/feature/home/presentation/widgets/popular_cars_section.dart';

import 'package:vehicle_rental_system/feature/notification/presentation/bloc/notification_bloc.dart';

import 'package:vehicle_rental_system/feature/brand/domain/entity/brand.dart';
import 'package:vehicle_rental_system/feature/vehicle/domain/entity/vehicle.dart';

import 'package:vehicle_rental_system/feature/vehicle/presentation/bloc/vehicle_bloc.dart';
import 'package:vehicle_rental_system/feature/rental/presentation/view/rental_details_screen.dart';
import 'package:vehicle_rental_system/feature/vehicle/presentation/view/vehicle_detail_screen.dart';
import 'package:vehicle_rental_system/feature/vehicle/presentation/widgets/vehicle_card_explore.dart';

class HomeScreen extends StatefulWidget {
  final void Function(bool)? onExploreTap;
  final VoidCallback? onBookingTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onProfileTap;

  const HomeScreen({
    super.key,
    this.onExploreTap,
    this.onBookingTap,
    this.onFavoriteTap,
    this.onProfileTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // ============================================================
  // CATEGORY
  // ============================================================

  // Index 0 = All
  // Index 1..n = categories
  int selectedCategoryIndex = 0;

  // Becomes true after the first successful vehicle fetch.
  bool _hasLoadedOnce = false;

  // ============================================================
  // SELECTED BRAND
  // ============================================================

  String _selectedBrandName(List<Brand> brands) {
    final index = selectedCategoryIndex - 1;

    if (index < 0 || index >= brands.length) {
      return '';
    }

    return brands[index].name;
  }

  // ============================================================
  // FILTER VEHICLES
  // ============================================================

  List<Vehicle> _filteredVehicles(List<Brand> brands, List<Vehicle> vehicles) {
    final brand = _selectedBrandName(brands);

    // "All"
    if (brand.isEmpty) {
      return vehicles;
    }

    // Filter by brand
    return vehicles
        .where((vehicle) => vehicle.brand.toLowerCase() == brand.toLowerCase())
        .toList();
  }

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    // Load vehicles
    context.read<VehicleBloc>().add(const GetVehicles());

    // Load brands
    context.read<BrandBloc>().add(const GetBrands());
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshData() async {
    context.read<VehicleBloc>().add(const GetVehicles());
    context.read<BrandBloc>().add(const GetBrands());
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<VehicleBloc, VehicleState>(
      listener: (context, state) {
        if (state is VehicleLoaded) {
          setState(() {
            _hasLoadedOnce = true;
          });
        }
      },
      child: BlocBuilder<VehicleBloc, VehicleState>(
        builder: (context, state) {
          // ==========================================================
          // INITIAL LOADING
          // ==========================================================

          if (!_hasLoadedOnce &&
              (state is VehicleInitial || state is VehicleLoading)) {
            return const HomeLoadingSkeleton();
          }

          // ==========================================================
          // INITIAL ERROR
          // ==========================================================

          if (!_hasLoadedOnce && state is VehicleError) {
            return Scaffold(
              backgroundColor: colorScheme.surface,
              body: SafeArea(
                child: Center(
                  child: _ErrorWidget(
                    message: state.message,
                    onRetry: () {
                      context.read<VehicleBloc>().add(const GetVehicles());

                      context.read<BrandBloc>().add(const GetBrands());
                    },
                  ),
                ),
              ),
            );
          }

          // ==========================================================
          // HOME
          // ==========================================================

          return Scaffold(
            body: CustomScrollView(
              key: const PageStorageKey('home_screen'),
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ========================================================
                // APP BAR
                // ========================================================
                SliverAppBar(
                  automaticallyImplyLeading: false,

                  // Hide when scrolling down
                  floating: true,

                  // Show immediately when scrolling up
                  snap: true,

                  // Don't stay pinned
                  pinned: false,

                  elevation: 0,
                  scrolledUnderElevation: 0,

                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,

                  surfaceTintColor: Colors.transparent,

                  titleSpacing: 16,
                  centerTitle: false,

                  title: const AnimatedGreeting(),

                  actions: [
                    InkWell(
                      onTap: () {
                        context.go(AppRoutes.notification);
                      },
                      child: BlocBuilder<NotificationBloc, NotificationState>(
                        builder: (context, state) {
                          final unreadCount = state is NotificationLoaded
                              ? state.notifications
                                    .where((n) => !n.isRead)
                                    .length
                              : 0;

                          return AppNotification(
                            notificationCount: unreadCount,
                            onTap: () {
                              context.go(AppRoutes.notification);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),

                // ========================================================
                // PULL TO REFRESH
                // ========================================================
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

                // ========================================================
                // HOME CONTENT
                // ========================================================
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.chipHorizontalPadding,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ==================================================
                          // SEARCH
                          // ==================================================
                          InkWell(
                            onTap: () {
                              widget.onExploreTap?.call(true);
                            },
                            child: AppTextField(
                              enabled: false,
                              hint: 'Search cars or brands..',
                              prefixIcon: Icons.search,
                              keyboardType: TextInputType.text,
                            ),
                          ),

                          SizedBox(height: 8.h),

                          // ==================================================
                          // BANNER
                          // ==================================================
                          HomeBannerSlider(
                            onExploreTap: () {
                              widget.onExploreTap?.call(false);
                            },
                          ),

                          SizedBox(height: 8.h),

                          // ==================================================
                          // BRAND CATEGORY
                          // ==================================================
                          BlocBuilder<BrandBloc, BrandState>(
                            builder: (context, state) {
                              final isLoaded = state is BrandsLoaded;

                              final brands = isLoaded
                                  ? state.brands
                                  : const <Brand>[];

                              // ------------------------------------------------
                              // BRAND LOADING
                              // ------------------------------------------------

                              if (!isLoaded) {
                                return const BrandChipsShimmer();
                              }

                              // ------------------------------------------------
                              // BRAND LIST
                              // ------------------------------------------------

                              return SizedBox(
                                height: 55.h,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,

                                  physics: const BouncingScrollPhysics(),

                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppDimensions.space12,
                                  ),

                                  itemCount: brands.length + 1,

                                  separatorBuilder: (_, _) {
                                    return SizedBox(
                                      width: AppDimensions.space16,
                                    );
                                  },

                                  itemBuilder: (context, index) {
                                    // ======================================
                                    // ALL
                                    // ======================================

                                    if (index == 0) {
                                      return _CategoryItem(
                                        title: 'All',
                                        image: '',
                                        isSelected: selectedCategoryIndex == 0,
                                        onTap: () {
                                          setState(() {
                                            selectedCategoryIndex = 0;
                                          });

                                          log('Filter: All');
                                        },
                                      );
                                    }

                                    // ======================================
                                    // BRAND
                                    // ======================================

                                    final brand = brands[index - 1];

                                    return _CategoryItem(
                                      title: brand.name,
                                      image: brand.imageUrl,
                                      isSelected:
                                          selectedCategoryIndex == index,
                                      onTap: () {
                                        setState(() {
                                          selectedCategoryIndex = index;
                                        });

                                        log('Filter: ${brand.name}');
                                      },
                                    );
                                  },
                                ),
                              );
                            },
                          ),

                          SizedBox(height: 8.h),

                          // ==================================================
                          // POPULAR CARS TITLE
                          // ==================================================
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Popular Cars',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.sp,
                                  letterSpacing: -0.4,
                                  height: 1.2,
                                ),
                              ),

                              InkWell(
                                onTap: () {
                                  widget.onExploreTap?.call(false);
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  width: 36.w,
                                  height: 36.h,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.92),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 18.r,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 8.h),

                          // ==================================================
                          // POPULAR CARS
                          // ==================================================
                          BlocBuilder<VehicleBloc, VehicleState>(
                            builder: (context, state) {
                              // ============================================
                              // LOADING
                              // ============================================

                              if (state is VehicleLoading) {
                                return SizedBox(
                                  height: 270.h,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,

                                    physics:
                                        const NeverScrollableScrollPhysics(),

                                    itemCount: 2,

                                    separatorBuilder: (_, _) {
                                      return SizedBox(width: 14.w);
                                    },

                                    itemBuilder: (context, index) {
                                      return ShimmerCard(
                                        width: 280.w,
                                        filled: true,
                                      );
                                    },
                                  ),
                                );
                              }

                              // ============================================
                              // ERROR
                              // ============================================

                              if (state is VehicleError) {
                                return _ErrorWidget(
                                  message: state.message,
                                  onRetry: () {
                                    context.read<VehicleBloc>().add(
                                      const GetVehicles(),
                                    );
                                  },
                                );
                              }

                              // ============================================
                              // LOADED
                              // ============================================

                              if (state is VehicleLoaded) {
                                // Get brands from BrandBloc
                                final brandState = context
                                    .read<BrandBloc>()
                                    .state;

                                final brands = brandState is BrandsLoaded
                                    ? brandState.brands
                                    : const <Brand>[];

                                final filteredVehicles = _filteredVehicles(
                                  brands,
                                  state.vehicles,
                                );

                                // ==========================================
                                // EMPTY
                                // ==========================================

                                if (filteredVehicles.isEmpty) {
                                  return _EmptyVehiclesWidget(
                                    brand: _selectedBrandName(brands),
                                  );
                                }

                                // ==========================================
                                // POPULAR CARS
                                // ==========================================

                                return PopularCarsSection(
                                  vehicles: filteredVehicles,

                                  onSeeAll: () {
                                    widget.onExploreTap?.call(false);
                                  },

                                  // ========================================
                                  // VEHICLE TAP
                                  // ========================================
                                  onVehicleTap: (vehicle) {
                                    log(
                                      'Vehicle: '
                                      '${vehicle.brand} '
                                      '${vehicle.model}',
                                    );

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) {
                                          return VehicleDetailScreen(
                                            vehicle: vehicle,
                                          );
                                        },
                                      ),
                                    );
                                  },

                                  // ========================================
                                  // FAVORITE
                                  // ========================================
                                  onFavoriteTap: (vehicle) {
                                    log(
                                      'Favorite: '
                                      '${vehicle.brand} '
                                      '${vehicle.model}',
                                    );

                                    widget.onFavoriteTap?.call();
                                  },

                                  // ========================================
                                  // RENT
                                  // ========================================
                                  onRentTap: (vehicle) {
                                    log(
                                      'Rent: '
                                      '${vehicle.brand} '
                                      '${vehicle.model}',
                                    );

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) {
                                          return RentalDetailsScreen(
                                            vehicle: vehicle,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                );
                              }

                              // ============================================
                              // INITIAL
                              // ============================================

                              return const SizedBox.shrink();
                            },
                          ),

                          SizedBox(height: 8.h),

                          // ==================================================
                          // RECOMMENDED TITLE
                          // ==================================================
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Recommended Cars for you',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.sp,
                                  letterSpacing: -0.4,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 12.h),
                        ],
                      ),
                    ]),
                  ),
                ),

                // ==========================================================
                // RECOMMENDED VEHICLES
                // ==========================================================
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.chipHorizontalPadding,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: BlocBuilder<VehicleBloc, VehicleState>(
                      builder: (context, state) {
                        // ================================================
                        // LOADING
                        // ================================================

                        if (state is VehicleLoading) {
                          return Column(
                            children: [
                              const ShimmerCard(),

                              SizedBox(height: 12.h),

                              const ShimmerCard(),
                            ],
                          );
                        }

                        // ================================================
                        // ERROR
                        // ================================================

                        if (state is VehicleError) {
                          return _ErrorWidget(
                            message: state.message,
                            onRetry: () {
                              context.read<VehicleBloc>().add(
                                const GetVehicles(),
                              );
                            },
                          );
                        }

                        // ================================================
                        // LOADED
                        // ================================================

                        if (state is VehicleLoaded) {
                          // Get brands from BrandBloc
                          final brandState = context.read<BrandBloc>().state;

                          final brands = brandState is BrandsLoaded
                              ? brandState.brands
                              : const <Brand>[];

                          final filteredVehicles = _filteredVehicles(
                            brands,
                            state.vehicles,
                          );

                          // ==============================================
                          // EMPTY
                          // ==============================================

                          if (filteredVehicles.isEmpty) {
                            return _EmptyVehiclesWidget(
                              brand: _selectedBrandName(brands),
                            );
                          }

                          // ==============================================
                          // VEHICLES
                          // ==============================================

                          return Column(
                            children: filteredVehicles.map((vehicle) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: 12.h),
                                child: VehicleCardExplore(
                                  vehicle: vehicle,

                                  // ====================================
                                  // VEHICLE TAP
                                  // ====================================
                                  onTap: () {
                                    log(
                                      'Recommended: '
                                      '${vehicle.brand} '
                                      '${vehicle.model}',
                                    );

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) {
                                          return VehicleDetailScreen(
                                            vehicle: vehicle,
                                          );
                                        },
                                      ),
                                    );
                                  },

                                  // ====================================
                                  // FAVORITE
                                  // ====================================
                                  onFavoriteTap: () {
                                    log(
                                      'Recommended favorite: '
                                      '${vehicle.brand} '
                                      '${vehicle.model}',
                                    );

                                    widget.onFavoriteTap?.call();
                                  },
                                ),
                              );
                            }).toList(),
                          );
                        }

                        // ================================================
                        // INITIAL
                        // ================================================

                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),

                // ==========================================================
                // BOTTOM SPACE
                // ==========================================================
                SliverToBoxAdapter(child: SizedBox(height: 40.h)),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ====================================================================
// CATEGORY ITEM
// ====================================================================

class _CategoryItem extends StatelessWidget {
  final String title;
  final String image;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.title,
    required this.image,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(AppDimensions.radius16),

        child: AspectRatio(
          aspectRatio: AppDimensions.aspectRatioSquare,

          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),

            curve: Curves.easeOut,

            width: AppSize.w(context, 20),

            decoration: BoxDecoration(
              color: isSelected
                  ? colorScheme.primary.withValues(alpha: 0.0)
                  : colorScheme.surface,

              borderRadius: BorderRadius.circular(AppDimensions.radius16),

              border: Border.all(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outline.withValues(alpha: 0.15),
                width: isSelected ? 1.5 : 1,
              ),

              boxShadow: [
                if (!isSelected)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
              ],
            ),

            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radius16),

              child: image.isEmpty
                  // ==================================================
                  // ALL
                  // ==================================================
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.grid_view_rounded,
                            size: 22.r,
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                          ),

                          SizedBox(height: 4.h),

                          Text(
                            title,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: isSelected
                                      ? colorScheme.primary
                                      : colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    )
                  // ==================================================
                  // CATEGORY IMAGE
                  // ==================================================
                  : Image.network(
                      image,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.image_not_supported_outlined,
                          color: colorScheme.onSurfaceVariant,
                        );
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ====================================================================
// EMPTY VEHICLES
// ====================================================================

class _EmptyVehiclesWidget extends StatelessWidget {
  final String brand;

  const _EmptyVehiclesWidget({required this.brand});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.h),

      child: Column(
        children: [
          Icon(
            Icons.no_crash_outlined,
            size: 48.r,
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
          ),

          SizedBox(height: 12.h),

          Text(
            brand.isEmpty
                ? 'No vehicles available'
                : 'No $brand cars available',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// ERROR
// ====================================================================

class _ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorWidget({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.h),

      child: Column(
        children: [
          Icon(Icons.error_outline, size: 44.r, color: theme.colorScheme.error),

          SizedBox(height: 8.h),

          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),

          SizedBox(height: 12.h),

          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
