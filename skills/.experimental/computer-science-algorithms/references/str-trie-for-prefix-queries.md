---
title: Use A Trie For Prefix Queries Over Many Strings
impact: MEDIUM
impactDescription: O(n·m) per query to O(m) — autocompleter / spellchecker workloads
tags: str, trie, prefix, autocomplete
---

## Use A Trie For Prefix Queries Over Many Strings

When the workload is "given a dictionary of n strings and many incoming queries, does any string start with this prefix / which strings start with this prefix?", a hash-set of full strings doesn't help — it can only answer exact matches. A **trie** (prefix tree) stores all n words in space O(total characters) and answers "does any word have prefix p?" in O(|p|) regardless of n. For autocomplete-style use cases this is decisive: with n = 10⁶ words and average query length 10, naive scan is 10⁷ ops per query; trie is 10 ops.

For *only* "is this exact string in the dictionary?", a `set` is better — O(|p|) on average, smaller constant factor.

**Incorrect (linear scan for prefix match — O(n·m) per query):**

```python
def words_with_prefix(words: list[str], pref: str) -> list[str]:
    # n words × O(|pref|) per check = O(n·|pref|). Per-query.
    return [w for w in words if w.startswith(pref)]
```

**Correct (trie — O(|pref|) per "has prefix" query, plus subtree walk for enumeration):**

```python
class TrieNode:
    __slots__ = ("children", "is_word")
    def __init__(self):
        self.children: dict[str, "TrieNode"] = {}
        self.is_word = False

class Trie:
    def __init__(self):
        self.root = TrieNode()

    def insert(self, word: str) -> None:
        node = self.root
        for c in word:
            if c not in node.children:
                node.children[c] = TrieNode()
            node = node.children[c]
        node.is_word = True

    def has_prefix(self, pref: str) -> bool:
        node = self.root
        for c in pref:
            if c not in node.children:
                return False
            node = node.children[c]
        return True

    def words_with_prefix(self, pref: str) -> list[str]:
        node = self.root
        for c in pref:
            if c not in node.children:
                return []
            node = node.children[c]
        # DFS from this subtree — proportional to output size + descendant count.
        out: list[str] = []
        def walk(n: TrieNode, path: list[str]) -> None:
            if n.is_word: out.append("".join(path))
            for ch, child in n.children.items():
                path.append(ch); walk(child, path); path.pop()
        walk(node, list(pref))
        return out
```

**When the alphabet is small and fixed (e.g. ASCII 26), use arrays instead of dicts** for children — ~3x faster and smaller memory per node.

**Variants for related problems:**

- **Suffix trie** of one string — answer any substring query in O(|q|); but uses O(n²) space for naive construction. Use **suffix array** or **suffix automaton** instead in practice.
- **Aho-Corasick** — multi-pattern KMP on a trie. Finds all occurrences of *all* dictionary words in a text in O(text + dict + matches).

Reference: [Competitive Programmer's Handbook §26 — String algorithms (Trie)](https://cses.fi/book/book.pdf)
