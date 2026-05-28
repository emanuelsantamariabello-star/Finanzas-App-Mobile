import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finanzas_app_mobile/presentation/screens/login_screen.dart';
import 'package:finanzas_app_mobile/presentation/screens/main_navigation_screen.dart';
import 'package:finanzas_app_mobile/core/theme.dart';
import 'package:finanzas_app_mobile/providers/dashboard_provider.dart';

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
  final DashboardProvider _dashboardProvider = DashboardProvider();
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
  }

  @override
  void dispose() {
    _dashboardProvider.dispose();
    super.dispose();
  }

  void checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
  }

  Widget _buildApp({required Widget home}) {
    return ChangeNotifierProvider<DashboardProvider>.value(
      value: _dashboardProvider,
      child: MaterialApp(
        title: 'Finanzas App',
        debugShowCheckedModeBanner: false,
        locale: _locale,
        supportedLocales: _supportedLocales,
        localizationsDelegates: _localizationsDelegates,
        theme: AppTheme.darkTheme,
        home: home,
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
