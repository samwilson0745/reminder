import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationApi{
  static final _notifications = FlutterLocalNotificationsPlugin();
  static final onNotifications = BehaviorSubject<String?>();
  static Future  _notificationDetails() async{
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'channel id',
        'channel name',
        importance: Importance.max,
      ),
      iOS: IOSNotificationDetails()
    );
  }
  static Future init({bool initScheduled = false})async{
    var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid,iOS: IOSInitializationSettings());
    await _notifications.initialize(initializationSettings);
  }

  static Future showNotification({
    int id=0,
    String? title,
    String? body,
    String? payload,
  })async => _notifications.show(id, title, body,await _notificationDetails(),payload: payload);

  static Future showScheduledNotification({
    int id=0,
    String? title,
    String? body,
    String? payload,
    required DateTime scheduledDate
  })async => _notifications.zonedSchedule(
      id, title, body,
      _scheduleDaily(Time(scheduledDate.hour,scheduledDate.minute)),
      await _notificationDetails(),
      payload: payload,
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
  );
  static tz.TZDateTime _scheduleDaily(Time time){
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate = tz.TZDateTime(tz.local,now.year,now.month,now.day,time.hour,time.minute,time.second);
    return scheduledDate.isBefore(now)?scheduledDate.add(Duration(days:1)):scheduledDate;
  }
}

