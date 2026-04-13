---
title: Kill Features a Popularity Baseline Already Captures
impact: CRITICAL
impactDescription: prevents redundant features inflating the portfolio
tags: firstp, baseline, popularity, redundancy
---

## Kill Features a Popularity Baseline Already Captures

If your ship-criterion is "beat a top-N-by-completed-bookings popularity baseline", any feature whose signal is already dominated by completed-booking count will not move the needle — it correlates with what the baseline already ranks on. Before investing in a candidate feature, compute its correlation with booking count over a recent window. Features with Pearson ρ > 0.7 against booking count are almost certainly subsumed; features with ρ < 0.3 are the ones worth building. Kill the rest before they get into the store.

**Incorrect (builds "review_count" as a feature without noticing it is colinear with the baseline):**

```python
feature_registry.register(
    name="listing_review_count",
    hypothesis="More reviews predict higher booking probability",
    primary_metric="booking_rate",
)
# correlation of review_count with completed_booking_count = 0.87
# the popularity baseline already ranks listings by booking count, so this feature
# adds negligible lift on top of baseline and bloats the store.
```

**Correct (correlation screen before registration):**

```python
def screen_against_baseline(
    candidate_name: str, candidate_values: dict[str, float], booking_counts: dict[str, int]
) -> str:
    ids = list(candidate_values.keys() & booking_counts.keys())
    corr = pearsonr(
        [candidate_values[i] for i in ids],
        [booking_counts[i] for i in ids],
    ).statistic
    if abs(corr) > 0.7:
        return f"REJECT: {candidate_name} colinear with baseline (ρ={corr:.2f})"
    if abs(corr) < 0.3:
        return f"ACCEPT: {candidate_name} orthogonal to baseline (ρ={corr:.2f})"
    return f"INVESTIGATE: {candidate_name} partial overlap (ρ={corr:.2f})"

# registration is gated on this screen; reviewer comments required if correlation > 0.5.
```

Reference: [Google — Rules of Machine Learning, Rule #1 and Rule #20](https://developers.google.com/machine-learning/guides/rules-of-ml)
