import 'package:finanzas_app_mobile/core/theme.dart';
import 'package:finanzas_app_mobile/presentation/screens/profile_screen.dart';
import 'package:finanzas_app_mobile/providers/app_settings_provider.dart';
import 'package:finanzas_app_mobile/providers/dashboard_provider.dart';
import 'package:finanzas_app_mobile/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<AppSettingsProvider> pumpProfile(
    WidgetTester tester,
    Map<String, Object> initialPreferences,
  ) async {
    SharedPreferences.setMockInitialValues(initialPreferences);
    FlutterSecureStorage.setMockInitialValues({});
    final appSettingsProvider = AppSettingsProvider();
    final dashboardProvider = DashboardProvider();
    final themeProvider = ThemeProvider();
    await appSettingsProvider.initialize();
    await themeProvider.loadThemeMode();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppSettingsProvider>.value(
            value: appSettingsProvider,
          ),
          ChangeNotifierProvider<DashboardProvider>.value(
            value: dashboardProvider,
          ),
          ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const ProfileScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    return appSettingsProvider;
  }

  testWidgets('abre Configuración de la app desde Perfil', (tester) async {
    await pumpProfile(tester, {
      'userName': 'Usuario de prueba',
      'userEmail': 'usuario@prueba.com',
    });

    final settingsAccess = find.text('Configuración de la app');
    await tester.scrollUntilVisible(settingsAccess, 250);
    await tester.tap(settingsAccess);
    await tester.pumpAndSettle();

    expect(find.text('Personaliza tu experiencia'), findsOneWidget);
    expect(find.text('Contenido de Inicio'), findsOneWidget);
    expect(find.text('Recordatorios y avisos'), findsOneWidget);
  });

  testWidgets('conserva configuraciones después de cerrar sesión', (
    tester,
  ) async {
    final appSettingsProvider = await pumpProfile(tester, {
      'isLoggedIn': true,
      'userId': 7,
      'userName': 'Usuario de prueba',
      'userEmail': 'usuario@prueba.com',
      'themeMode': 'light',
      'show_home_insights': false,
      'show_home_saving_recommendations': false,
    });

    expect(appSettingsProvider.showHomeInsights, isFalse);
    expect(appSettingsProvider.showHomeSavingRecommendations, isFalse);

    final logoutAccess = find.text('Cerrar sesión');
    await tester.scrollUntilVisible(logoutAccess, 250);
    await tester.tap(logoutAccess);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Cerrar sesión'));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('isLoggedIn'), isNull);
    expect(prefs.getInt('userId'), isNull);
    expect(prefs.getBool('show_home_insights'), isFalse);
    expect(prefs.getBool('show_home_saving_recommendations'), isFalse);
    expect(prefs.getString('themeMode'), 'light');

    final restoredProvider = AppSettingsProvider();
    await restoredProvider.initialize();

    expect(restoredProvider.showHomeInsights, isFalse);
    expect(restoredProvider.showHomeSavingRecommendations, isFalse);
  });
}
