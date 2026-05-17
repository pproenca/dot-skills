---
title: Use Co-Change Prediction As A Ground-Truth Proxy When No Expert Labels Exist
impact: HIGH
impactDescription: eliminates need for expert ground-truth labelling; lift > 2 against random is the minimum bar
tags: valid, prediction, holdout, cross-validation, ground-truth-proxy
---

## Use Co-Change Prediction As A Ground-Truth Proxy When No Expert Labels Exist

The hardest problem in validating a clustering algorithm on real software is the **lack of ground truth**. Expert decompositions exist for benchmark systems (Mozilla, Linux, TOBEY) but **not for the codebase you actually want to analyse**. Hiring an expert costs months of architect-time. The standard workaround: **use future co-change events as a proxy for ground truth**. The argument: if your clustering captures "things that belong together," then files in the same cluster should be **more likely to co-change in the future** than random pairs. Split commits temporally (train on commits before time T, evaluate on commits after T); compute the lift of "same cluster ⇒ co-change" on held-out commits.

This is the **time-series cross-validation** of clustering. It's quantitative, reproducible, doesn't require labels, and works on any codebase with history. Beck-Diehl (EMSE 2013) and Bavota-Gemo-Lanza-Marcus (TSE 2014) both use it as the primary evaluation; the SAR research community is gradually adopting it as the "no ground truth available" default.

**Incorrect (only report intrinsic quality — modularity Q, silhouette — and call it done):**

```python
import networkx.algorithms.community as nxc

partition = leidenalg.find_partition(g, leidenalg.ModularityVertexPartition)
Q = nxc.modularity(G.to_undirected(), partition_as_sets(partition))
print(f"Modularity Q = {Q:.4f}")
# Q is intrinsic — high Q means "good partition under the modularity model".
# It does NOT mean "the clusters are meaningful". A random graph has Q ≈ 0;
# a real graph has Q > 0 even when its partition is wrong.
```

**Correct (Step 1 — split commits temporally):**

```python
from datetime import datetime, timedelta

def split_commits_temporally(repo, split_date: datetime):
    """Commits before split_date → training (for clustering input);
    commits after → held-out (for evaluation)."""
    train_commits = []
    test_commits = []
    for commit in iter_commits(repo):
        if commit.committed_datetime < split_date:
            train_commits.append(commit)
        else:
            test_commits.append(commit)
    return train_commits, test_commits

# Common split: 80/20 by time, or "everything older than 90 days" → train,
# "last 90 days" → test. The longer the test window, the more co-change
# pairs you have to evaluate against.
split_date = datetime.now() - timedelta(days=90)
train, test = split_commits_temporally(repo, split_date)
```

**Correct (Step 2 — score a clustering by held-out co-change prediction):**

```python
from collections import Counter

def evaluate_by_holdout_cochange(clusters: list[set], test_commits) -> dict:
    """
    For each held-out co-change pair (A, B):
      - "same_cluster" if cluster(A) == cluster(B)
      - "cross_cluster" otherwise
    Then: lift = P(same_cluster | co-change) / P(same_cluster)
          where P(same_cluster) is the chance baseline.

    Lift > 1 = clustering predicts co-change better than random.
    Lift > 2 = clustering predicts co-change much better than random.
    """
    file_to_cluster = {f: i for i, c in enumerate(clusters) for f in c}

    same = 0
    cross = 0
    unclustered_pairs = 0
    for commit in test_commits:
        if len(commit.modified_files) < 2 or len(commit.modified_files) > 30:
            continue
        files = list(commit.modified_files)
        for i, f1 in enumerate(files):
            for f2 in files[i+1:]:
                c1 = file_to_cluster.get(f1)
                c2 = file_to_cluster.get(f2)
                if c1 is None or c2 is None:
                    unclustered_pairs += 1
                    continue
                if c1 == c2:
                    same += 1
                else:
                    cross += 1

    # Baseline: P(same_cluster) under random pairing
    all_pairs = sum(len(c) * (len(c) - 1) // 2 for c in clusters)
    total_pairs = sum(1 for c in clusters for _ in c) * (sum(1 for c in clusters for _ in c) - 1) // 2
    p_same_baseline = all_pairs / max(total_pairs, 1)

    p_same_observed = same / max(same + cross, 1)
    lift = p_same_observed / max(p_same_baseline, 1e-9)

    return {
        "same_cluster_pairs": same,
        "cross_cluster_pairs": cross,
        "observed_p_same": p_same_observed,
        "baseline_p_same": p_same_baseline,
        "lift": lift,
    }
```

**Correct (Step 3 — compare multiple algorithms on the same held-out window):**

```python
def compare_algorithms_by_prediction(algorithms_outputs: dict[str, list[set]], test_commits):
    print(f"{'algorithm':>15}  {'same':>6}  {'cross':>6}  {'lift':>5}")
    for name, clusters in algorithms_outputs.items():
        r = evaluate_by_holdout_cochange(clusters, test_commits)
        print(f"{name:>15}  {r['same_cluster_pairs']:>6}  "
              f"{r['cross_cluster_pairs']:>6}  {r['lift']:>5.2f}")

# Typical software output:
#         leiden : 240 same / 1100 cross / lift 4.2
#        infomap : 268 same / 1072 cross / lift 4.6
#  sbm-hierarchical: 282 same /  990 cross / lift 4.9
#  random-baseline:  80 same / 1260 cross / lift 1.0  (sanity check)
# SBM has the best held-out predictive power on this codebase — *because*
# its inferred K matches the codebase's natural granularity.
```

**Why this is the right validation strategy:**

The two-line argument: (1) developers commit changes intentionally — when they co-change two files, they're declaring them coupled, (2) a clustering should encode coupling. Therefore: **a clustering that predicts future co-changes well captures real coupling**, not just spurious graph patterns. The metric is *quantitative*, *reproducible* (same temporal split → same number), and *cheap* (you have the data already).

Critical: **use a TEMPORAL split**, not a random one. Random splits leak — files coupled today have co-change records in both train and test, so random-split evaluation is too optimistic. Temporal split simulates "I clustered the codebase 90 days ago — how well did it predict what's coupled now?"

**Other ground-truth proxies (use multiple if possible):**

| Proxy | When useful |
|-------|-------------|
| **Held-out co-change** | Codebase has > 6 months of history. Default. |
| **Bug-fix prediction** | Bugs that touch multiple files reveal coupling. Use a bug tracker. |
| **Ownership boundaries** | Files owned (mostly committed to) by the same team are likely coupled. Use `git blame` aggregation. |
| **Pull-request bundling** | Files merged together in a PR are intentionally coupled. Use GitHub/GitLab API. |
| **Story/ticket linking** | Files linked to the same JIRA ticket. Requires tooling. |
| **Test-failure correlation** | Files whose changes break the same tests. Requires CI history. |

The best practice (Beck-Diehl 2013): **report multiple proxies** when no expert label exists. Convergent evidence — same algorithm wins on co-change AND bug-fix AND PR-bundling — is much stronger than a single proxy.

**When NOT to use co-change prediction:**

- Recent codebase (< 200 commits) — temporal split leaves nothing.
- Very stable codebase (long stretches of no commits) — test window has too few pairs.
- Codebase right after a refactor — co-change patterns reflect the OLD architecture; pre-refactor history isn't valid.

**Production:** Not yet packaged as a library. The above pattern (build clustering on train commits, evaluate on test commits) is implemented ad-hoc in most SAR research. The closest packaged tool is `pydriller` for commit walking + your own evaluation logic.

Reference: [Evaluating the impact of software evolution on software clustering (Beck & Diehl, Empirical Software Engineering 2013)](https://link.springer.com/article/10.1007/s10664-012-9220-1)
