import 'package:flutter/material.dart';
import 'package:finanzas_app_mobile/core/motion/app_motion.dart';
import 'package:finanzas_app_mobile/core/theme.dart';
import 'package:finanzas_app_mobile/presentation/screens/home_screen.dart';
import 'package:finanzas_app_mobile/presentation/screens/movements_screen.dart';
import 'package:finanzas_app_mobile/presentation/screens/profile_screen.dart';
import 'package:finanzas_app_mobile/presentation/screens/statistics_screen.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_animated_indexed_stack.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int currentIndex = 0;

  late final List<Widget> screens = [
    const HomeScreen(),
    const MovementsScreen(),
    const StatisticsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: AppAnimatedIndexedStack(index: currentIndex, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.colorScheme.surface,
        selectedItemColor: AppTheme.corporateGreen,
        unselectedItemColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        onTap: (index) {
          setState(() => currentIndex = index);
        },
        items: [
          BottomNavigationBarItem(
            icon: _AnimatedNavigationIcon(
              icon: Icons.home_rounded,
              selected: currentIndex == 0,
            ),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: _AnimatedNavigationIcon(
              icon: Icons.swap_horiz_rounded,
              selected: currentIndex == 1,
            ),
            label: 'Movimientos',
          ),
          BottomNavigationBarItem(
            icon: _AnimatedNavigationIcon(
              icon: Icons.bar_chart_rounded,
              selected: currentIndex == 2,
            ),
            label: 'Estadísticas',
          ),
          BottomNavigationBarItem(
            icon: _AnimatedNavigationIcon(
              icon: Icons.person_rounded,
              selected: currentIndex == 3,
            ),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class _AnimatedNavigationIcon extends StatelessWidget {
  final IconData icon;
  final bool selected;

  const _AnimatedNavigationIcon({required this.icon, required this.selected});

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.duration(context, AppMotion.fast);

    return AnimatedSlide(
      offset: selected ? const Offset(0, -0.06) : Offset.zero,
      duration: duration,
      curve: AppMotion.enter,
      child: AnimatedScale(
        scale: selected ? 1.08 : 1,
        duration: duration,
        curve: AppMotion.enter,
        child: Icon(icon),
      ),
    );
  }
}
