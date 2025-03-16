import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseApi {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize Firebase Messaging and Local Notifications
  Future<void> initNotifications() async {
    // Request Notification Permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('User permission: ${settings.authorizationStatus}');

    // Get FCM Token
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');

    // Handle Notifications
    _initLocalNotifications();
    _setupFCMHandlers();
  }

  /// Initialize Local Notifications for Foreground Messages
  void _initLocalNotifications() {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@drawable/arrhn_logo2k25');

    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    _localNotificationsPlugin.initialize(initSettings);
  }

  /// Create Notification Channel (Required for Android 8+)
  // Future<void> _createNotificationChannel() async {
  //   const AndroidNotificationChannel channel = AndroidNotificationChannel(
  //     'high_importance_channel', // Must match Firebase payload
  //     'Important Notifications',
  //     description: 'This channel is used for important notifications.',
  //     importance: Importance.high,
  //   );

  //   await _localNotificationsPlugin
  //       .resolvePlatformSpecificImplementation<
  //           AndroidFlutterLocalNotificationsPlugin>()
  //       ?.createNotificationChannel(channel);
  // }

  /// Listen to FCM Messages
  void _setupFCMHandlers() {
    // Foreground Notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground Message: ${message.notification?.title}');
      // _showLocalNotification(message);
    });

    // Background Notifications (User taps notification)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('User opened notification: ${message.notification?.title}');
    });

    // Terminated State (App launched via notification)
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        print('App launched from notification: ${message.notification?.title}');
      }
    });
  }

  //Show Local Notification
  // Future<void> _showLocalNotification(RemoteMessage message) async {
  //   const AndroidNotificationDetails androidDetails =
  //       AndroidNotificationDetails(
  //     'high_importance_channel', // Must match Firebase payload
  //     'Important Notifications',
  //     importance: Importance.high,
  //     priority: Priority.high,
  //     icon: '@drawable/arrhn_logo2k25',
  //   );

  //   const NotificationDetails details = NotificationDetails(
  //     android: androidDetails,
  //   );

  //   await _localNotificationsPlugin.show(
  //     0,
  //     message.notification?.title ?? 'No Title',
  //     message.notification?.body ?? 'No Body',
  //     details,
  //   );
  // }
}
