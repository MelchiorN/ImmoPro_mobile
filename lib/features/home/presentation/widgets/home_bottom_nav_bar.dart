import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class HomeBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const HomeBottomNavBar({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A56A0).withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: AppColors.outlineVariant.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _NavItem(
              icon: Icons.home,
              label: 'Accueil',
              isActive: currentIndex == 0,
              onTap: () => onTap?.call(0),
            ),
            _NavItem(
              icon: Icons.search,
              label: 'Recherche',
              isActive: currentIndex == 1,
              onTap: () => onTap?.call(1),
            ),
            // Bouton central "Vendre"
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => onTap?.call(2),
                  child: Transform.translate(
                    offset: const Offset(0, -8),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1A56A0).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Vendre',
                  style: TextStyle(
                    fontFamily: 'HankenGrotesk',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.05 * 11,
                  ),
                ),
              ],
            ),
            _NavItem(
              icon: Icons.favorite_border,
              label: 'Mes Biens',
              isActive: currentIndex == 3,
              onTap: () => onTap?.call(3),
            ),
            _NavItem(
              icon: Icons.person_outline,
              label: 'Profil',
              isActive: currentIndex == 4,
              onTap: () => onTap?.call(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'HankenGrotesk',
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
                letterSpacing: 0.05 * 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
