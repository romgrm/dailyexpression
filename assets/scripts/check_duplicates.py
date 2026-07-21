#!/usr/bin/env python3
"""Detect duplicates in the Daily Expression corpus.

Three levels:
  1. HARD  - duplicate concept ids                     -> exit code 1
  2. HARD  - same normalized expression text used by
             two different concepts (per language)     -> exit code 1
  3. SOFT  - near-duplicate expression texts, and
             concepts whose meanings look too similar
             (possible conceptual duplicates)          -> warnings only

Usage: python3 scripts/check_duplicates.py [path/to/corpus.json]
"""
import json
import re
import sys
import unicodedata
from difflib import SequenceMatcher
from itertools import combinations

FUZZY_TEXT = 0.82      # near-duplicate threshold for expression texts
FUZZY_MEANING = 0.72   # similarity threshold to flag possible concept dups

# Elisions / stopwords stripped so that surface variants collapse together,
# e.g. "Avoir d'autres chats à fouetter" == "avoir d autres chats a fouetter"
STOP = {"a", "à", "de", "d", "l", "le", "la", "les", "un", "une", "des",
        "son", "sa", "ses", "en", "au", "aux", "du", "quelqu", "quelquun",
        "to", "the", "a", "an", "ones", "one", "someone", "somebody", "your"}


def normalize(text: str) -> str:
    """lowercase, strip accents/punctuation/stopwords -> canonical key."""
    text = unicodedata.normalize("NFD", text.lower())
    text = "".join(ch for ch in text if unicodedata.category(ch) != "Mn")
    text = re.sub(r"[^a-z0-9\s]", " ", text)
    tokens = [t for t in text.split() if t not in STOP]
    return " ".join(tokens)


def main(path: str) -> int:
    with open(path, encoding="utf-8") as f:
        corpus = json.load(f)
    concepts = corpus["concepts"]
    errors, warnings = [], []

    # -- 1. duplicate ids -----------------------------------------------
    seen = {}
    for i, c in enumerate(concepts):
        if c["id"] in seen:
            errors.append(f"duplicate id '{c['id']}' (positions {seen[c['id']]} and {i})")
        seen[c["id"]] = i

    # -- 2. exact text duplicates + 3a. fuzzy text ----------------------
    langs = set()
    for c in concepts:
        langs.update(c.get("forms", {}).keys())

    for lang in sorted(langs):
        entries = [(c["id"], c["forms"][lang]["text"])
                   for c in concepts if lang in c.get("forms", {})]
        by_norm = {}
        for cid, text in entries:
            key = normalize(text)
            if key in by_norm and by_norm[key][0] != cid:
                errors.append(
                    f"[{lang}] same expression in '{by_norm[key][0]}' and '{cid}': "
                    f"\"{by_norm[key][1]}\" / \"{text}\"")
            else:
                by_norm[key] = (cid, text)

        norm_list = [(cid, text, normalize(text)) for cid, text in entries]
        for (id1, t1, n1), (id2, t2, n2) in combinations(norm_list, 2):
            if n1 == n2:
                continue  # already reported as exact
            ratio = SequenceMatcher(None, n1, n2).ratio()
            if ratio >= FUZZY_TEXT:
                warnings.append(
                    f"[{lang}] near-duplicate texts ({ratio:.2f}): "
                    f"'{id1}' \"{t1}\"  ~  '{id2}' \"{t2}\"")

    # -- 3b. conceptual duplicates via meaning similarity ----------------
    for lang in ("fr", "en"):
        meanings = [(c["id"], c["meaning"][lang], normalize(c["meaning"][lang]))
                    for c in concepts if lang in c.get("meaning", {})]
        for (id1, m1, n1), (id2, m2, n2) in combinations(meanings, 2):
            ratio = SequenceMatcher(None, n1, n2).ratio()
            if ratio >= FUZZY_MEANING:
                warnings.append(
                    f"[meaning.{lang}] possible conceptual duplicate ({ratio:.2f}): "
                    f"'{id1}' \"{m1}\"  ~  '{id2}' \"{m2}\"")

    # -- report -----------------------------------------------------------
    for e in errors:
        print(f"ERROR   {e}")
    for w in warnings:
        print(f"WARNING {w}")
    print(f"\n{len(concepts)} concepts checked: "
          f"{len(errors)} error(s), {len(warnings)} warning(s) to review.")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1] if len(sys.argv) > 1 else "corpus.json"))
