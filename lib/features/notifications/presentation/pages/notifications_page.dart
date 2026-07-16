import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../controllers/notifications_controller.dart';
import '../../data/models/notification_model.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late final NotificationsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = NotificationsController();
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              if (_controller.unreadCount == 0) return const SizedBox.shrink();
              return TextButton(
                onPressed: _controller.markAllAsRead,
                child: const Text(
                  'Tout lire',
                  style: TextStyle(
                    color: Colors.white70,
                    fontFamily: 'HankenGrotesk',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return switch (_controller.status) {
            NotificationsStatus.initial ||
            NotificationsStatus.loading => const Center(
                child: CircularProgressIndicator(color: AppColors.primaryContainer),
              ),
            NotificationsStatus.error => _buildError(),
            NotificationsStatus.loaded => _buildList(),
          };
        },
      ),
    );
  }

  Widget _buildList() {
    final items = _controller.notifications;

    if (items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none_rounded,
                size: 64, color: AppColors.outlineVariant),
            SizedBox(height: 16),
            Text(
              'Aucune notification',
              style: TextStyle(
                fontFamily: 'HankenGrotesk',
                fontSize: 16,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primaryContainer,
      onRefresh: _controller.load,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(
          height: 1,
          indent: 16,
          endIndent: 16,
          color: AppColors.outlineVariant,
        ),
        itemBuilder: (context, index) =>
            _NotificationTile(
              notification: items[index],
              onTap: () => _controller.markAsRead(items[index].id),
            ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded,
              size: 48, color: AppColors.outlineVariant),
          const SizedBox(height: 12),
          Text(
            _controller.errorMessage ?? 'Erreur de chargement',
            style: const TextStyle(
              fontFamily: 'HankenGrotesk',
              fontSize: 15,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _controller.load,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Réessayer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryContainer,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tuile notification
// ─────────────────────────────────────────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.lu;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: isUnread
            ? AppColors.primaryContainer.withValues(alpha: 0.05)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icône
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _iconColor(notification.type).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _iconData(notification.type),
                color: _iconColor(notification.type),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            // Contenu
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.titre,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 14,
                            fontWeight: isUnread
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: AppColors.onBackground,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 8, top: 4),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: const TextStyle(
                      fontFamily: 'HankenGrotesk',
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatDate(notification.createdAt),
                    style: const TextStyle(
                      fontFamily: 'HankenGrotesk',
                      fontSize: 11,
                      color: AppColors.outline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconData(String type) {
    return switch (type) {
      'visite_planifiee'  => Icons.calendar_month_rounded,
      'rapport_soumis'    => Icons.assignment_rounded,
      'bien_publie'       => Icons.home_rounded,
      'bien_rejete'       => Icons.cancel_rounded,
      _                   => Icons.notifications_rounded,
    };
  }

  Color _iconColor(String type) {
    return switch (type) {
      'visite_planifiee'  => AppColors.primaryContainer,
      'rapport_soumis'    => const Color(0xFF2E7D32),
      'bien_publie'       => const Color(0xFF1565C0),
      'bien_rejete'       => AppColors.error,
      _                   => AppColors.outline,
    };
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1)  return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24)   return 'Il y a ${diff.inHours} h';
    if (diff.inDays < 7)     return 'Il y a ${diff.inDays} j';

    // Format manuel dd/MM/yyyy
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }
}
