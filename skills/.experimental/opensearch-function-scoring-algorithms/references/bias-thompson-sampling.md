---
title: Explore Ranking Alternatives with Thompson Sampling
impact: HIGH
impactDescription: 95% of greedy gain with proven exploration
tags: bias, thompson-sampling, exploration, bandit, beta
---

## Explore Ranking Alternatives with Thompson Sampling

A purely greedy ranker (always show the highest-predicted-relevance result) never learns whether *other* items might convert better — it just exploits its current estimate. Thompson Sampling provides Bayes-optimal exploration: maintain a posterior distribution over each item's relevance, *sample* from each posterior at scoring time, and rank by sampled values. Items with tight posteriors (lots of data) get nearly-deterministic scores; items with wide posteriors (little data) get randomized scores that occasionally win, gathering data. Asymptotically optimal regret, simpler than UCB, and trivially parallelizable.

**Incorrect (pure greedy — never explores; never learns about under-served items):**

```python
# Always show by current point estimate of conversion rate
def rank(candidates):
    return sorted(candidates, key=lambda c: c.estimated_conv_rate, reverse=True)
```

**Correct (Thompson Sampling — sample from Beta posterior, rank by sample):**

```python
import numpy as np

def thompson_rank(candidates):
    # Each candidate has alpha = bookings + 1, beta = (impressions - bookings) + 1
    # (Beta prior with one pseudo-success and one pseudo-failure)
    sampled_scores = []
    for c in candidates:
        alpha = c.bookings_30d + 1
        beta_param = (c.impressions_30d - c.bookings_30d) + 1
        sample = np.random.beta(alpha, beta_param)
        sampled_scores.append((sample, c))

    return [c for _, c in sorted(sampled_scores, key=lambda x: -x[0])]
```

**Apply in OpenSearch via `script_score` with a randomization seed:**

OpenSearch doesn't natively have Beta sampling in Painless, so push the sampled scores via a pre-query step:

```python
# At request time:
sampled_scores = {c.id: float(np.random.beta(c.bookings+1, c.impressions-c.bookings+1))
                  for c in candidates}

opensearch_query = {
    "query": {
        "function_score": {
            "query": {"match": {"city": query.city}},
            "functions": [{
                "script_score": {
                    "script": {
                        "source": "params.ts_scores.containsKey(doc['_id'].value) ? params.ts_scores[doc['_id'].value] : 0.5",
                        "params": {"ts_scores": sampled_scores}
                    }
                }
            }],
            "boost_mode": "multiply"
        }
    }
}
```

**Why Beta is the right posterior for conversion:** Conversion is a Bernoulli trial (booked / not booked) with a Beta prior — conjugate, so the posterior update is just `α += bookings; β += non-bookings`. Closed-form, computationally trivial.

**Discounted Thompson Sampling for non-stationary marketplaces:**

```python
# Apply exponential decay to old observations — keeps posterior current as preferences shift
def update_with_decay(c, click_event, gamma=0.999):
    c.alpha = gamma * c.alpha + (1 if click_event.booked else 0)
    c.beta_param = gamma * c.beta_param + (0 if click_event.booked else 1)
```

`gamma=0.999` per day gives effective horizon of ~1000 days; `gamma=0.95` gives ~20 days (responsive to fast-changing demand).

**Calibrate exploration vs exploitation via prior strength:**

| Prior | Exploration | When |
|-------|-------------|------|
| `Beta(1, 1)` | Maximum (uniform) | Pure cold-start; very few observations |
| `Beta(20, 980)` | Strong toward 2% conversion | Confident prior; new items pulled to category mean |

Stronger prior → less exploration on new items (they don't immediately get sampled high). Use the category mean as the prior mean, prior strength = your shrinkage parameter `m`.

**Don't apply Thompson Sampling at the head of every query:** Apply only to the *exploration slot* (5-10% of impressions) — see `market-cold-start-exploration`. Doing it on every result randomizes the user experience to an unacceptable degree.

Reference: [Russo, Van Roy et al. — A Tutorial on Thompson Sampling (Foundations and Trends 2018)](https://web.stanford.edu/~bvr/pubs/TS_Tutorial.pdf) · [Chapelle & Li — An Empirical Evaluation of Thompson Sampling (NIPS 2011)](https://papers.nips.cc/paper/4321-an-empirical-evaluation-of-thompson-sampling)
