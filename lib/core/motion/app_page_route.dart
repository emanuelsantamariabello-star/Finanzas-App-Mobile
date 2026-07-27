import 'package:finanzas_app_mobile/core/motion/app_motion.dart';
import 'package:flutter/material.dart';

abstract final class AppPageRoute {
  static PageRoute<T> build<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    RouteSettings? settings,
    bool fullscreenDialog = false,
  }) {
    final duration = AppMotion.duration(context, AppMotion.emphasized);

    return PageRouteBuilder<T>(
      settings: settings,
      fullscreenDialog: fullscreenDialog,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (routeContext, animation, secondaryAnimation) {
        return builder(routeContext);
      },
      transitionsBuilder: (routeContext, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0.025, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: AppMotion.enter),
                ),
            child: child,
          ),
        );
      },
    );
  }
}
