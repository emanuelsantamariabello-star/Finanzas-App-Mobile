import 'package:finanzas_app_mobile/core/theme.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mantiene colores corporativos en ambos temas', () {
    expect(AppTheme.darkTheme.colorScheme.primary, AppTheme.corporateGreen);
    expect(AppTheme.lightTheme.colorScheme.primary, AppTheme.corporateGreen);
    expect(AppTheme.darkTheme.colorScheme.error, AppTheme.corporateRed);
    expect(AppTheme.lightTheme.colorScheme.error, AppTheme.corporateRed);
    expect(AppTheme.darkTheme.cardTheme.color, const Color(0xFF161B22));
    expect(AppTheme.lightTheme.cardTheme.color, Colors.white);
  });

  for (final themeMode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('snackbar respeta el tema ${themeMode.name}', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: TextButton(
                  onPressed: () {
                    AppSnackbar.success(context, 'Operación completada');
                  },
                  child: const Text('Mostrar'),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Mostrar'));
      await tester.pump();

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      final theme = themeMode == ThemeMode.dark
          ? AppTheme.darkTheme
          : AppTheme.lightTheme;
      final expectedBackground = themeMode == ThemeMode.dark
          ? theme.colorScheme.surfaceContainerHighest
          : theme.colorScheme.inverseSurface;

      expect(snackBar.backgroundColor, expectedBackground);
      expect(find.text('Operación completada'), findsOneWidget);
    });
  }
}
