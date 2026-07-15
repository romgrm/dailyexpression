import 'package:flutter/material.dart';

/// A small uppercase, letter-spaced, muted label — the editorial "overline"
/// used for section headers and taglines (e.g. "UNE EXPRESSION · CHAQUE JOUR").
final class Overline extends StatelessWidget {
  const Overline(this.text, {super.key, this.color, this.textAlign});

  final String text;
  final Color? color;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text.toUpperCase(),
      textAlign: textAlign,
      style: theme.textTheme.labelMedium?.copyWith(
        color: color ?? theme.colorScheme.onSurfaceVariant,
        letterSpacing: 1.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
