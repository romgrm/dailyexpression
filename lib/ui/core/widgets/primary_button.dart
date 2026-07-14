import 'package:flutter/material.dart';

import 'package:daily_expression/ui/core/theme/app_spacing.dart';

/// The single filled teal pill CTA per screen (e.g. "Commencer", "Continuer",
/// "Activer les rappels"). Full width by default; supports an optional trailing
/// icon (the "→" in the mockups). Styling comes from the app theme's
/// [FilledButtonThemeData], so it stays consistent everywhere.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.trailingIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label),
            if (trailingIcon != null) ...[
              const SizedBox(width: AppSpacing.xs),
              Icon(trailingIcon, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}
