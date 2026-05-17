---
title: Apply Temporal Decay So Old Co-Change Counts Less Than Recent
impact: MEDIUM-HIGH
impactDescription: 5-8% MoJoFM improvement on 6-month half-life vs un-weighted (Beck-Diehl EMSE 2013)
tags: evol, temporal-decay, half-life, exponential, recency
---

## Apply Temporal Decay So Old Co-Change Counts Less Than Recent

The naive co-change miner treats every commit equally — a co-change in 2019 weighs as much as one in 2025. But codebases evolve: modules that were tightly coupled three years ago may have been decoupled by a refactor; new modules added six months ago should weigh more heavily in the *current* architecture picture. **Temporal decay** scales each co-change event by a decreasing function of its age, so the mined coupling reflects the *current* structure.

The canonical formulation (Hassan & Holt, ICSE 2004, "Predicting change propagation in software systems") uses **exponential decay** with a configurable half-life. A 6-month half-life means a co-change today contributes 1.0; six months ago contributes 0.5; one year ago contributes 0.25; two years ago contributes 0.0625. Configurable based on how fast the codebase evolves — fast-moving startup: 3 months; mature enterprise: 12+ months.

**Incorrect (count co-change without temporal weighting — old refactors haunt the current architecture):**

```python
from collections import Counter
from datetime import datetime

pair_count = Counter()
for commit in iter_commits(repo):  # default: oldest to newest
    files = sorted(commit.modified_files)
    for i, f1 in enumerate(files):
        for f2 in files[i+1:]:
            pair_count[(f1, f2)] += 1
# pair_count[("auth/old.py", "user/old.py")] = 50 — all from 2018 when they
# were tightly coupled. They've since been decoupled. The mining still says
# "these files are coupled."
```

**Correct (Step 1 — exponential decay weighting):**

```python
import math
from datetime import datetime
from collections import defaultdict

def cochange_with_decay(repo, half_life_days: float = 180, now: datetime = None):
    """
    Each commit's contribution is weighted by exp(-age / half_life * ln(2)).
    half_life_days = 180 means co-change from 6 months ago counts 0.5.
    half_life_days = 90 means 3 months ago counts 0.5 — faster forgetting.
    """
    now = now or datetime.now()
    pair_weight = defaultdict(float)
    file_weight = defaultdict(float)
    total_weight = 0.0

    decay_constant = math.log(2) / half_life_days

    for commit in iter_commits(repo):
        if not is_feature_commit(commit):  # see evol-filter-large-commits
            continue
        age_days = (now - commit.committed_datetime).days
        weight = math.exp(-decay_constant * age_days)
        total_weight += weight
        files = sorted(commit.modified_files)
        for f in files:
            file_weight[f] += weight
        for i, f1 in enumerate(files):
            for f2 in files[i+1:]:
                pair_weight[(f1, f2)] += weight

    return file_weight, pair_weight, total_weight
```

**Correct (Step 2 — compute decayed lift):**

```python
def decayed_lift(pair, file_weight, pair_weight, total_weight):
    """Same lift formula, but using weighted counts instead of raw counts."""
    a, b = pair
    w_a  = file_weight[a]    / total_weight
    w_b  = file_weight[b]    / total_weight
    w_ab = pair_weight[pair] / total_weight
    if w_a == 0 or w_b == 0:
        return 0
    return w_ab / (w_a * w_b)

# Use the decayed lift in clust-leiden-not-louvain etc.
strong_pairs = [
    (p, decayed_lift(p, file_weight, pair_weight, total_weight))
    for p in pair_weight
    if pair_weight[p] / total_weight >= 0.02
]
strong_pairs.sort(key=lambda x: -x[1])
```

**Correct (Step 3 — sensitivity sweep on the half-life parameter):**

```python
def sweep_half_life(repo, half_life_options=(30, 90, 180, 365, 730, None)):
    """Compare the top-coupled pairs under different half-lives.
    Pairs that stay coupled at all half-lives = robust coupling.
    Pairs that only appear at long half-lives = historical, possibly defunct.
    Pairs that only appear at short half-lives = recent / emerging."""
    rankings = {}
    for hl in half_life_options:
        label = "no decay" if hl is None else f"{hl}-day half-life"
        if hl is None:
            file_w, pair_w, total = cochange_no_decay(repo)
        else:
            file_w, pair_w, total = cochange_with_decay(repo, half_life_days=hl)
        ranked = sorted(
            [(p, decayed_lift(p, file_w, pair_w, total)) for p in pair_w],
            key=lambda x: -x[1],
        )[:50]
        rankings[label] = {p: rank for rank, (p, _) in enumerate(ranked)}
    return rankings
```

**Calibrating the half-life:**

| Half-life | Implied "memory" | Codebase type |
|-----------|------------------|---------------|
| 30 days | Captures last quarter sharply | Fast-moving startup, daily merges |
| 90 days | Last 6 months get most weight | Mid-size, weekly releases |
| 180 days | **Default** — balances recency and history | Most production codebases |
| 365 days | Slow forgetting, year-plus history | Mature stable codebase, long releases |
| 730+ days | Long history | Compliance/regulated, multi-year stability |

If you're unsure, pick 180 days and sweep around it; if conclusions don't change between 90 and 365, you're robust.

**Empirical baseline:** Hassan-Holt (ICSE 2004) showed exponential decay improves change-prediction recall by 15–20% over un-weighted co-change on Mozilla and NetBSD. Beck-Diehl (EMSE 2013) tested decay on architectural recovery: 6-month half-life produced decompositions ~5 MoJoFM points closer to expert ground truth than un-weighted on six open-source systems. The effect is modest but consistent.

**The asymmetric variant — only-recent or only-old:**

```python
# Sometimes you specifically want the *recent* picture (what's currently
# coupled?) — set a hard cutoff instead of decay:
def recent_only_cochange(repo, days: int = 180):
    cutoff = datetime.now() - timedelta(days=days)
    return cochange_no_decay(
        iter_commits(repo, since=cutoff)
    )

# Or the *historical* picture (what was coupled before the big refactor?):
def historical_cochange(repo, until_date):
    return cochange_no_decay(
        iter_commits(repo, until=until_date)
    )
```

**When NOT to use temporal decay:**

- Very short history (< 100 commits over 6 months) — every commit is "recent"; decay does nothing.
- You explicitly want the *all-time* picture for historical analysis.
- The codebase has long quiet periods followed by bursts (e.g. annual release cycles) — exponential decay penalises everything from the quiet period; consider weighting by commit activity instead of calendar time.

**Production:** GitLens applies a soft recency boost in its "co-changed" display. JetBrains' "Recently changed together" uses a 180-day window cutoff. Sourcegraph's co-change index supports both decay and hard windows.

Reference: [Predicting change propagation in software systems (Hassan & Holt, ICSE 2004)](https://dl.acm.org/doi/10.1109/ICSM.2004.1357810)
