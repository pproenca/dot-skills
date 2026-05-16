---
title: Use The Stdlib Or KMP For Substring Search, Not Naive Matching
impact: MEDIUM
impactDescription: O(n·m) worst case to O(n+m) — orders of magnitude on adversarial input
tags: str, kmp, substring-search, pattern-matching
---

## Use The Stdlib Or KMP For Substring Search, Not Naive Matching

Naive `for i in range(n): if text[i:i+m] == pattern` is O(n·m) worst case — adversarial inputs like `"aaaaa..."` searching for `"aaaab"` trigger the worst case on every position. Stdlib `str.find` / `re.search` use Boyer-Moore-Horspool or similar with sub-linear average performance; for guaranteed linear worst case, write KMP (Knuth-Morris-Pratt) — O(n+m) for any input. The Z-function and the Rabin-Karp rolling hash are linear-expected alternatives that also handle multi-pattern or 2D variants.

For *most* code, `str.find` is the answer. Reach for KMP / Z when you need to *also* answer "where does the pattern match repeated in the text," or when you're solving a problem that doesn't reduce to a single find call.

**Incorrect (naive substring search — O(n·m)):**

```python
def find_naive(text: str, pat: str) -> int:
    # On text = "a"*n + "b", pattern = "a"*m + "b", every position scans m chars.
    n, m = len(text), len(pat)
    for i in range(n - m + 1):
        if text[i:i + m] == pat:
            return i
    return -1
```

**Correct (stdlib, sub-linear average):**

```python
def find(text: str, pat: str) -> int:
    return text.find(pat)
```

**Alternative (KMP, guaranteed linear worst case):**

```python
def kmp_search(text: str, pat: str) -> int:
    # Build the failure table: fail[i] = longest proper prefix of pat[..i] that is
    # also a suffix. This lets the search never look back in `text`.
    if not pat: return 0
    fail = [0] * len(pat)
    k = 0
    for i in range(1, len(pat)):
        while k > 0 and pat[k] != pat[i]:
            k = fail[k - 1]
        if pat[k] == pat[i]:
            k += 1
        fail[i] = k

    j = 0
    for i, c in enumerate(text):
        while j > 0 and pat[j] != c:
            j = fail[j - 1]
        if pat[j] == c:
            j += 1
            if j == len(pat):
                return i - j + 1
    return -1
```

**Use rolling hash (Rabin-Karp) when:** you need to search for many patterns of the same length simultaneously, or you're doing 2D matching on a grid.

**Use the Z-function when:** you want all match positions in one pass and prefer Z to KMP for ease of implementation in problems like "longest border" or "compress string by prefix."

Reference: [cp-algorithms — Prefix function (KMP)](https://cp-algorithms.com/string/prefix-function.html)
