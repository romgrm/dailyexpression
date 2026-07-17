/// Spacing scale on a 4px grid. Use these instead of raw padding/gap values so
/// spacing stays consistent across the app.
abstract final class AppSpacing {
  AppSpacing._();

  /// A 1px hairline, for separators and thin borders.
  static const double hairline = 1;

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
}
