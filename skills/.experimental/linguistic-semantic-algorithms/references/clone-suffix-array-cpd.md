---
title: Use Token-Level Suffix Arrays for Precise Clone Boundary Detection
impact: MEDIUM-HIGH
impactDescription: finds clone boundaries in O(n log n) with exact location and length
tags: clone, suffix-array, cpd, token-level, pmd
---

## Use Token-Level Suffix Arrays for Precise Clone Boundary Detection

MinHash and SimHash tell you which files are similar; they don't tell you *which lines*. For that you need a suffix array over the entire codebase's token stream. Build the array once, find longest common substrings between every pair, and the algorithm hands you exact clone regions — start file, start line, length in tokens. This is the algorithm behind [PMD CPD](https://pmd.github.io/pmd/pmd_userdocs_cpd.html) (Copy/Paste Detector), used at Google, Microsoft, and most large engineering orgs. It catches the exact "we wrote this same 40-line block in 7 places" situation that aggregate similarity scores blur.

**Incorrect (diff every-pair to find common blocks — O(n²·m), days on a real repo):**

```python
import difflib, pathlib, itertools

def common_blocks(a: str, b: str, min_lines: int = 10) -> list[tuple]:
    matcher = difflib.SequenceMatcher(None, a.splitlines(), b.splitlines(), autojunk=False)
    return [(m.a, m.b, m.size) for m in matcher.get_matching_blocks() if m.size >= min_lines]

files = list(pathlib.Path("src").rglob("*.py"))
# For 10k files: 50M pair-diffs, each O(m·n)
for a, b in itertools.combinations(files, 2):
    blocks = common_blocks(a.read_text(errors="ignore"), b.read_text(errors="ignore"))
    if blocks:
        print(f"{a} ~ {b}: {blocks}")
```

**Correct (token-stream suffix array — one pass over the concatenated corpus):**

```python
# Build the corpus token stream once; suffix array gives all
# longest-common-token-runs ≥ K in O(N log N).
import re, pathlib
import pydivsufsort                              # pip install pydivsufsort

WORD = re.compile(r"[A-Za-z_][A-Za-z0-9_]*|\S")
K = 80                                            # minimum clone length in tokens

# 1. Tokenize every file and remember which tokens came from where
tokens: list[str] = []
origin: list[tuple[str, int]] = []                # (file, token-index-within-file)
SENTINEL = "\x01"                                 # forbidden in source — separates files
for p in pathlib.Path("src").rglob("*.py"):
    src = p.read_text(errors="ignore")
    file_toks = WORD.findall(src)
    for i, t in enumerate(file_toks):
        tokens.append(t)
        origin.append((str(p), i))
    tokens.append(SENTINEL)
    origin.append(("__sep__", 0))

# 2. Map tokens to small integers, build the suffix array
vocab = {t: i for i, t in enumerate(sorted(set(tokens)))}
arr = bytes(vocab[t] % 255 + 1 for t in tokens)   # crude byte-encode for the demo
sa = pydivsufsort.divsufsort(arr)

# 3. Compute LCP (longest common prefix) array
lcp = pydivsufsort.kasai_lcp(arr, sa)

# 4. Adjacent suffixes with lcp >= K and from different files are clones
clones = []
for i in range(1, len(sa)):
    if lcp[i] >= K:
        a_file, a_idx = origin[sa[i - 1]]
        b_file, b_idx = origin[sa[i]]
        if a_file != "__sep__" and b_file != "__sep__" and a_file != b_file:
            clones.append((lcp[i], a_file, a_idx, b_file, b_idx))

clones.sort(reverse=True)
for ln, af, ai, bf, bi in clones[:10]:
    print(f"  {ln} toks  {af}:tok{ai}  ~  {bf}:tok{bi}")
# 312 toks  src/integrations/stripe/refund.py:tok40  ~  src/integrations/braintree/refund.py:tok42
# 218 toks  src/api/v1/orders.py:tok110  ~  src/api/v2/orders.py:tok98
```

**Use a real tool for production.** [PMD CPD](https://pmd.github.io/pmd/pmd_userdocs_cpd.html) (Java, but supports 25+ languages including Python, Go, JS, C/C++), [Simian](https://www.harukizaemon.com/simian/), and [jscpd](https://github.com/kucherenko/jscpd) for JS implement this algorithm with all the gotchas handled (tokenization, identifier normalization, ignore-blocks). The DIY version above is fine for one-off analyses; for CI, use the tools.

**Token normalization controls clone type detected.** Replace every identifier with `IDENT` before suffix-array construction → detects Type-2 clones (renamed identifiers). Replace literals with `LIT` too → Type-3 (constant changes). Most CPD tools toggle this per-mode.

**Combine with `clone-minhash-lsh` for a two-stage pipeline:** MinHash to find candidate file pairs (fast), suffix array within each pair (precise). Together they handle whole-repo Type-1/2 clone detection on >10M LoC in under an hour.

**When NOT to apply:**
- Cross-language clone detection — token streams are incompatible; use AST or embedding methods
- Generated code (protobuf, GraphQL schemas) — they all clone-match each other meaninglessly; exclude or ignore by file pattern

Reference: [Kamiya, Kusumoto & Inoue, CCFinder (TSE 2002)](https://ieeexplore.ieee.org/document/1019480), [PMD CPD docs](https://pmd.github.io/pmd/pmd_userdocs_cpd.html), [Manber & Myers, Suffix arrays: A new method for on-line string searches (1990)](https://dl.acm.org/doi/10.5555/320176.320218)
