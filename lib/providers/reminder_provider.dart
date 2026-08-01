import 'package:flutter/material.dart';
import 'package:finanzas_app_mobile/data/models/reminder_model.dart';
import 'package:finanzas_app_mobile/data/services/notification_service.dart';
import 'package:finanzas_app_mobile/data/services/reminder_storage_service.dart';
import 'package:finanzas_app_mobile/data/services/user_scoped_storage_service.dart';

class ReminderProvider extends ChangeNotifier {
  static const Duration _notificationTimeout = Duration(seconds: 3);

  ReminderProvider({
    ReminderStorageService? storageService,
    NotificationService? notificationService,
  }) : _storageService = storageService ?? ReminderStorageService(),
       _notificationService = notificationService ?? NotificationService();

  final ReminderStorageService _storageService;
  final NotificationService _notificationService;

  List<ReminderModel> _reminders = [];
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;
  int? _initializedUserId;

  List<ReminderModel> get reminders => List.unmodifiable(_reminders);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    final userId = await UserScopedStorageService.currentUserId();
    if (_isInitialized && _initializedUserId == userId) return;

    await _notificationService.initialize();
    await loadReminders();
    _initializedUserId = userId;
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> loadReminders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reminders = await _storageService.loadReminders();
      await _runNotificationTask(
        () => _notificationService.syncReminders(_reminders),
      );
    } catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveReminder(ReminderModel reminder) async {
    final currentIndex = _reminders.indexWhere(
      (item) => item.id == reminder.id,
    );
    final nextReminder = reminder.copyWith(
      createdAt: reminder.createdAt ?? DateTime.now(),
    );

    if (currentIndex >= 0) {
      _reminders[currentIndex] = nextReminder;
    } else {
      _reminders = [..._reminders, nextReminder];
    }

    await _persistReminders();
    await _syncReminder(nextReminder);
  }

  Future<bool> ensurePermission() async {
    try {
      return await _notificationService.requestPermissions().timeout(
        _notificationTimeout,
        onTimeout: () => false,
      );
    } catch (_) {
      return false;
    }
  }

  Future<void> toggleReminder(String reminderId, bool isEnabled) async {
    final index = _reminders.indexWhere((item) => item.id == reminderId);

    if (index < 0) return;

    final updatedReminder = _reminders[index].copyWith(isEnabled: isEnabled);
    _reminders[index] = updatedReminder;

    await _persistReminders();
    await _syncReminder(updatedReminder);
  }

  Future<void> deleteReminder(String reminderId) async {
    _reminders = _reminders.where((item) => item.id != reminderId).toList();
    await _persistReminders();
    await _runNotificationTask(
      () => _notificationService.cancelReminder(reminderId),
    );
  }

  Future<void> clearAllReminders() async {
    _reminders = [];
    await _persistReminders();
    await _runNotificationTask(_notificationService.cancelAllReminders);
  }

  Future<void> _persistReminders() async {
    _error = null;

    try {
      await _storageService.saveReminders(_reminders);
    } catch (error) {
      _error = error.toString();
    }

    notifyListeners();
  }

  Future<void> _syncReminder(ReminderModel reminder) async {
    if (reminder.isEnabled) {
      await _runNotificationTask(
        () => _notificationService.scheduleReminder(reminder),
      );
      return;
    }

    await _runNotificationTask(
      () => _notificationService.cancelReminder(reminder.id),
    );
  }

  Future<void> _runNotificationTask(Future<void> Function() task) async {
    try {
      await task().timeout(_notificationTimeout);
    } catch (error) {
      _error = error.toString();
      notifyListeners();
    }
  }
}
