import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

enum AppButtonVariant { primary, outlined, text, danger }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = isLoading
        ? const SizedBox(
            width: 20, height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
              Text(label),
            ],
          );

    final w = width ?? double.infinity;
    final effectiveOnPressed = (isLoading || onPressed == null) ? null : onPressed;

    switch (variant) {
      case AppButtonVariant.primary:
        return SizedBox(
          width: w, height: height,
          child: ElevatedButton(onPressed: effectiveOnPressed, child: child),
        );
      case AppButtonVariant.outlined:
        return SizedBox(
          width: w, height: height,
          child: OutlinedButton(onPressed: effectiveOnPressed, child: child),
        );
      case AppButtonVariant.text:
        return SizedBox(
          width: w, height: height,
          child: TextButton(onPressed: effectiveOnPressed, child: child),
        );
      case AppButtonVariant.danger:
        return SizedBox(
          width: w, height: height,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
            ),
            onPressed: effectiveOnPressed,
            child: child,
          ),
        );
    }
  }
}

// ─── Small icon button ────────────────────────────────────────────────────────

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.primaryLight,
          borderRadius: BorderRadius.circular(size / 2),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.primary, size: size * 0.5),
      ),
    );
  }
}
