import 'package:finanzas_app_mobile/core/motion/app_motion.dart';
import 'package:flutter/material.dart';

typedef AppNumberFormatter = String Function(double value);

class AppAnimatedNumberText extends StatelessWidget {
  const AppAnimatedNumberText({
    super.key,
    required this.value,
    required this.formatter,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final double value;
  final AppNumberFormatter formatter;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final finalLabel = formatter(value);

    return Semantics(
      label: finalLabel,
      excludeSemantics: true,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value),
        duration: AppMotion.duration(context, AppMotion.emphasized),
        curve: AppMotion.enter,
        builder: (context, animatedValue, _) {
          return Text(
            formatter(animatedValue),
            style: style,
            textAlign: textAlign,
            maxLines: maxLines,
            overflow: overflow,
          );
        },
      ),
    );
  }
}
