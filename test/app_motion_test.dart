import 'package:finanzas_app_mobile/core/motion/app_motion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('define una escala breve y consistente de movimiento', () {
    expect(AppMotion.fast, const Duration(milliseconds: 160));
    expect(AppMotion.standard, const Duration(milliseconds: 220));
    expect(AppMotion.emphasized, const Duration(milliseconds: 300));
    expect(AppMotion.fast < AppMotion.standard, isTrue);
    expect(AppMotion.standard < AppMotion.emphasized, isTrue);
  });

  testWidgets('mantiene la duración cuando el movimiento está habilitado', (
    tester,
  ) async {
    late Duration resolvedDuration;

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: false),
        child: Builder(
          builder: (context) {
            resolvedDuration = AppMotion.duration(context, AppMotion.standard);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(resolvedDuration, AppMotion.standard);
  });

  testWidgets('elimina la duración cuando el sistema reduce movimiento', (
    tester,
  ) async {
    late Duration resolvedDuration;

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: Builder(
          builder: (context) {
            resolvedDuration = AppMotion.duration(
              context,
              AppMotion.emphasized,
            );
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(resolvedDuration, Duration.zero);
  });

  testWidgets('usa movimiento normal si no existe MediaQuery', (tester) async {
    late bool reduceMotion;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Builder(
          builder: (context) {
            reduceMotion = AppMotion.reduceMotion(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(reduceMotion, isFalse);
  });
}
