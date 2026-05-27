# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

Categories are ordered by **cascade severity** — how much an upstream mistake poisons
everything downstream — multiplied by **frequency** in real metric-design work. A metric
built on a fuzzy construct or an uncomputable ideal is noise or unusable no matter how
careful the later steps are, so those tiers come first.

---

## 1. Construct Definition & Operationalization (def)

**Impact:** CRITICAL  
**Description:** A metric is only as meaningful as the construct it claims to measure. If the target property stays fuzzy ("maintainability," "how reducible this code is"), the formula silently measures whatever is convenient and every downstream number inherits the ambiguity — you cannot prove, validate, or safely optimize a quantity you never pinned down. This category forces the upstream decisions: name the latent construct, fix the unit of analysis and the measurement boundary, write a falsifiable operational definition, and keep the construct strictly separate from the proxy you will actually compute.

## 2. Computability & Tractability (comp)

**Impact:** CRITICAL  
**Description:** The reason genuinely useful metrics stay "uncracked" is almost always that their ideal form is uncomputable or undecidable: minimal program size reduces to Kolmogorov complexity (uncomputable), and every non-trivial semantic property of programs — including behavioral equivalence — is undecidable by Rice's theorem. Defining a metric as the ideal quantity guarantees it can never be computed. The discipline is to design a deterministic, tractable proxy whose error has a proven direction (a sound lower bound, a conservative over-approximation), so the number is always computable and its relationship to the ideal is known rather than hoped. A metric an agent recomputes thousands of times must also be cheap — near-linear on the AST/CFG, not NP-hard.

## 3. Measurement-Theoretic Foundations (meas)

**Impact:** HIGH  
**Description:** A measure's scale type — nominal, ordinal, interval, or ratio (Stevens) — determines which arithmetic and statistics are even meaningful. Averaging ordinal severity scores, summing percentages, or claiming "twice as complex" on an interval scale produces numbers that look quantitative but encode nothing. Representational measurement theory requires the metric to be a homomorphism from an empirical relational structure to a numerical one: the operations you perform on the numbers must mirror real relations among the things measured. Declaring the scale, unit, and meaningful zero up front constrains every later step and blocks invalid aggregation.

## 4. Proof of Metric Properties (prop)

**Impact:** HIGH  
**Description:** A metric makes formal claims, and those claims must be proven, not assumed — exactly as you prove an algorithm correct via invariants. Monotonicity (more of the underlying property must move the score in the claimed direction), invariance under transformations that should not matter (renaming, formatting, statement reordering) versus sensitivity to those that should, boundedness and normalization, and additivity or composability when you assert it. The axiomatic frameworks of Weyuker and of Briand–Morasca–Basili give concrete properties to check for size, length, complexity, cohesion, and coupling measures; a metric that violates the properties its construct demands is measuring something other than what it claims.

## 5. Determinism & Reproducibility (det)

**Impact:** HIGH  
**Description:** A metric an agent optimizes must be a pure function of well-defined inputs: identical input yields an identical number across runs, machines, language versions, and tool versions. Hidden non-determinism — hash-map iteration order, unstable tie-breaking, floating-point accumulation order, an unpinned parser, or ambiguity about which representation is measured (raw source vs. post-macro AST) — turns the score into noise and makes any optimization gradient chase artifacts. This category pins the input representation, ordering, tie-breaks, normalization, and tool versions so the measurement is reproducible by anyone.

## 6. Construct Validity & Calibration (valid)

**Impact:** MEDIUM-HIGH  
**Description:** A metric can be perfectly defined, computable, and deterministic and still measure the wrong thing. Construct validity is the empirical evidence that it captures its construct and not a trivial confound — the canonical failure is cyclomatic complexity correlating ~0.9 with raw lines of code, adding little beyond a length count. Establishing convergent validity (agreement with accepted measures of the same construct), discriminant validity (it is not a relabeling of size), and predictive validity (it forecasts the outcome you care about), then beating an obvious baseline and calibrating thresholds against ground truth, is what earns a metric trust.

## 7. Optimization Safety & Anti-Gaming (game)

**Impact:** MEDIUM  
**Description:** "When a measure becomes a target, it ceases to be a good measure" (Goodhart). The moment a metric is optimized — especially by an automated agent that will exploit any cheap path — the correlation that made it useful can break, and the optimizer reward-hacks the proxy instead of improving the construct. Designing for optimization means making the cheapest way to raise the score the genuinely good change (incentive compatibility), pairing the target with guardrail metrics, hard-blocking improvements that violate the construct's invariants (a size reduction that breaks behavioral equivalence), and recognizing the Goodhart variants (regressional, extremal, causal) so the metric survives being pushed on.

## 8. Aggregation, Reporting & Adoption (agg)

**Impact:** LOW-MEDIUM  
**Description:** A metric earns adoption only when others can apply it and get the same answer. Aggregating across units must respect the scale type (no mean of an ordinal scale — use medians or full distributions), reporting must carry uncertainty rather than false-precision point estimates, the definition must be versioned because a silently changed metric breaks every trend line, and a reference implementation with published test vectors is what lets independent tools reproduce it — the step that turned RSA and NDCG from papers into infrastructure.
