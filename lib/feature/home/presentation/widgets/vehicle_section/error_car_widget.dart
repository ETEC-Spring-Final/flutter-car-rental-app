// ====================================================================
// ERROR
// ====================================================================

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ErrorCarWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorCarWidget({required this.message, required this.onRetry});

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
