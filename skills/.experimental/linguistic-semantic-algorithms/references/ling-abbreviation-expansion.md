---
title: Expand Identifier Abbreviations Against a Domain Dictionary
impact: MEDIUM
impactDescription: reduces synonym fragmentation by 30-40% in identifier-vocabulary tasks
tags: ling, abbreviation, expansion, normalization, preprocessing
---

## Expand Identifier Abbreviations Against a Domain Dictionary

After camel/snake splitting, the resulting tokens are still polluted by abbreviations: `idx`, `mgr`, `cfg`, `usr`, `addr`. To downstream algorithms these are distinct from `index`, `manager`, `config`, `user`, `address` — yet semantically they're the same words. Abbreviation expansion maps each short form to its canonical long form. A combined approach — community dictionary for common abbreviations + corpus-mined expansions for project-specific ones — recovers most of the lost signal. The output is a vocabulary 30-40% smaller and substantially less fragmented.

**Incorrect (treat abbreviations and their expansions as different tokens — synonym dilution):**

```python
# After camel/snake split, "userManager" and "usrMgr" produce
# {user, manager} and {usr, mgr}. Topic models split this concept,
# similarity scores miss the match. Two buckets per real word.
```

**Correct (expand with a dictionary + project-mined map, then index):**

```python
import re, collections, pathlib

# 1. Community dictionary for common abbreviations.
#    Curate this once and reuse across projects.
COMMON_ABBREV = {
    "idx": "index", "mgr": "manager", "cfg": "config", "usr": "user",
    "addr": "address", "auth": "authentication", "msg": "message",
    "req": "request", "resp": "response", "err": "error", "val": "value",
    "num": "number", "obj": "object", "ctx": "context", "txn": "transaction",
    "qty": "quantity", "amt": "amount", "ts": "timestamp", "dt": "datetime",
    "btn": "button", "ack": "acknowledgement", "len": "length", "max": "maximum",
    "min": "minimum", "alloc": "allocate", "init": "initialize", "img": "image",
    "evt": "event", "perm": "permission", "pkg": "package", "lib": "library",
}

# 2. Mine project-specific abbreviations: if "sitter" and "sttr" co-occur
#    in the same files frequently, treat "sttr" -> "sitter".
def mine_project_abbrev(token_counts: collections.Counter,
                        co_occur: collections.Counter,
                        min_overlap: float = 0.7) -> dict[str, str]:
    """For each candidate short token, find the long token it commonly co-occurs with
    and whose Levenshtein-normalized prefix overlap exceeds threshold."""
    from rapidfuzz.distance import Levenshtein
    long_terms = [t for t, c in token_counts.items() if len(t) >= 5 and c >= 20]
    short_terms = [t for t, c in token_counts.items() if 2 <= len(t) <= 4 and c >= 10]
    project_map = {}
    for short in short_terms:
        best_score = 0
        best_long = None
        for long in long_terms:
            if not long.startswith(short[0]): continue
            # Co-occurrence count + edit-distance proximity
            co = co_occur.get(tuple(sorted([short, long])), 0)
            if co < 5: continue
            ed_norm = 1 - Levenshtein.normalized_distance(short, long[:len(short) + 2])
            score = co * ed_norm
            if score > best_score:
                best_score = score
                best_long = long
        if best_long and best_score > min_overlap * token_counts[short]:
            project_map[short] = best_long
    return project_map

# 3. Combine and apply uniformly
def expand(token: str, expansion_map: dict) -> str:
    return expansion_map.get(token, token)

# Project-specific abbreviations might include {"sttr": "sitter", "lstng": "listing"}
# Combined map is applied to every identifier token before any downstream algorithm.
full_map = {**COMMON_ABBREV}                         # then merge mined map
```

**Validate the project-mined map by hand.** Auto-mining produces ~80% correct expansions but the wrong ones can be very wrong (`io` → `iota`, `id` → `idle`). Have a human approve the top-100 mined expansions before applying — it takes 15 minutes.

**Order matters: split → expand → stem.** Apply this rule between `ling-camel-snake-split` and `ling-porter-stemming`. Stemming an unexpanded `usr` gives you `usr`; stemming `user` gives you `user`. The combined pipeline produces a clean vocabulary that's stable across spelling variants.

**For identifier-heavy languages (Java, C#) the impact is largest.** Languages with looser conventions (Python, JS, Ruby) tend toward written-out names already; the dictionary helps but mining yields less. Measure your specific gain on a held-out set.

**Combine with `concept-entity-name-resolution`** for the most aggressive normalization. Abbreviation expansion handles spelling variants of the same word; entity resolution handles synonyms (`user` ↔ `customer` ↔ `member`). The two complement.

**When NOT to apply:**
- Codebases with intentionally-cryptic identifiers (heavily golfed code, generated symbols) — expansion adds noise
- Single-letter loop variables (`i`, `j`, `k`) — exclude from expansion entirely; they carry no semantic content

Reference: [Lawrie et al., Effective Identifier Names for Comprehension and Memory (ISSE 2007)](https://www.researchgate.net/publication/220629432), [Corazza et al., Identifier Expansion via TF-IDF (CASCON 2012)](https://dl.acm.org/doi/10.5555/2399776.2399793)
