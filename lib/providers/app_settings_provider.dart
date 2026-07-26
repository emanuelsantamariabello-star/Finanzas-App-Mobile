import 'package:finanzas_app_mobile/data/models/app_settings_model.dart';
import 'package:finanzas_app_mobile/data/services/app_settings_storage_service.dart';
import 'package:flutter/material.dart';

class AppSettingsProvider extends ChangeNotifier {
  AppSettingsProvider({AppSettingsStorageService? storageService})
    : _storageService = storageService ?? AppSettingsStorageService();

  final AppSettingsStorageService _storageService;

  AppSettingsModel _settings = const AppSettingsModel();
  bool _isInitialized = false;
  String? _error;

  bool get showHomeInsights => _settings.showHomeInsights;
  bool get showHomeSavingRecommendations =>
      _settings.showHomeSavingRecommendations;
  bool get isInitialized => _isInitialized;
  String? get error => _error;

  Future<void> initialize() async {
    if (_isInitialized) return;

    _error = null;

    try {
      _settings = await _storageService.loadSettings();
    } catch (error) {
      _error = error.toString();
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> setShowHomeInsights(bool value) async {
    if (_settings.showHomeInsights == value) return;

    _settings = _settings.copyWith(showHomeInsights: value);
    await _persistSettings();
  }

  Future<void> setShowHomeSavingRecommendations(bool value) async {
    if (_settings.showHomeSavingRecommendations == value) return;

    _settings = _settings.copyWith(showHomeSavingRecommendations: value);
    await _persistSettings();
  }

  Future<void> _persistSettings() async {
    _error = null;
    notifyListeners();

    try {
      await _storageService.saveSettings(_settings);
    } catch (error) {
      _error = error.toString();
      notifyListeners();
    }
  }
}
