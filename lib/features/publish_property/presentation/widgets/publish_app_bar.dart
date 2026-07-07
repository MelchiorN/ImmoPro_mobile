import 'package:flutter/material.dart';
import 'step_indicator.dart';

/// AppBar commune au flow "Publier un bien".
/// Affiche le titre, le sous-titre d'étape et l'indicateur de points.
class PublishAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final int currentStep; // 0-based (0 → étape 1)
  final int totalSteps;
  final VoidCallback? onBack;

  const PublishAppBar({
    super.key,
    required this.title,
    required this.currentStep,
    this.totalSteps = 4,
    this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF003E7E),
      foregroundColor: Colors.white,
      elevation: 2,
      shadowColor: Colors.black26,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: onBack ?? () => Navigator.of(context).maybePop(),
      ),
      titleSpacing: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Text(
            'Étape ${currentStep + 1} sur $totalSteps',
            style: const TextStyle(
              fontFamily: 'HankenGrotesk',
              fontSize: 11,
              color: Color(0xBFFFFFFF),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: StepIndicator(
              currentStep: currentStep,
              totalSteps: totalSteps,
            ),
          ),
        ),
      ],
    );
  }
}
