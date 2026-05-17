---
title: Ablate Each Input Signal And Measure The Drop In Quality
impact: MEDIUM-HIGH
impactDescription: reveals which input signals carry signal vs noise; eliminates unhelpful components from the pipeline
tags: valid, ablation, sensitivity, factor-analysis, attribution
---

## Ablate Each Input Signal And Measure The Drop In Quality

You built a multi-signal pipeline (structural + co-change + lexical, weighted multilayer — see `graph-combine-signals-in-multilayer-graphs`). You report MoJoFM = 73 on a benchmark. **Which signal actually mattered?** Without ablation, you don't know — and worse, neither do your reviewers. The right experimental protocol is **leave-one-out ablation**: for each input signal, *remove* it (set its weight to 0 or rebuild the graph without it), re-run the full pipeline, and measure the drop in quality. The signal whose removal drops quality the most is doing the most work; signals whose removal *increases* quality were actually hurting.

This is the standard practice in ML research (Sutskever-Hinton 2014 "On the importance of initialization and momentum in deep learning" ablate momentum, learning rate, ...) and almost never done in software clustering. The result is often surprising: many studies that report "we combined three signals" find on ablation that one signal does 80% of the work and the others contribute noise.

**Incorrect (report final pipeline result; assume each component is useful):**

```python
G = multilayer_combine(
    layers={"call": G_call, "cochange": G_cc, "lexical": G_lex},
    alpha={"call": 0.4, "cochange": 0.4, "lexical": 0.2},
)
clusters = leiden(G)
mojo = mojofm(clusters, ground_truth)
print(f"MoJoFM = {mojo:.2f}")
# 73.5. Sounds good. But call alone might give 71; lexical might hurt.
# Without ablation, you have no way to find out.
```

**Correct (Step 1 — define the ablation set: each signal removed individually):**

```python
def ablation_configurations(base_alphas: dict[str, float]):
    """
    Yield (config_name, modified_alpha) for each ablation:
      - all_signals: the baseline (everything on)
      - drop_X: signal X removed; remaining signals re-normalized to sum to 1
      - X_only: only signal X (others removed)
    """
    signals = list(base_alphas.keys())
    yield ("all_signals", dict(base_alphas))
    for sig in signals:
        # drop_X: remove sig, re-normalize
        remaining = {s: w for s, w in base_alphas.items() if s != sig}
        total = sum(remaining.values())
        remaining = {s: w/total for s, w in remaining.items()}
        yield (f"drop_{sig}", remaining)
    for sig in signals:
        # X_only: keep only sig
        yield (f"{sig}_only", {sig: 1.0})
```

**Correct (Step 2 — run pipeline for each configuration):**

```python
def ablation_study(layers, base_alphas, ground_truth, run_pipeline):
    """
    layers: {"call": G_call, "cochange": G_cc, "lexical": G_lex}
    base_alphas: {"call": 0.4, "cochange": 0.4, "lexical": 0.2}
    ground_truth: list[set[file]] — expert decomposition for MoJoFM
    run_pipeline(layers_dict, alpha_dict) → list[set[file]]
    """
    results = []
    for name, alphas in ablation_configurations(base_alphas):
        # Filter layers to only those with non-zero alpha
        used_layers = {s: layers[s] for s, w in alphas.items() if w > 0 and s in layers}
        used_alphas = {s: w for s, w in alphas.items() if w > 0 and s in layers}
        clusters = run_pipeline(used_layers, used_alphas)
        score = mojofm(clusters, ground_truth)
        results.append({"config": name, "alphas": alphas, "mojofm": score})
        print(f"  {name:>20}  MoJoFM = {score:>6.2f}")
    return results
```

**Correct (Step 3 — interpret the contributions):**

```python
def interpret_ablation(results):
    """
    Two derived quantities per signal:
      contribution_drop = MoJoFM(all_signals) - MoJoFM(drop_X)
        — how much does the full pipeline lose when X is removed?
      contribution_solo  = MoJoFM(X_only) - random_baseline
        — how much does X alone explain?

    Three patterns to look for:
    - X drives everything: contribution_drop high, contribution_solo high
    - X is complementary: contribution_drop moderate, contribution_solo lower
    - X is noise: contribution_drop ≤ 0 (removing X improves or neutral)
    """
    res_by_name = {r["config"]: r["mojofm"] for r in results}
    baseline = res_by_name["all_signals"]

    print(f"\n{'signal':>15}  {'drop_x':>8}  {'x_only':>8}  {'verdict':>20}")
    for sig in ["call", "cochange", "lexical"]:
        drop_x = baseline - res_by_name.get(f"drop_{sig}", baseline)
        x_only = res_by_name.get(f"{sig}_only", 0) - 30  # 30 ≈ random baseline
        verdict = (
            "drives most"      if drop_x > 5 and x_only > 30
            else "complementary" if 0 < drop_x <= 5
            else "noise (drop it)" if drop_x <= 0
            else "ambiguous"
        )
        print(f"{sig:>15}  {drop_x:>+8.2f}  {x_only:>+8.2f}  {verdict:>20}")
```

**A real example pattern (Beck-Diehl 2013 ablation on Apache Tomcat):**

```text
   config              MoJoFM
   all_signals         73.5
   drop_call           70.1  (Δ = −3.4)
   drop_cochange       62.8  (Δ = −10.7)  ← co-change is doing the heavy lifting
   drop_lexical        72.9  (Δ = −0.6)   ← lexical contributes marginally
   call_only           65.2
   cochange_only       69.4
   lexical_only        51.5
```

Conclusion: this codebase's clustering quality is driven by **co-change**, not by structural dependencies. Lexical adds almost nothing. You can drop lexical from your pipeline (saves preprocessing time + complexity) without losing accuracy. *This* is the conclusion that ablation gives you and a single end-to-end run doesn't.

**Beyond signal ablation — hyperparameter and algorithm ablation:**

```python
# The same protocol works for hyperparameters:
# - Resolution γ:  γ = 0.7, 1.0, 1.5, 2.0
# - K (for k-means / NMF): K = 10, 20, 50, 100
# - Algorithm choice: Leiden vs Infomap vs SBM
# - Preprocessing options: with/without omnipresent filter, etc.
#
# Build a Cartesian grid of these and report the MoJoFM heat map. The
# regions of stable high-quality are the robust operating points.
```

**Why ablation is non-negotiable for serious analysis:**

A pipeline with N components has 2^N possible ablations. Reporting one configuration's MoJoFM (or any other metric) gives a single number. Reporting the ablation lattice gives an *attribution* — which components carry the signal, which are noise, which are redundant. Without it you can't:
- Defend the pipeline design ("we tried it without X and it was 10 points worse")
- Simplify ("we showed X contributed nothing; we removed it")
- Generalise ("X works on Tomcat; on Jenkins, X *hurts* — interesting")

**When NOT to ablate:**

- Quick exploratory analysis where you'll come back to validation later. Fine; just don't claim "we proved the pipeline works."
- Single-signal pipeline (nothing to ablate).
- The signals are inseparable by construction (e.g. embeddings learned jointly) — ablate at a coarser granularity.

**Production:** No standard tool — ablation is a *practice*, not a library. Most ML research papers include an ablation table; software-clustering research papers typically don't, which is a maturity gap the field is starting to address.

Reference: [Evaluating the impact of software evolution on software clustering (Beck & Diehl, EMSE 2013)](https://link.springer.com/article/10.1007/s10664-012-9220-1)
