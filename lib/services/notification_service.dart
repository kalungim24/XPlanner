import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone
    tz.initializeTimeZones();

    // Request notification permission
    await _requestPermission();

    // Android initialization settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Initialization settings
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize the plugin
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  Future<void> _requestPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap if needed
  }

  Future<void> scheduleTaskReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await initialize();

    // Schedule reminder 1 hour before the deadline
    final reminderTime = scheduledDate.subtract(const Duration(hours: 1));
    
    // Convert to local timezone
    final scheduledTime = tz.TZDateTime.from(reminderTime, tz.local);

    // Don't schedule if the time is in the past
    if (scheduledTime.isBefore(tz.TZDateTime.now(tz.local))) {
      // If reminder time is in the past, schedule for the deadline time instead
      final deadlineTime = tz.TZDateTime.from(scheduledDate, tz.local);
      if (deadlineTime.isBefore(tz.TZDateTime.now(tz.local))) {
        return; // Deadline is also in the past, don't schedule
      }
      // Schedule at deadline time if reminder time has passed
      final finalTime = deadlineTime;
      await _scheduleNotification(id, title, body, finalTime);
      return;
    }
    
    await _scheduleNotification(id, title, body, scheduledTime);
  }

  Future<void> _scheduleNotification(
    int id,
    String title,
    String body,
    tz.TZDateTime scheduledTime,
  ) async {

    // Android notification details
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'task_reminders',
      'Task Reminders',
      channelDescription: 'Notifications for task deadlines',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    // iOS notification details
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    // Notification details
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Schedule the notification
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelReminder(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
  }

  // Generate a unique ID from task ID string
  int getNotificationId(String taskId) {
    return taskId.hashCode.abs() % 2147483647; // Max int for notification ID
  }
}

