import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class SearchSection extends StatefulWidget {
  final ValueChanged<String>? onSearch;
  final VoidCallback? onFilterTap;

  const SearchSection({
    super.key,
    this.onSearch,
    this.onFilterTap,
  });

  @override
  State<SearchSection> createState() => _SearchSectionState();
}

class _SearchSectionState extends State<SearchSection> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
              color: const Color(0xFF1A56A0).withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _controller,
          onSubmitted: widget.onSearch,
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
            prefixIconConstraints: const BoxConstraints(
              minWidth: 48,
            ),
            suffixIcon: GestureDetector(
              onTap: widget.onFilterTap,
              child: const Padding(
                padding: EdgeInsets.only(right: 16, left: 8),
                child: Icon(
                  Icons.tune,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
            ),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 48,
            ),
          ),
        ),
      ),
    );
  }
}
