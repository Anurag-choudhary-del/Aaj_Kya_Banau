import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Device-local meal reminders. Only explicitly selected meals are scheduled.
class MealNotificationService {
  MealNotificationService._();
  static final MealNotificationService instance = MealNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const int _breakfastId = 71001;
  static const int _lunchId = 71002;
  static const int _dinnerId = 71003;
  static const int _snacksId = 71004;

  Future<void> initialize() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
    } catch (error) {
      // Keep the timezone database default if the device timezone is unavailable.
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
    final granted = await android?.requestNotificationsPermission();
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    final iosGranted = await ios?.requestPermissions(alert: true, badge: true, sound: true);
    return granted ?? iosGranted ?? true;
  }

  Future<void> cancelMealReminders() async {
    await initialize();
    for (final id in [_breakfastId, _lunchId, _dinnerId, _snacksId]) {
      await _plugin.cancel(id);
    }
  }

  /// Schedule the next day’s chosen breakfast/lunch/snacks and today’s chosen dinner.
  /// Breakfast/lunch/snacks reminders are at 19:00, 19:15 and 19:30 respectively;
  /// dinner reminder is at 12:30 on the day it is planned.
  Future<void> schedule({
    required bool enabled,
    required DateTime now,
    required String language,
    required String? breakfast,
    required String? lunch,
    required String? dinner,
    required String? snacks,
  }) async {
    await initialize();
    await cancelMealReminders();
    if (!enabled) return;

    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final permission = await _hasPermissionOrRequest();
    if (!permission) return;

    if (breakfast != null) {
      await _scheduleAt(_breakfastId, tomorrow, 19, 0,
        _title(language, 'breakfast'), _body(language, 'breakfast', breakfast));
    }
    if (lunch != null) {
      await _scheduleAt(_lunchId, tomorrow, 19, 15,
        _title(language, 'lunch'), _body(language, 'lunch', lunch));
    }
    if (snacks != null) {
      await _scheduleAt(_snacksId, tomorrow, 19, 30,
        _title(language, 'snacks'), _body(language, 'snacks', snacks));
    }
    if (dinner != null) {
      await _scheduleAt(_dinnerId, today, 12, 30,
        _title(language, 'dinner'), _body(language, 'dinner', dinner));
    }
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
    var when = tz.TZDateTime(tz.local, date.year, date.month, date.day, hour, minute);
    if (!when.isAfter(tz.TZDateTime.now(tz.local))) {
      // Never schedule a stale reminder; the next planner change can schedule the next date.
      return;
    }
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

  String _title(String language, String meal) {
    if (language == 'Hindi') {
      return switch (meal) {
        'breakfast' => 'कल के नाश्ते की याद',
        'lunch' => 'कल के दोपहर के खाने की याद',
        'dinner' => 'आज रात के खाने की याद',
        _ => 'कल के स्नैक्स की याद',
      };
    }
    if (language == 'Hinglish') {
      return switch (meal) {
        'breakfast' => 'Kal breakfast reminder',
        'lunch' => 'Kal lunch reminder',
        'dinner' => 'Aaj dinner reminder',
        _ => 'Kal snacks reminder',
      };
    }
    return switch (meal) {
      'breakfast' => 'Tomorrow’s breakfast reminder',
      'lunch' => 'Tomorrow’s lunch reminder',
      'dinner' => 'Tonight’s dinner reminder',
      _ => 'Tomorrow’s snacks reminder',
    };
  }

  String _body(String language, String meal, String dish) {
    if (language == 'Hindi') {
      final label = switch (meal) {
        'breakfast' => 'कल नाश्ते में',
        'lunch' => 'कल दोपहर के खाने में',
        'dinner' => 'आज रात के खाने में',
        _ => 'कल स्नैक्स में',
      };
      return '$label $dish बनाने का प्लान है। क्या आपके पास सारी सामग्री है?';
    }
    if (language == 'Hinglish') {
      final label = switch (meal) {
        'breakfast' => 'Kal breakfast mein',
        'lunch' => 'Kal lunch mein',
        'dinner' => 'Aaj dinner mein',
        _ => 'Kal snacks mein',
      };
      return '$label $dish banane ka plan hai. Kya aapke paas saara samaan hai?';
    }
    final label = switch (meal) {
      'breakfast' => 'You planned',
      'lunch' => 'You planned',
      'dinner' => 'You planned',
      _ => 'You planned',
    };
    final when = switch (meal) {
      'breakfast' => 'for breakfast tomorrow',
      'lunch' => 'for lunch tomorrow',
      'dinner' => 'for dinner today',
      _ => 'for snacks tomorrow',
    };
    return '$label $dish $when. Do you have all the ingredients?';
  }
}
