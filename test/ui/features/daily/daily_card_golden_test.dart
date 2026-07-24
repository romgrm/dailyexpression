import 'package:daily_expression/domain/models/language_pair.dart';
import 'package:daily_expression/l10n/generated/app_localizations.dart';
import 'package:daily_expression/ui/core/theme/app_theme.dart';
import 'package:daily_expression/ui/features/daily/view/widgets/daily_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/corpus_mock.dart';
import '../../../support/golden_fonts.dart';

/// Golden (snapshot) coverage for the hero [DailyCard] across the corpus v2
/// display cases. Because 1 day = 1 expression, we cannot wait for a specific
/// concept to surface on-device; these render curated mock concepts through the
/// real projection pipeline so any layout regression is caught immediately.
///
/// Regenerate with: flutter test --update-goldens test/ui/features/daily/daily_card_golden_test.dart
///
/// The card renders with the real [AppTheme] color scheme and the vendored
/// brand fonts (loaded by [loadGoldenFonts]): Lora for display/titles and
/// DM Sans for body/labels, mirroring [AppTypography]. The app fetches these
/// via google_fonts at runtime, which is unavailable in the offline test zone,
/// so the golden theme composes the same serif/sans split from the bundled TTFs
/// — keeping colours, spacing, pills, badges, layout AND text faithful.
ThemeData _goldenTheme(Brightness brightness) {
  final scheme = brightness == Brightness.dark
      ? AppTheme.darkColorScheme
      : AppTheme.lightColorScheme;
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: goldenSansFont,
  );
  TextStyle? serif(TextStyle? style) =>
      style?.copyWith(fontFamily: goldenSerifFont, fontWeight: FontWeight.w600);
  return base.copyWith(
    textTheme: base.textTheme
        .copyWith(
          displayLarge: serif(base.textTheme.displayLarge),
          displayMedium: serif(base.textTheme.displayMedium),
          displaySmall: serif(base.textTheme.displaySmall),
          headlineLarge: serif(base.textTheme.headlineLarge),
          headlineMedium: serif(base.textTheme.headlineMedium),
          headlineSmall: serif(base.textTheme.headlineSmall),
          titleLarge: serif(base.textTheme.titleLarge),
        )
        .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface),
  );
}

void main() {
  setUpAll(loadGoldenFonts);

  Future<void> pumpCard(
    WidgetTester tester, {
    required MockDaily daily,
    required Locale locale,
    Brightness brightness = Brightness.light,
  }) async {
    tester.view.physicalSize = const Size(430, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: _goldenTheme(Brightness.light),
        darkTheme: _goldenTheme(Brightness.dark),
        themeMode:
            brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: DailyCard(
              expression: daily.expression,
              nativeLanguageName: daily.nativeLanguageName,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('normal — fr -> en, native equivalent present', (tester) async {
    final daily = await loadMockDaily(
      conceptId: 'rain_heavy',
      pair: const LanguagePair(native: 'fr', target: 'en'),
      uiLanguageCode: 'fr',
    );
    await pumpCard(tester, daily: daily, locale: const Locale('fr'));

    await expectLater(
      find.byType(DailyCard),
      matchesGoldenFile('goldens/daily_card_normal.png'),
    );
  });

  testWidgets('no native equivalent — fr -> en, placeholder shown',
      (tester) async {
    final daily = await loadMockDaily(
      conceptId: 'call_shotgun',
      pair: const LanguagePair(native: 'fr', target: 'en'),
      uiLanguageCode: 'fr',
    );
    await pumpCard(tester, daily: daily, locale: const Locale('fr'));

    await expectLater(
      find.byType(DailyCard),
      matchesGoldenFile('goldens/daily_card_no_equivalent.png'),
    );
  });

  testWidgets('regional variant — en -> fr, Québécois badge', (tester) async {
    final daily = await loadMockDaily(
      conceptId: 'thumb_a_ride',
      pair: const LanguagePair(native: 'en', target: 'fr'),
      uiLanguageCode: 'fr',
    );
    await pumpCard(tester, daily: daily, locale: const Locale('fr'));

    await expectLater(
      find.byType(DailyCard),
      matchesGoldenFile('goldens/daily_card_variant.png'),
    );
  });

  testWidgets('non-equivalence note — fr -> en, callout shown', (tester) async {
    final daily = await loadMockDaily(
      conceptId: 'spill_the_beans',
      pair: const LanguagePair(native: 'fr', target: 'en'),
      uiLanguageCode: 'fr',
    );
    await pumpCard(tester, daily: daily, locale: const Locale('fr'));

    await expectLater(
      find.byType(DailyCard),
      matchesGoldenFile('goldens/daily_card_callout.png'),
    );
  });

  testWidgets('dark theme — fr -> en, native equivalent present',
      (tester) async {
    final daily = await loadMockDaily(
      conceptId: 'rain_heavy',
      pair: const LanguagePair(native: 'fr', target: 'en'),
      uiLanguageCode: 'fr',
    );
    await pumpCard(
      tester,
      daily: daily,
      locale: const Locale('fr'),
      brightness: Brightness.dark,
    );

    await expectLater(
      find.byType(DailyCard),
      matchesGoldenFile('goldens/daily_card_dark.png'),
    );
  });
}
