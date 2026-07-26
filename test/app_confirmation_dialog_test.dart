import 'package:finanzas_app_mobile/core/theme.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('confirma una acción destructiva', (tester) async {
    bool? result;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () async {
                  result = await showAppConfirmationDialog(
                    context,
                    title: 'Eliminar movimiento',
                    message: 'Esta acción no se puede deshacer.',
                    confirmLabel: 'Eliminar',
                    icon: Icons.delete_outline_rounded,
                  );
                },
                child: const Text('Abrir'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<AlertDialog>(find.byType(AlertDialog)).scrollable,
      true,
    );
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
  });

  testWidgets('cancela la confirmación', (tester) async {
    bool? result;

    await tester.pumpWidget(
      MaterialApp(
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () async {
                  result = await showAppConfirmationDialog(
                    context,
                    title: 'Cerrar sesión',
                    message: '¿Deseas continuar?',
                    confirmLabel: 'Cerrar sesión',
                    icon: Icons.logout_rounded,
                  );
                },
                child: const Text('Abrir'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(result, isFalse);
  });
}
