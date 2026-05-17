---
title: Validate Ranking Changes with Counterfactual Evaluation
impact: MEDIUM-HIGH
impactDescription: 80% of A/B-test signal without exposing users
tags: bias, counterfactual, off-policy, evaluation, ips
---

## Validate Ranking Changes with Counterfactual Evaluation

Every A/B test costs days of wall-clock, statistical-power budget, and risks user exposure to a bad ranker. Counterfactual (off-policy) evaluation answers "how would a *new* policy have performed on *past* logged data?" without running the new policy live. Using IPS as the off-policy estimator, you can pre-screen 5-10 candidate rankers offline, ship only the top 1-2 to A/B test. Airbnb (KDD 2025 "Harnessing the Power of Interleaving and Counterfactual Evaluation") reports this saves ~80% of A/B-test calendar time.

**Incorrect (every ranking change ships to A/B test — slow, risky):**

```python
# Direct path: idea → ship to 5% A/B → wait 14 days → analyze
new_ranker = train_v2()
ab_test.launch(treatment=new_ranker, control=current_ranker, traffic_pct=5)
# 14 days later: lift signal often within noise band — wasted cycle if it was a bad idea
```

**Correct (counterfactual filter before A/B test):**

```python
# Step 1: Estimate counterfactual reward of new_ranker on logged data
def ips_estimator(new_ranker, logged_data, propensity_table):
    """
    logged_data: list of (query, ranking_shown, item_clicked, position_clicked,
                          logging_policy_score)
    new_ranker: function (query, candidates) -> ranking
    """
    total_reward = 0.0
    total_weight = 0.0
    for record in logged_data:
        new_ranking = new_ranker(record.query, record.candidates)
        new_position = position_of(record.item_clicked, new_ranking)
        if new_position is None or new_position > 50:
            continue  # item not in new policy's top-K

        # IPS weight: prob under new policy / prob under logging policy
        p_new = soft_position_prob(new_position)
        p_log = propensity_table.get(record.position_clicked, 0.05)
        weight = min(p_new / p_log, 50.0)  # clip to avoid huge weights

        total_reward += weight * record.reward  # 1 for conversion, 0 otherwise
        total_weight += weight

    return total_reward / max(total_weight, 1.0)  # estimated reward per impression

# Step 2: Rank candidate rankers by counterfactual estimate
candidates_to_test = [ranker_v2_a, ranker_v2_b, ranker_v2_c, ranker_v2_d, ranker_v2_e]
estimates = [(r, ips_estimator(r, logged_data, propensities)) for r in candidates_to_test]

# Step 3: A/B only the top 1-2
top_two = sorted(estimates, key=lambda x: -x[1])[:2]
for ranker, est in top_two:
    print(f"Counterfactual conversion estimate: {est:.4f}")
    ab_test.launch(treatment=ranker, ...)
```

**Variance reduction with Self-Normalized IPS (SNIPS):**

Raw IPS has high variance when propensities are extreme. SNIPS normalizes by the sum of weights:

```text
SNIPS = (Σ w_i × reward_i) / (Σ w_i)
```

Use SNIPS instead of raw IPS in production — substantially lower variance, slightly biased but accept the trade-off.

**Doubly-Robust (DR) estimator — even lower variance:**

Train a separate per-item reward predictor `r̂(query, item)`. DR estimator:

```text
DR = E_new[r̂] + (1/N) Σ (1/p_log_i) × (r_i - r̂_i) × 1[item shown by new policy]
```

If `r̂` is decent, the residual is small and variance drops further. Standard pattern for marketplace counterfactual eval.

**Calibration check before trusting offline estimates:**

Once a quarter, run a deliberate A/B and compare its result to your counterfactual estimate for the same change. If the offline estimate and the online result diverge by >30%, your propensity model is wrong — fix that before trusting more offline estimates.

**The marketplace habit:** Treat counterfactual evaluation as a triage step, not a substitute for A/B. Goal: of every 10 ideas, kill 8 offline, A/B test the top 2. Saves engineering and user-exposure budget enormously.

Reference: [Joachims, Swaminathan, Schnabel — Unbiased Learning-to-Rank with Biased Feedback (WSDM 2017)](https://www.cs.cornell.edu/people/tj/publications/joachims_etal_17a.pdf) · [Airbnb — Harnessing Interleaving and Counterfactual Evaluation (KDD 2025)](https://airbnb.tech/infrastructure/academic-publications-airbnb-tech-2025-year-in-review/) · [Just Eat Takeaway — IPS Offline Estimator](https://medium.com/justeattakeaway-tech/inverse-propensity-score-based-offline-estimator-for-deterministic-ranking-lists-using-position-89ce866c27dd)
