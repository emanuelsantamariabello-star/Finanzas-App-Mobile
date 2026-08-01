import 'package:finanzas_app_mobile/core/theme.dart';
import 'package:finanzas_app_mobile/presentation/screens/settings_screen.dart';
import 'package:finanzas_app_mobile/providers/app_settings_provider.dart';
import 'package:finanzas_app_mobile/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpSettings(
    WidgetTester tester, {
    required AppSettingsProvider appSettingsProvider,
    required ThemeProvider themeProvider,
  }) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppSettingsProvider>.value(
            value: appSettingsProvider,
          ),
          ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('muestra las secciones principales de configuración', (
    tester,
  ) async {
    final appSettingsProvider = AppSettingsProvider();
    final themeProvider = ThemeProvider();
    await appSettingsProvider.initialize();
    await themeProvider.loadThemeMode();

    await pumpSettings(
      tester,
      appSettingsProvider: appSettingsProvider,
      themeProvider: themeProvider,
    );

    expect(find.text('Apariencia'), findsOneWidget);
    expect(find.text('Contenido de Inicio'), findsOneWidget);
    expect(find.text('Notificaciones'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Privacidad'), 200);
    expect(find.text('Privacidad'), findsOneWidget);
    expect(find.text('Insights rápidos'), findsOneWidget);
    expect(find.text('Sugerencias de ahorro'), findsOneWidget);
    expect(find.text('Recordatorios y avisos'), findsOneWidget);
    expect(find.text('Privacidad y datos'), findsOneWidget);
  });

  testWidgets('abre el control de privacidad y eliminación de cuenta', (
    tester,
  ) async {
    final appSettingsProvider = AppSettingsProvider();
    final themeProvider = ThemeProvider();
    await appSettingsProvider.initialize();
    await themeProvider.loadThemeMode();

    await pumpSettings(
      tester,
      appSettingsProvider: appSettingsProvider,
      themeProvider: themeProvider,
    );

    await tester.scrollUntilVisible(find.text('Privacidad y datos'), 250);
    await tester.tap(find.text('Privacidad y datos'));
    await tester.pumpAndSettle();

    expect(find.text('Control de tus datos'), findsOneWidget);
    expect(find.text('Eliminar mi cuenta'), findsWidgets);
    expect(find.text('Escribe ELIMINAR para confirmar'), findsOneWidget);
  });

  testWidgets('actualiza las preferencias visibles de Inicio', (tester) async {
    final appSettingsProvider = AppSettingsProvider();
    final themeProvider = ThemeProvider();
    await appSettingsProvider.initialize();
    await themeProvider.loadThemeMode();

    await pumpSettings(
      tester,
      appSettingsProvider: appSettingsProvider,
      themeProvider: themeProvider,
    );

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    expect(appSettingsProvider.showHomeInsights, isFalse);
    expect(appSettingsProvider.showHomeSavingRecommendations, isTrue);
  });

  testWidgets('permite cambiar el tema desde Configuración', (tester) async {
    final appSettingsProvider = AppSettingsProvider();
    final themeProvider = ThemeProvider();
    await appSettingsProvider.initialize();
    await themeProvider.loadThemeMode();

    await pumpSettings(
      tester,
      appSettingsProvider: appSettingsProvider,
      themeProvider: themeProvider,
    );

    await tester.tap(find.text('Tema'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Claro'));
    await tester.pumpAndSettle();

    expect(themeProvider.themeMode, ThemeMode.light);
  });
}
