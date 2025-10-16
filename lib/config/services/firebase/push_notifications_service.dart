import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotificationsService {

  static FirebaseMessaging messaging = FirebaseMessaging.instance; // Para saber todo del proyecto con respecto a firebase
  static FlutterLocalNotificationsPlugin flutterLocalNotification = FlutterLocalNotificationsPlugin();
  static String? token;

  static Future initNotifications () async {

    await messaging.requestPermission();

    final token = await FirebaseMessaging.instance.getToken();
    // ignore: avoid_print
    print('FCM-token: $token');

    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
    FirebaseMessaging.onMessage.listen(_onMessageHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenApp);

    const AndroidInitializationSettings androidInitializationSettings =       
      AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInitializationSettings = DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings
    );

    await flutterLocalNotification.initialize(initializationSettings);
    await _initLocalNotifications();

  }


  /// Mensajes en segundo plano 
  static Future _backgroundHandler(RemoteMessage message) async{
    print (' *** onBackgroundHandler ***');
  }

  // mensajes con la apicacion abierta
  static Future _onMessageHandler(RemoteMessage message) async{
    print('*** onMessageHandler ***');

    const androidDetails = AndroidNotificationDetails(
      'channelId', 
      'channelName',
      priority: Priority.high,
      playSound: true,
      enableVibration: true
    );

    const iOSDetails = DarwinNotificationDetails();

    const generalNotificationDetail = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    final notification = message.notification;

    await flutterLocalNotification.show(
      notification.hashCode,
      notification?.title ?? 'no-title',
      notification?.body ?? 'no-body',
      generalNotificationDetail,
    );
  }

  static Future _onMessageOpenApp(RemoteMessage message) async{
  }

  /// Local Notifications
  static _initLocalNotifications() async {
    const AndroidInitializationSettings androidInitializationSettings =             
      AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings iosInitializationSettings = DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await flutterLocalNotification.initialize( initializationSettings );
  }

}
