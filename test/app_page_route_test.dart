import 'package:finanzas_app_mobile/core/motion/app_page_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('abre y cierra una ruta conservando su resultado', (
    tester,
  ) async {
    bool? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () async {
                  result = await Navigator.push<bool>(
                    context,
                    AppPageRoute.build(
                      context,
                      builder: (destinationContext) => Scaffold(
                        body: TextButton(
                          onPressed: () =>
                              Navigator.pop(destinationContext, true),
                          child: const Text('Volver'),
                        ),
                      ),
                    ),
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
    await tester.pump();
    expect(find.byType(FadeTransition), findsWidgets);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Volver'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
    expect(find.text('Abrir'), findsOneWidget);
  });

  testWidgets('elimina la transición si el sistema reduce movimiento', (
    tester,
  ) async {
    late PageRoute<void> route;

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: Builder(
          builder: (context) {
            route = AppPageRoute.build(
              context,
              builder: (_) => const SizedBox.shrink(),
            );
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(route.transitionDuration, Duration.zero);
    expect(route.reverseTransitionDuration, Duration.zero);
  });
}
