import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:vehicle_rental_system/app/theme/app_colors.dart';
import 'package:vehicle_rental_system/app/theme/app_dimensions.dart';
import 'package:vehicle_rental_system/core/widgets/app_badge.dart';
import 'package:vehicle_rental_system/feature/vehicle/domain/entity/vehicle.dart';
import 'package:vehicle_rental_system/core/widgets/favorite_toggle.dart';
import 'package:vehicle_rental_system/feature/vehicle/presentation/widgets/spec_item.dart';

class VehicleCardExplore extends StatelessWidget {
  final Vehicle vehicle;

  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  const VehicleCardExplore({
    super.key,
    required this.vehicle,
    this.onTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ============================================================
                // IMAGE
                // ============================================================
                AspectRatio(
                  //aspectRatio: 1.87,
                  aspectRatio: AppDimensions.vehicleCardAspectRatio,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // ------------------------------------------------------
                      // CAR IMAGE
                      // ------------------------------------------------------
                      if (vehicle.images.isNotEmpty)
                        Image.network(
                          vehicle.images.first.fileUrl,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,

                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }

                            return Container(
                              color: colorScheme.surfaceContainerHighest,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            );
                          },

                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: colorScheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.directions_car_outlined,
                                size: 50.r,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            );
                          },
                        )
                      else
                        Container(
                          color: colorScheme.surfaceContainerHighest,
                          child: Icon(
                            Icons.directions_car_outlined,
                            size: 50.r,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),

                      // ------------------------------------------------------
                      // ELECTRIC BADGE
                      // ------------------------------------------------------

                      /*
                      Positioned(
                        top: 14,
                        left: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF009B4D),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.bolt_rounded,
                                size: 18,
                                color: Colors.white,
                              ),

                              const SizedBox(width: 5),

                              Text(
                                vehicle.fuelType,
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ------------------------------------------------------
                      // FAVORITE BUTTON
                      // ------------------------------------------------------
                      Positioned(
                        top: 12,
                        right: 12,
                        child: FavoriteToggle(
                          onFavoriteTap: onFavoriteTap,
                          vehicle: vehicle,
                        ),
                      ),

                      */
                      Positioned(
                        top: 8,
                        left: 8,
                        right: 8,
                        child: Row(
                          mainAxisAlignment: .spaceBetween,
                          children: [
                            // ------------------------------------------------
                            // TYPE
                            // ------------------------------------------------
                            AppBadge(
                              label: vehicle.fuelType,
                              icon: Icons.bolt_rounded,
                              backgroundColor: const Color(0xFF009B4D),
                              textColor: AppColors.white,
                              iconColor: AppColors.white,
                            ),

                            // ------------------------------------------------
                            // FAVORITE
                            // ------------------------------------------------
                            FavoriteToggle(
                              //onFavoriteTap: onFavoriteTap,
                              vehicle: vehicle,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ============================================================
                // CONTENT
                // ============================================================
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
                  child: Column(
                    children: [
                      // ------------------------------------------------------
                      // MODEL + PRICE
                      // ------------------------------------------------------
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              '${vehicle.brand} ${vehicle.model}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),

                          const SizedBox(width: 10),

                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      '\$${vehicle.pricePerDay.toStringAsFixed(0)}',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),

                                TextSpan(
                                  text: ' /day',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: .spaceAround,
                        children: [
                          // Text(
                          //   //vehicle.model,
                          //   '${vehicle.brand} ${vehicle.model}',
                          //   maxLines: 1,
                          //   overflow: TextOverflow.ellipsis,
                          //   style: theme.textTheme.titleMedium?.copyWith(
                          //     fontWeight: FontWeight.w800,
                          //   ),
                          // ),

                          // SizedBox(width: 10.w),
                          SpecItem(
                            icon: Icons.settings_outlined,
                            text: vehicle.transmission,
                          ),

                          //const SizedBox(width: 8),
                          SpecItem(
                            icon: Icons.local_gas_station_outlined,
                            text: vehicle.fuelType,
                          ),

                          //const SizedBox(width: 8),
                          SpecItem(
                            icon: Icons.person_outline_rounded,
                            text: '${vehicle.seats}',
                          ),
                        ],
                      ),

                      /*

                      // ------------------------------------------------------
                      // RATING + DISTANCE + FEATURE
                      // ------------------------------------------------------
                      Row(
                        children: [
                          // Rating
                          const Icon(
                            Icons.star_rounded,
                            size: 19,
                            color: AppColors.primary,
                          ),

                          // Flexible(
                          //   child: Text(
                          //     vehicle.rating.toString(),
                          //     maxLines: 1,
                          //     overflow: TextOverflow.ellipsis,
                          //     style: theme.textTheme.bodyMedium?.copyWith(
                          //       color: colorScheme.onSurfaceVariant,
                          //     ),
                          //   ),
                          // ),

                          //const SizedBox(width: 4),

                          // Text(
                          //   vehicle.rating.toStringAsFixed(1),
                          //   style: theme.textTheme.bodyMedium?.copyWith(
                          //     color: colorScheme.onSurface,
                          //     fontWeight: FontWeight.w500,
                          //   ),
                          // ),
                          _Dot(),

                          // Distance
                          const Icon(
                            Icons.location_on_outlined,
                            size: 17,
                            color: Color(0xFF607080),
                          ),

                          //const SizedBox(width: 2),

                          // Text(
                          //   MapService.getLocationName(
                          //     vehicle.latitude,
                          //     vehicle.longitude,
                          //   ).toString(),
                          //   style: theme.textTheme.bodyMedium?.copyWith(
                          //     color: colorScheme.onSurfaceVariant,
                          //   ),
                          // ),
                          /*
                          FutureBuilder<String>(
                            future: MapService.getLocationName(
                              vehicle.latitude,
                              vehicle.longitude,
                            ),
                            builder: (context, snapshot) {
                              final locationName =
                                  snapshot.data ?? 'Loading location...';

                              final cityName = locationName
                                  .split(',')
                                  .first
                                  .trim();

                              return Text(
                                cityName,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),

                          */
                          _Dot(),

                          // Feature
                          Flexible(
                            child: Text(
                              vehicle.transmission,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),

                      */
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// DOT
// ============================================================================

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        '•',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 16,
        ),
      ),
    );
  }
}
