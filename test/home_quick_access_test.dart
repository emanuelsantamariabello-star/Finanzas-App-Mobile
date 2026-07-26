import 'package:finanzas_app_mobile/core/theme.dart';
import 'package:finanzas_app_mobile/presentation/screens/budgets_screen.dart';
import 'package:finanzas_app_mobile/presentation/screens/financial_goals_screen.dart';
import 'package:finanzas_app_mobile/presentation/screens/home_screen.dart';
import 'package:finanzas_app_mobile/presentation/screens/reminder_settings_screen.dart';
import 'package:finanzas_app_mobile/providers/budget_provider.dart';
import 'package:finanzas_app_mobile/providers/dashboard_provider.dart';
import 'package:finanzas_app_mobile/providers/goal_provider.dart';
import 'package:finanzas_app_mobile/providers/reminder_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> pumpHome(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'userName': 'Usuario'});

    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => BudgetProvider()),
          ChangeNotifierProvider(create: (_) => DashboardProvider()),
          ChangeNotifierProvider(create: (_) => GoalProvider()),
          ChangeNotifierProvider(create: (_) => ReminderProvider()),
        ],
        child: MaterialApp(
          locale: const Locale('es', 'CO'),
          supportedLocales: const [Locale('es', 'CO')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: AppTheme.lightTheme,
          home: const HomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('muestra accesos rápidos en una lista horizontal', (
    tester,
  ) async {
    await pumpHome(tester);

    expect(find.text('Accesos rápidos'), findsOneWidget);
    expect(find.text('Recordatorios'), findsOneWidget);
    expect(find.text('Metas'), findsOneWidget);
    expect(find.text('Presupuestos'), findsOneWidget);

    final list = tester.widget<ListView>(
      find.byKey(const ValueKey('home_quick_access_list')),
    );
    expect(list.scrollDirection, Axis.horizontal);
  });

  testWidgets('abre las herramientas desde los accesos rápidos', (
    tester,
  ) async {
    await pumpHome(tester);

    await tester.tap(find.text('Recordatorios'));
    await tester.pumpAndSettle();
    expect(find.byType(ReminderSettingsScreen), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Metas'));
    await tester.pumpAndSettle();
    expect(find.byType(FinancialGoalsScreen), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    final quickAccessList = find.byKey(
      const ValueKey('home_quick_access_list'),
    );
    await tester.drag(quickAccessList, const Offset(-180, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Presupuestos'));
    await tester.pumpAndSettle();
    expect(find.byType(BudgetsScreen), findsOneWidget);
  });
}
