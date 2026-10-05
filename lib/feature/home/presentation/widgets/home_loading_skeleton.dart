import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import 'package:vehicle_rental_system/app/theme/app_dimensions.dart';
import 'package:vehicle_rental_system/feature/home/presentation/widgets/brand_section/brand_chips_shimmer.dart';
import 'package:vehicle_rental_system/feature/home/presentation/widgets/vehicle_section/shimmer_card.dart';

/// Full-page shimmer skeleton shown while the home data (brands + vehicles)
/// is being fetched. Composes the reusable [BrandChipsShimmer] and
/// [ShimmerCard] placeholders with page-level bars and a banner block.
class HomeLoadingSkeleton extends StatelessWidget {
  const HomeLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fill = colorScheme.surfaceContainerHighest;

    Widget bar(double width, double height, {double radius = 4}) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Shimmer.fromColors(
          baseColor: fill,
          highlightColor: colorScheme.surface,
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.space12,
              vertical: 12.h,
            ),
            children: [
              bar(160.w, 24, radius: AppDimensions.radius16),
              SizedBox(height: 16.h),
              bar(1.sw - 24.w, 50, radius: AppDimensions.radius16),
              SizedBox(height: 20.h),
              AspectRatio(
                aspectRatio: 1.9,
                child: Container(
                  decoration: BoxDecoration(
                    color: fill,
                    borderRadius: BorderRadius.circular(AppDimensions.radius16),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              bar(130.w, 20, radius: AppDimensions.radius16),
              SizedBox(height: 12.h),
              const BrandChipsShimmer(),
              SizedBox(height: 20.h),
              bar(150.w, 20, radius: AppDimensions.radius16),
              SizedBox(height: 12.h),
              SizedBox(
                height: 270.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 2,
                  separatorBuilder: (_, _) {
                    return SizedBox(width: 14.w);
                  },
                  itemBuilder: (context, index) {
                    return const ShimmerCard(width: 280, filled: true);
                  },
                ),
              ),
              SizedBox(height: 20.h),
              bar(170.w, 20, radius: AppDimensions.radius16),
              SizedBox(height: 12.h),
              const ShimmerCard(),
              SizedBox(height: 12.h),
              const ShimmerCard(),
            ],
          ),
        ),
      ),
    );
  }
}
