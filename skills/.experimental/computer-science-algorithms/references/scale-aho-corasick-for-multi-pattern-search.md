---
title: Use Aho-Corasick For Searching Many Patterns Against The Same Text
impact: MEDIUM-HIGH
impactDescription: O(P · |T|) to O(|T| + |P_total| + matches) — m patterns in one pass
tags: scale, aho-corasick, multi-pattern, automaton
---

## Use Aho-Corasick For Searching Many Patterns Against The Same Text

When you need to find all occurrences of **many** patterns in a text, calling KMP or `str.find` once per pattern is O(P × |T|) — for P = 10⁵ patterns and a 10⁹-byte text, that's 10¹⁴ operations. **Aho-Corasick (1975)** builds a trie of all patterns, adds *failure links* (Knuth-Morris-Pratt style suffix transitions), and walks the text **once** in O(|T| + total pattern length + number of matches). The same per-character cost regardless of how many patterns you're matching.

This is the foundation of: virus scanners (ClamAV scans for 10⁶+ signatures simultaneously), DNA motif search, content filters / profanity blocklists, malware string matching, dictionary-based tokenization, fast spam-keyword detection at email scale.

**Incorrect (per-pattern search — quadratic in pattern count):**

```python
def find_all_per_pattern(text: str, patterns: list[str]) -> list[tuple[int, str]]:
    # Each `text.find` is sub-linear average but O(|text| · |pattern|) worst.
    # Total: O(P · |text|). At P = 10⁵ this dominates every benchmark.
    matches = []
    for pat in patterns:
        start = 0
        while True:
            i = text.find(pat, start)
            if i == -1:
                break
            matches.append((i, pat))
            start = i + 1
    return matches
```

**Correct (Aho-Corasick — one pass, O(|text| + total |patterns| + |matches|)):**

```python
from collections import deque

class AhoCorasick:
    def __init__(self, patterns: list[str]):
        # Build the goto trie, then BFS to add failure and output links.
        self.children: list[dict[str, int]] = [{}]
        self.fail: list[int] = [0]
        self.output: list[list[str]] = [[]]
        for pat in patterns:
            node = 0
            for c in pat:
                if c not in self.children[node]:
                    self.children.append({})
                    self.fail.append(0)
                    self.output.append([])
                    self.children[node][c] = len(self.children) - 1
                node = self.children[node][c]
            self.output[node].append(pat)
        # BFS to set fail and accumulate outputs along fail chain.
        q = deque()
        for c, n in self.children[0].items():
            self.fail[n] = 0
            q.append(n)
        while q:
            node = q.popleft()
            for c, n in self.children[node].items():
                # Follow fail until a node has a child on `c`, or back to root.
                f = self.fail[node]
                while f and c not in self.children[f]:
                    f = self.fail[f]
                self.fail[n] = self.children[f].get(c, 0) if f or c in self.children[0] else 0
                # If the fail-target matches its own pattern, inherit its output.
                self.output[n].extend(self.output[self.fail[n]])
                q.append(n)

    def find_all(self, text: str):
        # Single pass over `text`. Each character does amortized O(1) work
        # (failure links amortize like KMP). Yields (end_index, pattern).
        node = 0
        for i, c in enumerate(text):
            while node and c not in self.children[node]:
                node = self.fail[node]
            node = self.children[node].get(c, 0)
            for pat in self.output[node]:
                yield (i - len(pat) + 1, pat)

# Usage
ac = AhoCorasick(["he", "she", "his", "hers"])
print(list(ac.find_all("ushers")))
# → [(1, 'she'), (2, 'he'), (2, 'hers')]
```

**Performance reality check:** a hand-rolled Python version is OK for thousands of patterns; for 10⁶+ patterns at production speed, use `pyahocorasick` (C extension, ~50x faster) or a SIMD-accelerated implementation (Hyperscan from Intel handles literal+regex multi-pattern at multi-GB/s).

**Alternatives:**

- **Commentz-Walter** combines Aho-Corasick with Boyer-Moore shifting — faster in practice for many long patterns, but harder to implement
- **Bit-parallel multi-pattern** (Wu-Manber, MultiBM) — best for small alphabets and large patterns
- **Suffix automaton of the text** — invert the problem: build automaton once on the text, query each pattern in O(|pattern|). Use when text is fixed and patterns change.

**When NOT to use:**

- Only one pattern — use `str.find` or KMP
- Patterns are regexes — use Hyperscan or RE2's set-of-regex API; Aho-Corasick is literal-string only
- Very few patterns (≤ ~5) — startup cost of building the automaton outweighs the win

**Production:** ClamAV virus signatures, Snort/Suricata IDS, fgrep (`grep -F -f patterns.txt`), Lucene's keyword tokenizer, spam keyword scanning at every major email provider.

Reference: [Aho-Corasick algorithm — Wikipedia](https://en.wikipedia.org/wiki/Aho%E2%80%93Corasick_algorithm)
