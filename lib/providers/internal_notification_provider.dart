import 'package:finanzas_app_mobile/core/network/api_exception.dart';
import 'package:finanzas_app_mobile/data/models/internal_notification_model.dart';
import 'package:finanzas_app_mobile/data/services/internal_notification_service.dart';
import 'package:finanzas_app_mobile/data/services/internal_notification_storage_service.dart';
import 'package:finanzas_app_mobile/data/services/user_scoped_storage_service.dart';
import 'package:flutter/material.dart';

class InternalNotificationProvider extends ChangeNotifier {
  InternalNotificationProvider({
    InternalNotificationService? notificationService,
    InternalNotificationStorageService? storageService,
  }) : _notificationService =
           notificationService ?? InternalNotificationService(),
       _storageService = storageService ?? InternalNotificationStorageService();

  final InternalNotificationService _notificationService;
  final InternalNotificationStorageService _storageService;

  List<InternalNotificationModel> _notifications = [];
  Set<String> _readIds = {};
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;
  int? _initializedUserId;

  List<InternalNotificationModel> get notifications =>
      List.unmodifiable(_notifications);
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  int get unreadCount =>
      _notifications.where((item) => !_readIds.contains(item.id)).length;

  bool isRead(String notificationId) => _readIds.contains(notificationId);

  Future<void> initialize({bool forceRefresh = false}) async {
    final userId = await UserScopedStorageService.currentUserId();

    if (userId == null) {
      _notifications = [];
      _readIds = {};
      _error = null;
      _isLoading = false;
      _isInitialized = true;
      _initializedUserId = null;
      notifyListeners();
      return;
    }

    if (!forceRefresh && _isInitialized && _initializedUserId == userId) {
      return;
    }

    if (_initializedUserId != userId) {
      _notifications = [];
      _readIds = await _storageService.loadReadIds();
    }

    _initializedUserId = userId;
    _isInitialized = true;
    await refresh();
  }

  Future<void> refresh() async {
    final userId = await UserScopedStorageService.currentUserId();
    if (userId == null) return;

    if (_initializedUserId != userId) {
      _initializedUserId = userId;
      _notifications = [];
      _readIds = await _storageService.loadReadIds();
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await _notificationService.getNotifications(userId);
    } catch (error) {
      _error = apiErrorMessage(
        error,
        fallback: 'No se pudieron cargar las notificaciones',
      );
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    _readIds = {
      ..._readIds,
      ..._notifications.map((notification) => notification.id),
    };
    try {
      await _storageService.saveReadIds(_readIds);
    } catch (_) {
      _error = 'No se pudo guardar el estado de las notificaciones';
    }
    notifyListeners();
  }
}
