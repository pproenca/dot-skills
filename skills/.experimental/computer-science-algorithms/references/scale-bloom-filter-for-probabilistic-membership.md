---
title: Use A Bloom Filter For Cheap Probabilistic Membership At Scale
impact: MEDIUM-HIGH
impactDescription: 64x memory reduction vs hash set — 1 bit per element with ~1% false-positive rate
tags: scale, bloom-filter, probabilistic, sketch
---

## Use A Bloom Filter For Cheap Probabilistic Membership At Scale

A hash set storing 10⁹ entries needs ~64 GB of RAM (8-byte pointers + load factor). A Bloom filter holding the same set with a 1% false-positive rate needs ~1.2 GB — a 50x reduction — and answers "is x possibly in the set?" in O(k) where k is the number of hash functions (typically 7-10). The cost: **no false negatives, but ~1% false positives** (configurable, smaller filter = more FPs). It also cannot enumerate members or delete entries (use counting Bloom filter or cuckoo filter for deletion).

The killer use case: filter cheap-to-check elements before an expensive check. URL crawler "have we seen this URL?", database "could this row exist?" (avoid disk seek), CDN "have we cached this object?", spam filter, password-breach checks (HIBP). Every false positive triggers the expensive path; every true negative skips it.

**Incorrect (hash set on a billion-URL crawler — 64 GB heap, GC pressure):**

```python
def crawl(urls):
    seen: set[str] = set()
    for url in urls:
        if url in seen:        # exact, but at n = 10⁹ this is ~80-100 GB of memory
            continue
        seen.add(url)
        fetch(url)
```

**Correct (Bloom filter — ~1.2 GB for 10⁹ URLs at 1% FP rate):**

```python
import math
from bitarray import bitarray
import mmh3  # MurmurHash3 — non-cryptographic, fast

class BloomFilter:
    def __init__(self, n: int, fp_rate: float = 0.01):
        # m = -(n * ln p) / (ln 2)^2 bits; k = (m/n) * ln 2 hashes.
        self.m = max(8, int(-(n * math.log(fp_rate)) / (math.log(2) ** 2)))
        self.k = max(1, int((self.m / n) * math.log(2)))
        self.bits = bitarray(self.m)
        self.bits.setall(False)

    def add(self, key: str) -> None:
        for i in range(self.k):
            self.bits[mmh3.hash(key, seed=i, signed=False) % self.m] = True

    def __contains__(self, key: str) -> bool:
        # False ⇒ definitely not in set. True ⇒ likely in set (with fp_rate false-positive risk).
        return all(
            self.bits[mmh3.hash(key, seed=i, signed=False) % self.m]
            for i in range(self.k)
        )

def crawl(urls):
    seen = BloomFilter(n=10**9, fp_rate=0.01)
    for url in urls:
        if url in seen:        # ~1% of new URLs incorrectly skipped — acceptable for a crawler
            continue
        seen.add(url)
        fetch(url)
```

**When NOT to use:**

- The application cannot tolerate even one false positive (membership must be exact)
- You need to delete elements (use counting Bloom or cuckoo filter)
- You need to enumerate members (Bloom filter cannot reveal what's stored)
- The set is small enough that a hash set fits comfortably (n < ~10⁶)

**Production deployments:** Cassandra and HBase use Bloom filters to skip disk reads. Chrome's "Safe Browsing" used a Bloom filter for the local URL blocklist. Bitcoin SPV clients use Bloom filters to request relevant transactions without revealing which addresses they own.

Reference: [Bloom filter — Wikipedia](https://en.wikipedia.org/wiki/Bloom_filter)
