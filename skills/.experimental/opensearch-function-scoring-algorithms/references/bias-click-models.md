---
title: Estimate Click Propensities with PBM, Cascade, or DBN
impact: HIGH
impactDescription: enables IPS without randomization experiments
tags: bias, click-models, pbm, cascade, dbn, propensity
---

## Estimate Click Propensities with PBM, Cascade, or DBN

IPS requires per-position propensities — the probability a user examined position `i`. Click models infer these from observed click patterns without needing the (costly) randomization experiments described in `bias-position-ips`. Three click models cover most marketplace scenarios: **PBM** (Position-Based Model — clicks independent across positions); **Cascade** — user scans top-to-bottom and stops at first click; **DBN** (Dynamic Bayesian Network) — adds the satisfaction event (user stops after click if satisfied). Pick by your traffic pattern.

**Incorrect (assume uniform propensity across positions — naive average):**

```python
# Naive — treat every position equally
position_propensity = {i: 1.0 for i in range(1, 51)}
```

This is what *no* bias correction looks like.

**Correct (PBM with EM — start here for most marketplaces):**

```python
# Position-Based Model (PBM)
#   Assumption: Click iff (Examined at position) AND (Item is Relevant)
#   P(click | q, item, pos) = P(examined | pos) × P(relevant | q, item)
#   EM:
#     E-step: attribute clicks to examination vs relevance given current params
#     M-step: re-estimate examination prior per position

from pyclick.click_models.PBM import PBM

sessions = parse_marketplace_sessions(click_log)  # list of [(query, item, position, clicked)]
pbm = PBM()
pbm.train(sessions)

# Export propensity table for IPS training
position_propensity = {
    p: pbm.params[PBM.param_names.exam][p - 1]
    for p in range(1, 51)
}
```

**Alternative — Cascade Model:**

```text
Assumption: User scans top-to-bottom, clicks if relevant, stops at first click
  P(click_i = 1) = relevance_i × Π_{j<i} (1 - relevance_j)
```

Use when: users click *at most once* per session (specific transactional searches). Less suited to browse-heavy marketplaces.

**Alternative — DBN (Dynamic Bayesian Network):**

```text
Adds a Satisfaction event after click:
  P(continue | clicked) = 1 - σ
  σ is per-item — captures how often a click leads to a "good" outcome
```

Use when: you have both clicks AND conversion signal — DBN models both jointly. Highest-capacity option for marketplace data where you want propensities and per-item satisfaction together.

**Validation:** Hold out a slice of randomized-exposure traffic (1-2% of queries with shuffled top-K) and compare PBM-derived propensities against the empirical position-CTR from the randomized slice. They should track within ~10%.

**When PBM fails:** If your marketplace has strong rank-dependent layout (e.g., images get larger at the top), PBM under-estimates position-1 propensity. Use a multi-modal model (incorporates layout features) or DBN with attention weights as a per-position covariate.

Reference: [Chuklin, Markov, de Rijke — Click Models for Web Search (book, 2015)](https://www.morganclaypool.com/doi/10.2200/S00654ED1V01Y201507ICR043) · [pyClick library](https://github.com/markovi/PyClick) · [Wang et al. — Position Bias Estimation (WSDM 2018)](https://research.google/pubs/pub46485/)
