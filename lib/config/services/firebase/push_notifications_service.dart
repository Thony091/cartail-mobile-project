import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:portafolio_project/config/constants/secure_storage_keys.dart';
import 'package:portafolio_project/config/services/secure_storage_service.dart';
import 'package:portafolio_project/firebase_options.dart';

class PushNotificationsService {
  static final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin
      _localNotifications = FlutterLocalNotificationsPlugin();

  static final _secureStorage = SecureStorageService.instance;

  static String? fcmToken;

  // 🔹 Canal Android (obligatorio)
  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    'default_channel',
    'Default Notifications',
    description: 'Canal principal',
    importance: Importance.high,
  );

  static Future<void> init() async {
    final initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _onMessageOpenedApp(initialMessage);
    }
    // 🔹 Permisos
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    // 🔹 Token APNs (iOS necesita esto)
    final apnsToken = await _messaging.getAPNSToken();
    print('🍎 APNs Token: $apnsToken');

    // 🔹 Token inicial
    final token = await _messaging.getToken();
    await _persistFcmToken(token);
    print('🔥 FCM Token: $token');

    // 🔹 Renovación de token
    _messaging.onTokenRefresh.listen((newToken) async {
      await _persistFcmToken(newToken);
      print('🔄 Nuevo token: $newToken');
    });

    // 🔹 Local notifications
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _localNotifications.initialize(initializationSettings);

    // 🔹 Android channel
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    // 🔹 Listeners
    FirebaseMessaging.onMessage.listen(_onMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
  }

  // 🔹 Foreground
  static Future<void> _onMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'default_channel',
          'Default Notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // 🔹 Tap en notificación
  static Future<void> _onMessageOpenedApp(
      RemoteMessage message,
  ) async {
    print('👉 Notificación tocada');
    // Aquí navegas con go_router usando message.data
  }

  static Future<void> _persistFcmToken(String? token) async {
    fcmToken = token;
    if (token == null) {
      await _secureStorage.delete(key: secureStorageFcmTokenKey);
      return;
    }
    await _secureStorage.write(
      key: secureStorageFcmTokenKey,
      value: token,
    );
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message,
) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Aquí solo lógica mínima (no UI)
  print('📩 Background message: ${message.messageId}');
}
