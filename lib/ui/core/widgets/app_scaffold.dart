import 'package:flutter/material.dart';

import 'package:daily_expression/ui/core/theme/app_spacing.dart';

/// Page shell with safe-area, standard horizontal padding, and an optional
/// pinned bottom action.
final class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.bottomAction,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
  });

  final Widget body;
  final Widget? bottomAction;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Padding(padding: padding, child: body)),
      bottomNavigationBar: bottomAction == null
          ? null
          : SafeArea(
              minimum: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Padding(padding: padding, child: bottomAction),
            ),
    );
  }
}
