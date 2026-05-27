---
name: deterministic-metric-design
description: Use this skill whenever designing, reviewing, or validating a quantitative metric, score, measure, or index — turning a fuzzy property like 'maintainability', 'risk', or 'how reducible this code is' into a deterministic, computable number an agent can trust and optimize. Covers the path from construct to adoption — operationalizing the construct, confronting computability limits (Kolmogorov, Rice) with sound proxies, picking the right measurement scale, proving properties (monotonicity, invariance, the Weyuker/Briand axioms), guaranteeing determinism, establishing construct validity (not just LOC in disguise), and hardening against Goodhart-style gaming when an agent optimizes the metric. Trigger even when the user doesn't say 'metric' — if they want to quantify, score, rank, or measure code/behavior, build a deterministic optimization target, or invent a measure for something previously unquantified (e.g., behavior-preserving codebase-size reduction), apply this skill.
metadata:
  internal: true
---
# dot-skills Deterministic Metric Design Best Practices

Design metrics that are deterministic, computable, provable, and valid — measures an agent can trust and *optimize against* without gaming them. The 44 rules across 8 categories take a metric from a fuzzy construct to an adoptable, machine-checkable number: define the construct, confront computability limits with sound proxies, ground it in measurement theory, prove its properties, pin its determinism, validate it empirically, harden it against optimization pressure, and package it for adoption.

A running example threads through every category — **a deterministic measure of behavior-preserving codebase-size reduction** (shrink code without changing how the app works). It is the ideal stress test because its ideal form is provably out of reach (Kolmogorov complexity is uncomputable; program equivalence is undecidable by Rice's theorem), so the whole craft is building a deterministic, tractable proxy with a proven guarantee.

This is the measurement-design layer that the `*-algorithms` skills *apply* (Big-O, NDCG, cyclomatic, MoJoFM) but never *teach*.

## When to Apply

Use this skill when:

- Designing a new metric, score, or index — or reviewing someone's proposed metric for rigor
- Asked to "quantify", "measure", "score", or "rank" a property that has no agreed measure yet
- Building a deterministic optimization target an agent will push on (e.g., reduce code size without changing behavior)
- Auditing an existing metric that "feels off" — it suspiciously tracks LOC, jumps between runs, or gets gamed
- Turning a research idea or formula into something computable, reproducible, and adoptable

## Workflow: Define → Make Computable → Prove → Validate → Harden

The categories are ordered by cascade severity — an upstream mistake poisons everything below it. Work top-down, and jump straight to a category using this table:

| If you are… | Start in | First rule |
|-------------|----------|------------|
| Starting from a fuzzy property | `def-` | [def-name-the-latent-construct](references/def-name-the-latent-construct.md) |
| Worried the ideal is uncomputable / undecidable | `comp-` | [comp-do-not-define-metric-as-uncomputable-ideal](references/comp-do-not-define-metric-as-uncomputable-ideal.md) |
| Unsure whether you can average or take ratios | `meas-` | [meas-declare-the-scale-type](references/meas-declare-the-scale-type.md) |
| Claiming the metric behaves a certain way | `prop-` | [prop-prove-monotonicity](references/prop-prove-monotonicity.md) |
| Getting different numbers between runs | `det-` | [det-pin-iteration-and-tie-break-order](references/det-pin-iteration-and-tie-break-order.md) |
| Unsure it measures the real thing | `valid-` | [valid-discriminant-not-just-loc](references/valid-discriminant-not-just-loc.md) |
| Letting an agent optimize the metric | `game-` | [game-hard-block-construct-violating-wins](references/game-hard-block-construct-violating-wins.md) |
| Publishing the metric for others | `agg-` | [agg-ship-reference-impl-and-test-vectors](references/agg-ship-reference-impl-and-test-vectors.md) |

Each reference file is a `{category}-{slug}.md` containing: WHY it matters, an **Incorrect** example with the failure annotated, a **Correct** example with the minimal fix, and a reference. The incorrect/correct examples are metric *definitions and procedures*, not application code — the contrast is a badly-designed measure versus the fixed one.

## Rule Categories by Priority

| # | Category | Prefix | Impact | Rules |
|---|----------|--------|--------|-------|
| 1 | Construct Definition & Operationalization | `def-` | CRITICAL | 6 |
| 2 | Computability & Tractability | `comp-` | CRITICAL | 7 |
| 3 | Measurement-Theoretic Foundations | `meas-` | HIGH | 5 |
| 4 | Proof of Metric Properties | `prop-` | HIGH | 6 |
| 5 | Determinism & Reproducibility | `det-` | HIGH | 5 |
| 6 | Construct Validity & Calibration | `valid-` | MEDIUM-HIGH | 6 |
| 7 | Optimization Safety & Anti-Gaming | `game-` | MEDIUM | 5 |
| 8 | Aggregation, Reporting & Adoption | `agg-` | LOW-MEDIUM | 4 |

See [`references/_sections.md`](references/_sections.md) for the full ordering rationale.

## Quick Reference

### 1. Construct Definition & Operationalization (CRITICAL)

- [`def-name-the-latent-construct`](references/def-name-the-latent-construct.md) — Name the unobservable property before writing any formula
- [`def-separate-construct-from-proxy`](references/def-separate-construct-from-proxy.md) — Keep construct, proxy, and their assumed link distinct
- [`def-write-falsifiable-operational-definition`](references/def-write-falsifiable-operational-definition.md) — Specify the exact procedure that yields the number
- [`def-fix-unit-of-analysis`](references/def-fix-unit-of-analysis.md) — Pin the unit of analysis and the measurement boundary
- [`def-anchor-to-the-decision`](references/def-anchor-to-the-decision.md) — Attach the decision and action threshold the metric drives
- [`def-operationalize-behavior-and-size`](references/def-operationalize-behavior-and-size.md) — Define "behavior" (≈) and "size" so a formatter can't move them

### 2. Computability & Tractability (CRITICAL)

- [`comp-do-not-define-metric-as-uncomputable-ideal`](references/comp-do-not-define-metric-as-uncomputable-ideal.md) — Don't define the metric as Kolmogorov complexity
- [`comp-respect-rices-theorem-for-semantic-properties`](references/comp-respect-rices-theorem-for-semantic-properties.md) — Use sound approximations for undecidable semantic facts
- [`comp-choose-a-decidable-observational-equivalence`](references/comp-choose-a-decidable-observational-equivalence.md) — Replace undecidable equivalence with a checkable ≈
- [`comp-design-a-proxy-with-a-proven-error-direction`](references/comp-design-a-proxy-with-a-proven-error-direction.md) — Give the proxy a sound bound that never over-states
- [`comp-keep-the-metric-tractable`](references/comp-keep-the-metric-tractable.md) — Pick a near-linear proxy, not an NP-hard optimum
- [`comp-bound-approximation-error-explicitly`](references/comp-bound-approximation-error-explicitly.md) — Quantify and report the proxy↔ideal gap
- [`comp-prefer-monotone-confluent-transformations`](references/comp-prefer-monotone-confluent-transformations.md) — Confluent, terminating rewrites give a unique fixed point

### 3. Measurement-Theoretic Foundations (HIGH)

- [`meas-declare-the-scale-type`](references/meas-declare-the-scale-type.md) — Declare nominal/ordinal/interval/ratio before any statistic
- [`meas-only-admissible-statistics`](references/meas-only-admissible-statistics.md) — Use only statistics invariant under the scale's transforms
- [`meas-establish-meaningful-zero-and-unit`](references/meas-establish-meaningful-zero-and-unit.md) — Give a true zero and a named unit for ratio claims
- [`meas-preserve-the-empirical-relation`](references/meas-preserve-the-empirical-relation.md) — Verify the metric orders known anchor cases correctly
- [`meas-avoid-ad-hoc-weighted-sums`](references/meas-avoid-ad-hoc-weighted-sums.md) — Don't sum incommensurable scales with arbitrary weights

### 4. Proof of Metric Properties (HIGH)

- [`prop-prove-monotonicity`](references/prop-prove-monotonicity.md) — Prove the score moves the right way when the construct does
- [`prop-prove-invariance-under-irrelevant-transforms`](references/prop-prove-invariance-under-irrelevant-transforms.md) — Prove invariance to renaming and formatting
- [`prop-ensure-sensitivity-to-relevant-change`](references/prop-ensure-sensitivity-to-relevant-change.md) — Ensure it still discriminates (no saturation)
- [`prop-check-weyuker-briand-axioms`](references/prop-check-weyuker-briand-axioms.md) — Check the published axioms for your measure type
- [`prop-prove-boundedness-and-handle-empty`](references/prop-prove-boundedness-and-handle-empty.md) — Prove the range; define the empty / zero-denominator case
- [`prop-prove-or-disclaim-composability`](references/prop-prove-or-disclaim-composability.md) — Prove additivity before aggregating, or refuse to sum

### 5. Determinism & Reproducibility (HIGH)

- [`det-make-the-metric-a-pure-function`](references/det-make-the-metric-a-pure-function.md) — No hidden time, network, or global state
- [`det-pin-iteration-and-tie-break-order`](references/det-pin-iteration-and-tie-break-order.md) — Sort by a total key; seed any randomness
- [`det-pin-the-input-representation`](references/det-pin-the-input-representation.md) — Fix exactly which representation (AST stage) you measure
- [`det-control-floating-point-and-accumulation`](references/det-control-floating-point-and-accumulation.md) — Fix summation order and rounding precision
- [`det-version-and-record-the-toolchain`](references/det-version-and-record-the-toolchain.md) — Emit metric version, tool versions, and input hash

### 6. Construct Validity & Calibration (MEDIUM-HIGH)

- [`valid-converge-with-accepted-measure`](references/valid-converge-with-accepted-measure.md) — Show convergence with a trusted measure of the construct
- [`valid-discriminant-not-just-loc`](references/valid-discriminant-not-just-loc.md) — Prove incremental signal beyond LOC / size
- [`valid-predictive-validity-against-outcome`](references/valid-predictive-validity-against-outcome.md) — Show it predicts the real outcome out-of-sample
- [`valid-beat-the-trivial-baseline`](references/valid-beat-the-trivial-baseline.md) — Quote the lift over a dumb baseline
- [`valid-calibrate-thresholds-to-ground-truth`](references/valid-calibrate-thresholds-to-ground-truth.md) — Derive thresholds from data, not round numbers
- [`valid-validate-out-of-sample`](references/valid-validate-out-of-sample.md) — Use a holdout / temporal split to avoid overfitting the corpus

### 7. Optimization Safety & Anti-Gaming (MEDIUM)

- [`game-make-cheapest-improvement-the-right-one`](references/game-make-cheapest-improvement-the-right-one.md) — Make the cheapest score gain the genuine one
- [`game-recognize-goodhart-variants`](references/game-recognize-goodhart-variants.md) — Anticipate regressional / extremal / causal Goodhart
- [`game-pair-with-guardrail-metrics`](references/game-pair-with-guardrail-metrics.md) — Add counter-metrics that veto a regressing "win"
- [`game-hard-block-construct-violating-wins`](references/game-hard-block-construct-violating-wins.md) — Gate on invariants; never use a tradable soft penalty
- [`game-detect-reward-hacking-with-audits`](references/game-detect-reward-hacking-with-audits.md) — Spot-audit top scores; watch proxy↔outcome drift

### 8. Aggregation, Reporting & Adoption (LOW-MEDIUM)

- [`agg-respect-scale-in-aggregation`](references/agg-respect-scale-in-aggregation.md) — Aggregate the way the scale permits (no mean of ordinal)
- [`agg-report-uncertainty-not-false-precision`](references/agg-report-uncertainty-not-false-precision.md) — Report intervals / bounds, not false precision
- [`agg-version-the-metric-publicly`](references/agg-version-the-metric-publicly.md) — Semver + changelog so consumers stay comparable
- [`agg-ship-reference-impl-and-test-vectors`](references/agg-ship-reference-impl-and-test-vectors.md) — Publish test vectors so implementations agree

## How to Use

1. Identify where you are with the **Workflow** table and open the matching first rule.
2. Work the categories top-down — `def-` and `comp-` are CRITICAL because a fuzzy construct or an uncomputable ideal makes everything downstream noise or unusable.
3. When proposing or critiquing a metric, quote the rule by file path so reviewers can check the reasoning.
4. For a new metric, produce a one-page spec naming: construct, proxy, scale + unit + zero, proven properties, determinism guarantees, validity evidence, guardrails, and version — one line per category here.
5. See [`references/_sections.md`](references/_sections.md) for ordering rationale and [`assets/templates/_template.md`](assets/templates/_template.md) when adding rules.

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions, impact levels, and ordering rationale |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for adding new rules |
| [metadata.json](metadata.json) | Discipline, type, and source references |

## Related Skills

- `same-results-less-code`, `code-simplifier`, `complexity-optimizer`, `knip-deadcode` — prescriptive code-reduction skills. This skill supplies the measurement layer they lack: a deterministic, behavior-preserving reduction *metric* to target and verify.
- `algorithmic-complexity-review`, `computer-science-algorithms` — apply existing measures (Big-O). This skill teaches how to design new ones.
- `opensearch-function-scoring-algorithms` — applied ranking metrics (NDCG, A/B tests). This skill is the foundational methodology beneath its `eval-` category.
