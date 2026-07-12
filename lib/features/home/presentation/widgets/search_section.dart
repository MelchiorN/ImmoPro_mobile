import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SearchSection extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onSearch;
  final VoidCallback? onFilterTap;
  final bool hasActiveFilters;

  const SearchSection({
    super.key,
    this.controller,
    this.onSearch,
    this.onFilterTap,
    this.hasActiveFilters = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEBF4FB),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A56A0).withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          onSubmitted: onSearch,
          style: const TextStyle(
            fontFamily: 'HankenGrotesk',
            fontSize: 16,
            color: AppColors.onSurface,
          ),
          decoration: InputDecoration(
            hintText: 'Où cherchez-vous ?',
            hintStyle: const TextStyle(
              fontFamily: 'HankenGrotesk',
              fontSize: 16,
              color: AppColors.onSurfaceVariant,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 48,
              vertical: 16,
            ),
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 16, right: 8),
              child: Icon(
                Icons.search,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 48),
            suffixIcon: GestureDetector(
              onTap: onFilterTap,
              child: Padding(
                padding: const EdgeInsets.only(right: 14, left: 8),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.tune,
                      color: hasActiveFilters
                          ? AppColors.primaryContainer
                          : AppColors.primary,
                      size: 24,
                    ),
                    if (hasActiveFilters)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            suffixIconConstraints: const BoxConstraints(minWidth: 48),
          ),
        ),
      ),
    );
  }
}
