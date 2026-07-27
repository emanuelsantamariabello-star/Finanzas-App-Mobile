import 'package:finanzas_app_mobile/core/motion/app_motion.dart';
import 'package:finanzas_app_mobile/presentation/widgets/app_pressable.dart';
import 'package:flutter/material.dart';

class AppFormDecoration {
  static InputDecoration input({
    required BuildContext context,
    required String label,
    required IconData icon,
    String? hint,
    Widget? suffixIcon,
  }) {
    final theme = Theme.of(context);

    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: theme.inputDecorationTheme.fillColor ?? theme.cardColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }
}

class AppSurfaceCard extends StatelessWidget {
  const AppSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.4)),
      ),
      child: child,
    );
  }
}

class AppFormScrollView extends StatelessWidget {
  const AppFormScrollView({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.includeKeyboardInset = false,
    this.includeBottomSafeInset = false,
    this.maxContentWidth = 640,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool includeKeyboardInset;
  final bool includeBottomSafeInset;
  final double maxContentWidth;

  @override
  Widget build(BuildContext context) {
    final keyboardInset = includeKeyboardInset
        ? MediaQuery.viewInsetsOf(context).bottom
        : 0.0;
    final bottomSafeInset = includeBottomSafeInset
        ? MediaQuery.viewPaddingOf(context).bottom
        : 0.0;
    final effectivePadding = padding.add(
      EdgeInsets.only(bottom: bottomSafeInset),
    );

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: AnimatedPadding(
        duration: AppMotion.duration(context, AppMotion.fast),
        curve: AppMotion.enter,
        padding: EdgeInsets.only(bottom: keyboardInset),
        child: SingleChildScrollView(
          padding: effectivePadding,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.loadingLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final String? loadingLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveLabel = isLoading ? loadingLabel ?? label : label;
    final isEnabled = !isLoading && onPressed != null;

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: effectiveLabel,
      excludeSemantics: true,
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: isEnabled
              ? () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  onPressed!();
                }
              : null,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: AnimatedSwitcher(
            duration: AppMotion.duration(context, AppMotion.fast),
            switchInCurve: AppMotion.enter,
            switchOutCurve: AppMotion.exit,
            child: Row(
              key: ValueKey(isLoading),
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoading)
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.onPrimary,
                    ),
                  )
                else if (icon != null)
                  Icon(icon),
                if (isLoading || icon != null) const SizedBox(width: 8),
                Flexible(
                  child: Text(effectiveLabel, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
        ),
      ).withPressFeedback(enabled: isEnabled),
    );
  }
}
