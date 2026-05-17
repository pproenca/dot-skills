---
title: Tokenize Once Instead of Re-scanning a String per Pattern
impact: CRITICAL
impactDescription: O(p*L) to O(L+p) per document — across D docs, O(D*p*L) drops to O(D*(L+p))
tags: nested, string-search, tokenize, hidden-quadratic, aho-corasick
---

## Tokenize Once Instead of Re-scanning a String per Pattern

`pattern in text` (Python) or `text.includes(pattern)` (JS) scans the full text — O(L) where L is text length. Looping over p patterns and running this check produces O(p*L) per document, which is fine for tiny p but catastrophic when you scan thousands of keywords against thousands of documents. When patterns are whole tokens, the rewrite is trivial: tokenize the text once into a set, then each membership test is O(1). When patterns are arbitrary substrings, use a multi-pattern algorithm (Aho-Corasick) that scans the text once and matches all patterns in a single pass — O(L + p + matches).

Note: the tokenize approach changes matching semantics from substring to whole-token — `"cat" in "concatenate"` is true for `in`, false after tokenization. For substring matching across multiple patterns, use Aho-Corasick.

**Incorrect (re-scan per pattern — O(p*L)):**

```python
flagged = []
for keyword in BANNED_KEYWORDS:          # p ~ 5,000
    for doc in documents:                 # d ~ 10,000
        if keyword in doc.body:           # O(L)
            flagged.append((doc, keyword))
# 5,000 × 10,000 × avg_doc_length scans
```

**Correct (tokenize once when patterns are whole tokens — O(L + p)):**

```python
banned = set(BANNED_KEYWORDS)             # O(p)
flagged = []
for doc in documents:
    tokens = set(doc.body.split())        # O(L) once per doc
    for hit in tokens & banned:           # O(min(L, p))
        flagged.append((doc, hit))
```

**Alternative (Aho-Corasick for arbitrary substrings):**

```python
import ahocorasick
A = ahocorasick.Automaton()
for kw in BANNED_KEYWORDS:
    A.add_word(kw, kw)
A.make_automaton()

for doc in documents:
    for end_idx, kw in A.iter(doc.body):  # one scan finds all patterns
        flagged.append((doc, kw))
```

**When NOT to use this pattern:**
- When p is small (≲ 10) and L is large — the per-pattern scan is already cheap and a tokenize-then-set conversion may not pay for itself.
- When patterns include regex (anchors, alternation, lookaround) — switch to a single combined regex with alternation, or a regex-trie library.

Reference: [Aho–Corasick algorithm — NIST DADS](https://xlinux.nist.gov/dads/HTML/AhoCorasick.html)
