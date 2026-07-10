# Daily Expression — MVP Build Plan

Fully-offline Flutter app: one authentic idiom per day (native fr/es → English).
Layered architecture (data → domain → ui), Cubit state, go_router with an onboarding
gate, manual immutable models + hand-written `fromJson` (no freezed). Six milestones,
each ending in a review checkpoint the user approves before proceeding.

## Confirmed decisions
- State: Cubit (`flutter_bloc`), playing the ViewModel role from the architecture skill.
- Platforms: iOS + Android equally. Target = English only; native = fr/es.
- Navigation: `go_router` + onboarding redirect gate (deep-linking config excluded, offline app).
- Models: manual immutable classes + manual `fromJson` (pattern matching). No codegen/freezed.
- l10n: gen-l10n, synthetic-package, `arb-dir: lib/l10n`; UI langs fr/es (en = template). fr "tu", es "tú".
- Source of truth: `assets/corpus/corpus.json` (read-only) + `assets/scripts/validate_corpus.py`.
- MVP excludes: paywall, audio, widgets, favorites, archive, SRS, backend, analytics, accounts.

## Non-negotiable invariants
1. **Day determinism** — `SelectDailyExpression(pair, localDay)` is pure/local, identical everywhere
   (including notifications scheduled ahead). Anchor date constant; day boundary = device local midnight.
2. **Real content in reminders** — each notification carries that day's actual idiom.
3. **Streak integrity** — consecutive local days increment; a miss resets. Unit-tested. No freeze/repair.
4. **Localization discipline** — zero hardcoded user-facing strings; corpus renders as-is.

## Architecture (`lib/`)
```
data/
  models/        DTOs mirroring corpus JSON (CorpusDto, ConceptDto, FormDto, GlossDto, ConfigDto) + fromJson
  services/      CorpusAssetLoader, PreferencesService, NotificationService, SystemClock
  repositories/  CorpusRepository, SettingsRepository, StreakRepository  (map DTO → domain)
domain/
  models/        pure entities (below) — zero Flutter imports
  time/          Clock interface
  use_cases/     SelectDailyExpression, StreakCalculator, BuildReminderWindow
ui/
  core/          theme (AppColors/AppTypography/AppTheme), shared widgets, router
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
  (the availability rule lives here, pure)
- `DailyExpression {date, conceptId, idiom, literalImage, nativeEquivalent, example,
  exampleTranslation, meaning, level, categoryLabel, register, nonEquivalenceNote?, isNonEquivalent}`
- `LanguageInfo {code, nameNative, displayNames{}, flag}`
- `CorpusConfig {languages, categories, activePairs, selectableNativeCodes}`
- `AppSettings {nativeLanguage, reminderHour, reminderMinute, onboardingComplete}`
- `StreakState {count, lastOpenedDay?}`
- `ScheduledReminder {id, dateTime, title, body}`

**Contracts**
- `CorpusRepository`: `ensureLoaded()`, `config`, `activePairs`, `availableConcepts(pair)` (filtered + ordered),
  `categoryLabel(code, nativeLang)`
- `SettingsRepository`: `read()`, `save(AppSettings)`
- `StreakRepository`: `read()`, `save(StreakState)`
- `NotificationService`: `requestPermission()`, `scheduleWindow(list)`, `cancelAll()`
- `Clock`: `now()`, `today()` (date-only local midnight)

**Use cases**
- `SelectDailyExpression(corpusRepo)` — `days = dateOnly(localDay).difference(kAnchorDay).inDays`;
  `idx = ((days % n) + n) % n` into availability-filtered, editorial-ordered concepts; map to
  `DailyExpression` via `pair.glossKey`. Shared by UI **and** notifications. `kAnchorDay = 2026-01-01` local.
- `StreakCalculator.next(prev, today)` — same day → unchanged; `today == last + 1` → count+1; else → count=1.
- `BuildReminderWindow(select)` — builds 14 days of `ScheduledReminder`, each carrying the real idiom text.

## Corpus schema (v2.1) — grounding
- Concept fields: `id`, `category`, `level` (CEFR), `register`, `meaning{lang}`,
  `forms{lang:{text, example}}`, `glosses{"{target}_{native}":{literal, example_translation, note?}}`, `tags[]`.
- Availability rule: `forms[native] & forms[target] & glosses[key] & meaning[native]`.
- Non-equivalence: `glosses[key].note != null` → honest UI callout (never fabricate an idiom).
- `daily_card_render`: `forms.en.text` → `glosses.en_fr.literal` → `forms.fr.text` → `forms.en.example`
  → `glosses.en_fr.example_translation`, plus `meaning[native]`, CEFR badge, category label, note callout.
- 8 concepts, all valid for fr→en and es→en. Corpus is append-only / editorial order.

## Design tokens
cream `#F5F1E9` bg, surface `#FEFDFA`, teal `#2E6A5D` / tint `#E7F0EC`, ink `#26231C`, muted `#8B8577`,
sand `#F5EFE2`, gold badge `#F7ECC8`/`#8A6D1B`, flame `#E2572B`. Fraunces serif (`google_fonts`) for
display/titles; system sans body. Radii ~20, pill buttons, soft shadows, one teal CTA per screen,
never pure-white full screens.

## Dependencies
- runtime: `flutter_bloc`, `bloc`, `go_router`, `shared_preferences`, `flutter_local_notifications`,
  `timezone`, `flutter_timezone`, `google_fonts`, `intl`, `flutter_localizations` (sdk).
- dev: `flutter_lints`, `bloc_test`, `test`.

## Milestones (review checkpoint after each)
### M0 · Setup
Add deps; `pubspec` (`generate: true`, register corpus asset, Fraunces); `l10n.yaml` + minimal ARBs;
folder skeleton; theme tokens; replace counter `main.dart` with providers + router placeholder.
**CHECK:** `flutter pub get`, `flutter analyze` clean, app runs a blank themed screen.

### M1 · Domain core (+tests)
enums → value models → `Concept` (+`isAvailableFor`) → `DailyExpression` → `CorpusConfig` →
settings/streak/reminder VOs → `Clock` → the three use cases.
**CHECK:** `flutter test` green — availability (incl. `es` non-equivalence), selection determinism
(midnight rollover + wrap-around past concept 8), streak via `FakeClock`, reminder-window content; validator OK.

### M2 · Data
DTOs + `fromJson` (pattern matching) → `CorpusAssetLoader` → `CorpusRepository` (map/filter/order,
tested against the **real** asset) → Preferences + `SettingsRepository` → `StreakRepository` → `SystemClock`.
**CHECK:** repo tests green, analyze clean.

### M3 · Daily card
`DailyCubit` → `DailyView` hero card in `daily_card_render` order + CEFR badge + category + streak flame →
non-equivalence callout → opening the card updates the streak → route `/`.
**CHECK:** manual run iOS + Android; widget test for card + non-equivalence.

### M4 · Onboarding
`OnboardingCubit` (native pick fr/es, others greyed → waitlist; English confirm; reminders pitch) →
3-step views → persist `AppSettings` + `onboardingComplete` → go_router redirect gate.
**CHECK:** fresh install → onboarding → daily; relaunch skips onboarding.

### M5 · Notifications
`NotificationService` (init, tz, permission, schedule, cancel) → wire `BuildReminderWindow` (14-day window) →
reschedule on app resume (`WidgetsBindingObserver`) → permission flow in onboarding, graceful deny.
**CHECK:** scheduled notification shows the real idiom; resume refreshes; under iOS 64-pending cap.

### M6 · Settings + polish
`SettingsCubit` + view (language, reminder time, about) → changes reschedule + refresh card →
final l10n pass (zero hardcoded strings) → flame/empty/error polish.
**CHECK:** analyze + test + validator all green; manual smoke iOS + Android.

## Testing gate (every milestone)
`python3 assets/scripts/validate_corpus.py` · `flutter analyze` · `flutter test`.
Leverages `.agents` skills: `dart-add-unit-test`, `flutter-add-widget-test`, `dart-run-static-analysis`,
`flutter-setup-localization`, `flutter-setup-declarative-routing`, `flutter-implement-json-serialization`,
`flutter-apply-architecture-best-practices`.

## Open defaults (confirm before M0)
1. Day anchor = `2026-01-01` local.
2. Reminder window = 14 days.
3. Selection wraps (repeats every 8 days) — no anti-repeat logic in MVP.
4. `go_router` + redirect gate (vs. plain Navigator).
5. No freezed — hand-written immutable models with `==` / `copyWith`.
