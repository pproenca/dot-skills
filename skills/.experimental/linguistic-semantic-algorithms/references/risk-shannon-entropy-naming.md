---
title: Compute Shannon Entropy of Identifier Tokens to Flag Overloaded Names
impact: LOW-MEDIUM
impactDescription: eliminates overloaded-name confusion via per-token directory entropy
tags: risk, shannon-entropy, naming-quality, overloaded-names, zipf
---

## Compute Shannon Entropy of Identifier Tokens to Flag Overloaded Names

A well-defined identifier appears in a small, focused set of contexts. An "overloaded" name like `process`, `data`, `handler`, or `state` appears almost uniformly across the whole codebase — its Shannon entropy over the directory distribution is high (close to the max). High-entropy identifiers are warning signs: either the team is reusing the same name for different concepts (the worst kind of naming debt) or the name is so generic it conveys nothing. Compute per-identifier entropy across files/directories and surface the top-50 most-overloaded names; nearly all are renaming opportunities.

**Incorrect (rank identifiers by frequency — confuses common with overloaded):**

```python
import re, collections, pathlib

# Pure frequency. "user" appears 5000× because the system is about
# users — that's appropriate. "data" appears 4500× across totally
# unrelated contexts — that's overloading. Frequency can't tell them apart.
WORD = re.compile(r"[A-Za-z_][A-Za-z0-9_]{2,}")
counts = collections.Counter()
for p in pathlib.Path("src").rglob("*.py"):
    counts.update(WORD.findall(p.read_text(errors="ignore")))
for w, n in counts.most_common(20):
    print(f"  {n:>5}  {w}")
```

**Correct (Shannon entropy over per-directory distribution — overloaded names rank high):**

```python
import math, re, collections, pathlib

WORD = re.compile(r"[A-Za-z_][A-Za-z0-9_]{2,}")

# 1. Count occurrences per (token, directory)
per_dir: dict[str, collections.Counter] = collections.defaultdict(collections.Counter)
for p in pathlib.Path("src").rglob("*.py"):
    top_dir = p.relative_to("src").parts[0] if len(p.relative_to("src").parts) > 1 else "ROOT"
    for w in WORD.findall(p.read_text(errors="ignore")):
        per_dir[w][top_dir] += 1

# 2. Compute Shannon entropy of each token's directory distribution
def entropy(dist: collections.Counter) -> float:
    total = sum(dist.values())
    if total == 0: return 0.0
    return -sum((c / total) * math.log2(c / total) for c in dist.values() if c > 0)

n_dirs = len({d for cnt in per_dir.values() for d in cnt})
max_entropy = math.log2(n_dirs)

results = []
for tok, dist in per_dir.items():
    total = sum(dist.values())
    if total < 50:                                 # ignore rare tokens
        continue
    H = entropy(dist)
    normalized = H / max_entropy                    # 0 = lives in one dir, 1 = uniform
    results.append({"token": tok, "total": total, "entropy": H, "norm": normalized})

# 3. Sort by entropy × frequency — overloaded AND common
results.sort(key=lambda r: -r["norm"] * math.log(r["total"]))
print(f"{'norm-H':>7}  {'total':>6}  token")
for r in results[:20]:
    print(f"{r['norm']:>7.2f}  {r['total']:>6}  {r['token']}")
# 0.94    4521  data        <- spread across every dir; rename per context
# 0.91    3210  handler     <- same problem
# 0.89    2860  process     <- and again
# 0.32    5102  sitter      <- high count but low entropy: focused = good
```

**Interpret normalized entropy thresholds:**

| Norm-H | Meaning | Action |
|---|---|---|
| 0.0-0.3 | name is concentrated in one module — *appropriate* | leave it |
| 0.3-0.6 | spread across a few modules — *usually fine* | check by hand |
| 0.6-0.85 | spread broadly — *likely overloaded* | rename in some contexts |
| 0.85-1.0 | uniform across the whole codebase — *definitely overloaded* | rename per use |

**Don't rename naively — replace per context with a more specific term.** `data` in `billing/` becomes `invoice_payload`; `data` in `auth/` becomes `credential`. The point of identifying overloaded names is to fix them locally with names that mean something, not to globally substitute.

**Combine with `concept-tfidf-rare-terms`** — TF-IDF lifts domain-specific names; entropy demotes overloaded names. Used together they sharply differentiate the codebase's domain vocabulary from its naming-debt vocabulary.

**This rule is also a "is naming discipline slipping?" trend metric.** Track the median normalized entropy over time. Rising median = the team is increasingly reusing the same generic names across modules. Falling median = naming is becoming more specific. Either trend is informative for engineering-management retrospectives.

**Test against Zipf's law as a sanity check.** Identifier-token frequency in a well-named codebase roughly follows Zipf's law (the n-th most-common token appears ~1/n as often as the most-common). Codebases with severe naming debt show flatter distributions; that's an alternative aggregate signal of naming health.

**When NOT to apply:**
- Tiny repos (<20 files) — entropy is unstable; eyeball is fine
- Heavily-shared utility identifiers by design (`logger`, `db`, `app`) — these will always have high entropy; whitelist them

Reference: [Shannon, A Mathematical Theory of Communication (1948)](https://people.math.harvard.edu/~ctm/home/text/others/shannon/entropy/entropy.pdf), [Allamanis et al., A Convolutional Attention Network for Extreme Summarization (ICML 2016)](https://miltos.allamanis.com/publications/2016convattn/)
