---
title: Cache Expensive Pure-Function Results
impact: MEDIUM-HIGH
impactDescription: Eliminates repeated heavy computation — common 10-100× speedups
tags: compute, memoization, pure-function, cache, lru-cache
---

## Cache Expensive Pure-Function Results

Pure functions (deterministic output, no side effects) are safe to memoize — call them once per distinct argument set, cache the result. The pattern applies broadly: date parsing (`new Date(s)` against the same string), JSON parsing of constants, cryptographic digests, expensive normalizations (`unicode.normalize`, `path.resolve`), feature-flag lookups, ML embeddings. Inside hot loops these accumulate fast; one `datetime.strptime` is microseconds, but a million of them is a second of CPU you spend instead of doing useful work. Distinct from [`rec-share-memo-across-top-level-calls`](rec-share-memo-across-top-level-calls.md), which addresses recursion — this rule covers non-recursive computation that happens to be repeated.

**Incorrect (re-parse the same constants — O(n) repeat work):**

```python
def is_in_business_hours(ts):
    open_time = datetime.strptime("09:00", "%H:%M").time()    # parse every call
    close_time = datetime.strptime("17:00", "%H:%M").time()   # parse every call
    return open_time <= ts.time() <= close_time

for event in events:                # 1,000,000 events
    if is_in_business_hours(event.timestamp):
        ...
# 2,000,000 redundant strptime calls
```

**Correct (parse once, reference the cached value):**

```python
_BUSINESS_OPEN = datetime.strptime("09:00", "%H:%M").time()
_BUSINESS_CLOSE = datetime.strptime("17:00", "%H:%M").time()

def is_in_business_hours(ts):
    return _BUSINESS_OPEN <= ts.time() <= _BUSINESS_CLOSE
```

**Alternative (`lru_cache` for argument-keyed memoization):**

```python
from functools import lru_cache

@lru_cache(maxsize=1024)
def parse_locale(locale_str):
    # Expensive: ICU lookup, normalization, fallback chain
    return _load_locale_data(locale_str)

# Hot path: called with ~50 distinct locales over millions of requests
# → 50 expensive parses total, rest are O(1) cache hits
```

**When NOT to use this pattern:**
- When the function depends on hidden state (clock, RNG, mutable globals) — cached results lie. Either make the dependencies explicit arguments or skip the cache.
- When inputs are nearly always distinct — the cache fills with single-use entries and just wastes memory.

Reference: [`functools.lru_cache` — Python's standard memoization decorator](https://docs.python.org/3/library/functools.html#functools.lru_cache)
