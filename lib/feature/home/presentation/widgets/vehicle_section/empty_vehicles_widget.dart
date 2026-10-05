// ====================================================================
// EMPTY VEHICLES
// ====================================================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmptyVehiclesWidget extends StatelessWidget {
  final String brand;

  const EmptyVehiclesWidget({required this.brand});

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
