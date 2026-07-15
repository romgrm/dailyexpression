# Architecture

A living, summary-level reference for how Daily Expression is structured. For the
build roadmap (slices, milestones, scope), see [plans/daily-expression-mvp.md](../plans/daily-expression-mvp.md).

## Principles
- **Layered, dependencies point inward:** `ui → domain ← data`. The domain layer
  is pure Dart and imports no Flutter.
- **Immutable domain models** with `==`/`copyWith`; no code generation.
- **One Cubit + explicit state per feature** (loading / loaded / error).
- **Reusable components first:** shared widgets live in `ui/core/widgets/`;
  screens compose them, never duplicate.
- **Data-driven from the corpus:** languages/pairs come from `corpus.json`, so
  content changes need no code change.
- **Test the logic, not static screens.**

## Layers

```
ui/       screens + cubits (Flutter)        depends on → domain, data
domain/   pure models & rules (no Flutter)  depends on → nothing
data/     repositories, loaders, storage    depends on → domain
```

- **domain** — the vocabulary of the app: value objects and rules. Framework-free
  and trivially testable.
- **data** — the only layer that knows about storage (`SharedPreferences`) and
  assets (`corpus.json`). Repositories transform raw sources into domain models
  so nothing upstream touches JSON or preference keys.
- **ui** — screens and their cubits. Cubits hold state and call repositories;
  views render domain models via the shared component kit.

## Directory map (`lib/`)

```
domain/
  models/     LanguagePair, LanguageInfo, CorpusConfig, AppSettings, AppThemeMode, …
data/
  services/   CorpusAssetLoader (loads/decodes corpus.json)
  repositories/ CorpusRepository (config → models), SettingsRepository (prefs ↔ AppSettings)
ui/
  core/
    theme/    AppColors, AppTypography, AppTheme, AppSpacing, ThemeCubit
    widgets/  Logo, PrimaryButton, SectionCard, Overline, PageDots (barrel: widgets.dart)
    router/   GoRouter config
  features/
    onboarding/ splash + first-run flow
l10n/         generated localizations (fr/es; en = template)
main.dart     composition root (bootstrap + providers)
```

## Key building blocks

### Domain models
- **AppSettings** — persisted user preferences: `nativeLanguage` (null until
  chosen), `reminderHour`/`reminderMinute` (plain ints), `themeMode`,
  `onboardingComplete`. The source of truth for the onboarding gate.
- **LanguagePair** — `{native, target}` with `glossKey` (e.g. `en_fr`).
- **LanguageInfo** — a language's code, native name, per-UI-language display
  names, and flag; `displayName(uiLang)` picks the right label.
- **CorpusConfig** — the corpus `config` section; `selectableNativeCodes` is
  derived from active pairs (adding a pair surfaces a language, no code change).

### Data
- **CorpusAssetLoader** — loads and decodes `assets/corpus/corpus.json`
  (injectable `AssetBundle` for tests).
- **CorpusRepository** — parses raw corpus JSON into domain models; caches the
  parsed config. Grows a concept-selection API for the daily card.
- **SettingsRepository** — reads/writes `AppSettings` to `SharedPreferences`.
  `read()` is synchronous so startup can resolve the route without an async gap.

### Design system
- **AppColors / AppTypography / AppTheme** — Figma light + dark tokens →
  Material 3 themes (Fraunces serif for display, system sans for body).
- **AppSpacing** — one generic 4px-grid scale for all padding/gap/radius/size;
  no raw dimensional values in widgets.
- **ThemeCubit** — drives `ThemeMode` (system / light / dark).

## Runtime flow

### Startup (composition root, `main.dart`)
1. Initialize bindings, load `SharedPreferences`.
2. Build `SettingsRepository` + `CorpusRepository`.
3. Synchronously read the persisted `AppSettings`.
4. Provide repositories; seed `ThemeCubit` and the app-wide settings state.

### Routing gate
The router chooses the initial location from `AppSettings.onboardingComplete`:
- onboarded → `/` (home)
- not onboarded → `/onboarding`

Because settings are read synchronously before the first frame, a returning user
never flashes the onboarding. A `refreshListenable` on the settings stream
re-evaluates the gate the moment onboarding completes.

### Onboarding
A stepped flow driven by a cubit: brief splash intro (auto-advances) → native
language pick (rows from `CorpusConfig`) → target confirm (English, locked) →
reminders pitch (time picker). On completion the choices are persisted and the
router navigates to home.

## Testing
- Unit-test logic: repositories (against the real corpus asset), selection
  determinism, cubit transitions.
- Keep a minimal app-boot smoke test; skip widget tests for static screens.
- Gate every change with `flutter analyze` + `flutter test` +
  `python3 assets/scripts/validate_corpus.py`.
