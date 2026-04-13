---
title: Kill Features That Do Not Earn Their Maintenance Cost
impact: MEDIUM
impactDescription: removes 20-40% of features over the first year of portfolio maturity
tags: prove, deprecation, maintenance, kill
---

## Kill Features That Do Not Earn Their Maintenance Cost

Features accumulate cost long after they stop earning lift: storage, serving latency, drift monitoring, schema migration risk, cognitive load during debugging. Any feature whose ablation test shows a lift below the maintenance cost threshold — typically anything under a 0.5% statistically-significant improvement on the primary metric — should be killed, its registry entry archived, its storage freed, and its computation dag entries removed. This is unpopular (someone spent a quarter building it) but necessary: a 60-feature portfolio with 15 useful features is strictly worse than a 15-feature portfolio.

**Incorrect (keeps every feature ever shipped because nobody owns deletion):**

```python
# feature store has 140 features
# 40 were disabled two years ago but never deleted; their drift alarms still fire
# every debug session starts by asking "is this feature still used?"
```

**Correct (quarterly kill review based on attribution):**

```python
@dataclass
class FeatureAudit:
    name: str
    last_trained_in_model: datetime
    attributed_lift_pct: float  # from its ablation A/B
    monthly_maintenance_hours: float

def quarterly_kill_review(features: list[FeatureAudit]) -> list[str]:
    to_kill = []
    for f in features:
        age = datetime.now() - f.last_trained_in_model
        if age > timedelta(days=180) and f.attributed_lift_pct < 0.5:
            to_kill.append(f.name)
        if f.monthly_maintenance_hours > 2 and f.attributed_lift_pct < 0.5:
            to_kill.append(f.name)
    return to_kill

def archive_feature(name: str):
    feature_registry.archive(name)
    feature_store.stop_computing(name)
    feature_store.delete_monitoring(name)
    ann_index.rebuild_without(name)
```

Reference: [Google — Rules of Machine Learning, Rule #22: Clean up features you are no longer using](https://developers.google.com/machine-learning/guides/rules-of-ml)
