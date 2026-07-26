import 'package:finanzas_app_mobile/core/theme.dart';
import 'package:finanzas_app_mobile/presentation/screens/profile_screen.dart';
import 'package:finanzas_app_mobile/providers/app_settings_provider.dart';
import 'package:finanzas_app_mobile/providers/dashboard_provider.dart';
import 'package:finanzas_app_mobile/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('abre Configuración de la app desde Perfil', (tester) async {
    SharedPreferences.setMockInitialValues({
      'userName': 'Usuario de prueba',
      'userEmail': 'usuario@prueba.com',
    });

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

    final settingsAccess = find.text('Configuración de la app');
    await tester.scrollUntilVisible(settingsAccess, 250);
    await tester.tap(settingsAccess);
    await tester.pumpAndSettle();

    expect(find.text('Personaliza tu experiencia'), findsOneWidget);
    expect(find.text('Contenido de Inicio'), findsOneWidget);
    expect(find.text('Recordatorios y avisos'), findsOneWidget);
  });
}
