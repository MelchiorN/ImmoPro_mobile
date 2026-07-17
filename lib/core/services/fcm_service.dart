import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../network/api_client.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  description: 'Ce canal est utilisé pour les notifications importantes.', // description
  importance: Importance.max,
);

/// Gère l'intégration Firebase Cloud Messaging (FCM).
///
/// Responsabilités :
///  1. Initialiser Firebase Messaging et demander les permissions
///  2. Récupérer le device token FCM
///  3. L'envoyer au backend via POST /api/device-token
///  4. Configurer les handlers de notifications (foreground / background / tap)
class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final ApiClient _api = ApiClient.instance;

  // ─────────────────────────────────────────────────────────────────────────
  // Initialisation — à appeler après login réussi
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> init() async {
    // 1. Demander les permissions (iOS + Android 13+)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('[FCM] Permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('[FCM] Permission refusée — push désactivé.');
      return;
    }

    // Configurer le canal pour Android
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Initialiser les notifications locales (pour Android au premier plan)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
    );

    // Configurer Firebase pour afficher les notifs au premier plan sur iOS
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. Récupérer et envoyer le token au backend
    await _registerToken();

    // 3. Rafraîchir le token si FCM le renouvelle
    _messaging.onTokenRefresh.listen((newToken) async {
      debugPrint('[FCM] Token renouvelé — envoi au backend.');
      await _sendTokenToBackend(newToken);
    });

    // 4. Handlers de notifications
    _setupNotificationHandlers();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Enregistrer le token
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _registerToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        debugPrint('[FCM] Token: $token');
        await _sendTokenToBackend(token);
      }
    } catch (e) {
      debugPrint('[FCM] Erreur récupération token: $e');
    }
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      await _api.postAuth('/device-token', {'device_token': token});
      debugPrint('[FCM] Token envoyé au backend.');
    } catch (e) {
      debugPrint('[FCM] Erreur envoi token: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Supprimer le token au logout
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> removeToken() async {
    try {
      await _api.deleteAuth('/device-token');
      await _messaging.deleteToken();
      debugPrint('[FCM] Token supprimé.');
    } catch (e) {
      debugPrint('[FCM] Erreur suppression token: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Handlers de notifications
  // ─────────────────────────────────────────────────────────────────────────

  void _setupNotificationHandlers() {
    // App au premier plan — afficher une notification système manuellement via flutter_local_notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[FCM] Notification reçue en foreground: ${message.notification?.title}');
      
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      // Si le message contient une notification et qu'on est sur Android, on l'affiche
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: '@mipmap/ic_launcher',
              priority: Priority.max,
              importance: Importance.max,
            ),
          ),
        );
      }

      // Optionnel : déclencher aussi votre logique d'UI interne si besoin
      _onMessageController?.call(message);
    });

    // App en arrière-plan, tap sur la notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[FCM] App ouverte via notification: ${message.notification?.title}');
      _onTapController?.call(message);
    });
  }

  // Callbacks optionnels pour réagir dans l'UI
  void Function(RemoteMessage)? _onMessageController;
  void Function(RemoteMessage)? _onTapController;

  void setOnMessage(void Function(RemoteMessage) callback) {
    _onMessageController = callback;
  }

  void setOnTap(void Function(RemoteMessage) callback) {
    _onTapController = callback;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Handler background (top-level, hors classe — requis par Firebase)
// ─────────────────────────────────────────────────────────────────────────────

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM Background] ${message.notification?.title}');
  // Pas besoin de faire quoi que ce soit : FCM affiche la notif automatiquement
}
