---
title: Use SimHash 64-bit Fingerprints for Constant-Time Similarity Lookups
impact: MEDIUM-HIGH
impactDescription: reduces a file to a 64-bit fingerprint with O(1) Hamming distance
tags: clone, simhash, fingerprint, hamming-distance, charikar
---

## Use SimHash 64-bit Fingerprints for Constant-Time Similarity Lookups

SimHash (Charikar, 2002) compresses a document into a 64-bit fingerprint where similar documents have fingerprints differing in only a few bits — Hamming distance estimates dissimilarity. Compared to MinHash, SimHash uses less storage (one 64-bit integer per document vs. a 128-element array), and Hamming distance is faster to compute on modern CPUs (single XOR + popcount). It's the right choice when you have *many* documents and need a similarity index that fits in cache. Google originally used it for near-duplicate web page detection on the entire crawl.

**Incorrect (MD5 / SHA hash → equality test — catches only identical files, misses near-duplicates):**

```python
import hashlib, pathlib

# Cryptographic hashes flip every bit on a one-character change.
# Useless for similarity — even reformatting whitespace destroys equality.
fingerprints = {}
for p in pathlib.Path("src").rglob("*.py"):
    h = hashlib.sha256(p.read_text(errors="ignore").encode()).hexdigest()
    fingerprints.setdefault(h, []).append(str(p))

# Returns only EXACT duplicates — useless for near-duplicate search.
dupes = {h: ps for h, ps in fingerprints.items() if len(ps) > 1}
```

**Correct (SimHash — small Hamming distance ↔ small Jaccard, O(1) check per pair):**

```python
import re, pathlib
from simhash import Simhash, SimhashIndex   # pip install simhash

WORD = re.compile(r"\w+")

def features(text: str) -> list[str]:
    """Token features for SimHash. Stripping comments / strings first improves precision."""
    return WORD.findall(text)

# 1. Compute fingerprints for every file
records: list[tuple[str, Simhash]] = []
for p in pathlib.Path("src").rglob("*.py"):
    sig = Simhash(features(p.read_text(errors="ignore")), f=64)
    records.append((str(p), sig))

# 2. Build a fast index for near-neighbours (Hamming distance ≤ k bits)
index = SimhashIndex([(name, sig) for name, sig in records], k=8)   # 8/64 bit tolerance

# 3. Query each file's near-neighbours
seen = set()
for name, sig in records:
    for nbr in index.get_near_dups(sig):
        if nbr == name: continue
        key = tuple(sorted([name, nbr]))
        if key in seen: continue
        seen.add(key)
        dist = sig.distance(dict(records)[nbr])
        print(f"  hamming={dist:>2}/64  {name}  ~  {nbr}")
# hamming= 2/64  src/api/checkout_v1.py  ~  src/api/checkout_v2.py    <- near-identical
# hamming= 5/64  src/utils/email.py       ~  src/utils/sms.py          <- structural twin
```

**The k parameter** in `SimhashIndex(records, k=N)` is the Hamming-distance tolerance. Lower k → more strict matches but fewer false positives; higher k → looser matches. For Type-1 clones, k=3-5 (out of 64); for Type-2 (renamed identifiers, same structure), k=6-10.

**Strip strings and comments before computing the fingerprint.** Otherwise SimHash matches based on shared boilerplate text. Token-level features after dropping string-literal and comment tokens are far more discriminating.

**SimHash vs MinHash decision rubric:**
| Need | Use |
|---|---|
| Smallest fingerprint storage | SimHash (8 bytes) |
| Best similarity estimation accuracy | MinHash (128-element signature) |
| Sub-linear retrieval | Both (LSH for MinHash; SimhashIndex bands for SimHash) |
| Weighted-feature similarity | MinHash + WeightedMinHash |
| Memory-bound at huge scale | SimHash (fits 1B docs in 8 GB) |

**Combine with `mine-change-coupling`:** two near-duplicate files that *also* change together are textbook copy-paste-and-edit clones — the worst kind, because the duplication is reinforced every commit. Refactor those first.

**When NOT to apply:**
- Need to identify duplicated *regions* within files — SimHash is whole-file; use suffix-array CPD or AST clone tools instead
- Documents shorter than ~50 tokens — fingerprint is unstable; fall back to direct token comparison

Reference: [Charikar, Similarity Estimation Techniques from Rounding Algorithms (STOC 2002)](https://www.cs.princeton.edu/courses/archive/spr04/cos598B/bib/CharikarEstim.pdf), [Manku, Jain & Sarma, Detecting Near-Duplicates for Web Crawling (WWW 2007)](https://www.cs.princeton.edu/courses/archive/spr05/cos598E/bib/Princeton.pdf)
