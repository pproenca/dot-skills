---
title: Filter Out Large Commits Before Mining Co-Change
impact: HIGH
impactDescription: a single 200-file commit inflates pair counts by 200·199/2 ≈ 20K; filter aggressively
tags: evol, large-commits, formatting-commits, cochange-noise, filter
---

## Filter Out Large Commits Before Mining Co-Change

Co-change mining (`evol-mine-cochange-with-lift-and-confidence`) assumes each commit represents an *intentional unit of change*. **Large commits violate this assumption catastrophically**. A single 200-file commit produces 200×199/2 ≈ 20,000 co-change pairs — more than ten thousand "instances of coupling" from one event. The damage is mostly to false positives: files that have nothing to do with each other but appeared together in a "rename project" or "apply prettier" commit get flagged as strongly coupled.

The right move is mechanical: **exclude commits above a size threshold** before any mining. Zimmermann's ROSE used 30 files as the cap; Hassan & Holt (ICSE 2004) used 100; Beck & Diehl (EMSE 2013) showed the choice between 20 and 100 changes MoJoFM by 3–8 points but excluding nothing changes it by 25+. The threshold matters less than *some* threshold. The same logic applies to commits flagged by message ("Merge", "Revert", "Format", "Lint", "Reformat", "Move", "Rename") — these are operational events, not feature coupling.

**Incorrect (mine co-change from raw history — every "apply prettier" commit corrupts pair counts):**

```python
from collections import Counter

pair_count = Counter()
file_count = Counter()
total = 0
for commit in iter_commits(repo):
    files = commit.modified_files
    total += 1
    for f in files:
        file_count[f] += 1
    for i, f1 in enumerate(sorted(files)):
        for f2 in sorted(files)[i+1:]:
            pair_count[(f1, f2)] += 1
# The "apply prettier" commit touched 1,200 files. Now every pair of those
# files has +1 co-change. The lift calculation can't distinguish "structural
# pair" from "happened to be reformatted together."
```

**Correct (Step 1 — define a filter that rejects commits by size and message):**

```python
import re

# Conventional message patterns for non-coupling events
NON_FEATURE_PATTERNS = [
    re.compile(r"^(merge|revert)\b", re.I),
    re.compile(r"\b(format|reformat|prettier|black|gofmt|eslint --fix|lint --fix)\b", re.I),
    re.compile(r"^(bump|update)\b.*\b(version|dependencies|deps)\b", re.I),
    re.compile(r"\b(rename|move)\b.*\b(file|directory|module)\b", re.I),
    re.compile(r"^(typo|fix typo|grammar|spelling)\b", re.I),
    re.compile(r"^(generate|regenerate|codegen)\b", re.I),
    re.compile(r"\bsquash\b", re.I),
]

def is_feature_commit(commit, max_files: int = 30) -> bool:
    """Conservative filter: small commit AND no operational message."""
    if len(commit.modified_files) > max_files:
        return False
    if any(p.search(commit.message) for p in NON_FEATURE_PATTERNS):
        return False
    if commit.is_merge:  # most VCS libs expose this
        return False
    return True
```

**Correct (Step 2 — mine co-change with the filter applied):**

```python
def mine_filtered_cochange(repo, max_files: int = 30):
    """Same algorithm as before, but each commit must pass is_feature_commit."""
    file_count = Counter()
    pair_count = Counter()
    total = 0
    rejected = {"size": 0, "merge": 0, "message": 0}
    for commit in iter_commits(repo):
        if len(commit.modified_files) > max_files:
            rejected["size"] += 1; continue
        if commit.is_merge:
            rejected["merge"] += 1; continue
        if any(p.search(commit.message) for p in NON_FEATURE_PATTERNS):
            rejected["message"] += 1; continue
        total += 1
        files = set(commit.modified_files)
        for f in files:
            file_count[f] += 1
        for i, f1 in enumerate(sorted(files)):
            for f2 in sorted(files)[i+1:]:
                pair_count[(f1, f2)] += 1
    print(f"Mined: {total} feature commits, rejected: {rejected}")
    return file_count, pair_count, total
```

**Correct (Step 3 — sensitivity sweep on the size threshold):**

```python
def sweep_size_threshold(repo, thresholds=(10, 20, 30, 50, 100, 200, None)):
    """How robust is your mining to the size threshold? If results change
    dramatically between thresholds, your filtering needs attention."""
    results = []
    for t in thresholds:
        cap = float("inf") if t is None else t
        fc = Counter(); pc = Counter(); total = 0
        for commit in iter_commits(repo):
            if len(commit.modified_files) > cap or commit.is_merge:
                continue
            total += 1
            for f in commit.modified_files:
                fc[f] += 1
            sorted_files = sorted(commit.modified_files)
            for i, a in enumerate(sorted_files):
                for b in sorted_files[i+1:]:
                    pc[(a, b)] += 1
        # Top pairs at each threshold
        top = sorted(pc.items(), key=lambda x: -x[1])[:5]
        results.append((t, total, top))
    return results
```

**The empirical-shape rule of thumb:**

| Commit size cap | What gets filtered | When to use |
|-----------------|---------------------|-------------|
| 5 | Almost nothing except big refactors | Only when commits are tiny (atomic-commit cultures) |
| 10 | Bulk renames, "fix typo across files" | Mainline / well-disciplined teams |
| 30 | + Larger refactors, big config updates | **Default** — Zimmermann et al. used 30 |
| 50 | + Substantial feature commits | When teams squash many changes per merge |
| 100 | Almost nothing | Lenient — useful for monorepo |
| ∞ | Nothing | Wrong; results dominated by operational commits |

**Empirical baseline:** Beck & Diehl (EMSE 2013, "Evaluating the Impact of Software Evolution on Software Clustering") measured the effect of large-commit filtering on MoJoFM agreement with expert decompositions across 6 open-source systems. Going from no filter to threshold 30: +25 to +40 MoJoFM points. Going from threshold 30 to threshold 10: +2 to +5 MoJoFM points. Most of the value is in removing the giant outliers, not in tight tuning.

**Don't over-filter:**

- Some legitimate features really do span many files (a new endpoint adding routes + models + tests + migrations). A threshold of 5 misses these.
- Operational commits are signal *of a different kind* — they tell you which files are tested/configured together. If you're studying *deployment* coupling, keep them.
- Generated-code commits should be filtered upstream (gitattributes `linguist-generated=true`), not by size — they sneak through at small sizes too.

**When NOT to filter:**

- You're studying refactoring or release engineering directly — those events ARE your data.
- Very small repositories (< 100 commits) — filtering leaves nothing. Lower the threshold or use structural mining only.
- Recently-imported repositories where everything is one "initial commit" of 5,000 files — co-change mining is useless until real history accumulates.

**Production:** GitLens "co-changed files" applies a 100-file cap by default; the Sourcegraph code-intel co-change index uses 50. JetBrains' "Files changed together" feature filters at 30. The convention is consistent across tools.

Reference: [Mining Version Histories to Guide Software Changes (Zimmermann et al., IEEE TSE 2005)](https://ieeexplore.ieee.org/document/1463238)
