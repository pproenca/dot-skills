---
title: Validate Online-Offline Metric Correlation Before Trusting Offline Scores
impact: HIGH
impactDescription: prevents shipping rankers that improve NDCG but hurt conversion
tags: eval, online-offline, correlation, validation, calibration
---

## Validate Online-Offline Metric Correlation Before Trusting Offline Scores

Offline NDCG going up while online conversion goes down is a classic failure mode. Causes: judgment grades don't match what users actually want; annotators were a different population from real users; the judgment set is stale and misses current intents; or the metric is right but the experiment was confounded. The fix is to *validate* the offline metric against online outcomes periodically — for every shipped A/B test, log both the offline NDCG delta and the online conversion delta. Plot them. If the correlation across experiments is below ~0.5, the offline metric is broken and offline triage is doing more harm than good.

**Incorrect (trust offline NDCG without checking it predicts online behavior):**

```python
# "+0.04 NDCG@10 on the judgment set — ship it"
if offline_ndcg_delta > 0.02:
    ship_ranker(new_ranker)
```

A ranker can improve NDCG by surfacing items that the *judges* liked but real users don't book. Without validation, this is silent quality erosion.

**Correct (track online-offline pairs across experiments, check correlation):**

```python
# After every A/B test concludes, log the (offline, online) delta pair
experiments_log = [
    {"id": "ranker_v23", "offline_ndcg_delta": 0.012, "online_conv_delta": 0.008},
    {"id": "ranker_v24", "offline_ndcg_delta": 0.031, "online_conv_delta": 0.019},
    {"id": "ranker_v25", "offline_ndcg_delta": -0.004, "online_conv_delta": -0.006},
    {"id": "ranker_v26", "offline_ndcg_delta": 0.025, "online_conv_delta": -0.011},  # <- divergence
    # ... at least 10-20 experiments to compute meaningful correlation
]

import numpy as np
from scipy.stats import pearsonr

offline = np.array([e["offline_ndcg_delta"] for e in experiments_log])
online  = np.array([e["online_conv_delta"]  for e in experiments_log])
r, p = pearsonr(offline, online)

if r < 0.5:
    raise CalibrationError(
        f"Offline-online correlation only {r:.2f} (p={p:.3f}). "
        f"Judgment set may not reflect user intent — investigate before trusting "
        f"more offline scores."
    )

# Why 0.5? Below this threshold, the offline metric explains less than
# 25% (r²) of online metric variance, and Kohavi et al. ("Trustworthy
# Online Controlled Experiments", 2020) found that *directional agreement*
# (sign of effect) drops below ~80% — meaning roughly 1 in 5 offline
# "wins" reverse direction online. That's worse than triage; it's noise.
# At r > 0.7 (≥50% variance explained) offline triage is genuinely useful.
```

**Diagnose-and-fix when correlation is low:**

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| Offline up, online flat | Judgment set is too easy / saturated | Rebalance to include harder queries |
| Offline up, online down | Judges differ from real users | Re-annotate with users (or with user-proxy heuristics like booking signals) |
| Correlation noisy | Judgment set too small (<200 queries) | Expand the set |
| Correlation negative | Wrong metric for the use case | Switch from NDCG to MRR / per-segment metric / business metric |
| One experiment flips correlation | Outlier — check for confounded test | Exclude that experiment, re-run |

**Update the judgment set with online winners:** For each shipped A/B test where the new ranker won online, sample queries from the test and add their booked items to the judgment set with grade 4. This continuously aligns the judgment set with online outcomes — bootstrapped supervision.

**Where this rule belongs in the workflow:**

```text
Idea → Offline NDCG triage (eval-ndcg-primary-metric)
                  ↓
       Online-offline correlation check (this rule)
                  ↓
       Counterfactual eval (bias-counterfactual-eval)
                  ↓
       Interleaving (bias-interleaved-evaluation)
                  ↓
       A/B test (eval-ab-sample-size-mde)
                  ↓
       Ship + log (offline, online) delta pair
                  ↓
       Periodically: recompute correlation
```

**Why this matters more than any individual metric choice:** No metric is correct in isolation. A metric is only *useful* if it correlates with the business outcome you care about. Validation closes the loop — it tells you which offline metric to trust, and when to stop trusting it.

Reference: [Microsoft Research — Online Controlled Experiments at Scale (KDD 2013)](https://exp-platform.com/Documents/2013-02-OnlineControlledExperimentsAtLargeScale.pdf) · [Airbnb Engineering — Beyond A/B Testing](https://airbnb.tech/data/beyond-a-b-test-speeding-up-airbnb-search-ranking-experimentation-through-interleaving/)
