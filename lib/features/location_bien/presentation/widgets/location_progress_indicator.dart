import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme.dart';

enum LocationStepState { idle, active, done }

class LocationProgStep extends StatelessWidget {
  final String label;
  final LocationStepState state;
  const LocationProgStep({super.key, required this.label, required this.state});

  @override
  Widget build(BuildContext context) {
    final barColor = switch (state) {
      LocationStepState.done   => AppColors.primary,
      LocationStepState.active => AppColors.primary,
      LocationStepState.idle   => AppColors.outlineVariant,
    };
    final textColor = switch (state) {
      LocationStepState.done   => AppColors.primary,
      LocationStepState.active => AppColors.primary,
      LocationStepState.idle   => AppColors.onSurfaceVariant,
    };
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'HankenGrotesk',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class LocationProgConnector extends StatelessWidget {
  final bool active;
  const LocationProgConnector({super.key, required this.active});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 4,
            color: active ? AppColors.primary : AppColors.outlineVariant,
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }
}
