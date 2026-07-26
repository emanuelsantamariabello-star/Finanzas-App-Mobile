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
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool includeKeyboardInset;

  @override
  Widget build(BuildContext context) {
    final keyboardInset = includeKeyboardInset
        ? MediaQuery.viewInsetsOf(context).bottom
        : 0.0;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: keyboardInset),
        child: SingleChildScrollView(
          padding: padding,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: child,
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

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading || onPressed == null
            ? null
            : () {
                FocusManager.instance.primaryFocus?.unfocus();
                onPressed!();
              },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
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
              child: Text(
                isLoading ? loadingLabel ?? label : label,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
