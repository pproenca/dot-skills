---
title: Use a Trie for Prefix Search
impact: MEDIUM-HIGH
impactDescription: O(n*L) per query to O(L + k) — k = matches, L = query length
tags: ds, trie, prefix-tree, autocomplete, string-search
---

## Use a Trie for Prefix Search

Autocomplete and prefix-match queries against a list of strings are O(n*L) — for every one of n entries, check whether its first L characters match. A trie indexes by character, so a prefix query walks L levels down the tree and then enumerates only matching leaves — O(L + k) where k is the result count. For a dictionary of 100,000 words, prefix lookup is microseconds against a trie versus tens of milliseconds against a list. The same structure also accelerates "is X a prefix of any stored word?" — a single tree walk gives a yes/no answer.

**Incorrect (linear scan per query — O(n*L)):**

```python
def autocomplete(prefix, words):
    return [w for w in words if w.startswith(prefix)]
# 100,000 words × ~8-char prefix check = ~800K character comparisons per keystroke
```

**Correct (trie — O(L + k) per query):**

```python
# Tiny trie sketch — production: use `pygtrie`, `marisa-trie`, or build with classes
trie = {}
for word in words:
    node = trie
    for ch in word:
        node = node.setdefault(ch, {})
    node['$'] = word                    # mark word boundary

def autocomplete(prefix, trie):
    node = trie
    for ch in prefix:
        if ch not in node:
            return []
        node = node[ch]
    return _collect(node)               # DFS from current node — O(k)

def _collect(node):
    out = []
    if '$' in node: out.append(node['$'])
    for ch, child in node.items():
        if ch != '$': out.extend(_collect(child))
    return out
```

**Alternative (sorted array + binary search for static dictionaries):**

```python
import bisect
words.sort()
def autocomplete(prefix):
    lo = bisect.bisect_left(words, prefix)
    out = []
    while lo < len(words) and words[lo].startswith(prefix):
        out.append(words[lo]); lo += 1
    return out
# O(log n + k) per query — simpler than a trie, similar perf for static data
```

**When NOT to use this pattern:**
- When the dictionary is small (≲ 1,000 words) and queries are infrequent — the constant factors dominate.
- When you also need fuzzy matching — reach for BK-trees, Levenshtein automata, or n-gram indexes instead.

Reference: [Trie (NIST DADS) — prefix-tree data structure](https://xlinux.nist.gov/dads/HTML/trie.html)
