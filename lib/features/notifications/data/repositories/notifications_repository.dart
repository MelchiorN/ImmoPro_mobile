import '../datasources/notifications_remote_datasource.dart';
import '../models/notification_model.dart';

class NotificationsRepository {
  final NotificationsRemoteDataSource _dataSource;

  NotificationsRepository([NotificationsRemoteDataSource? dataSource])
      : _dataSource = dataSource ?? NotificationsRemoteDataSourceImpl();

  Future<({List<NotificationModel> notifications, int unreadCount})> getNotifications() =>
      _dataSource.getNotifications();

  Future<void> markAsRead(String id) => _dataSource.markAsRead(id);

  Future<void> markAllAsRead() => _dataSource.markAllAsRead();
}
