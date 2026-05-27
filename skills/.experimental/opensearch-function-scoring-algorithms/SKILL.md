---
name: opensearch-function-scoring-algorithms
description: Use this skill when designing, tuning, reviewing, or evaluating search relevance and ranking for a two-sided marketplace on OpenSearch/Elasticsearch — covers candidate retrieval (hybrid BM25 + kNN, RRF, two-tower EBR), base relevance (BM25F, multi_match, LambdaMART), quality signals (Wilson lower bound, Bayesian average, rank_feature saturation/sigmoid), personalization (listing/user/session embeddings), spatial/temporal decay (gauss/exp), marketplace balance (conversion-weighted ranking, supply fairness, Pareto multi-objective), bias correction (IPS, click models, Thompson sampling), empirical evaluation (judgment sets, NDCG, ablation, A/B sizing, CUPED, regression suites), and diversity (MMR, DPP, max-per-host). Triggers on function_score, rank_feature, script_score, kNN, hybrid query, learning-to-rank, two-sided ranking, exposure fairness, NDCG, A/B testing, judgment set construction, ranking ablation, or "why is my OpenSearch ranking bad". Applies to Elasticsearch too — same APIs.
---

# Marketplace-Research OpenSearch Function Scoring Best Practices

A reference distillation of research-backed algorithms for ranking in two-sided marketplaces (Airbnb, Uber Eats, DoorDash, Etsy, eBay, Booking.com) implemented on OpenSearch or Elasticsearch. Contains **56 rules across 9 categories**, prioritised by cascade effect in the search ranking pipeline. Each rule explains the WHY (the cascade or the bias it corrects), shows incorrect-vs-correct code (OpenSearch JSON queries, Painless scripts, Python pre-processing, evaluation methodology), and links to the canonical source — KDD/SIGIR/WSDM papers, the OpenSearch documentation, and the engineering blogs of the marketplaces that proved these patterns at scale.

## When to Apply

Reach for this skill when:

- Designing a new marketplace search system on OpenSearch or Elasticsearch from scratch
- Tuning function_score / rank_feature / script_score queries that aren't moving the needle
- Setting up hybrid retrieval (BM25 + dense vectors) with Reciprocal Rank Fusion
- Choosing between HNSW and IVF for billion-scale ANN indexes
- Adding personalization via listing/user embeddings or two-tower architectures
- Correcting position bias in click logs before retraining an LTR model
- Designing exposure-fairness or new-listing cold-start exposure allocation
- Composing decay functions (gauss / exp / linear) over geo + date + freshness
- Diversifying the top window with MMR, DPP, or per-host caps
- Debugging "why does my top-10 show 8 listings from one host?" or "why does ranking favor popular incumbents?"
- **Building offline evaluation infrastructure** — graded judgment sets, NDCG@k pipelines, ablation studies, regression query suites
- **Designing A/B tests for ranking changes** — MDE / power / sample-size pre-computation, CUPED variance reduction, online-offline correlation calibration
- **Attributing lift to specific scoring components** — "did my new bias-correction help, or was it the embeddings, or both?"

The rules apply to any OpenSearch/Elasticsearch-backed marketplace search regardless of vertical — accommodation, food delivery, restaurants, services, jobs, secondhand goods, real estate. Triggers include "marketplace ranking", "search relevance", "function_score", "rank_feature", "script_score", "kNN", "hybrid search", "RRF", "learning to rank", "embedding-based retrieval", "two-tower", "position bias", "MMR", "supply fairness", "Pareto multi-objective", "NDCG", "judgment set", "ablation study", "CUPED", "A/B sample size", "ranking eval", and "why are my search results bad".

## The Search Ranking Lifecycle

Categories are derived from the marketplace search ranking pipeline. Earlier stages cascade — a miss in recall (stage 1) cannot be repaired by any downstream boost, and a wrong base relevance multiplies through every functional score:

```text
Query → [1] Recall → [2] Base Relevance → [3] Quality Signals → [4] Personalization
      → [5] Geo/Time Decay → [6] Marketplace Balance → [7] Diversity Re-rank → Results
                                                            ↑
                                          [8] Bias Correction (applied across all stages
                                                       and into training)
                                                            ↑
                                          [9] Evaluation & Measurement (the meta-layer:
                                                       judgment sets, NDCG, ablation, A/B
                                                       sizing, CUPED — without these you
                                                       can't tell if any rule helped)
```

## Rule Categories by Priority

| Priority | Category | Impact | Prefix | Rules |
|----------|----------|--------|--------|-------|
| 1 | Candidate Retrieval & Recall | CRITICAL | `recall-` | 6 |
| 2 | Base Relevance & Field Scoring | CRITICAL | `rel-` | 7 |
| 3 | Quality Signals & Confidence Bounds | HIGH | `qual-` | 6 |
| 4 | Personalization & Embeddings | HIGH | `pers-` | 7 |
| 5 | Spatial & Temporal Decay | HIGH | `decay-` | 5 |
| 6 | Two-Sided Marketplace Balance | HIGH | `market-` | 7 |
| 7 | Bias Correction & Online Learning | HIGH | `bias-` | 6 |
| 8 | Evaluation & Measurement | HIGH | `eval-` | 7 |
| 9 | Diversity & Re-ranking | MEDIUM-HIGH | `div-` | 5 |

## Quick Reference

### 1. Candidate Retrieval & Recall (CRITICAL)

- [`recall-hybrid-rrf`](references/recall-hybrid-rrf.md) — Use Hybrid BM25 + kNN with Reciprocal Rank Fusion
- [`recall-two-tower-ebr`](references/recall-two-tower-ebr.md) — Use Two-Tower Architecture for Embedding-Based Retrieval
- [`recall-prefilter-knn`](references/recall-prefilter-knn.md) — Apply Pre-Filter to kNN with Hard Constraints
- [`recall-hnsw-vs-ivf`](references/recall-hnsw-vs-ivf.md) — Choose HNSW for Latency, IVF for Memory at Scale
- [`recall-multi-stage`](references/recall-multi-stage.md) — Split Retrieval into Cheap Recall and Expensive Re-rank
- [`recall-query-expansion`](references/recall-query-expansion.md) — Apply Synonym Expansion at Index Time for Recall, Query Time for Precision

### 2. Base Relevance & Field Scoring (CRITICAL)

- [`rel-bm25f-field-weights`](references/rel-bm25f-field-weights.md) — Tune BM25F Field Weights Before k1/b
- [`rel-multi-match-strategy`](references/rel-multi-match-strategy.md) — Pick multi_match Type by Query Shape, Not by Default
- [`rel-bm25-k1-b-tuning`](references/rel-bm25-k1-b-tuning.md) — Tune BM25 k1 and b Per-Field for Short Marketplace Documents
- [`rel-listwise-loss`](references/rel-listwise-loss.md) — Prefer Listwise (LambdaMART) over Pairwise (RankNet) LTR Loss
- [`rel-script-score-over-function-score`](references/rel-script-score-over-function-score.md) — Use script_score Query, Not function_score, for Composition
- [`rel-rescore-over-bool-should`](references/rel-rescore-over-bool-should.md) — Use rescore Phase for Heavy Scoring, Not bool/should at Retrieval
- [`rel-avoid-boost-inflation`](references/rel-avoid-boost-inflation.md) — Avoid Field-Boost Inflation Above ~10x

### 3. Quality Signals & Confidence Bounds (HIGH)

- [`qual-wilson-lower-bound`](references/qual-wilson-lower-bound.md) — Sort by Wilson Lower Bound, Not Average Rating
- [`qual-bayesian-average`](references/qual-bayesian-average.md) — Use Bayesian Average for Star Ratings with Low Sample Sizes
- [`qual-rank-feature-saturation`](references/qual-rank-feature-saturation.md) — Saturate Popularity Counts with rank_feature.saturation
- [`qual-rank-feature-sigmoid`](references/qual-rank-feature-sigmoid.md) — Apply Sigmoid Modifier for Bounded Ratio Signals
- [`qual-log1p-vs-saturation`](references/qual-log1p-vs-saturation.md) — Choose log1p over Saturation for Long-Tail Signal Preservation
- [`qual-completeness-score`](references/qual-completeness-score.md) — Score Listing Completeness as a Quality Signal

### 4. Personalization & Embeddings (HIGH)

- [`pers-listing-embeddings`](references/pers-listing-embeddings.md) — Train Listing Embeddings from Booking-Session Co-occurrence
- [`pers-type-embeddings-cold-start`](references/pers-type-embeddings-cold-start.md) — Use Type Embeddings for Cold-Start Users and Listings
- [`pers-real-time-session-vector`](references/pers-real-time-session-vector.md) — Update Session Vector in Real-Time from Click Events
- [`pers-multi-modal-embeddings`](references/pers-multi-modal-embeddings.md) — Use Multi-Modal Embeddings (Text + Image) for Recall
- [`pers-cross-encoder-rerank`](references/pers-cross-encoder-rerank.md) — Apply Cross-Encoder Re-rank on Top-50 for Personalization
- [`pers-tower-split-offline-online`](references/pers-tower-split-offline-online.md) — Split Item Tower Offline, Query Tower Online
- [`pers-contextual-features`](references/pers-contextual-features.md) — Inject Contextual Features into script_score

### 5. Spatial & Temporal Decay (HIGH)

- [`decay-gauss-geo`](references/decay-gauss-geo.md) — Use Gauss Decay for Geo Distance, Not Linear
- [`decay-exp-freshness`](references/decay-exp-freshness.md) — Use Exp Decay for Time Freshness, Gauss for Date Proximity
- [`decay-scale-calibration`](references/decay-scale-calibration.md) — Calibrate Decay Scale to the 0.5-Score Distance Target
- [`decay-offset-noise`](references/decay-offset-noise.md) — Add Offset to Decay Functions for Noisy Sparse Fields
- [`decay-multi-field-composition`](references/decay-multi-field-composition.md) — Compose Multi-Field Decay with Explicit Weights

### 6. Two-Sided Marketplace Balance (HIGH)

- [`market-conversion-weighted-ranking`](references/market-conversion-weighted-ranking.md) — Weight Ranking by Conversion Rate, Not Click-Through Rate
- [`market-cold-start-exploration`](references/market-cold-start-exploration.md) — Boost Cold-Start Listings with Bounded Exposure Allocation
- [`market-supply-fairness-lorenz`](references/market-supply-fairness-lorenz.md) — Monitor Supply-Side Fairness with Lorenz/Gini Metrics
- [`market-host-quality-signals`](references/market-host-quality-signals.md) — Separate Host-Quality and Listing-Quality Signals
- [`market-inventory-health`](references/market-inventory-health.md) — Penalize Listings with Low Inventory Health
- [`market-pareto-multi-objective`](references/market-pareto-multi-objective.md) — Optimize Multi-Objective Ranking with Pareto-Aware Weights
- [`market-price-relevance`](references/market-price-relevance.md) — Score Price Relevance with Soft Bands, Not Hard Filters

### 7. Bias Correction & Online Learning (HIGH)

- [`bias-position-ips`](references/bias-position-ips.md) — Correct Position Bias with Inverse Propensity Scoring
- [`bias-click-models`](references/bias-click-models.md) — Estimate Click Propensities with PBM, Cascade, or DBN
- [`bias-thompson-sampling`](references/bias-thompson-sampling.md) — Explore Ranking Alternatives with Thompson Sampling
- [`bias-counterfactual-eval`](references/bias-counterfactual-eval.md) — Validate Ranking Changes with Counterfactual Evaluation
- [`bias-interleaved-evaluation`](references/bias-interleaved-evaluation.md) — Use Interleaved Evaluation for Low-Traffic Ranking Comparisons
- [`bias-popularity-debiasing`](references/bias-popularity-debiasing.md) — Subsample Popular Items in Embedding Training Negatives

### 8. Evaluation & Measurement (HIGH)

- [`eval-graded-judgment-set`](references/eval-graded-judgment-set.md) — Build a Graded Judgment Set for Offline Evaluation
- [`eval-ndcg-primary-metric`](references/eval-ndcg-primary-metric.md) — Use NDCG@k as the Primary Offline Ranking Metric
- [`eval-online-offline-correlation`](references/eval-online-offline-correlation.md) — Validate Online-Offline Metric Correlation Before Trusting Offline Scores
- [`eval-ablation-attribution`](references/eval-ablation-attribution.md) — Run Ablation Studies to Attribute Lift to Specific Components
- [`eval-ab-sample-size-mde`](references/eval-ab-sample-size-mde.md) — Calculate A/B Sample Size from MDE Before Running
- [`eval-cuped-variance-reduction`](references/eval-cuped-variance-reduction.md) — Apply CUPED to Halve A/B Sample Size with Pre-Experiment Covariates
- [`eval-regression-query-suite`](references/eval-regression-query-suite.md) — Maintain a Regression Query Suite for Silent Quality Drops

### 9. Diversity & Re-ranking (MEDIUM-HIGH)

- [`div-mmr-rerank`](references/div-mmr-rerank.md) — Apply MMR Rerank for Top-Window Diversity
- [`div-max-per-host`](references/div-max-per-host.md) — Cap Impressions Per Host with Max-Per-Group Constraint
- [`div-category-diversity`](references/div-category-diversity.md) — Diversify Categories Hierarchically in the Top Window
- [`div-dpp-quality-diversity`](references/div-dpp-quality-diversity.md) — Use Determinantal Point Processes for Joint Quality and Diversity
- [`div-window-penalty`](references/div-window-penalty.md) — Apply Window-Based Diversity Penalty in Rescore

## How to Use

For a focused question ("which decay function for geo distance?"), jump directly to the relevant rule (`decay-gauss-geo`) — each rule is self-contained with the WHY, OpenSearch query/Painless code, and the canonical source citation.

For a full ranking system review, work the categories top-to-bottom. The cascade ordering is real: get recall right first (no boost recovers a missed candidate), then base relevance (it's the multiplicand of every functional score), then quality / personalization / decay / marketplace balance / bias correction in that order. Diversity is the last re-rank step over a well-ordered top window.

For correcting bias before retraining, start with `bias-position-ips` and `bias-click-models` — applying IPS to position-confounded click data is the single highest-leverage change for any marketplace that retrains LTR models on logged clicks.

**For testing multiple algorithms together and validating empirically**, start with `eval-graded-judgment-set` (build the foundation), `eval-ndcg-primary-metric` (pick the metric), then `eval-ablation-attribution` (attribute lift to specific components). Pair with `eval-online-offline-correlation` to verify your offline metric predicts online behavior, `eval-ab-sample-size-mde` + `eval-cuped-variance-reduction` for disciplined A/B testing, and `eval-regression-query-suite` to catch silent quality drops on named queries.

For research-citing a design decision, every rule ends with the canonical reference — KDD/SIGIR/WSDM papers, the relevant engineering blog (Airbnb, Pinterest, DoorDash, Etsy, Just Eat Takeaway, Thumbtack), or the OpenSearch documentation page.

Read [section definitions](references/_sections.md) for the cascade-impact rationale behind the category ordering, or [the rule template](assets/templates/_template.md) when adding a new rule.

## Reference Files

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and ordering by cascade impact |
| [AGENTS.md](AGENTS.md) | Compact TOC navigation (auto-built; do not edit by hand) |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for authoring new rules |
| [metadata.json](metadata.json) | Version and authoritative reference URLs |
