import 'package:finanzas_app_mobile/data/models/app_settings_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsStorageService {
  static const String _showHomeInsightsKey = 'show_home_insights';
  static const String _showHomeSavingRecommendationsKey =
      'show_home_saving_recommendations';

  Future<AppSettingsModel> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    return AppSettingsModel(
      showHomeInsights: prefs.getBool(_showHomeInsightsKey) ?? true,
      showHomeSavingRecommendations:
          prefs.getBool(_showHomeSavingRecommendationsKey) ?? true,
    );
  }

  Future<void> saveSettings(AppSettingsModel settings) async {
    final prefs = await SharedPreferences.getInstance();

    await Future.wait([
      prefs.setBool(_showHomeInsightsKey, settings.showHomeInsights),
      prefs.setBool(
        _showHomeSavingRecommendationsKey,
        settings.showHomeSavingRecommendations,
      ),
    ]);
  }
}
