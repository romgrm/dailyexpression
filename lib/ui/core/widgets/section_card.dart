import 'package:flutter/material.dart';

import 'package:daily_expression/ui/core/theme/app_spacing.dart';

/// A rounded surface card with a soft border — the editorial container used for
/// grouped content (e.g. the "EN CONTEXTE" block, settings sections).
final class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? scheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: child,
    );
  }
}
