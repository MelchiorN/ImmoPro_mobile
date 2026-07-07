import 'package:flutter/material.dart';

/// Indicateur de progression visuel — petits points/traits pour les 4 étapes.
class StepIndicator extends StatelessWidget {
  final int currentStep; // 0-based (0 à 3)
  final int totalSteps;

  const StepIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalSteps, (i) {
        final isActive = i == currentStep;
        final isDone = i < currentStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: isDone || isActive
                ? Colors.white
                : Colors.white.withValues(alpha: 0.35),
          ),
        );
      }),
    );
  }
}
