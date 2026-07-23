import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:daily_expression/ui/core/theme/app_colors.dart';

/// The Daily Expression logo: two raindrops that also read as an opening
/// French guillemet («). Shown large on the splash and smaller in top bars,
/// optionally inside the brand's rounded-square ("squircle") background.
///
/// The mark is rendered from `assets/brand/logo_mark.svg` — the single source
/// of truth shared with the app icon — and tinted per theme.
final class Logo extends StatelessWidget {
  const Logo({super.key, this.size = 72, this.withBackground = true});

  static const _asset = 'assets/brand/logo_mark.svg';

  final double size;
  final bool withBackground;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // The squircle uses the soft "equivalent" tint in light (teal drops) and
    // the card surface in dark (cream drops) so it stays visible against the
    // scaffold. Shown bare, the drops take the theme's primary.
    final backgroundColor =
        isDark ? scheme.surface : scheme.secondaryContainer;
    final markColor = withBackground
        ? (isDark ? AppColors.brandCreamSoft : AppColors.brandTeal)
        : scheme.primary;
    final markSize = size * (withBackground ? 0.56 : 1);
    final mark = SvgPicture.asset(
      _asset,
      width: markSize,
      height: markSize,
      colorFilter: ColorFilter.mode(markColor, BlendMode.srcIn),
    );

    if (!withBackground) {
      return SizedBox(width: size, height: size, child: Center(child: mark));
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Center(child: mark),
    );
  }
}
