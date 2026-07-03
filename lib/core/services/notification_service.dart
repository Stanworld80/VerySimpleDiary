import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle payload / Deep Link
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          debugPrint("Notification clicked with payload: $payload");
        }
      },
    );
  }

  static Future<void> requestPermissions() async {
    final androidImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  static Future<void> schedulePeriodNotifications({
    required List<String> activePeriods,
  }) async {
    await _notificationsPlugin.cancelAll();

    final Map<String, TimeOfDay> periodTimes = {
      'nuit': const TimeOfDay(hour: 5, minute: 0),
      'matin': const TimeOfDay(hour: 11, minute: 0),
      'journee': const TimeOfDay(hour: 17, minute: 0),
      'soir': const TimeOfDay(hour: 23, minute: 0),
    };

    for (final period in activePeriods) {
      final time = periodTimes[period.toLowerCase()];
      if (time == null) continue;

      final id = _getNotificationId(period);
      
      final String periodLabel = period[0].toUpperCase() + period.substring(1);
      const String title = "Rappel Very Simple Diary";
      final String body = "La période de $periodLabel est terminée. Prenez quelques secondes pour remplir votre journal !";

      await _scheduleDailyNotification(
        id: id,
        title: title,
        body: body,
        hour: time.hour,
        minute: time.minute,
        payload: "period=$period",
      );
    }
  }

  static int _getNotificationId(String period) {
    switch (period.toLowerCase()) {
      case 'nuit': return 101;
      case 'matin': return 102;
      case 'journee': return 103;
      case 'soir': return 104;
      default: return 100;
    }
  }

  static Future<void> _scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required String payload,
  }) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'diary_reminders',
      'Rappels du journal',
      channelDescription: 'Notifications de rappel de fin de période',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        platformDetails,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
      debugPrint("Scheduled notification id $id for $hour:$minute daily");
    } catch (e) {
      debugPrint("Error scheduling notification: $e");
    }
  }

  static Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}

class TimeOfDay {
  final int hour;
  final int minute;
  const TimeOfDay({required this.hour, required this.minute});
}
