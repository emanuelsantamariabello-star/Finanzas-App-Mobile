import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:finanzas_app_mobile/data/services/session_storage_service.dart';
import 'package:finanzas_app_mobile/presentation/screens/login_screen.dart';
import 'package:finanzas_app_mobile/presentation/screens/main_navigation_screen.dart';
import 'package:finanzas_app_mobile/core/theme.dart';
import 'package:finanzas_app_mobile/providers/app_settings_provider.dart';
import 'package:finanzas_app_mobile/providers/budget_provider.dart';
import 'package:finanzas_app_mobile/providers/dashboard_provider.dart';
import 'package:finanzas_app_mobile/providers/goal_provider.dart';
import 'package:finanzas_app_mobile/providers/internal_notification_provider.dart';
import 'package:finanzas_app_mobile/providers/reminder_provider.dart';
import 'package:finanzas_app_mobile/providers/theme_provider.dart';

void main() {
  runApp(const FinanzasApp());
}

class FinanzasApp extends StatefulWidget {
  const FinanzasApp({super.key});

  @override
  State<FinanzasApp> createState() => _FinanzasAppState();
}

class _FinanzasAppState extends State<FinanzasApp> {
  bool? isLoggedIn;
  final AppSettingsProvider _appSettingsProvider = AppSettingsProvider();
  final BudgetProvider _budgetProvider = BudgetProvider();
  final DashboardProvider _dashboardProvider = DashboardProvider();
  final GoalProvider _goalProvider = GoalProvider();
  final InternalNotificationProvider _internalNotificationProvider =
      InternalNotificationProvider();
  final ReminderProvider _reminderProvider = ReminderProvider();
  final SessionStorageService _sessionStorageService = SessionStorageService();
  final ThemeProvider _themeProvider = ThemeProvider();
  static const _locale = Locale('es', 'CO');
  static const List<Locale> _supportedLocales = [
    Locale('es', 'CO'),
    Locale('en', 'US'),
  ];
  static final List<LocalizationsDelegate<dynamic>> _localizationsDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  @override
  void initState() {
    super.initState();
    checkLogin();
    _appSettingsProvider.initialize();
    _themeProvider.loadThemeMode();
  }

  @override
  void dispose() {
    _appSettingsProvider.dispose();
    _budgetProvider.dispose();
    _dashboardProvider.dispose();
    _goalProvider.dispose();
    _internalNotificationProvider.dispose();
    _reminderProvider.dispose();
    _themeProvider.dispose();
    super.dispose();
  }

  void checkLogin() async {
    final hasActiveSession = await _sessionStorageService.hasActiveSession();
    if (!mounted) return;
    setState(() {
      isLoggedIn = hasActiveSession;
    });

    if (hasActiveSession) {
      unawaited(
        Future.wait([
          _budgetProvider.initialize(),
          _goalProvider.initialize(),
          _internalNotificationProvider.initialize(),
          _reminderProvider.initialize(),
        ]),
      );
    }
  }

  Widget _buildApp({required Widget home}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppSettingsProvider>.value(
          value: _appSettingsProvider,
        ),
        ChangeNotifierProvider<BudgetProvider>.value(value: _budgetProvider),
        ChangeNotifierProvider<DashboardProvider>.value(
          value: _dashboardProvider,
        ),
        ChangeNotifierProvider<GoalProvider>.value(value: _goalProvider),
        ChangeNotifierProvider<InternalNotificationProvider>.value(
          value: _internalNotificationProvider,
        ),
        ChangeNotifierProvider<ReminderProvider>.value(
          value: _reminderProvider,
        ),
        ChangeNotifierProvider<ThemeProvider>.value(value: _themeProvider),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Finanzas App',
            debugShowCheckedModeBanner: false,
            locale: _locale,
            supportedLocales: _supportedLocales,
            localizationsDelegates: _localizationsDelegates,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: home,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn == null) {
      return _buildApp(
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return _buildApp(
      home: isLoggedIn! ? const MainNavigationScreen() : const LoginScreen(),
    );
  }
}
