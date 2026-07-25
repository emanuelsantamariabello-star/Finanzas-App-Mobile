import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:finanzas_app_mobile/main.dart';

void main() {
  testWidgets('muestra login cuando no hay sesion activa', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const FinanzasApp());
    await tester.pumpAndSettle();

    expect(find.text('Bienvenido'), findsOneWidget);
    expect(find.text('Iniciar sesi\u00f3n'), findsOneWidget);
  });

  testWidgets('muestra la navegacion principal cuando hay sesion activa', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'isLoggedIn': true});

    await tester.pumpWidget(const FinanzasApp());
    await tester.pumpAndSettle();

    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('Movimientos'), findsOneWidget);
    expect(find.text('Perfil'), findsOneWidget);
  });
}
