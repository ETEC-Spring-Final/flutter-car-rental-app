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

import 'package:vehicle_rental_system/feature/home/presentation/bloc/home_bloc.dart';
import 'package:vehicle_rental_system/feature/home/presentation/widgets/animated_greeting.dart';
import 'package:vehicle_rental_system/feature/home/presentation/widgets/home_banner_slider.dart';
import 'package:vehicle_rental_system/feature/home/presentation/widgets/home_loading_skeleton.dart';
import 'package:vehicle_rental_system/feature/home/presentation/widgets/popular_cars_section.dart';

import 'package:vehicle_rental_system/feature/notification/presentation/bloc/notification_bloc.dart';

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
  // PAGINATION
  // ============================================================

  // The paging itself lives in HomeBloc; these three controllers only turn
  // "the user reached the end of this list" into the matching event.

  // Distance from the end at which the next page is requested.
  static const double _loadMoreThreshold = 200;

  // The brand chip row.
  final ScrollController _brandScrollController = ScrollController();

  // The popular cars row, which scrolls on its own axis.
  final ScrollController _popularScrollController = ScrollController();

  // The page's own scroll, which drives the recommended list: that section is
  // a plain column inside the page scroll rather than a scrollable of its own.
  final ScrollController _pageScrollController = ScrollController();

  void _onBrandScroll() {
    _loadMoreOn(_brandScrollController, const HomeLoadMoreBrands());
  }

  void _onPopularScroll() {
    _loadMoreOn(_popularScrollController, const HomeLoadMoreVehicles());
  }

  void _onPageScroll() {
    _loadMoreOn(_pageScrollController, const HomeLoadMoreVehicles());
  }

  void _loadMoreOn(ScrollController controller, HomeEvent event) {
    if (!controller.hasClients) return;

    final position = controller.position;

    if (position.pixels >= position.maxScrollExtent - _loadMoreThreshold) {
      context.read<HomeBloc>().add(event);
    }
  }

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _brandScrollController.addListener(_onBrandScroll);

    _popularScrollController.addListener(_onPopularScroll);

    _pageScrollController.addListener(_onPageScroll);

    // Load the first page of vehicles and brands.
    context.read<HomeBloc>().add(const HomeStarted());
  }

  // ============================================================
  // REFRESH
  // ============================================================

  /// Waits for the reload to actually land.
  ///
  /// The event alone is not enough: the pull to refresh control holds its
  /// spinner for as long as this future runs, and adding an event returns
  /// immediately, which would flash the indicator and hide it before the
  /// pages arrive.
  Future<void> refreshData() async {
    final bloc = context.read<HomeBloc>();

    final settled = bloc.stream.firstWhere(
      (state) => state is! HomeLoaded || !state.isRefreshing,
    );

    bloc.add(const HomeRefreshed());

    await settled;
  }

  @override
  void dispose() {
    _brandScrollController
      ..removeListener(_onBrandScroll)
      ..dispose();

    _popularScrollController
      ..removeListener(_onPopularScroll)
      ..dispose();

    _pageScrollController
      ..removeListener(_onPageScroll)
      ..dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        // Show the full-page loading skeleton until the first page of
        // vehicles and brands has arrived.
        if (state is HomeInitial || state is HomeLoading) {
          return const HomeLoadingSkeleton();
        }

        // If the first page completely failed, show a retry screen.
        if (state is HomeError) {
          return Scaffold(
            backgroundColor: colorScheme.surface,
            body: SafeArea(
              child: Center(
                child: _ErrorWidget(
                  message: state.message,
                  onRetry: () {
                    context.read<HomeBloc>().add(const HomeStarted());
                  },
                ),
              ),
            ),
          );
        }

          return Scaffold(
            body: CustomScrollView(
              key: const PageStorageKey('home_screen'),
              controller: _pageScrollController,
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
                // There is no Material equivalent of this sliver: a Material
                // app would wrap the whole CustomScrollView in a
                // RefreshIndicator instead, which needs no reordering here.
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
                          // BRAND CATEGORY (from /api/brands)
                          // ==================================================
                          BlocBuilder<HomeBloc, HomeState>(
                            builder: (context, state) {
                              // Show shimmer skeleton chips while the first page
                              // of brands is being fetched.
                              if (state is! HomeLoaded) {
                                return const BrandChipsShimmer();
                              }

                              return SizedBox(
                                height: 55.h,
                                child: ListView.separated(
                                  controller: _brandScrollController,

                                  scrollDirection: Axis.horizontal,
              // AlwaysScrollable so a short page is still pullable, and
              // Bouncing so the overscroll the refresh control reacts to is
              // actually allowed.
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),

                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppDimensions.space12,
                                  ),

                                  // "All", the loaded brands, and a trailing
                                  // spinner while the next page is in flight.
                                  itemCount:
                                      state.brands.length +
                                      1 +
                                      (state.isLoadingMoreBrands ? 1 : 0),

                                  separatorBuilder: (_, _) {
                                    return SizedBox(
                                      width: AppDimensions.space16,
                                    );
                                  },

                                  itemBuilder: (context, index) {
                                    // ==========================================
                                    // MORE BRANDS SPINNER
                                    // ==========================================

                                    if (index > state.brands.length) {
                                      return const _BrandChipSpinner();
                                    }

                                    // ==========================================
                                    // ALL
                                    // ==========================================

                                    if (index == 0) {
                                      return _CategoryItem(
                                        title: 'All',
                                        image: '',
                                        isSelected: state.selectedBrand == null,
                                        onTap: () {
                                          context.read<HomeBloc>().add(
                                            const HomeBrandSelected(null),
                                          );

                                          log('Filter: All');
                                        },
                                      );
                                    }

                                    // ==========================================
                                    // BRAND
                                    // ==========================================

                                    final brand = state.brands[index - 1];

                                    return _CategoryItem(
                                      title: brand.name,
                                      image: brand.imageUrl,
                                      isSelected:
                                          state.selectedBrand == brand.name,
                                      onTap: () {
                                        context.read<HomeBloc>().add(
                                          HomeBrandSelected(brand.name),
                                        );

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
                          BlocBuilder<HomeBloc, HomeState>(
                            builder: (context, state) {
                              // ============================================
                              // LOADING
                              // ============================================

                              // Skeleton while the first page is in flight,
                              // which includes the reload after a brand change.
                              if (state is! HomeLoaded || state.isLoadingVehicles) {
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
                              // LOADED
                              // ============================================

                              if (state.hasNoVehicles) {
                                return _EmptyVehiclesWidget(
                                  brand: state.selectedBrand ?? '',
                                );
                              }

                              return PopularCarsSection(
                                // Ranked by reservation count, unlike the
                                // recommended section which keeps API order.
                                vehicles: state.popularVehicles,

                                controller: _popularScrollController,

                                isLoadingMore: state.isLoadingMoreVehicles,

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
                    child: BlocBuilder<HomeBloc, HomeState>(
                      builder: (context, state) {
                        // ================================================
                        // LOADING
                        // ================================================

                        if (state is! HomeLoaded || state.isLoadingVehicles) {
                          return Column(
                            children: [
                              const ShimmerCard(),
                              SizedBox(height: 12.h),
                              const ShimmerCard(),
                            ],
                          );
                        }

                        // ================================================
                        // LOADED
                        // ================================================

                        if (state.hasNoVehicles) {
                          return _EmptyVehiclesWidget(
                            brand: state.selectedBrand ?? '',
                          );
                        }

                        return Column(
                          children: [
                            ...state.vehicles.map((vehicle) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: 12.h),
                                child: VehicleCardExplore(
                                  vehicle: vehicle,

                                  // ==================================
                                  // VEHICLE TAP
                                  // ==================================
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

                                  // ==================================
                                  // FAVORITE
                                  // ==================================
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
                            }),

                            // ================================================
                            // LOADING THE NEXT PAGE
                            // ================================================

                            if (state.isLoadingMoreVehicles)
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 18.h),
                                child: SizedBox(
                                  width: 26.r,
                                  height: 26.r,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                  ),
                                ),
                              ),
                          ],
                        );
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
    );
  }
}

// ====================================================================
// BRAND CHIP SPINNER (shown while the next page of brands loads)
// ====================================================================

class _BrandChipSpinner extends StatelessWidget {
  const _BrandChipSpinner();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 55.h,
      height: 55.h,
      child: Center(
        child: SizedBox(
          width: 20.r,
          height: 20.r,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: colorScheme.primary,
          ),
        ),
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
