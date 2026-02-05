import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
  static FlutterLocalNotificationsPlugin? _notificationsPlugin;

  static Future<void> _initialize() async {
    if (_notificationsPlugin != null) return;
    _notificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initializationSettingsIOS = DarwinInitializationSettings();

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin!.initialize(settings: initializationSettings);
  }

  static void ensureInitialized() async {
    await _initialize();

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin!
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  static Future<void> sendNotificationsFor(Map<String, String> reports) async {
    if (reports.isEmpty) return;

    await _initialize();

    int notificationId = 0;
    for (var entry in reports.entries) {
      await _showNotification(
        id: notificationId++,
        title: '${entry.key} big report!',
        body: '${entry.value} lei',
      );
    }
  }

  static Future<void> sendNotificationsFromBackground(
    Map<String, String> reports,
  ) async {
    if (reports.isEmpty) return;

    await _initialize();

    int notificationId = 0;
    for (var entry in reports.entries) {
      await _showNotification(
        id: notificationId++,
        title: '${entry.key} big report!',
        body: '${entry.value} lei',
      );
    }
  }

  static Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'lotto_report_channel',
          'Lotto Report Notifications',
          channelDescription: 'Notifications for Lotto reports',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: false,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _notificationsPlugin!.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
    );
  }
}
