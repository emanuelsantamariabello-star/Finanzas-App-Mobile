import 'package:finanzas_app_mobile/core/theme.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_state_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('muestra estados consistentes en tema claro', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: AppEmptyState(
            icon: Icons.savings_outlined,
            title: 'Sin movimientos',
            message: 'Agrega tu primer movimiento.',
          ),
        ),
      ),
    );

    expect(find.text('Sin movimientos'), findsOneWidget);
    expect(find.byIcon(Icons.savings_outlined), findsOneWidget);
  });

  testWidgets('permite reintentar desde el estado de error', (tester) async {
    var retried = false;

    await tester.pumpWidget(
      MaterialApp(
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: Scaffold(
          body: AppErrorState(
            message: 'Sin conexión',
            onRetry: () => retried = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Reintentar'));

    expect(retried, isTrue);
    expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
  });

  testWidgets('muestra indicador y mensaje de carga', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: AppLoadingState(message: 'Cargando movimientos…'),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Cargando movimientos…'), findsOneWidget);
  });

  testWidgets('mantiene accesible el error con texto ampliado', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!,
        ),
        home: const Scaffold(
          body: SizedBox(
            height: 220,
            child: AppErrorState(
              message: 'No fue posible cargar la información solicitada.',
              compact: true,
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('No pudimos cargar la información'), findsOneWidget);
  });
}
