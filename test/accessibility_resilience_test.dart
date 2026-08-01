import 'package:finanzas_app_mobile/core/theme.dart';
import 'package:finanzas_app_mobile/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpLogin(
    WidgetTester tester, {
    required ThemeData theme,
  }) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          );
        },
        home: const LoginScreen(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('login sigue utilizable con texto ampliado en tema claro', (
    tester,
  ) async {
    await pumpLogin(tester, theme: AppTheme.lightTheme);

    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('login sigue utilizable con texto ampliado en tema oscuro', (
    tester,
  ) async {
    await pumpLogin(tester, theme: AppTheme.darkTheme);

    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('Recordar credenciales'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
