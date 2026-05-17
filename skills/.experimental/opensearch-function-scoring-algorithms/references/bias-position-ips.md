---
title: Correct Position Bias with Inverse Propensity Scoring
impact: HIGH
impactDescription: prevents 5-10× position-from-relevance confound
tags: bias, position-bias, ips, counterfactual, ltr
---

## Correct Position Bias with Inverse Propensity Scoring

A click on the #1 result doesn't mean that result is better — it means the user saw it first. Position bias is the largest systematic bias in implicit feedback: by some estimates, the #1 position receives 5-10× the clicks of position #5 *purely from position*, independent of relevance. Training an LTR model on raw click data without correction reinforces whatever was previously ranked at the top, creating a feedback loop that drifts away from true relevance. Inverse Propensity Scoring (Joachims et al., WSDM 2017) corrects this by weighting each observed click by `1 / propensity`, where propensity is the probability the user examined that position.

**The IPS framework:**

```text
Raw training signal:        L_naive = Σ click_i × loss(rank_i)

IPS-corrected signal:       L_ips   = Σ (click_i / p_i) × loss(rank_i)

  where p_i = P(examined | shown at position i)
```

Items at position 1 have p₁ ≈ 1; items at position 10 have p₁₀ ≈ 0.2. Dividing the click signal by propensity inflates the importance of clicks that occurred despite low examination probability, removing the position-from-relevance confound.

**Incorrect (training LTR on raw click logs — bias compounds):**

```python
# Raw click as training label — top-of-page gets 5-10x weight from position alone
training_examples = [
    (query, listing, listing.shown_position, listing.was_clicked)
    for impression in click_log
]

# This trains "what was at the top got clicked," not "what was relevant got clicked"
ltr.fit(training_examples)
```

**Correct (IPS-weighted training):**

```python
# 1. Estimate propensity p_i — e.g., from a position-bias model (see bias-click-models)
position_propensity = {1: 1.00, 2: 0.65, 3: 0.45, 4: 0.32, 5: 0.24,
                       6: 0.19, 7: 0.16, 8: 0.14, 9: 0.12, 10: 0.10}

# 2. Re-weight training examples by 1 / propensity
training_examples = []
for impression in click_log:
    p = position_propensity[impression.shown_position]
    if impression.was_clicked:
        weight = 1.0 / max(p, 0.05)  # clip propensity to avoid huge weights
        training_examples.append((impression.query, impression.listing, weight, label=1))

ltr.fit(training_examples)  # weighted loss
```

**Propensity-clipping:** Without a floor on `p`, a click at position 50 (p ≈ 0.02) gets weight 50× — a single click dominates the gradient. Clip propensities at `max(p, 0.05)` or use Self-Normalized IPS.

**Cold-start the propensity model:** Initially, you have no propensities. Two options:
1. **Randomized exposure (RandPair):** For 1-5% of queries, shuffle positions; observe clicks; fit a position-bias model. Joachims et al. recommend this when you can tolerate the UX hit.
2. **Result-randomization-free estimation:** EM-based estimation à la Wang et al. (WSDM 2018) — fit the propensity and the relevance model jointly.

**Validating IPS is working:** Track *offline NDCG against a held-out judged set* before and after IPS. If NDCG goes down, your propensity estimates are wrong; check for clipping, missing positions in propensity table, or a popularity-bias confound (see `bias-popularity-debiasing`).

**Why this isn't optional for marketplaces:** Position bias in marketplace click logs is documented to drift models monotonically toward popular-incumbent items (Thumbtack 2024, Just Eat Takeaway 2023). Uncorrected, your model trains itself into a self-reinforcing loop where the top of yesterday's results trains today's model to keep them at the top.

Reference: [Joachims et al. — Unbiased Learning-to-Rank with Biased Feedback (WSDM 2017)](https://www.cs.cornell.edu/people/tj/publications/joachims_etal_17a.pdf) · [Wang et al. — Position Bias Estimation (WSDM 2018)](https://research.google/pubs/pub46485/) · [Thumbtack — Position Bias in Features (arXiv 2402.02626)](https://arxiv.org/pdf/2402.02626)
