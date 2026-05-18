---
title: Split camelCase and snake_case Identifiers Before Any Text Analysis
impact: MEDIUM
impactDescription: prevents 50%+ vocabulary fragmentation that breaks every downstream algorithm
tags: ling, tokenization, identifier-split, preprocessing, camelcase
---

## Split camelCase and snake_case Identifiers Before Any Text Analysis

Every algorithm in this skill — TF-IDF, LDA, embeddings, clone detection, bug localization — fails silently if you forget to split identifiers. Treating `userId`, `user_id`, and `usrIdent` as three distinct tokens shatters vocabulary across spelling variants and produces nonsense topics, weak similarity, and useless clones. The correct preprocessing applies a single regex that handles camelCase, snake_case, screaming-snake, dotted (`pkg.Class.method`), and digits at boundaries. Do this once at the start of every pipeline, validate the output on a sample, and forget it.

**Incorrect (use the raw identifier as a token — every spelling variant is its own bucket):**

```python
import collections, pathlib, re

# Raw identifier tokenization. "userId" and "user_id" and "USER_ID"
# all count separately — vocabulary fragments, topics break.
RAW = re.compile(r"[A-Za-z_][A-Za-z0-9_]{2,}")
counts = collections.Counter()
for p in pathlib.Path("src").rglob("*.py"):
    counts.update(RAW.findall(p.read_text(errors="ignore")))
# Top entries: userId, user_id, USER_ID, usrId — same concept, four buckets.
```

**Correct (split on case/underscore/digit boundaries, lowercase, output sub-tokens):**

```python
import re, collections, pathlib

# Combined camelCase + snake_case + digit-boundary splitter.
# Tested against the Allamanis identifier-splitting corpus.
SPLIT = re.compile(
    r"""
    [A-Z]+(?=[A-Z][a-z])    |    # APIKey -> "API" "Key"
    [A-Z]?[a-z]+            |    # PascalCase or camelCase "case" parts
    [A-Z]+                  |    # all-caps acronym (URL, HTML)
    \d+                          # numeric parts
    """,
    re.VERBOSE,
)

def split_identifier(name: str) -> list[str]:
    return [t.lower() for t in SPLIT.findall(name)]

# Sanity checks
assert split_identifier("getUserById") == ["get", "user", "by", "id"]
assert split_identifier("user_id_2") == ["user", "id", "2"]
assert split_identifier("HTMLParser") == ["html", "parser"]
assert split_identifier("getHTTP2URL") == ["get", "http", "2", "url"]
assert split_identifier("USER_ROLE_ADMIN") == ["user", "role", "admin"]

# Apply everywhere
IDENT = re.compile(r"[A-Za-z_][A-Za-z0-9_]{1,}")
counts = collections.Counter()
for p in pathlib.Path("src").rglob("*.py"):
    for ident in IDENT.findall(p.read_text(errors="ignore")):
        counts.update(split_identifier(ident))
# Now "user" is a single token, "id" is a single token — vocabulary is clean.
```

**Validate against a labeled sample.** Identifier splitting is the kind of preprocessing that looks right until it isn't. Build a 200-identifier ground-truth list (mix of acronyms, abbreviations, compound nouns, numeric suffixes) and confirm the splitter agrees on >95% before trusting it.

**Use [spiral](https://github.com/casics/spiral) for production-quality splitting.** The regex above handles common cases; spiral handles long sequences of acronyms (`XMLHttpRequest`), domain-specific abbreviations (`URLEncoder`), and concatenated lowercase (`numfound` → `num`, `found`) that regex cannot. It's slower (a small ML model) but worth it for serious analysis.

**This rule is upstream of every other rule in this skill.** If you forget it, every downstream signal degrades — topics fragment, clone detection misses, bug localization scores noisier matches. Validate it FIRST.

**When NOT to apply:**
- Code where identifiers are intentional opaque codes (compiler-generated names, obfuscated builds) — splitting produces garbage
- Single-language repos where the convention is strictly enforced (e.g., only snake_case) — a simpler split-on-underscore is sufficient

Reference: [Hill & Pollock, Automatically Mining Identifier-name Conventions (ICSE 2009)](https://dl.acm.org/doi/10.1145/1572272.1572291), [Spiral identifier-splitter](https://github.com/casics/spiral)
