import 'package:flutter/foundation.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notifications_repository.dart';

enum NotificationsStatus { initial, loading, loaded, error }

class NotificationsController extends ChangeNotifier {
  final NotificationsRepository _repository;

  NotificationsController([NotificationsRepository? repository])
      : _repository = repository ?? NotificationsRepository();

  NotificationsStatus _status = NotificationsStatus.initial;
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  String? _errorMessage;

  NotificationsStatus get status => _status;
  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _status = NotificationsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getNotifications();
      _notifications = result.notifications;
      _unreadCount   = result.unreadCount;
      _status        = NotificationsStatus.loaded;
    } catch (e) {
      _errorMessage = 'Impossible de charger les notifications.';
      _status       = NotificationsStatus.error;
    }

    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    try {
      await _repository.markAsRead(id);
      _notifications = _notifications
          .map((n) => n.id == id ? n.copyWith(lu: true, luAt: DateTime.now()) : n)
          .toList();
      _unreadCount = _notifications.where((n) => !n.lu).length;
      notifyListeners();
    } catch (_) {
      // Silencieux : l'UI reste cohérente localement
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      _notifications = _notifications
          .map((n) => n.copyWith(lu: true, luAt: DateTime.now()))
          .toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (_) {
      // Silencieux
    }
  }
}
