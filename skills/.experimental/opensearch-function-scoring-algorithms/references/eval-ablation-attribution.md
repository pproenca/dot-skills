---
title: Run Ablation Studies to Attribute Lift to Specific Components
impact: HIGH
impactDescription: prevents bundled-change blame attribution failure
tags: eval, ablation, attribution, component, leave-one-out
---

## Run Ablation Studies to Attribute Lift to Specific Components

A marketplace ranking stack stacks many rules at once — BM25F, Wilson Lower Bound, listing embeddings, gauss decay, conversion-weighted scoring, IPS-corrected LTR, MMR diversity. When the new system as a whole is +0.04 NDCG@10, *which* of those moved the needle? Ablation studies answer this: turn each component off (or replace it with a no-op), measure the NDCG drop, and attribute the lift proportionally. Without ablation, you maintain a fragile stack of "everything matters" with no insight into which components are doing the work and which are dead weight.

**Incorrect (one big A/B test, no idea which component contributed):**

```python
# Old ranker vs new ranker (everything changed at once)
# Result: +0.038 NDCG@10, +1.2% conversion
# Insight: zero. We don't know if the listing embeddings did it or the bias correction
#          or the new decay function or the host fairness reweighting.
```

**Correct (additive ablation — measure marginal contribution of each component):**

```python
COMPONENTS = [
    ("baseline_bm25", build_bm25_only),
    ("+ bm25f_field_weights", add_bm25f),
    ("+ wilson_rating_signal", add_wilson),
    ("+ listing_embeddings", add_embeddings),
    ("+ gauss_geo_decay", add_geo_decay),
    ("+ conversion_weighted_rerank", add_conv_rerank),
    ("+ ips_position_correction", add_ips),
    ("+ mmr_diversity", add_mmr),
]

def additive_ablation(judgment_set, k=10):
    """Build up the stack one component at a time, measure NDCG after each."""
    results = []
    cumulative = None
    for name, mutator in COMPONENTS:
        cumulative = mutator(cumulative)
        ndcg = mean_ndcg_at_k(cumulative, judgment_set, k=k)
        results.append({"step": name, "ndcg": ndcg})
    return results

# Output:
# baseline_bm25                       NDCG@10 = 0.512
# + bm25f_field_weights               NDCG@10 = 0.541   (+0.029)
# + wilson_rating_signal              NDCG@10 = 0.548   (+0.007)
# + listing_embeddings                NDCG@10 = 0.583   (+0.035)  ← big win
# + gauss_geo_decay                   NDCG@10 = 0.594   (+0.011)
# + conversion_weighted_rerank        NDCG@10 = 0.612   (+0.018)
# + ips_position_correction           NDCG@10 = 0.620   (+0.008)
# + mmr_diversity                     NDCG@10 = 0.619   (-0.001)  ← negligible / negative
```

Now you know: listing embeddings + BM25F + conversion-weighted scoring did most of the work; MMR diversity is actually slightly hurting NDCG (which is expected — it trades NDCG for engagement, so the right next step is to measure session engagement separately).

**Use leave-one-out for "is this component still pulling its weight" checks:**

```python
def leave_one_out_ablation(full_stack, components, judgment_set, k=10):
    """For each component, build a stack without it and measure NDCG drop."""
    baseline = mean_ndcg_at_k(full_stack, judgment_set, k=k)
    results = []
    for name in components:
        ablated = remove_component(full_stack, name)
        ndcg = mean_ndcg_at_k(ablated, judgment_set, k=k)
        results.append({"removed": name, "ndcg": ndcg, "drop": baseline - ndcg})
    return sorted(results, key=lambda x: -x["drop"])

# Output:
# Removed bm25f_field_weights         NDCG@10 = 0.591  drop=0.029
# Removed listing_embeddings          NDCG@10 = 0.585  drop=0.035  ← still load-bearing
# Removed conversion_weighted_rerank  NDCG@10 = 0.602  drop=0.018
# Removed mmr_diversity               NDCG@10 = 0.620  drop=0.000  ← consider removing
```

**Order-dependence trap:** Additive ablation measures *marginal* contribution at each step — later additions look smaller because earlier ones already captured related signal. For component attribution in the *final* system, prefer leave-one-out (also called "subtractive ablation"), which is order-independent.

**Run ablations against multiple metrics:** NDCG@10, NDCG@5, per-stratum NDCG (head/torso/tail), and online metric proxies. A component might be NDCG-neutral but improve tail NDCG by 0.05 — visible only in stratified ablation.

**Use ablations to feed Pareto multi-objective decisions:** If two components have similar NDCG impact but very different latency cost, the cheaper one wins. Cross-reference with `market-pareto-multi-objective`.

**When ablation finds a component contributes ~0:**
1. Don't immediately remove it — it might be redundant *given* other components but load-bearing *without* them.
2. Run a "minimum stack" experiment — remove the suspect plus 1-2 of its plausible substitutes; if quality stays the same, it's truly removable.
3. If it stays, document it as kept-for-defense-in-depth, not because it pulls weight.

Reference: [Sculley et al. — Hidden Technical Debt in Machine Learning Systems (NIPS 2015)](https://papers.nips.cc/paper/5656-hidden-technical-debt-in-machine-learning-systems) · [Wikipedia — Ablation (Artificial Intelligence)](https://en.wikipedia.org/wiki/Ablation_(artificial_intelligence)) · [Capital One Tech — Ablation Studies for ML](https://capitalone.com/tech/machine-learning/xai-ablation-study)
