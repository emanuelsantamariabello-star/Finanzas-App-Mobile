import 'package:finanzas_app_mobile/core/theme.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_form_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final themeMode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('renderiza componentes de formulario en ${themeMode.name}', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          home: Scaffold(
            body: AppSurfaceCard(
              child: Column(
                children: [
                  Builder(
                    builder: (context) {
                      return TextField(
                        decoration: AppFormDecoration.input(
                          context: context,
                          label: 'Correo',
                          icon: Icons.email_outlined,
                        ),
                      );
                    },
                  ),
                  AppPrimaryButton(
                    label: 'Continuar',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('Correo'), findsOneWidget);
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
      expect(find.text('Continuar'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
    });
  }

  testWidgets('desactiva la acción y muestra loading', (tester) async {
    var pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: AppPrimaryButton(
            label: 'Guardar',
            loadingLabel: 'Guardando…',
            isLoading: true,
            onPressed: () => pressed = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));

    expect(pressed, isFalse);
    expect(find.text('Guardando…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('permite cerrar el teclado al tocar fuera del campo', (
    tester,
  ) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: AppFormScrollView(
            child: SizedBox(
              height: 500,
              child: Align(
                alignment: Alignment.topCenter,
                child: TextField(focusNode: focusNode),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextField));
    expect(focusNode.hasFocus, isTrue);

    await tester.tapAt(const Offset(20, 400));
    await tester.pump();

    expect(focusNode.hasFocus, isFalse);
    expect(
      tester
          .widget<SingleChildScrollView>(find.byType(SingleChildScrollView))
          .keyboardDismissBehavior,
      ScrollViewKeyboardDismissBehavior.onDrag,
    );
  });
}
