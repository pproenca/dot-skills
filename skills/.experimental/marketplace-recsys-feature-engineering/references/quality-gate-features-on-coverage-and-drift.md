---
title: Gate Every Feature on Coverage and Drift Alarms
impact: MEDIUM-HIGH
impactDescription: catches coverage collapse 10-20x earlier than metric drift
tags: quality, drift, coverage, alarms, monitoring
---

## Gate Every Feature on Coverage and Drift Alarms

A feature that starts at 95% coverage can silently degrade to 62% over a quarter as an upstream API changes, a migration is deployed, or a wizard question is retired — and the model's online metrics drift a week later when the gap has widened enough to matter. Every feature in production needs two monitors: a coverage alarm (population with non-null values should stay within ±3% of the baseline) and a drift alarm (population-stability index against a frozen reference window should stay under a threshold). Both are cheap to compute and catch regressions before they land in booking rate.

**Incorrect (no monitoring; find out from customer complaints):**

```python
# feature is deployed with no coverage or drift alarms
feature_store.put_batch(feature_group="listing_vision", values=compute_vision_features())
# two weeks later, CLIP-ingester bug drops coverage from 96% to 61%, nobody notices
```

**Correct (coverage + PSI checks wired into the deploy pipeline):**

```python
def coverage(values: list[float | None]) -> float:
    return sum(1 for v in values if v is not None) / len(values)

def population_stability_index(ref: list[float], current: list[float], bins: int = 10) -> float:
    quantiles = np.quantile(ref, np.linspace(0, 1, bins + 1))
    ref_dist, _ = np.histogram(ref, bins=quantiles)
    cur_dist, _ = np.histogram(current, bins=quantiles)
    ref_p = ref_dist / ref_dist.sum()
    cur_p = cur_dist / cur_dist.sum()
    eps = 1e-6
    return float(np.sum((cur_p - ref_p) * np.log((cur_p + eps) / (ref_p + eps))))

def post_deploy_check(feature_name: str, reference_window: str, current_window: str) -> None:
    ref = feature_store.query_window(feature_name, reference_window)
    cur = feature_store.query_window(feature_name, current_window)

    cov = coverage(cur)
    assert cov >= 0.80, f"{feature_name} coverage {cov:.2f} below 0.80 floor"

    psi = population_stability_index([v for v in ref if v is not None], [v for v in cur if v is not None])
    if psi > 0.25:
        alert(f"{feature_name} PSI={psi:.2f}", severity="page")
    elif psi > 0.1:
        alert(f"{feature_name} PSI={psi:.2f}", severity="warn")
```

Reference: [Great Expectations — Why Data Quality is Key to Successful MLOps](https://greatexpectations.io/blog/ml-ops-data-quality/)
