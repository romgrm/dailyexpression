---
name: daily-expression-context
description: Complete product and engineering context for Daily Expression, a Flutter app delivering one authentic idiomatic expression per day. ALWAYS consult this skill before working on any part of this project — features, architecture decisions, UI, data handling, notifications, tests, or corpus content — to stay aligned with the product vision, MVP scope, and non-negotiable constraints. Implementation details are YOUR responsibility; this skill defines intent and boundaries.
---

# Daily Expression — Product & Engineering Context

## What this app is

A daily micro-learning app for language learners. Every day, the user receives
ONE authentic expression in their target language (e.g. "It's raining cats and
dogs"), presented with:
- its literal word-for-word image translated into their native language
  ("Il pleut des chats et des chiens") — this imagery gap is the product's charm,
- the natural equivalent idiom in their native language ("Il pleut des cordes"),
- a usage example in context, with its translation.

The pedagogical bet: one memorable expression a day beats long lessons.
The emotional hook: the surprise of literal images and the differences between
languages. Tone: warm, calm, editorial — the opposite of noisy gamified apps.

Current active pairs: French→English and Spanish→English. The architecture must
make adding a pair a pure data change (it's one line in the corpus config).

## The corpus (single source of truth for content)

`assets/corpus/corpus.json`, bundled, read-only at runtime. Its `_schema` key is
self-documenting — READ IT before modeling anything. Key facts:
- Pivot structure: each concept carries its forms in every language, no language
  privileged. A concept is usable for a pair {native, target} only if it has
  forms for both languages AND the matching gloss (the "availability rule",
  documented in the schema).
- Some concepts are flagged non-equivalent (gloss note + tag): the native
  language has no image-based idiom. The UI must surface this honestly — it's a
  differentiator. Never invent a fake idiom to fill the gap.
- Content is never hardcoded in Dart. Corpus edits are validated by
  `python3 scripts/validate_corpus.py` — run it after any corpus change.
- The order of the concepts array is the editorial broadcast order: treat the
  corpus as append-only.

## MVP scope (hard boundary)

IN: onboarding (native language pick, target confirmation, reminders pitch),
the daily card, a daily local notification reminder, a simple streak, minimal
settings (language, reminder time, about).

OUT — do not build, even partially: monetization/paywall, audio pronunciation,
home-screen widgets, favorites, past-expressions archive, spaced repetition,
backend, analytics SDKs, accounts. If a task drifts out of scope, stop and flag it.

The app is fully offline. No network calls in the MVP.

## Non-negotiable product invariants

1. **Determinism of the day.** The expression shown for a given (pair, local
   calendar day) must be computable purely locally and identically from anywhere
   in the app — including notifications scheduled days in advance. Design for
   this from the start; day boundaries follow the device's local midnight.
2. **Real content in reminders.** The daily notification carries the actual
   expression of that day (that's the retention loop). Generic "come back!"
   notifications are forbidden. Respect iOS's pending-notification limits with
   a rolling scheduling window refreshed on app resume.
3. **Streak integrity.** Opening the daily card on consecutive local days
   increments the streak; missing a day resets it. Keep semantics simple and
   unit-tested; no freeze/repair mechanics in MVP.
4. **Localization discipline.** UI language = the user's native language (fr/es),
   via Flutter gen-l10n — zero hardcoded user-facing strings. French uses "tu",
   Spanish informal "tú". Corpus content renders as-is (it's already localized).
   Machine-facing strings (ids, logs, comments) are English.

## Engineering principles (you own the implementation)

- **Clean architecture**, pragmatically applied: clear separation between
  domain (models, selection logic, streak rules — pure Dart, framework-free),
  data (corpus loading, local persistence), and presentation. Keep it
  proportionate to an MVP — no ceremony for ceremony's sake.
- Dependencies flow inward; the domain layer imports nothing from Flutter.
- Time is injected, never grabbed ad hoc — daily rollover and streaks must be
  testable with fake clocks.
- State management: Riverpod. Persistence: shared_preferences is enough for MVP.
- No code generation packages unless they clearly pay for themselves.
- Testing is not optional for the domain: corpus decoding against the real
  asset, the availability rule, selection determinism (including midnight
  rollover and wrap-around), streak transitions, notification scheduling window.
- Prefer boring, readable Dart over cleverness. Small widgets, small files.

## Design direction (from approved mockups)

Warm editorial stationery, premium and calm:
- Palette: cream background #F5F1E9, off-white surfaces #FEFDFA, deep teal
  primary #2E6A5D with light tint #E7F0EC, warm near-black ink #26231C, muted
  #8B8577, sand accent #F5EFE2, gold CEFR badge #F7ECC8/#8A6D1B, streak flame
  #E2572B.
- Typography: a serif display face (Fraunces via google_fonts) for the
  expressions and titles — the serif voice IS the brand. System sans for body.
- Shapes: generous radii (cards ~20, pill buttons), soft shadows, one filled
  teal CTA per screen, never pure-white full screens.
- The daily card is the hero screen; its content order follows the corpus
  schema's daily_card_render. Non-equivalence notes get a discreet, honest
  callout.
- No gamification noise beyond the streak flame. No confetti.

## Working agreement

- Before coding, briefly state your plan and any structural decision you're
  making; then implement. Flag trade-offs instead of silently choosing.
- Run the corpus validator and the test suite before considering a task done.
- When mockups, this skill, and code conflict: this skill wins on scope and
  invariants, mockups win on visual details, and you decide the rest.