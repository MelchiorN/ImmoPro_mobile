import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/di/service_locator.dart';
import '../../../notifications/presentation/controllers/notifications_controller.dart';

/// AppBar de l'accueil — utilisée comme `appBar:` du Scaffold.
/// Flutter gère automatiquement le padding de la status bar.
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String userName;
  final NotificationsController? notificationsController;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;

  const HomeAppBar({
    super.key,
    required this.userName,
    this.notificationsController,
    this.onNotificationTap,
    this.onProfileTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final user = ServiceLocator.instance.currentUser;
    final profilePicture = user?.profilePicture;

    return AppBar(
      backgroundColor: AppColors.primaryContainer,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      // Force la status bar à avoir des icônes blanches sur fond bleu
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [ 
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                userName.isNotEmpty ? 'Bonjour $userName ' : 'Bienvenue',
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Notifications
            IconButton(
              onPressed: onNotificationTap,
              icon: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: notificationsController != null
                    ? ListenableBuilder(
                        listenable: notificationsController!,
                        builder: (context, _) => _bellIcon(
                          notificationsController!.unreadCount,
                        ),
                      )
                    : _bellIcon(0),
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 6),
            // Avatar profil
            GestureDetector(
              onTap: onProfileTap,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: _buildAvatar(profilePicture, user?.firstName),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bellIcon(int unreadCount) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Center(
          child: Icon(
            Icons.notifications_outlined,
            color: Colors.white,
            size: 20,
          ),
        ),
        if (unreadCount > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFFE53935),
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAvatar(String? profilePicture, String? firstName) {
    if (profilePicture != null && profilePicture.isNotEmpty) {
      return Image.network(
        profilePicture,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildInitials(firstName),
      );
    }
    return _buildInitials(firstName);
  }

  Widget _buildInitials(String? firstName) {
    final initial = (firstName != null && firstName.isNotEmpty)
        ? firstName[0].toUpperCase()
        : '?';
    return Container(
      color: const Color(0xFF1A56A0),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
