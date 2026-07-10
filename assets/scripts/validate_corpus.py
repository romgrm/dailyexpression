#!/usr/bin/env python3
"""Validate the Daily Expression corpus.

Checks structural integrity, enum values, cross-references, and the
availability rule for every pair in config.active_pairs.
Run after ANY corpus edit, and in CI.

Usage: python3 scripts/validate_corpus.py [path/to/corpus.json]
Exit code 0 = valid, 1 = errors found.
"""
import json
import re
import sys

LEVELS = {"A1", "A2", "B1", "B2", "C1", "C2"}
REGISTERS = {"neutral", "informal", "formal"}
ID_RE = re.compile(r"^[a-z0-9]+(_[a-z0-9]+)*$")


def non_empty_str(value) -> bool:
    return isinstance(value, str) and value.strip() != ""


def validate(corpus: dict) -> list[str]:
    errors: list[str] = []
    config = corpus.get("config", {})
    languages = set(config.get("languages", {}).keys())
    categories = set(config.get("categories", {}).keys())
    active_pairs = config.get("active_pairs", [])

    if not languages:
        errors.append("config.languages is missing or empty")
    if not active_pairs:
        errors.append("config.active_pairs is missing or empty")

    for i, pair in enumerate(active_pairs):
        for key in ("native", "target"):
            code = pair.get(key)
            if code not in languages:
                errors.append(f"active_pairs[{i}].{key}='{code}' not in config.languages")
        if pair.get("native") == pair.get("target"):
            errors.append(f"active_pairs[{i}] has identical native and target")

    concepts = corpus.get("concepts", [])
    if not concepts:
        errors.append("concepts array is missing or empty")

    seen_ids: set[str] = set()
    for idx, c in enumerate(concepts):
        cid = c.get("id", f"<concepts[{idx}]>")
        where = f"concept '{cid}'"

        # --- id ---
        if not non_empty_str(c.get("id")) or not ID_RE.match(c["id"]):
            errors.append(f"{where}: id must be non-empty snake_case")
        elif c["id"] in seen_ids:
            errors.append(f"{where}: duplicate id")
        else:
            seen_ids.add(c["id"])

        # --- enums & references ---
        if c.get("category") not in categories:
            errors.append(f"{where}: category '{c.get('category')}' not in config.categories")
        if c.get("level") not in LEVELS:
            errors.append(f"{where}: level '{c.get('level')}' not in {sorted(LEVELS)}")
        if c.get("register") not in REGISTERS:
            errors.append(f"{where}: register '{c.get('register')}' not in {sorted(REGISTERS)}")

        tags = c.get("tags")
        if not isinstance(tags, list) or not all(non_empty_str(t) for t in tags):
            errors.append(f"{where}: tags must be a list of non-empty strings")

        # --- meaning ---
        meaning = c.get("meaning", {})
        if not isinstance(meaning, dict) or not meaning:
            errors.append(f"{where}: meaning must be a non-empty object")
            meaning = {}
        for lang, text in meaning.items():
            if lang not in languages:
                errors.append(f"{where}: meaning has unknown language '{lang}'")
            if not non_empty_str(text):
                errors.append(f"{where}: meaning.{lang} is empty")

        # --- forms ---
        forms = c.get("forms", {})
        if not isinstance(forms, dict) or not forms:
            errors.append(f"{where}: forms must be a non-empty object")
            forms = {}
        for lang, form in forms.items():
            if lang not in languages:
                errors.append(f"{where}: forms has unknown language '{lang}'")
            if not isinstance(form, dict) or not non_empty_str(form.get("text")):
                errors.append(f"{where}: forms.{lang}.text is missing/empty")
            elif not non_empty_str(form.get("example")):
                errors.append(f"{where}: forms.{lang}.example is missing/empty")

        # --- glosses ---
        glosses = c.get("glosses", {})
        if not isinstance(glosses, dict):
            errors.append(f"{where}: glosses must be an object")
            glosses = {}
        for key, gloss in glosses.items():
            parts = key.split("_")
            if len(parts) != 2 or any(p not in languages for p in parts):
                errors.append(
                    f"{where}: gloss key '{key}' is not '{{target}}_{{native}}' with known languages"
                )
            if not isinstance(gloss, dict):
                errors.append(f"{where}: gloss '{key}' must be an object")
                continue
            if not non_empty_str(gloss.get("literal")):
                errors.append(f"{where}: gloss '{key}'.literal is missing/empty")
            if not non_empty_str(gloss.get("example_translation")):
                errors.append(f"{where}: gloss '{key}'.example_translation is missing/empty")
            if "note" not in gloss or (gloss["note"] is not None and not non_empty_str(gloss["note"])):
                errors.append(f"{where}: gloss '{key}'.note must be null or a non-empty string")

        # --- availability rule for every active pair ---
        for pair in active_pairs:
            native, target = pair.get("native"), pair.get("target")
            gloss_key = f"{target}_{native}"
            missing = []
            if native not in forms:
                missing.append(f"forms.{native}")
            if target not in forms:
                missing.append(f"forms.{target}")
            if gloss_key not in glosses:
                missing.append(f"glosses.{gloss_key}")
            if native not in meaning:
                missing.append(f"meaning.{native}")
            if missing:
                errors.append(
                    f"{where}: unusable for pair {native}->{target}, missing: {', '.join(missing)}"
                )

    return errors


def main() -> int:
    path = sys.argv[1] if len(sys.argv) > 1 else "assets/corpus/corpus.json"
    try:
        with open(path, encoding="utf-8") as f:
            corpus = json.load(f)
    except (OSError, json.JSONDecodeError) as e:
        print(f"FATAL: cannot read/parse {path}: {e}")
        return 1

    errors = validate(corpus)
    if errors:
        print(f"INVALID — {len(errors)} error(s):")
        for e in errors:
            print(f"  - {e}")
        return 1

    concepts = corpus.get("concepts", [])
    pairs = corpus.get("config", {}).get("active_pairs", [])
    print(f"OK — {len(concepts)} concepts valid for {len(pairs)} active pair(s).")
    return 0


if __name__ == "__main__":
    sys.exit(main())