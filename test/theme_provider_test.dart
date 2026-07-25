import 'package:finanzas_app_mobile/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('ThemeProvider carga dark por defecto', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = ThemeProvider();

    await provider.loadThemeMode();

    expect(provider.themeMode, ThemeMode.dark);
  });

  test('ThemeProvider restaura el modo guardado', () async {
    SharedPreferences.setMockInitialValues({'themeMode': 'light'});
    final provider = ThemeProvider();

    await provider.loadThemeMode();

    expect(provider.themeMode, ThemeMode.light);
  });

  test('ThemeProvider persiste cambios de modo', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = ThemeProvider();

    await provider.setThemeMode(ThemeMode.system);

    final prefs = await SharedPreferences.getInstance();
    expect(provider.themeMode, ThemeMode.system);
    expect(prefs.getString('themeMode'), 'system');
  });
}
