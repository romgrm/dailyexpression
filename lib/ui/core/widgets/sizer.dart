import 'package:flutter/material.dart';

import 'package:daily_expression/ui/core/theme/app_spacing.dart';

/// Axis-aware spacing sized to the design scale. Use instead of SizedBox for
/// gaps, e.g. `const Sizer.m()`.
final class Sizer extends StatelessWidget {
  const Sizer.xxs({super.key}) : _extent = AppSpacing.xxs;
  const Sizer.xs({super.key}) : _extent = AppSpacing.xs;
  const Sizer.s({super.key}) : _extent = AppSpacing.sm;
  const Sizer.m({super.key}) : _extent = AppSpacing.md;
  const Sizer.l({super.key}) : _extent = AppSpacing.lg;
  const Sizer.xl({super.key}) : _extent = AppSpacing.xl;
  const Sizer.xxl({super.key}) : _extent = AppSpacing.xxl;
  const Sizer.xxxl({super.key}) : _extent = AppSpacing.xxxl;

  final double _extent;

  @override
  Widget build(BuildContext context) {
    Axis? axis;
    context.visitAncestorElements((element) {
      final widget = element.widget;
      if (widget is Flex) {
        axis = widget.direction;
        return false;
      }
      if (widget is Scrollable) return false;
      return true;
    });
    return (axis ?? Axis.vertical) == Axis.horizontal
        ? SizedBox(width: _extent)
        : SizedBox(height: _extent);
  }
}
