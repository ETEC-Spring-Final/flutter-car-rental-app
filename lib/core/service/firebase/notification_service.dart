import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Initialize Firebase notification service
  Future<void> initialize() async {
    await _requestPermission();

    await _initializeLocalNotifications();

    await _createNotificationChannel();

    await _printFcmToken();

    _listenToForegroundMessages();

    _listenToTokenRefresh();
  }

  /// Request notification permission
  Future<void> _requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    log(
      'Notification permission: '
      '${settings.authorizationStatus}',
    );
  }

  /// Initialize flutter_local_notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(settings: initializationSettings);
  }

  /// Create Android notification channel
  Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      'payment_notifications',
      'Payment Notifications',
      description: 'Notifications related to payments and bookings',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// Get current FCM token
  Future<String?> getFcmToken() async {
    final token = await _firebaseMessaging.getToken();

    log('======================================');
    log('🔥 FCM TOKEN');
    log('$token');
    log('======================================');

    return token;
  }

  /// Only print token during initialization
  Future<void> _printFcmToken() async {
    await getFcmToken();
  }

  /// Listen when application is in foreground
  void _listenToForegroundMessages() {
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  /// Listen when Firebase changes the token
  void _listenToTokenRefresh() {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      log('======================================');
      log('🔥 FCM TOKEN REFRESHED');
      log(newToken);
      log('======================================');

      // IMPORTANT:
      // Send this new token to backend.
      //
      // We will implement that through your device repository.
    });
  }

  /// Handle foreground notification
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    log('======================================');
    log('🔥 FCM MESSAGE RECEIVED');
    log('Title: ${message.notification?.title}');
    log('Body: ${message.notification?.body}');
    log('Data: ${message.data}');
    log('======================================');

    final notification = message.notification;

    if (notification == null) {
      return;
    }

    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'payment_notifications',
          'Payment Notifications',
          channelDescription: 'Notifications related to payments and bookings',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
      ),
    );
  }
}
