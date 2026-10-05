import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import 'package:vehicle_rental_system/app/theme/app_dimensions.dart';
import 'package:vehicle_rental_system/app/theme/app_size.dart';

/// A self-contained shimmer placeholder for a horizontal row of brand /
/// category chips. Used on any screen that shows a list of filter chips
/// whose data is still being fetched.
class BrandChipsShimmer extends StatelessWidget {
  final double? height;
  final int itemCount;

  const BrandChipsShimmer({super.key, this.height, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fill = colorScheme.surfaceContainerHighest;

    return SizedBox(
      height: height ?? 55.h,
      child: Shimmer.fromColors(
        baseColor: fill,
        highlightColor: colorScheme.surface,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.space12,
          ),
          itemCount: itemCount,
          separatorBuilder: (_, _) {
            return SizedBox(width: AppDimensions.space16);
          },
          itemBuilder: (context, index) {
            return AspectRatio(
              aspectRatio: AppDimensions.aspectRatioSquare,
              child: Container(
                width: AppSize.w(context, 20),
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: BorderRadius.circular(AppDimensions.radius16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}