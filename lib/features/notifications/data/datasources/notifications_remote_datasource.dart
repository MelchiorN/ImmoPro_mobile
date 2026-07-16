import '../../../../core/network/api_client.dart';
import '../models/notification_model.dart';

abstract class NotificationsRemoteDataSource {
  Future<({List<NotificationModel> notifications, int unreadCount})> getNotifications();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
}

class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  final ApiClient _api;

  NotificationsRemoteDataSourceImpl([ApiClient? api])
      : _api = api ?? ApiClient.instance;

  @override
  Future<({List<NotificationModel> notifications, int unreadCount})> getNotifications() async {
    final response = await _api.getAuth('/client/notifications');
    final data = response['data'] as List<dynamic>? ?? [];
    final unreadCount = response['unread_count'] as int? ?? 0;

    final notifications = data
        .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return (notifications: notifications, unreadCount: unreadCount);
  }

  @override
  Future<void> markAsRead(String id) async {
    await _api.patchAuth('/client/notifications/$id/read');
  }

  @override
  Future<void> markAllAsRead() async {
    await _api.postAuth('/client/notifications/read-all');
  }
}
