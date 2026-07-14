# Daily Expression — MVP (V1) Build Plan

Fully-offline Flutter app: one authentic idiom per day (native fr/es → English).
Layered architecture (data → domain → ui), Cubit state, go_router with an onboarding
gate, manual immutable models + hand-written `fromJson` (no freezed). Six milestones,
each broken into fine-grained, individually-reviewable steps ending in a review checkpoint.

## V1 scope (locked)
- IN: splash, onboarding (native pick, target confirm, reminders pitch), daily card,
  daily local notification (real content), settings (source language, reminder time, theme, about),
  light + dark + auto theme.
- DEFERRED TO V2: audio pronunciation, streak.
- OUT (skill hard boundary): paywall, widgets, favorites, archive, SRS, backend, analytics, accounts.

## Confirmed decisions
- State: Cubit (`flutter_bloc`), playing the ViewModel role from the architecture skill.
- Platforms: iOS + Android equally. Target = English only; native = fr/es.
- Navigation: `go_router` + onboarding redirect gate (deep-linking config excluded, offline app).
- Models: manual immutable classes + manual `fromJson` (pattern matching). No codegen/freezed.
- l10n: gen-l10n, `synthetic-package: false` → `lib/l10n/generated/`; `arb-dir: lib/l10n`;
  UI langs fr/es (en = template). fr "tu", es "tú".
- Theme: light + dark + auto (ThemeMode.system) switcher; tokens are the Figma values (below), which
  SUPERSEDE the approximate palette in the skill (mockups win on visuals).
- DI: constructor injection via `MultiRepositoryProvider` (no get_it).
- Source of truth (content): `assets/corpus/corpus.json` (read-only) + `assets/scripts/validate_corpus.py`.

## Non-negotiable invariants
1. **Day determinism** — `SelectDailyExpression(pair, localDay)` is pure/local, identical everywhere
   (including notifications scheduled ahead). Anchor date constant; day boundary = device local midnight.
2. **Real content in reminders** — each notification carries that day's actual idiom (the retention loop for V1).
3. **Localization discipline** — zero hardcoded user-facing strings; corpus renders as-is.
(Streak integrity was invariant #3 in the skill; deliberately deferred to V2 by product decision.)

## Design references (`design/v1/`)
- `splashscreen_v1.png` — splash / intro (logo, "UNE EXPRESSION · CHAQUE JOUR", page dots).
- `langage_selection_v1.png` — onboarding native pick (Français ✓, Español, Anglais/Deutsch → "BIENTÔT").
- `langage_learning_selection_v1.png` — onboarding target confirm (Anglais, locked) + description + Commencer.
- `notification_asking_v1.png` — reminders pitch (bell, "Chaque jour à 8 h 00", Activer / Plus tard).
- `homescreen_v1.png` — daily card (hero).
- `settings_v1.png` — settings ("Réglages").

## Architecture (`lib/`)
```
data/
  dtos/          DTOs mirroring corpus JSON (CorpusDto, ConceptDto, FormDto, GlossDto, ConfigDto) + fromJson
  services/      CorpusAssetLoader, PreferencesService, NotificationService, SystemClock
  repositories/  CorpusRepository, SettingsRepository  (map DTO → domain)
domain/
  models/        pure entities (below) — zero Flutter imports
  time/          Clock interface
  use_cases/     SelectDailyExpression, BuildReminderWindow
ui/
  core/          theme (AppColors/AppTypography/AppTheme), shared widgets, router, ThemeCubit
  features/      onboarding · daily · settings  (each: cubit/ + view/)
l10n/            app_en.arb (template) · app_fr.arb · app_es.arb
main.dart        RepositoryProvider → MultiBlocProvider → MaterialApp.router
```
Dependencies flow inward; the domain layer imports zero Flutter. Time is injected via `Clock`.

## Domain entities & contracts
**Models**
- `LanguagePair {native, target, glossKey => '${target}_$native'}`
- `enum CefrLevel {a1..c2}` (+ label); `enum Register {neutral, informal, formal}`
- `ExpressionForm {text, example}`
- `Gloss {literal, exampleTranslation, note?, isNonEquivalent => note != null}`
- `Concept {id, category, level, register, meaning{}, forms{}, glosses{}, tags[]; isAvailableFor(pair)}`
- `DailyExpression {date, conceptId, idiom, literalImage, nativeEquivalent, example,
  exampleTranslation, meaning, level, categoryLabel, register, nonEquivalenceNote?, isNonEquivalent}`
- `LanguageInfo {code, nameNative, displayNames{}, flag}`
- `CorpusConfig {languages, categories, activePairs, selectableNativeCodes}`
- `enum AppThemeMode {system, light, dark}`
- `AppSettings {nativeLanguage, reminderHour=8, reminderMinute=0, themeMode=system, onboardingComplete=false}`
- `ScheduledReminder {id, dateTime, title, body}`
(V2: StreakState, StreakCalculator, StreakRepository.)

**Contracts**
- `CorpusRepository`: `ensureLoaded()`, `config`, `activePairs`, `availableConcepts(pair)` (filtered + ordered),
  `categoryLabel(code, nativeLang)`
- `SettingsRepository`: `read()`, `save(AppSettings)`
- `NotificationService`: `requestPermission()`, `scheduleWindow(list)`, `cancelAll()`
- `Clock`: `now()`, `today()` (date-only local midnight)

**Use cases**
- `SelectDailyExpression(corpusRepo)` — `days = dateOnly(localDay).difference(kAnchorDay).inDays`;
  `idx = ((days % n) + n) % n` into availability-filtered, editorial-ordered concepts; map to
  `DailyExpression` via `pair.glossKey`. Shared by UI **and** notifications. `kAnchorDay = 2026-01-01` local.
- `BuildReminderWindow(select)` — builds 14 days of `ScheduledReminder`, each carrying the real idiom text.

## Corpus schema (v2.1) — grounding
- Concept fields: `id`, `category`, `level` (CEFR), `register`, `meaning{lang}`,
  `forms{lang:{text, example}}`, `glosses{"{target}_{native}":{literal, example_translation, note?}}`, `tags[]`.
- Availability rule: `forms[native] & forms[target] & glosses[key] & meaning[native]`.
- Non-equivalence: `glosses[key].note != null` → honest UI callout (never fabricate an idiom).
- `daily_card_render`: `forms.en.text` → `glosses.en_fr.literal` → `forms.fr.text` → `forms.en.example`
  → `glosses.en_fr.example_translation`, plus `meaning[native]`, CEFR badge, category label, note callout.
- 8 concepts, all valid for fr→en and es→en. Corpus is append-only / editorial order.

## Design tokens (Figma — source of truth)
Base font size 16. Radius: `--radius: 1rem` → sm 12 · md 14 · lg 16 · xl 20. Corner default ~16–20.

| Role | Light | Dark |
|------|-------|------|
| background (scaffold) | #FAF8F4 | #141210 |
| foreground (text)     | #1C1917 | #F5F0EB |
| card / surface        | #FFFFFF | #1E1C19 |
| primary (teal)        | #1B6B6B | #4DB6AC |
| onPrimary             | #FFFFFF | #0E2626 |
| secondary/accent tint | #EBF5F5 | #1A2E2E |
| on secondary/accent   | #1B6B6B | #4DB6AC |
| muted (fill)          | #F0EDE8 | #262320 |
| mutedForeground       | #8B7E74 | #8B8073 |
| input background      | #F0EDE8 | rgba(245,240,235,.07) |
| switch background     | #C5BFB8 | (derived) |
| border / outline      | rgba(28,25,23,.08) | rgba(245,240,235,.07) |
| destructive / error   | #D4183D | #F2B8B5 text on muted red |
| ring / focus          | #1B6B6B | #4DB6AC |

Supplementary (not in Figma vars, on the daily card):
- Gold CEFR badge: bg #F7ECC8 / text #8A6D1B (light); dark variant derived.
Typography: Fraunces (serif, `google_fonts`) for display/titles (idiom headline, screen titles);
system sans for body/labels. h1→titleLarge/headline, uppercase muted overlines for section labels.

## Dependencies
- runtime: `flutter_bloc`, `bloc`, `go_router`, `shared_preferences`, `flutter_local_notifications`,
  `timezone`, `flutter_timezone`, `google_fonts`, `intl`, `flutter_localizations` (sdk).
- dev: `flutter_lints`, `bloc_test`, `mocktail`, `test`.

---

# Detailed milestones

Each step: **Goal / Files / Details / Done-when**. One conventional-commit per milestone.
Shared test fakes live in `test/support/`.

## M0 · Setup & Foundation
- **0.1** Runtime deps (`pubspec.yaml`). Done: `flutter pub get` clean.
- **0.2** Dev deps (bloc_test, mocktail). Done: analyze clean.
- **0.3** l10n: `generate: true` + `l10n.yaml` (`arb-dir: lib/l10n`, template `app_en.arb`,
  `output-localization-file: app_localizations.dart`, `synthetic-package: false`, output `lib/l10n/generated/`).
- **0.4** Seed ARBs `app_en/fr/es.arb` (appTitle + tagline; fr "tu", es "tú"). Done: `flutter gen-l10n` OK.
- **0.5** Folder skeleton: `lib/data/{models,services,repositories}`, `lib/domain/{models,time,use_cases}`,
  `lib/ui/{core/theme,core/widgets,core/router,features}`.
- **0.6** `app_colors.dart` — light + dark token sets (table above).
- **0.7** `app_typography.dart` — Fraunces display/titles + system body; `TextTheme buildTextTheme(ColorScheme)`.
- **0.8** `app_theme.dart` — `lightTheme` + `darkTheme` (M3 ColorSchemes from tokens, radii, pill buttons, scaffold bg).
- **0.9** `theme_cubit.dart` — holds `AppThemeMode`, maps to `ThemeMode`; seeded from settings later.
- **0.10** `app_router.dart` — `GoRouter` single `/` → themed `PlaceholderHome`; redirect gate stubbed.
- **0.11** `main.dart` — `DailyExpressionApp` wraps `MaterialApp.router` (theme/darkTheme/themeMode via ThemeCubit,
  `localizationsDelegates`, `supportedLocales: [fr, es]`); empty `MultiRepositoryProvider`/`MultiBlocProvider`.
- **CHECK:** `flutter pub get`, `flutter gen-l10n`, `flutter analyze` clean; runs a blank themed screen (light + dark).
- **Commit** `feat(setup): deps, light/dark theme, l10n scaffold, router shell`.

## M1 · Domain Core (pure Dart, fully tested)
- **1.1** Enums `cefr_level.dart`, `register.dart` (+label, +parse). Test: parse valid/invalid.
- **1.2** VOs `language_pair.dart`, `expression_form.dart`, `gloss.dart`, `language_info.dart`. Test: glossKey, isNonEquivalent.
- **1.3** `concept.dart` (+`isAvailableFor`). Test: fr→en & es→en; missing es gloss ⇒ unavailable for es→en.
- **1.4** `daily_expression.dart` (`fromConcept(...)` render order). Test: rain_heavy fr→en; other_fish_to_fry es→en ⇒ nonEquivalent.
- **1.5** `corpus_config.dart` (`selectableNativeCodes`). Test: {fr, es}.
- **1.6** `app_settings.dart` (+`AppThemeMode`), `scheduled_reminder.dart` — copyWith/==, defaults (reminder 08:00, themeMode system).
- **1.7** `domain/time/clock.dart` + `FakeClock` in `test/support/`. Test: today() strips time.
- **1.8** `use_cases/select_daily_expression.dart` — `kAnchorDay = DateTime.utc(2026,1,1)`, `idx=((days%n)+n)%n`.
  Tests: determinism, day advance, **midnight rollover**, **wrap-around past concept 8**, pre-anchor negatives.
- **1.9** `use_cases/build_reminder_window.dart` — 14 entries, real idiom bodies, unique ids. Tests: count/order/body.
- **1.10** Gate + commit `feat(domain): models, availability, daily selector, reminder window (+tests)`. **CHECK**.

## M2 · Data Layer
- **2.1** DTOs `data/dtos/corpus_dto.dart` (+ Config/Concept/Form/Gloss) — manual fromJson. Test: decode inline JSON.
- **2.2** `corpus_asset_loader.dart` — rootBundle + jsonDecode; injectable bundle. Test: fake bundle.
- **2.3** `corpus_repository.dart` — DTO→domain, cache, availableConcepts filtered+ordered, categoryLabel.
  Test (**real asset**): 8 concepts; both pairs = 8; labels localized; notes preserved.
- **2.4** `preferences_service.dart` — typed SharedPreferences wrapper. Test: setMockInitialValues.
- **2.5** `settings_repository.dart` — read/save AppSettings (incl themeMode), defaults. Test: round-trip + defaults.
- **2.6** `system_clock.dart` — implements Clock.
- **2.7** Gate + commit `feat(data): dtos, corpus/settings repositories, clock (+tests)`. **CHECK**.

## M3 · Daily Card (ref: homescreen_v1.png)
- **3.1** DI wiring at root; provide use cases.
- **3.2** `DailyState`: DailyLoading / DailyLoaded(expr) / DailyError(message).
- **3.3** `DailyCubit.load()` (selector + clock). No streak in V1.
- **3.4** Sub-widgets: top bar (logo + "Daily Expression" + gear), localized date overline,
  category pill (icon + label), CEFR gold badge, serif idiom headline, italic literal («…»),
  divider, teal-tinted "ÉQUIVALENT EN {NATIVE}" block, "EN CONTEXTE" card (example bold + translation muted).
  **No audio button (V2).**
- **3.5** Non-equivalence callout — discreet, only when isNonEquivalent.
- **3.6** `DailyView` composes render order; BlocBuilder loading/error/loaded.
- **3.7** Route `/` → DailyView; remove placeholder; gear → `/settings`.
- **3.8** Widget tests: fr→en fields; non-equivalent es→en callout; loading/error.
- **3.9** Manual run iOS + Android (light + dark). **CHECK**. Commit `feat(daily): hero card`.

## M4 · Onboarding (refs: splashscreen / langage_selection / langage_learning_selection / notification_asking)
- **4.1** OnboardingState/Cubit (step, native, reminder time).
- **4.2** Splash/intro screen (logo, tagline, page dots) → first launch entry.
- **4.3** Native pick (fr/es selectable; en/de greyed "BIENTÔT"); Continuer.
- **4.4** Target confirm (Anglais, locked) + description; Commencer.
- **4.5** Reminders pitch (bell; "Chaque jour à HH h MM" default 08:00 via time picker; Activer les rappels / Plus tard).
- **4.6** Persist AppSettings + onboardingComplete; permission ask (graceful deny).
- **4.7** Router redirect gate (not-complete → onboarding flow).
- **4.8** Cubit + widget tests. **CHECK** (fresh → onboarding → daily; relaunch skips). Commit.

## M5 · Notifications
- **5.1** `NotificationService` (init, tz via flutter_timezone, channel, permission, zonedSchedule, cancelAll).
- **5.2** `NotificationScheduler` wiring BuildReminderWindow (14-day window).
- **5.3** Schedule after onboarding + on settings change; **5.4** reschedule on resume (WidgetsBindingObserver);
  **5.5** graceful denial. **5.6** coordinator tests (fake service asserts 14 zoned schedules w/ real idiom bodies).
- **CHECK** (device: notification shows real idiom; resume refreshes; ≤64 pending). Commit.

## M6 · Settings + Polish (ref: settings_v1.png)
- **6.1** `SettingsCubit` + view. PRÉFÉRENCES: Langue source, Rappel quotidien, **Thème (Automatique/Clair/Sombre)**;
  À PROPOS: À propos de l'app, Laisser un avis; footer "Daily Expression · Version x.y.z".
- **6.2** Theme change → ThemeCubit + persist; language/time change → reschedule + refresh card.
- **6.3** Full l10n pass (no hardcoded strings). **6.4** empty/error/loading polish.
- **6.5** Final gate: validate_corpus.py + analyze + test + manual smoke (light+dark, both platforms).
- **CHECK**. Commit + tag `v0.1.0-mvp`.

## Cross-cutting conventions
1. One conventional-commit per milestone.
2. `test/support/` holds FakeClock, fake repos/bundle, shared fixtures.
3. Explicit state classes (loading/loaded/error) for every Cubit.
4. DI via `MultiRepositoryProvider` (constructor injection, no get_it).
5. `synthetic-package: false` for l10n.
6. Design = `design/v1/*` (visual truth); skill = scope/invariants; this plan = the rest.

## Testing gate (every milestone)
`python3 assets/scripts/validate_corpus.py` · `flutter analyze` · `flutter test`.

## Resolved defaults
1. Day anchor = `2026-01-01` local.  2. Reminder window = 14 days.  3. Selection wraps (repeats every 8 days) — no anti-repeat in MVP.
4. `go_router` + redirect gate.  5. No freezed.  6. Reminder default 08:00.  7. Theme = light+dark+auto.
