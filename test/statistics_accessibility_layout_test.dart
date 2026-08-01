import 'package:finanzas_app_mobile/core/theme.dart';
import 'package:finanzas_app_mobile/presentation/screens/statistics_screen.dart';
import 'package:finanzas_app_mobile/providers/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('las etiquetas de la gráfica no se solapan con texto ampliado', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final dashboardProvider = DashboardProvider()
      ..data = {
        'chart': {'income': 20000000, 'expense': 2000000},
      };

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: dashboardProvider,
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          builder: (context, child) {
            final mediaQuery = MediaQuery.of(context);
            return MediaQuery(
              data: mediaQuery.copyWith(textScaler: const TextScaler.linear(2)),
              child: child!,
            );
          },
          home: const StatisticsScreen(),
        ),
      ),
    );
    await tester.pump();

    final incomeLabel = find.text('Ingresos');
    final nextSection = find.text('📊 Evolución Mensual');
    expect(incomeLabel, findsOneWidget);
    expect(nextSection, findsOneWidget);
    expect(
      tester.getRect(incomeLabel).bottom,
      lessThan(tester.getRect(nextSection).top),
    );
    expect(tester.takeException(), isNull);
  });
}
