---
title: Use MinHash plus LSH to Find Near-Duplicate Code at Repository Scale
impact: MEDIUM-HIGH
impactDescription: reduces O(n^2) pairwise Jaccard to sub-linear retrieval at 10k+ files
tags: clone, minhash, lsh, near-duplicate, sublinear-search
---

## Use MinHash plus LSH to Find Near-Duplicate Code at Repository Scale

Pairwise Jaccard similarity on N files is O(N²) — quadratic and unrunnable on real repos. MinHash (Broder, 1997) replaces each file's k-shingle set with a fixed-size signature whose collisions estimate Jaccard. Locality-Sensitive Hashing on those signatures then makes the *search* sub-linear — given a query signature, you find all candidates above a similarity threshold in roughly O(log N). On a million-file mono-repo, finding all near-duplicate pairs above 0.7 Jaccard takes minutes, not days. This is the workhorse for Type-1 and most Type-2 clone detection across an enterprise codebase.

**Incorrect (all-pairs Jaccard — quadratic, infeasible above ~10k files):**

```python
import pathlib, re, itertools

WORD = re.compile(r"\w+")

def shingles(text: str, k: int = 5) -> set[str]:
    toks = WORD.findall(text)
    return {" ".join(toks[i:i + k]) for i in range(len(toks) - k + 1)}

files = list(pathlib.Path("src").rglob("*.py"))
shing = {p: shingles(p.read_text(errors="ignore")) for p in files}

# O(n²) comparisons — for 10,000 files = 50 million pair comparisons
for a, b in itertools.combinations(files, 2):
    j = len(shing[a] & shing[b]) / max(1, len(shing[a] | shing[b]))
    if j > 0.7:
        print(f"  {j:.2f}  {a}  {b}")
```

**Correct (MinHash signatures + LSH bands — sub-linear retrieval):**

```python
import pathlib, re
from datasketch import MinHash, MinHashLSH

WORD = re.compile(r"\w+")

def shingles(text: str, k: int = 5) -> set[str]:
    toks = WORD.findall(text)
    return {" ".join(toks[i:i + k]) for i in range(len(toks) - k + 1)}

def minhash(sh: set[str], num_perm: int = 128) -> MinHash:
    m = MinHash(num_perm=num_perm)
    for s in sh:
        m.update(s.encode("utf8"))
    return m

# 1. Build signatures
sigs: dict[str, MinHash] = {}
for p in pathlib.Path("src").rglob("*.py"):
    sigs[str(p)] = minhash(shingles(p.read_text(errors="ignore")))

# 2. Index in LSH with threshold = 0.7 (banding chosen to maximize recall at that threshold)
lsh = MinHashLSH(threshold=0.7, num_perm=128)
for path, sig in sigs.items():
    lsh.insert(path, sig)

# 3. Query each file's neighbours — only candidates above threshold are returned
seen = set()
for path, sig in sigs.items():
    for nbr in lsh.query(sig):
        if nbr == path: continue
        key = tuple(sorted([path, nbr]))
        if key in seen: continue
        seen.add(key)
        est = sigs[path].jaccard(sigs[nbr])
        if est > 0.7:
            print(f"  ~{est:.2f}  {path}  ~~  {nbr}")
```

**Tune k (shingle size).** Too small (k=2) → noise; too large (k=10) → misses small clones. k=5 for source code, k=3 for short identifiers, k=9 for natural-language text. Always shingle on *tokens*, not characters — character shingles match by syntax, token shingles match by meaning.

**Use weighted MinHash for IDF-aware similarity.** Plain MinHash treats every shingle equally. Real interesting clones share *rare* shingles, not common ones. [datasketch.WeightedMinHashGenerator](http://ekzhu.com/datasketch/weightedminhash.html) takes IDF weights and dramatically improves precision when paired with `concept-tfidf-rare-terms`.

**LSH banding chooses the precision-recall tradeoff.** `MinHashLSH(threshold=0.7)` solves for (b, r) such that recall is high at Jaccard ≥ 0.7. Lower threshold → more bands → more candidates → slower query but higher recall. Sweep 0.5/0.7/0.9 and pick by clone-purpose.

**Combine with `clone-suffix-array-cpd`** for precise clone boundaries. MinHash tells you *which* files are similar; suffix-array CPD tells you *where in the file* the duplicated tokens are.

**When NOT to apply:**
- Code translated between languages — token sets differ; use embeddings (`sim-codebert-embeddings`) instead
- Tiny repos (<500 files) — MinHash overhead exceeds savings; plain Jaccard is fine

Reference: [Broder, On the resemblance and containment of documents (SEQUENCES 1997)](http://www.cs.princeton.edu/courses/archive/spring13/cos598C/broder97resemblance.pdf), [datasketch — MinHash + LSH for Python](https://ekzhu.com/datasketch/)
