import 'package:finanzas_app_mobile/core/motion/app_motion.dart';
import 'package:flutter/material.dart';

class AppAnimatedIndexedStack extends StatelessWidget {
  final int index;
  final List<Widget> children;

  const AppAnimatedIndexedStack({
    super.key,
    required this.index,
    required this.children,
  }) : assert(index >= 0);

  @override
  Widget build(BuildContext context) {
    assert(index < children.length);
    final duration = AppMotion.duration(context, AppMotion.standard);

    return Stack(
      fit: StackFit.expand,
      children: List.generate(children.length, (childIndex) {
        final isActive = childIndex == index;

        return TickerMode(
          enabled: isActive,
          child: FocusScope(
            canRequestFocus: isActive,
            skipTraversal: !isActive,
            child: IgnorePointer(
              ignoring: !isActive,
              child: ExcludeSemantics(
                excluding: !isActive,
                child: AnimatedOpacity(
                  opacity: isActive ? 1 : 0,
                  duration: duration,
                  curve: isActive ? AppMotion.enter : AppMotion.exit,
                  child: AnimatedScale(
                    scale: isActive ? 1 : 0.985,
                    duration: duration,
                    curve: AppMotion.enter,
                    child: children[childIndex],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
