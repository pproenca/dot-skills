# Deterministic Metric Design

**Version 0.1.0**  
dot-skills  
May 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Methodology for inventing rigorous, deterministic software metrics for AI agents and LLMs. Contains 44 rules across 8 categories that take a metric from a fuzzy construct to an adoptable, machine-checkable number: construct definition and operationalization; computability and tractability (designing sound proxies when the ideal is uncomputable — Kolmogorov, Rice — or NP-hard); measurement-theoretic foundations (scales, units, admissible statistics); proof of metric properties (monotonicity, invariance, the Weyuker/Briand axioms); determinism and reproducibility; construct validity and calibration; optimization safety and anti-gaming (Goodhart variants, guardrails, hard gates); and aggregation, reporting, and adoption. Each rule includes a minimal-diff incorrect/correct example and an authoritative reference. A running example — a deterministic, behavior-preserving codebase-size-reduction metric — threads through every category. It is the measurement layer the *-algorithms skills apply but don't teach.

---

## Table of Contents

1. [Construct Definition & Operationalization](references/_sections.md#1-construct-definition-&-operationalization) — **CRITICAL**
   - 1.1 [Anchor the Metric to the Decision It Will Drive](references/def-anchor-to-the-decision.md) — HIGH (prevents orphan metrics that accrete and get misread)
   - 1.2 [Fix the Unit of Analysis and the Measurement Boundary](references/def-fix-unit-of-analysis.md) — HIGH (prevents incomparable values from silently mixed scopes)
   - 1.3 [Name the Latent Construct Before Writing Any Formula](references/def-name-the-latent-construct.md) — CRITICAL (prevents measuring a convenient proxy and calling it the property you care about)
   - 1.4 [Operationalize "Behavior-Preserving Size Reduction" Concretely](references/def-operationalize-behavior-and-size.md) — CRITICAL (prevents measuring something a code formatter can move for free)
   - 1.5 [Separate the Construct From the Proxy You Actually Compute](references/def-separate-construct-from-proxy.md) — CRITICAL (prevents the cyclomatic-equals-complexity category error)
   - 1.6 [Write a Falsifiable Operational Definition](references/def-write-falsifiable-operational-definition.md) — HIGH (prevents two implementations producing different numbers for one input)
2. [Computability & Tractability](references/_sections.md#2-computability-&-tractability) — **CRITICAL**
   - 2.1 [Avoid Defining a Metric as an Uncomputable Ideal](references/comp-do-not-define-metric-as-uncomputable-ideal.md) — CRITICAL (prevents defining a metric no Turing machine can compute)
   - 2.2 [Bound the Approximation Gap, Don't Leave It Implicit](references/comp-bound-approximation-error-explicitly.md) — HIGH (prevents an unquantified proxy from being trusted as exact)
   - 2.3 [Build "Size After Rewriting" From Confluent, Terminating Transforms](references/comp-prefer-monotone-confluent-transformations.md) — HIGH (prevents an order-dependent, non-deterministic fixed point)
   - 2.4 [Give the Proxy a Proven Error Direction](references/comp-design-a-proxy-with-a-proven-error-direction.md) — CRITICAL (prevents an over-stating proxy from triggering harmful edits)
   - 2.5 [Keep Metric Computation Near-Linear, Not NP-Hard](references/comp-keep-the-metric-tractable.md) — HIGH (prevents an NP-hard definition that can't run per commit (target O(V+E)))
   - 2.6 [Replace Undecidable Equivalence With a Checkable Observational Relation](references/comp-choose-a-decidable-observational-equivalence.md) — CRITICAL (prevents relying on undecidable full program equivalence)
   - 2.7 [Respect Rice's Theorem When Measuring Semantic Properties](references/comp-respect-rices-theorem-for-semantic-properties.md) — CRITICAL (prevents promising an exact count of an undecidable property)
3. [Measurement-Theoretic Foundations](references/_sections.md#3-measurement-theoretic-foundations) — **HIGH**
   - 3.1 [Avoid Ad-Hoc Weighted Sums Across Incommensurable Scales](references/meas-avoid-ad-hoc-weighted-sums.md) — MEDIUM-HIGH (prevents unfalsifiable weighted sums across incommensurable scales)
   - 3.2 [Declare the Scale Type Before Choosing Statistics](references/meas-declare-the-scale-type.md) — HIGH (prevents meaningless means and ratios on ordinal data)
   - 3.3 [Establish a Meaningful Zero and a Named Unit](references/meas-establish-meaningful-zero-and-unit.md) — HIGH (prevents invalid ratio claims made without a true zero and unit)
   - 3.4 [Make the Metric a Homomorphism of the Real Relation](references/meas-preserve-the-empirical-relation.md) — HIGH (prevents a metric whose ordering contradicts the real ordering)
   - 3.5 [Use Only Statistics Admissible for the Scale](references/meas-only-admissible-statistics.md) — HIGH (prevents "20% better" claims the scale cannot support)
4. [Proof of Metric Properties](references/_sections.md#4-proof-of-metric-properties) — **HIGH**
   - 4.1 [Check Your Measure Against the Weyuker / Briand Axioms](references/prop-check-weyuker-briand-axioms.md) — HIGH (prevents structural defects like a non-additive size measure)
   - 4.2 [Ensure Sensitivity to the Changes That Should Matter](references/prop-ensure-sensitivity-to-relevant-change.md) — HIGH (prevents a metric that saturates and stops discriminating)
   - 4.3 [Prove Composability Before Aggregating, or Disclaim It](references/prop-prove-or-disclaim-composability.md) — MEDIUM-HIGH (prevents invalid system-level totals from non-additive metrics)
   - 4.4 [Prove Invariance Under Transformations That Shouldn't Matter](references/prop-prove-invariance-under-irrelevant-transforms.md) — HIGH (prevents the metric from measuring surface text instead of structure)
   - 4.5 [Prove Monotonicity in the Underlying Property](references/prop-prove-monotonicity.md) — HIGH (prevents optimization from rewarding the wrong direction)
   - 4.6 [Prove the Claimed Bounds and Handle the Empty Case](references/prop-prove-boundedness-and-handle-empty.md) — MEDIUM-HIGH (prevents NaN/inf and out-of-range values on real inputs)
5. [Determinism & Reproducibility](references/_sections.md#5-determinism-&-reproducibility) — **HIGH**
   - 5.1 [Control Floating-Point Order and Rounding](references/det-control-floating-point-and-accumulation.md) — MEDIUM-HIGH (prevents float drift from flipping threshold decisions)
   - 5.2 [Make the Metric a Pure Function of Declared Inputs](references/det-make-the-metric-a-pure-function.md) — HIGH (prevents irreproducible scores from hidden time, network, or globals)
   - 5.3 [Pin Exactly Which Representation You Measure](references/det-pin-the-input-representation.md) — HIGH (prevents incomparable numbers across source, AST, and bytecode)
   - 5.4 [Pin Iteration Order and Tie-Breaking](references/det-pin-iteration-and-tie-break-order.md) — HIGH (prevents run-to-run variance from unordered iteration and hash seeds)
   - 5.5 [Version the Definition and Record the Toolchain](references/det-version-and-record-the-toolchain.md) — MEDIUM-HIGH (prevents broken trend lines across parser and library upgrades)
6. [Construct Validity & Calibration](references/_sections.md#6-construct-validity-&-calibration) — **MEDIUM-HIGH**
   - 6.1 [Beat the Trivial Baseline, Explicitly](references/valid-beat-the-trivial-baseline.md) — MEDIUM (prevents shipping a metric that fails to beat a trivial baseline)
   - 6.2 [Calibrate Action Thresholds to Ground Truth, Not Round Numbers](references/valid-calibrate-thresholds-to-ground-truth.md) — MEDIUM (prevents arbitrary round-number thresholds)
   - 6.3 [Establish Convergent Validity Against an Accepted Measure](references/valid-converge-with-accepted-measure.md) — MEDIUM-HIGH (prevents shipping a metric with no evidence it tracks its construct)
   - 6.4 [Prove Discriminant Validity — It Isn't Just Size in Disguise](references/valid-discriminant-not-just-loc.md) — MEDIUM-HIGH (prevents shipping a metric that is ~0.9 correlated with LOC)
   - 6.5 [Show Predictive Validity Against the Outcome You Care About](references/valid-predictive-validity-against-outcome.md) — MEDIUM-HIGH (prevents acting on an assumed, unmeasured metric-outcome link)
   - 6.6 [Validate Out-of-Sample to Avoid Overfitting the Corpus](references/valid-validate-out-of-sample.md) — MEDIUM (prevents overfit validity inflated by tuning on the test set)
7. [Optimization Safety & Anti-Gaming](references/_sections.md#7-optimization-safety-&-anti-gaming) — **MEDIUM**
   - 7.1 [Detect Reward-Hacking With Spot Audits and Drift Checks](references/game-detect-reward-hacking-with-audits.md) — LOW-MEDIUM (prevents undetected reward-hacking from accumulating over time)
   - 7.2 [Make the Cheapest Way to Improve the Metric the Right One](references/game-make-cheapest-improvement-the-right-one.md) — MEDIUM (prevents cheap degenerate edits from out-scoring real improvement)
   - 7.3 [Pair Every Target With Guardrail Metrics](references/game-pair-with-guardrail-metrics.md) — MEDIUM (prevents unmeasured regressions when one metric is optimized)
   - 7.4 [Recognize the Goodhart Variants Before You Optimize](references/game-recognize-goodhart-variants.md) — MEDIUM (prevents extremal Goodhart from silently breaking the proxy)
   - 7.5 [Reject Improvements That Violate the Construct's Invariants](references/game-hard-block-construct-violating-wins.md) — MEDIUM (prevents the optimizer from buying invariant violations with score)
8. [Aggregation, Reporting & Adoption](references/_sections.md#8-aggregation,-reporting-&-adoption) — **LOW-MEDIUM**
   - 8.1 [Aggregate Only in Ways the Scale Permits](references/agg-respect-scale-in-aggregation.md) — LOW-MEDIUM (prevents means of ordinal data and naive averaging of ratios)
   - 8.2 [Report Uncertainty, Not a False-Precision Point Estimate](references/agg-report-uncertainty-not-false-precision.md) — LOW-MEDIUM (prevents over-trusting a number the sampling can't support)
   - 8.3 [Ship a Reference Implementation and Published Test Vectors](references/agg-ship-reference-impl-and-test-vectors.md) — LOW-MEDIUM (prevents independent implementations from disagreeing)
   - 8.4 [Version and Changelog the Metric for Its Consumers](references/agg-version-the-metric-publicly.md) — LOW-MEDIUM (prevents broken cross-consumer comparisons across definition changes)

---

## References

1. [https://psychclassics.yorku.ca/Cronbach/construct.htm](https://psychclassics.yorku.ca/Cronbach/construct.htm)
2. [https://www.routledge.com/Software-Metrics-A-Rigorous-and-Practical-Approach-Third-Edition/Fenton-Bieman/p/book/9781439838228](https://www.routledge.com/Software-Metrics-A-Rigorous-and-Practical-Approach-Third-Edition/Fenton-Bieman/p/book/9781439838228)
3. [https://www.science.org/doi/10.1126/science.103.2684.677](https://www.science.org/doi/10.1126/science.103.2684.677)
4. [https://doi.org/10.1109/32.6178](https://doi.org/10.1109/32.6178)
5. [https://doi.org/10.1109/32.481535](https://doi.org/10.1109/32.481535)
6. [https://link.springer.com/book/10.1007/978-3-030-11298-1](https://link.springer.com/book/10.1007/978-3-030-11298-1)
7. [https://www.ams.org/journals/tran/1953-074-02/S0002-9947-1953-0053041-6/](https://www.ams.org/journals/tran/1953-074-02/S0002-9947-1953-0053041-6/)
8. [https://dl.acm.org/doi/10.1145/512950.512973](https://dl.acm.org/doi/10.1145/512950.512973)
9. [https://mitpress.mit.edu/9780262072816/the-minimum-description-length-principle/](https://mitpress.mit.edu/9780262072816/the-minimum-description-length-principle/)
10. [https://psycnet.apa.org/doi/10.1037/h0046016](https://psycnet.apa.org/doi/10.1037/h0046016)
11. [https://doi.org/10.1109/ICSM.2010.5609747](https://doi.org/10.1109/ICSM.2010.5609747)
12. [https://arxiv.org/abs/1803.04585](https://arxiv.org/abs/1803.04585)
13. [https://arxiv.org/abs/1606.06565](https://arxiv.org/abs/1606.06565)
14. [https://www.acm.org/publications/policies/artifact-review-and-badging-current](https://www.acm.org/publications/policies/artifact-review-and-badging-current)
15. [https://semver.org/](https://semver.org/)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |