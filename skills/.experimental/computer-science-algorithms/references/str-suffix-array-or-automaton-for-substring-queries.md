---
title: Use Suffix Arrays Or Suffix Automata For Heavy Substring Queries
impact: LOW-MEDIUM
impactDescription: O(n²) substring enumeration to O(n log n) construction + O(m) per query
tags: str, suffix-array, suffix-automaton, substring
---

## Use Suffix Arrays Or Suffix Automata For Heavy Substring Queries

When the workload is "many queries on substrings of a single fixed string" — count distinct substrings, longest repeated substring, longest common substring of multiple strings, k-th lexicographic substring — neither KMP nor a trie suffices. A **suffix array** (sorted array of all suffixes) is built in O(n log n) and answers many of these in O(m log n) per query. A **suffix automaton** is built in O(n) and gives O(m) per query for many tasks; it's the most compact representation of all distinct substrings of a string.

For one-off tasks, suffix automaton or suffix array; for problems that involve multiple strings, build a generalised suffix automaton or concatenate strings with a separator and build a suffix array.

**Incorrect (enumerate every substring, cubic blowup):**

```python
def count_distinct_substrings_naive(s: str) -> int:
    # O(n²) substrings, each up to O(n) to hash → O(n³). Infeasible for n ≥ 10⁴.
    return len({s[i:j] for i in range(len(s)) for j in range(i + 1, len(s) + 1)})
```

**Correct (suffix array via stdlib sort, good up to n ≈ 10⁴):**

```python
def build_suffix_array(s: str) -> list[int]:
    # Suffix array: indices of suffixes sorted lexicographically.
    # Python's sort key on slices is O(n) per comparison → O(n² log n).
    # Real implementations use DC3 or SA-IS for O(n).
    return sorted(range(len(s)), key=lambda i: s[i:])

def lcp_neighbours(s: str, sa: list[int]) -> list[int]:
    # LCP[i] = longest common prefix of sorted-suffix i and i+1.
    n = len(s)
    lcp = [0] * (n - 1)
    for i in range(n - 1):
        a, b = sa[i], sa[i + 1]
        k = 0
        while a + k < n and b + k < n and s[a + k] == s[b + k]:
            k += 1
        lcp[i] = k
    return lcp
```

**Count distinct substrings** (suffix array + LCP):

```python
def count_distinct_substrings(s: str) -> int:
    # Total substrings starting at suffix sa[i] is n - sa[i].
    # Subtract LCP with previous sorted suffix (they share that many starts).
    n = len(s)
    if n == 0:
        return 0
    sa = build_suffix_array(s)
    lcp = lcp_neighbours(s, sa)
    return sum(n - sa[i] - (lcp[i - 1] if i > 0 else 0) for i in range(n))
```

**When to reach for which:**

- **Single substring count / find** — KMP / `str.find`
- **Many same-length substring equality checks** — rolling hash
- **Longest repeated substring, count distinct substrings** — suffix array + LCP, or suffix automaton
- **All occurrences of many patterns in a text** — Aho-Corasick
- **Longest common substring of two strings** — generalised suffix automaton, or suffix array on `s1 + '#' + s2`

These are advanced — most code never needs them. But when the problem is shaped like "I keep doing substring work and it's quadratic," they're the right tool.

Reference: [cp-algorithms — Suffix array](https://cp-algorithms.com/string/suffix-array.html)
