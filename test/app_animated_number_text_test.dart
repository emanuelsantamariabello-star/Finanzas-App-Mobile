import 'package:finanzas_app_mobile/presentation/widgets/app_animated_number_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('anima hasta el valor final y expone una semántica estable', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppAnimatedNumberText(
            value: 250,
            formatter: (value) => '\$ ${value.round()}',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('\$ 250'), findsOneWidget);
    expect(find.bySemanticsLabel('\$ 250'), findsOneWidget);
  });

  testWidgets('continúa desde el valor visible cuando el dato cambia', (
    tester,
  ) async {
    final value = ValueNotifier(100.0);
    addTearDown(value.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder<double>(
            valueListenable: value,
            builder: (context, currentValue, _) {
              return AppAnimatedNumberText(
                value: currentValue,
                formatter: (animatedValue) => animatedValue.round().toString(),
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('100'), findsOneWidget);

    value.value = 200;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    expect(find.text('100'), findsNothing);
    expect(find.text('200'), findsNothing);

    await tester.pumpAndSettle();
    expect(find.text('200'), findsOneWidget);
  });

  testWidgets('elimina la duración con movimiento reducido', (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: AppAnimatedNumberText(
            value: 12,
            formatter: (value) => value.round().toString(),
          ),
        ),
      ),
    );

    final animation = tester.widget<TweenAnimationBuilder<double>>(
      find.byType(TweenAnimationBuilder<double>),
    );
    expect(animation.duration, Duration.zero);
  });
}
