#!/usr/bin/env python3
"""Validate the Daily Expression corpus (schema v2).

Contract enforced (ERRORS -> exit 1):
  - unique concept ids; required fields present
  - category / level / register / variant codes must exist in config
  - every form has non-empty text + example
  - every gloss key is '{target}_{native}' over known languages,
    references an existing forms[target], and has literal + example_translation
  - AVAILABILITY v2: a concept is available for pair {native, target} iff
      forms[target] AND glosses[target_native] AND meaning[native] exist.
    forms[native] is OPTIONAL (UI then shows ui_strings.no_equivalent[native]).
  - every active pair has >= 1 available concept
  - ui_strings.no_equivalent[native] must exist for every native language
    of an active pair (it is needed as soon as one concept lacks the form)

WARNINGS (non-blocking):
  - concept available for zero active pairs (dead weight)
  - no-equivalent concept whose gloss has no note (the note is the product!)

Usage: python3 scripts/validate_corpus.py [path/to/corpus.json]
"""
import json
import sys

LEVELS = {"A1", "A2", "B1", "B2", "C1", "C2"}
REGISTERS = {"formal", "neutral", "informal", "vulgar"}
REQUIRED_CONCEPT_FIELDS = ["id", "category", "level", "register",
                           "meaning", "forms", "glosses", "tags"]


def validate(path):
    errors, warnings = [], []
    try:
        with open(path, encoding="utf-8") as f:
            corpus = json.load(f)
    except (OSError, json.JSONDecodeError) as e:
        return [f"cannot load corpus: {e}"], []

    cfg = corpus.get("config", {})
    languages = set(cfg.get("languages", {}))
    categories = set(cfg.get("categories", {}))
    variants = set(cfg.get("variants", {}))
    active_pairs = cfg.get("active_pairs", [])
    placeholders = cfg.get("ui_strings", {}).get("no_equivalent", {})
    concepts = corpus.get("concepts", [])

    # ---- per-concept structural checks ----------------------------------
    seen_ids = set()
    for c in concepts:
        cid = c.get("id", "<no id>")
        for field in REQUIRED_CONCEPT_FIELDS:
            if field not in c:
                errors.append(f"{cid}: missing field '{field}'")
        if cid in seen_ids:
            errors.append(f"duplicate concept id '{cid}'")
        seen_ids.add(cid)

        if c.get("category") not in categories:
            errors.append(f"{cid}: unknown category '{c.get('category')}'")
        if c.get("level") not in LEVELS:
            errors.append(f"{cid}: unknown level '{c.get('level')}'")
        if c.get("register") not in REGISTERS:
            errors.append(f"{cid}: unknown register '{c.get('register')}'")

        forms = c.get("forms", {})
        if not forms:
            errors.append(f"{cid}: no forms at all (needs at least one language)")
        for lang, form in forms.items():
            if lang not in languages:
                errors.append(f"{cid}: form in unknown language '{lang}'")
            if not form.get("text"):
                errors.append(f"{cid}: forms.{lang}.text is empty")
            if not form.get("example"):
                errors.append(f"{cid}: forms.{lang}.example is empty")
            v = form.get("variant")
            if v is not None and v not in variants:
                errors.append(f"{cid}: forms.{lang} has unknown variant '{v}'")

        for lang, meaning in c.get("meaning", {}).items():
            if lang not in languages:
                errors.append(f"{cid}: meaning in unknown language '{lang}'")
            if not meaning:
                errors.append(f"{cid}: meaning.{lang} is empty")

        for key, gloss in c.get("glosses", {}).items():
            parts = key.split("_")
            if len(parts) != 2 or not all(p in languages for p in parts):
                errors.append(f"{cid}: malformed gloss key '{key}'")
                continue
            target, native = parts
            if target not in forms:
                errors.append(f"{cid}: gloss '{key}' but no forms.{target} to gloss")
            if not gloss.get("literal"):
                errors.append(f"{cid}: gloss '{key}' missing literal")
            if not gloss.get("example_translation"):
                errors.append(f"{cid}: gloss '{key}' missing example_translation")

    # ---- availability v2 per active pair --------------------------------
    def available(c, nat, tgt):
        return (tgt in c.get("forms", {})
                and f"{tgt}_{nat}" in c.get("glosses", {})
                and nat in c.get("meaning", {}))

    used_anywhere = set()
    for pair in active_pairs:
        nat, tgt = pair.get("native"), pair.get("target")
        if nat not in languages or tgt not in languages:
            errors.append(f"active pair {pair}: unknown language")
            continue
        avail = [c for c in concepts if available(c, nat, tgt)]
        used_anywhere.update(c["id"] for c in avail)
        no_eq = [c for c in avail if nat not in c.get("forms", {})]
        if not avail:
            errors.append(f"pair {nat}->{tgt}: zero available concepts")
        if no_eq and nat not in placeholders:
            errors.append(
                f"pair {nat}->{tgt}: {len(no_eq)} concept(s) without a native form, "
                f"but ui_strings.no_equivalent['{nat}'] is missing")
        for c in no_eq:
            if not c["glosses"][f"{tgt}_{nat}"].get("note"):
                warnings.append(
                    f"{c['id']}: no {nat} equivalent and no note in gloss "
                    f"'{tgt}_{nat}' — the note should explain the gap")
        print(f"pair {nat}->{tgt}: {len(avail)} concepts available "
              f"({len(no_eq)} without native equivalent)")

    for c in concepts:
        if c.get("id") and c["id"] not in used_anywhere:
            warnings.append(f"{c['id']}: not available for any active pair (dead weight)")

    return errors, warnings


if __name__ == "__main__":
    path = sys.argv[1] if len(sys.argv) > 1 else "corpus.json"
    errors, warnings = validate(path)
    for e in errors:
        print(f"ERROR   {e}")
    for w in warnings:
        print(f"WARNING {w}")
    print(f"\n{'FAIL' if errors else 'OK'}: {len(errors)} error(s), {len(warnings)} warning(s)")
    sys.exit(1 if errors else 0)
