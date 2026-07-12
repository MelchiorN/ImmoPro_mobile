import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/di/service_locator.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../profile/presentation/pages/profile_page.dart';

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
    // Padding bas pour la barre de navigation système (gestures Android / home indicator iOS)
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      // Hauteur dynamique : nav + espace système (pas de hauteur fixe pour éviter l'overflow)
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A56A0).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPad, top: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _NavItem(
              icon: Icons.home_rounded,
              label: 'Accueil',
              isActive: currentIndex == 0,
              onTap: () => onTap?.call(0),
            ),
            _NavItem(
              icon: Icons.search_rounded,
              label: 'Recherche',
              isActive: currentIndex == 1,
              onTap: () => onTap?.call(1),
            ),
            // Bouton central "Publier"
            const _PublishButton(),
            _NavItem(
              icon: Icons.favorite_border_rounded,
              label: 'Favoris',
              isActive: currentIndex == 3,
              onTap: () => onTap?.call(3),
            ),
            _buildProfileNavItem(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileNavItem(BuildContext context) {
    final user = ServiceLocator.instance.currentUser;
    final isActive = currentIndex == 4;

    Widget avatarWidget;
    if (user != null &&
        user.profilePicture != null &&
        user.profilePicture!.isNotEmpty) {
      avatarWidget = Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive
                ? AppColors.primary
                : AppColors.outlineVariant.withValues(alpha: 0.6),
            width: 1.5,
          ),
        ),
        child: ClipOval(
          child: Image.network(
            user.profilePicture!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                _buildInitialsAvatar(user, isActive),
          ),
        ),
      );
    } else if (user != null) {
      avatarWidget = Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive
                ? AppColors.primary
                : AppColors.outlineVariant.withValues(alpha: 0.6),
            width: 1.5,
          ),
        ),
        child: ClipOval(child: _buildInitialsAvatar(user, isActive)),
      );
    } else {
      avatarWidget = Icon(
        Icons.person_outline_rounded,
        color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
        size: 26,
      );
    }

    return _NavItem(
      icon: Icons.person_outline_rounded,
      customIcon: avatarWidget,
      label: 'Profil',
      isActive: isActive,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ProfilePage()),
        );
      },
    );
  }

  Widget _buildInitialsAvatar(UserEntity user, bool isActive) {
    final initial =
        user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '?';
    return Container(
      color:
          isActive ? AppColors.primaryContainer : AppColors.surfaceContainer,
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontFamily: 'HankenGrotesk',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color:
                isActive ? Colors.white : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

// ─── Bouton central Publier ───────────────────────────────────────────────────

class _PublishButton extends StatelessWidget {
  const _PublishButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/publish'),
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryContainer.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.add_rounded,
                  color: Colors.white, size: 26),
            ),
            const SizedBox(height: 3),
            const Text(
              'Publier',
              style: TextStyle(
                fontFamily: 'HankenGrotesk',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Item de navigation ───────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  final IconData icon;
  final Widget? customIcon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    this.customIcon,
    required this.label,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            customIcon ??
                Icon(
                  icon,
                  color: isActive
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                  size: 24,
                ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'HankenGrotesk',
                fontSize: 10,
                fontWeight:
                    isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
