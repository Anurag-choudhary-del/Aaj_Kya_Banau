import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class MealReminder {
  const MealReminder({
    required this.date,
    required this.category,
    required this.dish,
  });

  final DateTime date;
  final String category;
  final String dish;
}

/// Schedules reminders only for meals the user explicitly selected.
class MealNotificationService {
  MealNotificationService._();
  static final MealNotificationService instance = MealNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
    } catch (error) {
      debugPrint('Could not resolve device timezone for reminders: $error');
    }
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(const InitializationSettings(android: android, iOS: ios));
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    await initialize();
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final androidGranted = await android?.requestNotificationsPermission();
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    final iosGranted = await ios?.requestPermissions(alert: true, badge: true, sound: true);
    return androidGranted ?? iosGranted ?? true;
  }

  Future<void> cancelMealReminders() async {
    await initialize();
    final pending = await _plugin.pendingNotificationRequests();
    for (final request in pending) {
      if (request.payload?.startsWith('meal:') ?? false) {
        await _plugin.cancel(request.id);
      }
    }
  }

  /// Schedules explicitly selected meals for the next 45 days. Breakfast,
  /// lunch and snacks are reminded the previous evening; dinner is reminded
  /// at 12:30 PM on the day it is planned.
  Future<void> schedule({
    required bool enabled,
    required String language,
    required List<MealReminder> reminders,
  }) async {
    await initialize();
    await cancelMealReminders();
    if (!enabled || reminders.isEmpty) return;

    final permission = await _hasPermissionOrRequest();
    if (!permission) return;

    for (final reminder in reminders) {
      final day = DateTime(reminder.date.year, reminder.date.month, reminder.date.day);
      final int hour;
      final int minute;
      final DateTime notificationDate;
      switch (reminder.category) {
        case 'Breakfast':
          notificationDate = day.subtract(const Duration(days: 1));
          hour = 19;
          minute = 0;
          break;
        case 'Lunch':
          notificationDate = day.subtract(const Duration(days: 1));
          hour = 19;
          minute = 15;
          break;
        case 'Snacks':
          notificationDate = day.subtract(const Duration(days: 1));
          hour = 19;
          minute = 30;
          break;
        case 'Dinner':
          notificationDate = day;
          hour = 12;
          minute = 30;
          break;
        default:
          continue;
      }
      final id = _notificationId(day, reminder.category);
      await _scheduleAt(
        id,
        notificationDate,
        hour,
        minute,
        _title(language, reminder.category),
        _body(language, reminder.category, reminder.dish),
      );
    }
  }

  int _notificationId(DateTime day, String category) {
    final categoryId = switch (category) {
      'Breakfast' => 1,
      'Lunch' => 2,
      'Dinner' => 3,
      _ => 4,
    };
    return day.year * 100000 + day.month * 1000 + day.day * 10 + categoryId;
  }

  Future<bool> _hasPermissionOrRequest() async {
    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final enabled = await android?.areNotificationsEnabled();
    if (enabled == false) {
      return (await android?.requestNotificationsPermission()) ?? false;
    }
    return true;
  }

  Future<void> _scheduleAt(int id, DateTime date, int hour, int minute, String title, String body) async {
    final when = tz.TZDateTime(tz.local, date.year, date.month, date.day, hour, minute);
    if (!when.isAfter(tz.TZDateTime.now(tz.local))) return;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'meal_plan_reminders',
        'Meal plan reminders',
        channelDescription: 'Reminders for meals explicitly selected in the meal planner',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      when,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'meal:$id',
    );
  }

  String _title(String language, String category) {
    if (language == 'Hindi') {
      return switch (category) {
        'Breakfast' => 'कल के नाश्ते की याद',
        'Lunch' => 'कल के दोपहर के खाने की याद',
        'Dinner' => 'आज रात के खाने की याद',
        _ => 'कल के स्नैक्स की याद',
      };
    }
    if (language == 'Hinglish') {
      return switch (category) {
        'Breakfast' => 'Kal breakfast reminder',
        'Lunch' => 'Kal lunch reminder',
        'Dinner' => 'Aaj dinner reminder',
        _ => 'Kal snacks reminder',
      };
    }
    return switch (category) {
      'Breakfast' => 'Tomorrow’s breakfast reminder',
      'Lunch' => 'Tomorrow’s lunch reminder',
      'Dinner' => 'Tonight’s dinner reminder',
      _ => 'Tomorrow’s snacks reminder',
    };
  }

  String _body(String language, String category, String dish) {
    if (language == 'Hindi') {
      final label = switch (category) {
        'Breakfast' => 'कल नाश्ते में',
        'Lunch' => 'कल दोपहर के खाने में',
        'Dinner' => 'आज रात के खाने में',
        _ => 'कल स्नैक्स में',
      };
      return '$label $dish बनाने का प्लान है। क्या आपके पास सारी सामग्री है?';
    }
    if (language == 'Hinglish') {
      final label = switch (category) {
        'Breakfast' => 'Kal breakfast mein',
        'Lunch' => 'Kal lunch mein',
        'Dinner' => 'Aaj dinner mein',
        _ => 'Kal snacks mein',
      };
      return '$label $dish banane ka plan hai. Kya aapke paas saara samaan hai?';
    }
    final when = switch (category) {
      'Breakfast' => 'for breakfast tomorrow',
      'Lunch' => 'for lunch tomorrow',
      'Dinner' => 'for dinner today',
      _ => 'for snacks tomorrow',
    };
    return 'You planned $dish $when. Do you have all the ingredients?';
  }
}
