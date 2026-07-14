import 'package:flutter/material.dart';

/// The Daily Expression logo: a rounded, tinted square holding the brand glyph.
/// Used large on the splash screen and smaller (optionally without the square)
/// in top bars.
final class Logo extends StatelessWidget {
  const Logo({super.key, this.size = 72, this.withBackground = true});

  final double size;
  final bool withBackground;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final glyph = Icon(
      Icons.forum_outlined,
      size: size * 0.5,
      color: scheme.primary,
    );

    if (!withBackground) {
      return SizedBox(width: size, height: size, child: Center(child: glyph));
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Center(child: glyph),
    );
  }
}
