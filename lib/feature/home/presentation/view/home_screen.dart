import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vehicle_rental_system/app/router/app_routes.dart';
import 'package:vehicle_rental_system/app/theme/app_colors.dart';
import 'package:vehicle_rental_system/app/theme/app_dimensions.dart';

import 'package:vehicle_rental_system/core/widgets/app_notification.dart';
import 'package:vehicle_rental_system/core/widgets/app_text_field.dart';

import 'package:vehicle_rental_system/feature/brand/domain/entity/brand.dart';
import 'package:vehicle_rental_system/feature/brand/presentation/bloc/brand_bloc.dart';

import 'package:vehicle_rental_system/feature/home/presentation/widgets/animated_greeting.dart';
import 'package:vehicle_rental_system/feature/home/presentation/widgets/brand_section/brand_section.dart';
import 'package:vehicle_rental_system/feature/home/presentation/widgets/home_banner_slider.dart';
import 'package:vehicle_rental_system/feature/home/presentation/widgets/home_loading_skeleton.dart';
import 'package:vehicle_rental_system/feature/home/presentation/widgets/vehicle_section/error_car_widget.dart';
import 'package:vehicle_rental_system/feature/home/presentation/widgets/vehicle_section/popular/popular_cars_section.dart';
import 'package:vehicle_rental_system/feature/home/presentation/widgets/vehicle_section/recommend/recommend_cars_section.dart';
import 'package:vehicle_rental_system/feature/notification/presentation/bloc/notification_bloc.dart';
import 'package:vehicle_rental_system/feature/vehicle/domain/entity/vehicle.dart';
import 'package:vehicle_rental_system/feature/vehicle/presentation/bloc/vehicle_bloc.dart';

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
  // ============================================================
  // KEEP SCREEN ALIVE
  // ============================================================

  @override
  bool get wantKeepAlive => true;

  // ============================================================
  // SELECTED BRAND
  //
  // null = All brands
  // value = selected brand ID
  // ============================================================

  int? selectedBrandId;

  // ============================================================
  // INITIAL LOAD
  //
  // Used to show HomeLoadingSkeleton only on the first load.
  // ============================================================

  bool _hasLoadedOnce = false;

  // ============================================================
  // BRAND SELECTION
  // ============================================================

  void _onBrandSelected(Brand? brand) {
    setState(() {
      selectedBrandId = brand?.id;
    });

    log(
      brand == null
          ? 'Brand filter: All'
          : 'Brand filter: ${brand.name} (id: ${brand.id})',
    );
  }

  // ============================================================
  // INIT STATE
  // ============================================================

  @override
  void initState() {
    super.initState();

    // ------------------------------------------------------------
    // LOAD VEHICLES
    // ------------------------------------------------------------

    context.read<VehicleBloc>().add(const GetVehicles());

    // ------------------------------------------------------------
    // LOAD BRANDS
    // ------------------------------------------------------------

    context.read<BrandBloc>().add(const GetBrands());
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshData() async {
    context.read<VehicleBloc>().add(const GetVehicles(refresh: true));

    context.read<BrandBloc>().add(const GetBrands(refresh: true));
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
        // ----------------------------------------------------------
        // FIRST SUCCESSFUL VEHICLE LOAD
        // ----------------------------------------------------------

        if (state is VehicleLoaded) {
          if (!_hasLoadedOnce) {
            setState(() {
              _hasLoadedOnce = true;
            });
          }
        }
      },

      child: BlocBuilder<VehicleBloc, VehicleState>(
        builder: (context, vehicleState) {
          // ========================================================
          // INITIAL LOADING
          // ========================================================

          if (!_hasLoadedOnce &&
              (vehicleState is VehicleInitial ||
                  vehicleState is VehicleLoading)) {
            return const HomeLoadingSkeleton();
          }

          // ========================================================
          // INITIAL ERROR
          // ========================================================

          if (!_hasLoadedOnce && vehicleState is VehicleError) {
            return Scaffold(
              backgroundColor: colorScheme.surface,
              body: SafeArea(
                child: Center(
                  child: ErrorCarWidget(
                    message: vehicleState.message,
                    onRetry: () {
                      context.read<VehicleBloc>().add(const GetVehicles());

                      context.read<BrandBloc>().add(const GetBrands());
                    },
                  ),
                ),
              ),
            );
          }

          // ========================================================
          // HOME
          // ========================================================

          return Scaffold(
            body: CustomScrollView(
              key: const PageStorageKey('home_screen'),

              physics: const BouncingScrollPhysics(),

              slivers: [
                // ==================================================
                // APP BAR
                // ==================================================
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
                        builder: (context, notificationState) {
                          final unreadCount =
                              notificationState is NotificationLoaded
                              ? notificationState.notifications
                                    .where(
                                      (notification) => !notification.isRead,
                                    )
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

                // ==================================================
                // PULL TO REFRESH
                // ==================================================
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

                // ==================================================
                // HOME CONTENT
                // ==================================================
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.chipHorizontalPadding,
                  ),

                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ======================================
                          // SEARCH
                          // ======================================
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

                          // ======================================
                          // BANNER
                          // ======================================
                          HomeBannerSlider(
                            onExploreTap: () {
                              widget.onExploreTap?.call(false);
                            },
                          ),

                          SizedBox(height: 8.h),

                          // ======================================
                          // BRAND CATEGORY
                          // ======================================
                          SizedBox(height: 8.h),

                          BrandSection(
                            selectedBrandId: selectedBrandId,

                            onBrandSelected: _onBrandSelected,
                          ),

                          SizedBox(height: 16.h),

                          // ======================================
                          // POPULAR CARS TITLE
                          // ======================================
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

                          // ======================================
                          // POPULAR CARS
                          // ======================================
                          PopularCarsSection(
                            selectedBrandId: selectedBrandId,
                            onFavoriteTap: widget.onFavoriteTap,
                          ),

                          SizedBox(height: 12.h),

                          // ======================================
                          // RECOMMENDED TITLE
                          // ======================================
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

                          //SizedBox(height: 12.h),

                          // ======================================
                          // RECOMMENDED CARS
                          // ======================================
                          RecommendCarsSection(
                            selectedBrandId: selectedBrandId,
                            onFavoriteTap: widget.onFavoriteTap,
                          ),

                          SizedBox(height: 40.h),
                        ],
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
