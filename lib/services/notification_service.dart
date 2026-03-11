import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    if (kIsWeb) return;
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> showStatusNotification({
    required String oldStatus,
    required String newStatus,
  }) async {
    if (kIsWeb) return;

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'status_updates',
      'Status Updates',
      channelDescription: 'Notifications for Bihar Student Credit Card status changes',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      styleInformation: BigTextStyleInformation(''),
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // Fun messages with emojis
    String title = "Status Jump Alert! 🚀";
    String body = "Good News! 🎊 Your application moved from '$oldStatus' ➡️ '$newStatus'. You're one step closer! 🎓💰";

    if (newStatus.toLowerCase().contains('payment')) {
      title = "Payment Milestone! 💸";
      body = "Awesome! 🥳 Stage: $newStatus. The money is on its way to your dreams! ✨";
    }

    await _notificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}
