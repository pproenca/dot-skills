---
title: Reserve a Random Exploration Slice for Unbiased Training
impact: HIGH
impactDescription: enables counterfactual evaluation
tags: loop, exploration, ips
---

## Reserve a Random Exploration Slice for Unbiased Training

Every deployed ranker biases its own training data — it only shows users what the current model thinks they want, so the model never learns what it would have missed. Reserving a small random-exploration slice (2-5% of requests) shows an unbiased slate with a known sampling probability, which is the only way to train subsequent models without inheriting the previous model's blind spots. The exploration slice is also the gold-standard slice for counterfactual policy evaluation.

**Incorrect (all traffic routed through the model, feedback loop closed on itself):**

```python
def homefeed(seeker: Seeker) -> list[Listing]:
    response = personalize_runtime.get_recommendations(
        campaignArn=CAMPAIGN_ARN,
        userId=seeker.id,
        numResults=24,
    )
    return hydrate_listings(response["itemList"])
```

**Correct (3% random exploration slice, logged with propensity):**

```python
def homefeed(seeker: Seeker, request_id: str) -> list[Listing]:
    if random.random() < 0.03:
        feasible = retrieve_feasible(seeker)
        shown = random.sample(feasible, k=min(24, len(feasible)))
        log_exposure(request_id, shown, policy="exploration", propensity=1 / len(feasible))
        return shown

    response = personalize_runtime.get_recommendations(
        campaignArn=CAMPAIGN_ARN,
        userId=seeker.id,
        numResults=24,
    )
    shown = hydrate_listings(response["itemList"])
    log_exposure(request_id, shown, policy="personalize", propensity=None)
    return shown
```

Reference: [BPR: Bayesian Personalized Ranking from Implicit Feedback (Rendle et al., UAI 2009)](https://arxiv.org/abs/1205.2618)
