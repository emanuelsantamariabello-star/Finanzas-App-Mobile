import 'package:flutter/material.dart';

abstract final class AppMotion {
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration standard = Duration(milliseconds: 220);
  static const Duration emphasized = Duration(milliseconds: 300);

  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve standardCurve = Curves.easeInOutCubic;

  static bool reduceMotion(BuildContext context) {
    return MediaQuery.maybeOf(context)?.disableAnimations ?? false;
  }

  static Duration duration(BuildContext context, Duration preferred) {
    return reduceMotion(context) ? Duration.zero : preferred;
  }

  static AnimationStyle modalStyle(BuildContext context) {
    return AnimationStyle(
      duration: duration(context, emphasized),
      reverseDuration: duration(context, standard),
    );
  }
}
