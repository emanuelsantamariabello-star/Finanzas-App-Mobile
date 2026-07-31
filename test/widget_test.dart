import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:finanzas_app_mobile/main.dart';

void main() {
  testWidgets('muestra login cuando no hay sesion activa', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});

    await tester.pumpWidget(
      const FinanzasApp(recoverInterruptedSelection: false),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bienvenido'), findsOneWidget);
    expect(find.text('Iniciar sesi\u00f3n'), findsOneWidget);
  });

  testWidgets('muestra la navegacion principal cuando hay sesion activa', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'isLoggedIn': true, 'userId': 7});
    FlutterSecureStorage.setMockInitialValues({
      'auth_session_token': List.filled(64, 'a').join(),
      'auth_session_token_expires_at': DateTime.now()
          .add(const Duration(days: 30))
          .toUtc()
          .toIso8601String(),
    });

    await tester.pumpWidget(
      const FinanzasApp(recoverInterruptedSelection: false),
    );
    await tester.pumpAndSettle();

    expect(find.text('Inicio'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.text('Movimientos'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.text('Perfil'),
      ),
      findsOneWidget,
    );
  });
}
