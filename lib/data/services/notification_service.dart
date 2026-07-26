import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:finanzas_app_mobile/data/models/reminder_model.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static const String _channelId = 'finanzas_reminders';
  static const String _channelName = 'Recordatorios financieros';
  static const String _channelDescription =
      'Notificaciones para pagos, gastos fijos y metas.';
  static const int _rollingOccurrences = 12;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();
    await _configureLocalTimezone();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings: settings);

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(channel);

    _isInitialized = true;
  }

  Future<bool> requestPermissions() async {
    await initialize();

    if (Platform.isAndroid) {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final alreadyEnabled = await androidPlugin?.areNotificationsEnabled();
      if (alreadyEnabled == true) return true;

      final permissionResult = await androidPlugin
          ?.requestNotificationsPermission();
      return permissionResult ?? true;
    }

    if (Platform.isIOS) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >()
              ?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }

    return true;
  }

  Future<void> scheduleReminder(ReminderModel reminder) async {
    await initialize();

    final body = reminder.description?.trim().isNotEmpty == true
        ? reminder.description!.trim()
        : 'No olvides revisar: ${reminder.title}';
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    await cancelReminder(reminder.id);

    switch (reminder.frequency) {
      case 'daily':
        await _plugin.zonedSchedule(
          id: reminder.notificationSeed,
          title: reminder.title,
          body: body,
          scheduledDate: _nextDailyOccurrence(reminder.scheduledAt),
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: reminder.id,
        );
        return;
      case 'weekly':
        await _plugin.zonedSchedule(
          id: reminder.notificationSeed,
          title: reminder.title,
          body: body,
          scheduledDate: _nextWeeklyOccurrence(reminder.scheduledAt),
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          payload: reminder.id,
        );
        return;
      case 'biweekly':
        final dates = _nextBiweeklyOccurrences(reminder.scheduledAt);
        for (var index = 0; index < dates.length; index++) {
          await _plugin.zonedSchedule(
            id: _derivedNotificationId(reminder, index),
            title: reminder.title,
            body: body,
            scheduledDate: dates[index],
            notificationDetails: details,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            payload: reminder.id,
          );
        }
        return;
      case 'monthly':
      default:
        final dates = _nextMonthlyOccurrences(reminder.scheduledAt);
        for (var index = 0; index < dates.length; index++) {
          await _plugin.zonedSchedule(
            id: _derivedNotificationId(reminder, index),
            title: reminder.title,
            body: body,
            scheduledDate: dates[index],
            notificationDetails: details,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            payload: reminder.id,
          );
        }
    }
  }

  Future<void> syncReminders(List<ReminderModel> reminders) async {
    await initialize();
    await cancelAllReminders();

    for (final reminder in reminders.where((item) => item.isEnabled)) {
      await scheduleReminder(reminder);
    }
  }

  Future<void> cancelReminder(String reminderId) async {
    final seed = _notificationSeed(reminderId);
    await _plugin.cancel(id: seed);

    for (var index = 0; index < _rollingOccurrences; index++) {
      await _plugin.cancel(id: seed + index + 1);
    }
  }

  Future<void> cancelAllReminders() async {
    await _plugin.cancelAll();
  }

  Future<void> _configureLocalTimezone() async {
    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
  }

  tz.TZDateTime _nextDailyOccurrence(DateTime scheduledAt) {
    final now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      scheduledAt.hour,
      scheduledAt.minute,
    );

    if (!next.isAfter(now)) {
      next = next.add(const Duration(days: 1));
    }

    return next;
  }

  tz.TZDateTime _nextWeeklyOccurrence(DateTime scheduledAt) {
    final now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime.from(scheduledAt, tz.local);

    while (!next.isAfter(now)) {
      next = next.add(const Duration(days: 7));
    }

    return next;
  }

  List<tz.TZDateTime> _nextBiweeklyOccurrences(DateTime scheduledAt) {
    final now = tz.TZDateTime.now(tz.local);
    var current = tz.TZDateTime.from(scheduledAt, tz.local);

    while (!current.isAfter(now)) {
      current = current.add(const Duration(days: 15));
    }

    return List.generate(_rollingOccurrences, (index) {
      return current.add(Duration(days: 15 * index));
    });
  }

  List<tz.TZDateTime> _nextMonthlyOccurrences(DateTime scheduledAt) {
    final now = tz.TZDateTime.now(tz.local);
    var year = scheduledAt.year;
    var month = scheduledAt.month;
    var current = _buildMonthlyDate(
      year: year,
      month: month,
      scheduledAt: scheduledAt,
    );

    while (!current.isAfter(now)) {
      month++;
      if (month > 12) {
        month = 1;
        year++;
      }
      current = _buildMonthlyDate(
        year: year,
        month: month,
        scheduledAt: scheduledAt,
      );
    }

    final dates = <tz.TZDateTime>[];
    var loopYear = current.year;
    var loopMonth = current.month;

    for (var index = 0; index < _rollingOccurrences; index++) {
      final date = _buildMonthlyDate(
        year: loopYear,
        month: loopMonth,
        scheduledAt: scheduledAt,
      );
      dates.add(date);

      loopMonth++;
      if (loopMonth > 12) {
        loopMonth = 1;
        loopYear++;
      }
    }

    return dates;
  }

  tz.TZDateTime _buildMonthlyDate({
    required int year,
    required int month,
    required DateTime scheduledAt,
  }) {
    final lastDay = DateTime(year, month + 1, 0).day;
    final day = scheduledAt.day > lastDay ? lastDay : scheduledAt.day;

    return tz.TZDateTime(
      tz.local,
      year,
      month,
      day,
      scheduledAt.hour,
      scheduledAt.minute,
    );
  }

  int _derivedNotificationId(ReminderModel reminder, int index) {
    return reminder.notificationSeed + index + 1;
  }

  int _notificationSeed(String reminderId) {
    return reminderId.codeUnits.fold<int>(0, (value, char) {
          return (value * 31 + char) & 0x7fffffff;
        }) +
        1000;
  }
}
