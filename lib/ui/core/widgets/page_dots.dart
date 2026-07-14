import 'package:flutter/material.dart';

import 'package:daily_expression/ui/core/theme/app_spacing.dart';

/// Horizontal progress dots for the onboarding flow. The active dot is a wider
/// teal pill; the rest are small muted dots.
class PageDots extends StatelessWidget {
  const PageDots({super.key, required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
          width: active ? AppSpacing.xl : AppSpacing.xs,
          height: AppSpacing.xs,
          decoration: BoxDecoration(
            color: active
                ? scheme.primary
                : scheme.onSurfaceVariant.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(AppSpacing.xxs),
          ),
        );
      }),
    );
  }
}
