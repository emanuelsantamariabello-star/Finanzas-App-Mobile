import 'package:finanzas_app_mobile/core/motion/app_motion.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_animated_indexed_stack.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('conserva el estado al cambiar de módulo', (tester) async {
    final index = ValueNotifier(0);
    addTearDown(index.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder<int>(
            valueListenable: index,
            builder: (context, currentIndex, _) {
              return AppAnimatedIndexedStack(
                index: currentIndex,
                children: const [
                  _CounterScreen(label: 'Inicio'),
                  _CounterScreen(label: 'Movimientos'),
                ],
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Incrementar Inicio'));
    await tester.pump();
    expect(find.text('Inicio: 1'), findsOneWidget);

    index.value = 1;
    await tester.pumpAndSettle();
    expect(find.text('Movimientos: 0'), findsOneWidget);

    index.value = 0;
    await tester.pumpAndSettle();
    expect(find.text('Inicio: 1'), findsOneWidget);
  });

  testWidgets('bloquea interacción y semántica del módulo inactivo', (
    tester,
  ) async {
    var inactiveTaps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: AppAnimatedIndexedStack(
          index: 0,
          children: [
            const ColoredBox(color: Colors.green),
            Semantics(
              label: 'Acción inactiva',
              button: true,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => inactiveTaps++,
                child: const SizedBox.expand(),
              ),
            ),
          ],
        ),
      ),
    );

    await tester.tapAt(tester.getCenter(find.byType(AppAnimatedIndexedStack)));
    expect(inactiveTaps, 0);

    expect(find.bySemanticsLabel('Acción inactiva'), findsNothing);
  });

  testWidgets('elimina la transición cuando el sistema reduce movimiento', (
    tester,
  ) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: AppAnimatedIndexedStack(
            index: 0,
            children: const [SizedBox.expand(), SizedBox.expand()],
          ),
        ),
      ),
    );

    final transitions = tester.widgetList<AnimatedOpacity>(
      find.byType(AnimatedOpacity),
    );

    expect(
      transitions.every((transition) => transition.duration == Duration.zero),
      isTrue,
    );
    expect(AppMotion.reduceMotion(tester.element(find.byType(Stack))), isTrue);
  });
}

class _CounterScreen extends StatefulWidget {
  final String label;

  const _CounterScreen({required this.label});

  @override
  State<_CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<_CounterScreen> {
  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('${widget.label}: $count'),
        TextButton(
          onPressed: () => setState(() => count++),
          child: Text('Incrementar ${widget.label}'),
        ),
      ],
    );
  }
}
