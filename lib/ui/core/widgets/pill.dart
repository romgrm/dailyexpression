import 'package:flutter/material.dart';

import 'sizer.dart';
import 'package:daily_expression/ui/core/theme/app_spacing.dart';

/// A rounded label chip with optional leading icon and tap callback. Reused for
/// tags and badges (e.g. the "coming soon" label and the category pill).
final class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.icon,
    this.onTap,
  });

  final String label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = foregroundColor ?? scheme.onSecondaryContainer;

    final pill = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.xl),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: foreground),
            const Sizer.xxs(),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );

    if (onTap == null) return pill;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSpacing.xl),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.xl),
        onTap: onTap,
        child: pill,
      ),
    );
  }
}
