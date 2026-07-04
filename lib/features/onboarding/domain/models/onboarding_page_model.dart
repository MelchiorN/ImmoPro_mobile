import 'package:flutter/material.dart';

class OnboardingPageModel {
  final String title;
  final String description;
  /// Illustration vectorielle (slides 1-3 seulement)
  final IconData? illustrationIcon;
  final Color? iconColor;
  final Color? bgColor;
  /// Si true → slide 4 avec hero photo
  final bool useHeroImage;

  const OnboardingPageModel({
    required this.title,
    required this.description,
    this.illustrationIcon,
    this.iconColor,
    this.bgColor,
    this.useHeroImage = false,
  });
}
