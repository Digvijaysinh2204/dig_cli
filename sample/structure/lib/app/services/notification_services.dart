import 'dart:io';

import '../utils/import.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  kLog(
    content: 'Background notification tapped: ${notificationResponse.payload}',
    title: 'BACKGROUND_NOTIFICATION_TAP',
  );
}

class NotificationService extends GetxService {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'default_notification_channel_id';
  static const String _channelName = 'Default Notification Channel';

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    _channelId,
    _channelName,
    description: _channelName,
    importance: Importance.max,
    playSound: true,
    showBadge: true,
  );

  @override
  void onInit() {
    init();
    super.onInit();
  }

  Future<NotificationService> init() async {
    await _setupIOS();
    await _requestNotificationPermission();
    await _initializeFlutterLocalNotifications();
    _initializeFirebaseListeners();
    await _handleLaunchNotification();
    return this;
  }

  void _updateNotificationCount() {
    try {} catch (e) {
      kLog(content: e, title: 'COUNT_UPDATE_ERROR');
    }
  }

  int _createUniqueId() =>
      DateTime.now().millisecondsSinceEpoch.remainder(100000);

  void _initializeFirebaseListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      try {
        kLog(content: message.toMap(), title: 'FOREGROUND_NOTIFICATION');
        _updateNotificationCount();
        await _showNotification(message: message);
      } catch (e) {
        kLog(content: e, title: 'FOREGROUND_NOTIFICATION_ERROR');
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      kLog(content: 'App opened from background', title: 'NOTIFICATION_STATE');
      _updateNotificationCount();
      await _handleMessageFromData(message.data);
    });
  }

  Future<void> _initializeFlutterLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();

    final settings = const InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    await _flutterLocalNotificationsPlugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload != null) {
          final Map<String, dynamic> payload = jsonDecode(response.payload!);
          _updateNotificationCount();
          await _handleMessageFromData(payload);
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  Future<void> _showNotification({required RemoteMessage message}) async {
    if (message.notification == null) return;
    if (Platform.isIOS && message.notification?.apple != null) return;

    final androidDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: _channel.importance,
      priority: Priority.high,
      playSound: _channel.playSound,
      icon: '@drawable/notification',
      color: const Color(0xFF9A80AF),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id: _createUniqueId(),
      title: message.notification?.title,
      body: message.notification?.body,
      notificationDetails: notificationDetails,
      payload: jsonEncode(message.data),
    );

    kLog(content: 'Local notification displayed', title: 'SHOW_NOTIFICATION');
  }

  Future<void> _handleMessageFromData(Map<String, dynamic> data) async {}

  Future<void> _handleLaunchNotification() async {
    final launchDetails = await _flutterLocalNotificationsPlugin
        .getNotificationAppLaunchDetails();

    if (launchDetails?.didNotificationLaunchApp ?? false) {
      final payload = launchDetails!.notificationResponse?.payload;
      kLog(content: payload, title: 'NOTIFICATION_PAYLOAD');
      if (payload != null) {
        final Map<String, dynamic> data = jsonDecode(payload);
        _updateNotificationCount();
        await _handleMessageFromData(data);
      }
    }

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      kLog(
        content: 'App opened from terminated (FCM)',
        title: 'NOTIFICATION_STATE',
      );
      _updateNotificationCount();
      await _handleMessageFromData(initialMessage.data);
    }
  }

  Future<void> _setupIOS() async {
    if (Platform.isIOS) {
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<void> _requestNotificationPermission() async {
    final settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      kLog(content: 'Permission granted', title: 'PERMISSION');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      kLog(content: 'Provisional permission', title: 'PERMISSION');
    } else {
      kLog(content: 'Permission denied', title: 'PERMISSION');
    }

    await getFirebaseToken();
  }

  Future<void> getFirebaseToken() async {
    try {
      if (Platform.isIOS) await messaging.getAPNSToken();
      final token = await messaging.getToken() ?? 'N/A';
      kLog(content: token, title: 'FIREBASE_TOKEN');
      StoreData.setData(StoreKey.firebaseToken, token);
    } catch (e) {
      kLog(content: e, title: 'FIREBASE_TOKEN_ERROR');
      StoreData.setData(StoreKey.firebaseToken, 'N/A');
    }
  }

  /*   void handleNotificationTap({required NotificationData data}) {
    kLog(content: data.toJson(), title: 'NOTIFICATION_DATA');

    if ((StoreData.readData<bool>(StoreKey.isLogin) ?? false)) {
      try {
        switch (data.type.toString().toLowerCase()) {
          default:
            Get.toNamed(AppRoute.notificationView);
            kLog(content: 'Notification opened for type: ${data.type}');
            break;
        }
      } catch (e) {
        kLog(content: e, title: 'NOTIFICATION_TAP_ERROR');
        Get.toNamed(AppRoute.notificationView);
      }
    }
  }
 */
}
