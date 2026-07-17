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

## Build approach — screen-first vertical slices
M0 (foundation) is done. From here we build **screen by screen**. Each slice = the screen's UI (from
`design/v1/*`) + only the domain/data it needs + its tests. Reusable pieces live in `lib/ui/core/widgets/`
and are shared across screens (compose, never duplicate). Good patterns are non-negotiable even for the MVP:
immutable models, layered separation (`ui -> domain <- data`, domain imports zero Flutter), one Cubit +
explicit states per feature, DI via providers, manual `fromJson`, and unit tests for every piece of real logic.

## S1 - Shared UI kit + Splash (ref: splashscreen_v1.png)
Goal: reusable component library + first visible screen; validates theme in light/dark.
- **1.1** `ui/core/widgets/`: `PrimaryButton` (pill teal CTA), `AppScaffold` (bg + safe padding),
  `SectionCard` (rounded surface card), `Overline` (uppercase muted label), `PageDots`, `BrandMark` (logo mark).
- **1.2** `ui/features/onboarding/view/splash_screen.dart` - BrandMark + appTitle (serif) + appTagline overline + PageDots.
- **1.3** Route it as the initial screen (temporary) to see it.
- **1.4** Widget tests: renders title/tagline; component structure.
- **CHECK** (run light+dark, both platforms). Commit `feat(ui): shared component kit + splash`.

## S2 - Onboarding (refs: langage_selection / langage_learning_selection / notification_asking)
Goal: the 3-step first-run flow; introduces settings persistence + router gate.
- **2.1** `AppSettings` (+`AppThemeMode`) model, `PreferencesService`, `SettingsRepository`
  (read/save, defaults 08:00 / system) - round-trip + defaults tests.
- **2.2** Language list from corpus config (flags/labels) via `LanguageInfo`/`CorpusConfig` (prefer reading config).
- **2.3** `OnboardingCubit` + `OnboardingState` (step, chosenNative, reminderTime).
- **2.4** Views (reuse S1 kit): native pick (fr/es selectable; en/de greyed "BIENTOT"; Continuer),
  target confirm (Anglais locked + description; Commencer), reminders pitch (bell; time picker default 08:00;
  Activer les rappels / Plus tard).
- **2.5** Persist `AppSettings` + `onboardingComplete`; permission ask stubbed (real scheduling in S5).
- **2.6** go_router redirect gate: not-complete -> onboarding; complete -> `/`.
- **2.7** Cubit + widget tests. **CHECK** (fresh -> onboarding -> home; relaunch skips). Commit `feat(onboarding): first-run flow`.

## Daily selection & data model - CORE DESIGN (revised 2026-07-17)
The daily pick is the product's core. It must stay correct as the corpus grows and as premium
features (history, favorites, themes, multi-language) and a Supabase backend arrive later - with
NO breaking changes for existing users. Design decisions below supersede the old anchor+modulo idea.

### Decisions (locked with the user)
- **Per-user stream** (deterministic via a persisted `userSeed`), NOT a global "same expression for
  everyone today". Rationale: the social/shared angle is weak for idiom learning; per-user unlocks
  personalized history/themes.
- **Persisted daily log built now (S3)**, stored **local-only** (shared_preferences) behind a
  `DailyLogRepository` interface. Reinstall / 2nd-device history loss accepted before the backend.
- **Selection dedupes on `conceptId`**, never on date or category. "Seen" = set of `conceptId` in the log.
- **Category is display + future theme filter only** - it has ZERO effect on selection. Many concepts
  can share a category (e.g. several `weather`). The only hard rule: each `concept.id` is unique & stable.
- **Exhaustion** (~8 concepts today): reshuffle, avoiding immediate repeats (skip last-K seen). Optional
  future rule: avoid same category as the previous day (not needed for MVP).
- **Day boundary** = device LOCAL calendar day (matches the 08:00 local reminder).
- **Content lifecycle**: never delete an assigned concept; mark `active:false` to drop it from future
  pools while keeping it resolvable by id for history (documented; not enforced in MVP code).

### Log entry shape (local now, Supabase-ready)
`{ dayKey: "2026-07-17", pairKey: "en_fr", conceptId: "rain_heavy", assignedAt: <ts>, schemaVersion: 1 }`
Natural key = `(dayKey, pairKey)` locally, `(user_id, pair_key, day_key)` on the server.
`schemaVersion` + `assignedAt` are baked in from the first commit as migration/merge insurance.

### Algorithm - `GetDailyExpression(now)` (resolve-or-assign)
```
dayKey  = localDayKey(clock.now()); pairKey = '${target}_${native}'
existing = log.forDay(dayKey, pairKey)
if existing != null: return corpus.byId(existing.conceptId).renderFor(pair)   // frozen history
pool    = corpus.availableConcepts(pair)            // + theme/level filters later
seen    = log.history(pairKey).map((e) => e.conceptId).toSet()
cands   = pool.where((c) => !seen.contains(c.id))
if cands.isEmpty: cands = pool.where((c) => !lastK(seen).contains(c.id))       // reshuffle
pick    = cands.minBy((c) => stableHash('$userSeed|$pairKey|$dayKey|${c.id}'))
log.save(DailyAssignment(dayKey, pick.id, pairKey)); return pick.renderFor(pair)
```
Deterministic given (userSeed, clock, log, pool). Past days are frozen; adding concepts only enlarges
FUTURE candidate pools - never rewrites history.

### Backend evolution (Supabase - later, premium milestone)
- Table `daily_log (user_id, pair_key, day_key, concept_id, assigned_at, schema_version)`,
  PK `(user_id, pair_key, day_key)` = the local natural key.
- Migration = idempotent `upsert(onConflict: 'user_id,pair_key,day_key', ignoreDuplicates: true)`;
  device conflicts resolved by earliest `assigned_at` (first writer wins).
- **RLS** `auth.uid() = user_id` -> each user only reads/writes their own rows.
- **Anonymous auth** bridges existing local users: local log uploads under an anon session, later linked
  to a real identity (email/OAuth) without losing history.
- **Content stays bundled/CDN** (referenced by `concept_id`), never stored in Postgres -> corpus and
  user data evolve independently. Offline-first preserved: local log is the working store, Supabase syncs.
- Everything is a NEW `DailyLogRepository` implementation - `GetDailyExpression` and the UI are untouched.

## S3 - Daily Card (ref: homescreen_v1.png) - hero + core logic
Goal: the daily expression screen, backed by the real corpus and the deterministic PERSISTED selector.
- **3.1** Domain: enums `CefrLevel`/`Register`; VOs `LanguagePair`/`ExpressionForm`/`Gloss`;
  `Concept` (+`isAvailableFor`); `DailyExpression` (`fromConcept` render order); `CorpusConfig`;
  `DailyAssignment {dayKey, conceptId, pairKey, assignedAt, schemaVersion}`. Unit tests.
- **3.2** `Clock` interface + `SystemClock` + `FakeClock` (test/support) + `localDayKey(DateTime)` helper.
- **3.3** Data: `data/dtos/` corpus DTOs + `CorpusAssetLoader` + `CorpusRepository`
  (`availableConcepts(pair)` / `byId` / `categoryLabel`). Test against the **real asset**
  (8 concepts; both pairs = 8; notes preserved).
- **3.4** Persistence: `DailyLogRepository` interface + `PrefsDailyLogRepository` (shared_preferences
  JSON list): `forDay(dayKey,pairKey)` / `history(pairKey)` / `save(assignment)`. Round-trip tests.
  `userSeed` generated once at first launch, persisted in settings, injected into the use case.
- **3.5** Use case `GetDailyExpression` (resolve-or-assign, per Core Design) + deterministic `stableHash`.
  **Determinism tests**: same (seed,day,pool)=>same id; day advance; **midnight rollover**;
  **no-repeat until exhausted**; **reshuffle avoids last-K**; **frozen replay** (re-resolving a logged
  day returns the logged id even after the pool grows).
- **3.6** `DailyCubit` + `DailyState` (loading/loaded/error). (Optional: render first with a sample
  expression to nail layout, then wire the use case - explicitly flagged temporary scaffold.)
- **3.7** Card sub-widgets (reuse kit): top bar (Logo + title + gear), date Overline, category `Pill`,
  CEFR gold badge, serif idiom headline, italic literal, divider, teal-tinted "EQUIVALENT EN {NATIVE}"
  block, "EN CONTEXTE" SectionCard (example bold + translation muted). **No audio button (V2).**
- **3.8** Non-equivalence callout - discreet, only when `isNonEquivalent` (gloss.note != null).
- **3.9** `DailyView` composes render order; BlocBuilder states; route `/` -> DailyView; gear -> `/settings`.
- **3.10** Widget tests (fr->en fields; non-equivalent es->en callout; loading/error). **CHECK**
  (both platforms, light+dark; relaunch same day = same expression; next day = new; day 9 reshuffles
  without immediate repeat). Commit `feat(daily): stable-id deterministic selector + daily log + hero card`.

## S4 - Settings (ref: settings_v1.png)
Goal: preferences screen with a working theme switcher.
- **4.1** `SettingsCubit` + `SettingsState`.
- **4.2** View (reuse kit): PREFERENCES (Langue source, Rappel quotidien, Theme Automatique/Clair/Sombre);
  A PROPOS (A propos de l'app, Laisser un avis); version footer.
- **4.3** Theme change -> `ThemeCubit` + persist; seed `ThemeCubit` from settings on startup.
- **4.4** Language / reminder-time changes persist + refresh the daily card.
- **4.5** Widget + cubit tests. **CHECK**. Commit `feat(settings): preferences + theme switcher`.

## S5 - Notifications
Goal: the daily reminder loop carrying real content.
- **5.1** Use case `BuildReminderWindow` (14 days, real idiom bodies via SelectDailyExpression) + tests.
- **5.2** `NotificationService` (init, tz via flutter_timezone, channel, permission, zonedSchedule, cancelAll).
- **5.3** `NotificationScheduler` coordinator; schedule after onboarding + on settings change;
  reschedule on resume (WidgetsBindingObserver); graceful denial.
- **5.4** Coordinator tests (fake service asserts 14 zoned schedules with real idiom bodies).
- **CHECK** (device: notification shows real idiom; resume refreshes; <=64 pending). Commit `feat(notifications): daily reminder loop`.

## S6 - Polish + Release
- **6.1** Full l10n pass (no hardcoded strings; fr "tu" / es "tu").
- **6.2** Empty/error/loading states; transitions; accessibility (text scale, contrast).
- **6.3** Final gate: `validate_corpus.py` + `flutter analyze` + `flutter test` + manual smoke (light+dark, iOS+Android).
- **CHECK**. Commit + tag `v0.1.0-mvp`.

## Cross-cutting conventions
1. **Reusable components first** - shared widgets in `ui/core/widgets/`; screens compose them, never duplicate.
2. One conventional-commit per slice.
3. `test/support/` holds FakeClock, fake repos/bundle, shared fixtures.
4. Explicit state classes (loading/loaded/error) for every Cubit; immutable models with `==`/`copyWith`.
5. Layered separation: `ui -> domain <- data`; domain imports zero Flutter; DI via `MultiRepositoryProvider`.
6. Manual `fromJson` (pattern matching); no codegen/freezed.
7. Determinism/selector logic is always unit-tested regardless of build order.
8. Design = `design/v1/*` (visual truth); skill = scope/invariants; this plan = the rest.

## Testing gate (every slice)
`python3 assets/scripts/validate_corpus.py` - `flutter analyze` - `flutter test`.

## Resolved defaults
1. Day anchor = `2026-01-01` local.  2. Reminder window = 14 days.  3. Selection wraps (repeats every 8 days) - no anti-repeat in MVP.
4. `go_router` + redirect gate.  5. No freezed.  6. Reminder default 08:00.  7. Theme = light+dark+auto.
