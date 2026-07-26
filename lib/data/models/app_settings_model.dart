class AppSettingsModel {
  const AppSettingsModel({
    this.showHomeInsights = true,
    this.showHomeSavingRecommendations = true,
  });

  final bool showHomeInsights;
  final bool showHomeSavingRecommendations;

  AppSettingsModel copyWith({
    bool? showHomeInsights,
    bool? showHomeSavingRecommendations,
  }) {
    return AppSettingsModel(
      showHomeInsights: showHomeInsights ?? this.showHomeInsights,
      showHomeSavingRecommendations:
          showHomeSavingRecommendations ?? this.showHomeSavingRecommendations,
    );
  }
}
