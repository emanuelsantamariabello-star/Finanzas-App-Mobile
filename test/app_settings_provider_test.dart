import 'package:finanzas_app_mobile/providers/app_settings_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('inicia con el contenido de Inicio visible por defecto', () async {
    final provider = AppSettingsProvider();

    await provider.initialize();

    expect(provider.isInitialized, isTrue);
    expect(provider.showHomeInsights, isTrue);
    expect(provider.showHomeSavingRecommendations, isTrue);
    expect(provider.error, isNull);
  });

  test('persiste la visibilidad de los insights de Inicio', () async {
    final provider = AppSettingsProvider();
    await provider.initialize();

    await provider.setShowHomeInsights(false);

    final restoredProvider = AppSettingsProvider();
    await restoredProvider.initialize();

    expect(restoredProvider.showHomeInsights, isFalse);
    expect(restoredProvider.showHomeSavingRecommendations, isTrue);
  });

  test('persiste la visibilidad de las sugerencias de ahorro', () async {
    final provider = AppSettingsProvider();
    await provider.initialize();

    await provider.setShowHomeSavingRecommendations(false);

    final restoredProvider = AppSettingsProvider();
    await restoredProvider.initialize();

    expect(restoredProvider.showHomeInsights, isTrue);
    expect(restoredProvider.showHomeSavingRecommendations, isFalse);
  });
}
