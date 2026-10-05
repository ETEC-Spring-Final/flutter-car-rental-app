import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import 'package:vehicle_rental_system/app/theme/app_dimensions.dart';

/// A self-contained shimmer skeleton card with an image area and a few text
/// bars, mirroring the vehicle cards used across the app.
///
/// Set [filled] to `true` when placing the card inside a fixed-height
/// horizontal list: the image area then expands to fill the leftover height
/// instead of using a fixed aspect ratio, so it never overflows.
class ShimmerCard extends StatelessWidget {
  final double? width;

  /// When true, the image area expands to fill the leftover height instead
  /// of using a fixed aspect ratio (safe inside a fixed-height row).
  final bool filled;

  const ShimmerCard({super.key, this.width, this.filled = false});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fill = colorScheme.surfaceContainerHighest;

    return Container(
      width: width ?? double.infinity,
      padding: const EdgeInsets.only(bottom: 10),
      child: Shimmer.fromColors(
        baseColor: fill,
        highlightColor: colorScheme.surface,
        child: Material(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (filled)
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: fill,
                  ),
                )
              else
                AspectRatio(
                  aspectRatio: AppDimensions.vehicleCardAspectRatio,
                  child: Container(
                    width: double.infinity,
                    color: fill,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 140.w,
                      height: 14,
                      decoration: BoxDecoration(
                        color: fill,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      width: 100.w,
                      height: 12,
                      decoration: BoxDecoration(
                        color: fill,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Container(
                          width: 80.w,
                          height: 16,
                          decoration: BoxDecoration(
                            color: fill,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 36.w,
                          height: 36.w,
                          decoration: BoxDecoration(
                            color: fill,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}