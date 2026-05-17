# OpenSearch Function Scoring for Two-Sided Marketplaces

**Version 0.2.0**  
Marketplace-Research  
May 2026

> **Note:** Agent/LLM-facing table of contents for the OpenSearch Function Scoring for Two-Sided Marketplaces rule set; entry point for AI agents maintaining, generating, refactoring, or evaluating OpenSearch / Elasticsearch ranking code for marketplace search. Humans may also find it useful, but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive guide to research-backed scoring algorithms AND empirical-evaluation methodology for two-sided marketplace search on OpenSearch or Elasticsearch. Contains 56 rules across 9 categories, ordered by cascade effect in the search ranking pipeline — from candidate retrieval (where a miss cannot be recovered downstream) through base relevance, quality signals, personalization, decay, marketplace balance, bias correction, evaluation & measurement, and diversity. Each rule explains the underlying mechanism, shows incorrect-vs-correct code (OpenSearch JSON, Painless, Python pre-processing, evaluation pipelines), and cites a canonical source — KDD/SIGIR/WSDM/CIKM papers (Airbnb, Pinterest, Google, Microsoft), the OpenSearch documentation, and the engineering blogs of marketplaces that proved these patterns at scale (Airbnb, DoorDash, Etsy, Pinterest, Thumbtack, Just Eat Takeaway, Booking, Netflix). The evaluation category explicitly covers how to test multiple algorithms together — judgment sets, NDCG, ablation studies, A/B sample-size planning, CUPED variance reduction, online-offline correlation calibration, and regression query suites. Suitable as the source of truth for AI agents implementing, reviewing, OR evaluating marketplace ranking code.

---

## Table of Contents

1. [Candidate Retrieval & Recall](references/_sections.md#1-candidate-retrieval-&-recall) — **CRITICAL**
   - 1.1 [Apply Pre-Filter to kNN with Hard Constraints](references/recall-prefilter-knn.md) — CRITICAL (prevents empty result sets with strict filters)
   - 1.2 [Apply Synonym Expansion at Index Time for Recall, Query Time for Precision](references/recall-query-expansion.md) — MEDIUM-HIGH (prevents O(synonyms × terms) query blowup)
   - 1.3 [Choose HNSW for Latency, IVF for Memory at Scale](references/recall-hnsw-vs-ivf.md) — HIGH (3-10x memory savings with IVF beyond 100M vectors)
   - 1.4 [Split Retrieval into Cheap Recall and Expensive Re-rank](references/recall-multi-stage.md) — HIGH (10-100x cost reduction vs single-stage)
   - 1.5 [Use Hybrid BM25 + kNN with Reciprocal Rank Fusion](references/recall-hybrid-rrf.md) — CRITICAL (8-15% NDCG@10 lift over either alone)
   - 1.6 [Use Two-Tower Architecture for Embedding-Based Retrieval](references/recall-two-tower-ebr.md) — CRITICAL (enables sub-100ms recall at billion-item scale)
2. [Base Relevance & Field Scoring](references/_sections.md#2-base-relevance-&-field-scoring) — **CRITICAL**
   - 2.1 [Avoid Field-Boost Inflation Above ~10x](references/rel-avoid-boost-inflation.md) — MEDIUM-HIGH (prevents single-field dominance collapse)
   - 2.2 [Pick multi_match Type by Query Shape, Not by Default](references/rel-multi-match-strategy.md) — HIGH (10-25% relevance shift between types)
   - 2.3 [Prefer Listwise (LambdaMART) over Pairwise (RankNet) LTR Loss](references/rel-listwise-loss.md) — HIGH (3-8% NDCG@10 gain on graded relevance sets)
   - 2.4 [Tune BM25 k1 and b Per-Field for Short Marketplace Documents](references/rel-bm25-k1-b-tuning.md) — HIGH (5-15% NDCG@10 lift on title fields)
   - 2.5 [Tune BM25F Field Weights Before k1/b](references/rel-bm25f-field-weights.md) — CRITICAL (15-30% NDCG gain over single-field BM25)
   - 2.6 [Use rescore Phase for Heavy Scoring, Not bool/should at Retrieval](references/rel-rescore-over-bool-should.md) — HIGH (5-20x latency reduction with same ranking quality)
   - 2.7 [Use script_score Query, Not function_score, for Composition](references/rel-script-score-over-function-score.md) — HIGH (2-5x faster, supports caching and modern features)
3. [Quality Signals & Confidence Bounds](references/_sections.md#3-quality-signals-&-confidence-bounds) — **HIGH**
   - 3.1 [Apply Sigmoid Modifier for Bounded Ratio Signals](references/qual-rank-feature-sigmoid.md) — MEDIUM-HIGH (prevents flat-line at high ratios)
   - 3.2 [Choose log1p over Saturation for Long-Tail Signal Preservation](references/qual-log1p-vs-saturation.md) — MEDIUM-HIGH (preserves head-vs-super-head differentiation)
   - 3.3 [Saturate Popularity Counts with rank_feature.saturation](references/qual-rank-feature-saturation.md) — HIGH (prevents popularity-blowout where 10x reviews = 10x score)
   - 3.4 [Score Listing Completeness as a Quality Signal](references/qual-completeness-score.md) — MEDIUM (5-10% conversion lift on listings nudged to complete)
   - 3.5 [Sort by Wilson Lower Bound, Not Average Rating](references/qual-wilson-lower-bound.md) — HIGH (prevents 1-rating-of-5-stars beating 1000-ratings-of-4.8)
   - 3.6 [Use Bayesian Average for Star Ratings with Low Sample Sizes](references/qual-bayesian-average.md) — HIGH (prevents new-listing cold-start rating distortion)
4. [Personalization & Embeddings](references/_sections.md#4-personalization-&-embeddings) — **HIGH**
   - 4.1 [Apply Cross-Encoder Re-rank on Top-50 for Personalization](references/pers-cross-encoder-rerank.md) — HIGH (5-10% NDCG@10 lift on top window)
   - 4.2 [Inject Contextual Features into script_score](references/pers-contextual-features.md) — MEDIUM-HIGH (2-5% conversion lift from device/time/location context)
   - 4.3 [Split Item Tower Offline, Query Tower Online](references/pers-tower-split-offline-online.md) — HIGH (enables sub-100ms query latency at billion-item scale)
   - 4.4 [Train Listing Embeddings from Booking-Session Co-occurrence](references/pers-listing-embeddings.md) — HIGH (21% NDCG@10 lift in Airbnb production (KDD 2018))
   - 4.5 [Update Session Vector in Real-Time from Click Events](references/pers-real-time-session-vector.md) — HIGH (3-5% session conversion lift vs static user vector)
   - 4.6 [Use Multi-Modal Embeddings (Text + Image) for Recall](references/pers-multi-modal-embeddings.md) — MEDIUM-HIGH (7-12% incremental recall over text-only embeddings)
   - 4.7 [Use Type Embeddings for Cold-Start Users and Listings](references/pers-type-embeddings-cold-start.md) — HIGH (lifts cold-start ranking quality 12-18% NDCG)
5. [Spatial & Temporal Decay](references/_sections.md#5-spatial-&-temporal-decay) — **HIGH**
   - 5.1 [Add Offset to Decay Functions for Noisy Sparse Fields](references/decay-offset-noise.md) — MEDIUM (prevents micro-distance ranking instability)
   - 5.2 [Calibrate Decay Scale to the 0.5-Score Distance Target](references/decay-scale-calibration.md) — MEDIUM-HIGH (prevents over- or under-penalty cliffs)
   - 5.3 [Compose Multi-Field Decay with Explicit Weights](references/decay-multi-field-composition.md) — MEDIUM-HIGH (prevents one decay dimension from dominating)
   - 5.4 [Use Exp Decay for Time Freshness, Gauss for Date Proximity](references/decay-exp-freshness.md) — HIGH (prevents symmetric falloff on directional time)
   - 5.5 [Use Gauss Decay for Geo Distance, Not Linear](references/decay-gauss-geo.md) — HIGH (prevents linear over-penalty within walking distance)
6. [Two-Sided Marketplace Balance](references/_sections.md#6-two-sided-marketplace-balance) — **HIGH**
   - 6.1 [Boost Cold-Start Listings with Bounded Exposure Allocation](references/market-cold-start-exploration.md) — HIGH (enables supply growth without ranking instability)
   - 6.2 [Monitor Supply-Side Fairness with Lorenz/Gini Metrics](references/market-supply-fairness-lorenz.md) — HIGH (prevents winner-take-all supply collapse)
   - 6.3 [Optimize Multi-Objective Ranking with Pareto-Aware Weights](references/market-pareto-multi-objective.md) — HIGH (explicit Pareto frontier > implicit single objective)
   - 6.4 [Penalize Listings with Low Inventory Health](references/market-inventory-health.md) — MEDIUM-HIGH (prevents user dead-ends on unavailable inventory)
   - 6.5 [Score Price Relevance with Soft Bands, Not Hard Filters](references/market-price-relevance.md) — HIGH (prevents zero-result pages from tight budgets)
   - 6.6 [Separate Host-Quality and Listing-Quality Signals](references/market-host-quality-signals.md) — MEDIUM-HIGH (prevents host-good-listing-bad confusion)
   - 6.7 [Weight Ranking by Conversion Rate, Not Click-Through Rate](references/market-conversion-weighted-ranking.md) — HIGH (5-15% conversion lift vs CTR-only ranking)
7. [Bias Correction & Online Learning](references/_sections.md#7-bias-correction-&-online-learning) — **HIGH**
   - 7.1 [Correct Position Bias with Inverse Propensity Scoring](references/bias-position-ips.md) — HIGH (prevents 5-10× position-from-relevance confound)
   - 7.2 [Estimate Click Propensities with PBM, Cascade, or DBN](references/bias-click-models.md) — HIGH (enables IPS without randomization experiments)
   - 7.3 [Explore Ranking Alternatives with Thompson Sampling](references/bias-thompson-sampling.md) — HIGH (95% of greedy gain with proven exploration)
   - 7.4 [Subsample Popular Items in Embedding Training Negatives](references/bias-popularity-debiasing.md) — MEDIUM-HIGH (prevents head-item embedding collapse)
   - 7.5 [Use Interleaved Evaluation for Low-Traffic Ranking Comparisons](references/bias-interleaved-evaluation.md) — MEDIUM-HIGH (10-100x more statistical power than A/B at low traffic)
   - 7.6 [Validate Ranking Changes with Counterfactual Evaluation](references/bias-counterfactual-eval.md) — MEDIUM-HIGH (80% of A/B-test signal without exposing users)
8. [Evaluation & Measurement](references/_sections.md#8-evaluation-&-measurement) — **HIGH**
   - 8.1 [Apply CUPED to Halve A/B Sample Size with Pre-Experiment Covariates](references/eval-cuped-variance-reduction.md) — HIGH (40-60% variance reduction, 2x test throughput)
   - 8.2 [Build a Graded Judgment Set for Offline Evaluation](references/eval-graded-judgment-set.md) — HIGH (enables all offline ranking metrics)
   - 8.3 [Calculate A/B Sample Size from MDE Before Running](references/eval-ab-sample-size-mde.md) — HIGH (prevents 20-30% false positive rate from peeking)
   - 8.4 [Maintain a Regression Query Suite for Silent Quality Drops](references/eval-regression-query-suite.md) — MEDIUM (prevents tail/edge-case degradation while average is flat)
   - 8.5 [Run Ablation Studies to Attribute Lift to Specific Components](references/eval-ablation-attribution.md) — HIGH (prevents bundled-change blame attribution failure)
   - 8.6 [Use NDCG@k as the Primary Offline Ranking Metric](references/eval-ndcg-primary-metric.md) — HIGH (prevents metric-mismatch with multi-grade relevance)
   - 8.7 [Validate Online-Offline Metric Correlation Before Trusting Offline Scores](references/eval-online-offline-correlation.md) — HIGH (prevents shipping rankers that improve NDCG but hurt conversion)
9. [Diversity & Re-ranking](references/_sections.md#9-diversity-&-re-ranking) — **MEDIUM-HIGH**
   - 9.1 [Apply MMR Rerank for Top-Window Diversity](references/div-mmr-rerank.md) — MEDIUM-HIGH (3-7% session-level engagement lift)
   - 9.2 [Apply Window-Based Diversity Penalty in Rescore](references/div-window-penalty.md) — MEDIUM (preserves rank stability across sessions)
   - 9.3 [Cap Impressions Per Host with Max-Per-Group Constraint](references/div-max-per-host.md) — MEDIUM-HIGH (prevents single-host page domination)
   - 9.4 [Diversify Categories Hierarchically in the Top Window](references/div-category-diversity.md) — MEDIUM-HIGH (4-8% category-coverage lift in top-10)
   - 9.5 [Use Determinantal Point Processes for Joint Quality and Diversity](references/div-dpp-quality-diversity.md) — MEDIUM (1-3% engagement lift over MMR on high-stakes pages)

---

## References

1. [https://docs.opensearch.org/latest/query-dsl/compound/function-score/](https://docs.opensearch.org/latest/query-dsl/compound/function-score/)
2. [https://docs.opensearch.org/latest/query-dsl/specialized/script-score/](https://docs.opensearch.org/latest/query-dsl/specialized/script-score/)
3. [https://docs.opensearch.org/latest/query-dsl/specialized/rank-feature/](https://docs.opensearch.org/latest/query-dsl/specialized/rank-feature/)
4. [https://docs.opensearch.org/latest/search-plugins/knn/](https://docs.opensearch.org/latest/search-plugins/knn/)
5. [https://docs.opensearch.org/latest/search-plugins/ltr/](https://docs.opensearch.org/latest/search-plugins/ltr/)
6. [https://docs.opensearch.org/latest/query-dsl/full-text/combined-fields/](https://docs.opensearch.org/latest/query-dsl/full-text/combined-fields/)
7. [https://docs.opensearch.org/latest/vector-search/specialized-operations/vector-search-mmr/](https://docs.opensearch.org/latest/vector-search/specialized-operations/vector-search-mmr/)
8. [https://opensearch.org/blog/introducing-reciprocal-rank-fusion-hybrid-search/](https://opensearch.org/blog/introducing-reciprocal-rank-fusion-hybrid-search/)
9. [https://dl.acm.org/doi/10.1145/3219819.3219885](https://dl.acm.org/doi/10.1145/3219819.3219885)
10. [https://arxiv.org/pdf/2601.06873](https://arxiv.org/pdf/2601.06873)
11. [https://arxiv.org/pdf/2210.07774](https://arxiv.org/pdf/2210.07774)
12. [https://airbnb.tech/uncategorized/embedding-based-retrieval-for-airbnb-search/](https://airbnb.tech/uncategorized/embedding-based-retrieval-for-airbnb-search/)
13. [https://airbnb.tech/infrastructure/academic-publications-airbnb-tech-2025-year-in-review/](https://airbnb.tech/infrastructure/academic-publications-airbnb-tech-2025-year-in-review/)
14. [https://medium.com/airbnb-engineering/listing-embeddings-for-similar-listing-recommendations-and-real-time-personalization-in-search-601172f7603e](https://medium.com/airbnb-engineering/listing-embeddings-for-similar-listing-recommendations-and-real-time-personalization-in-search-601172f7603e)
15. [https://cormack.uwaterloo.ca/cormacksigir09-rrf.pdf](https://cormack.uwaterloo.ca/cormacksigir09-rrf.pdf)
16. [https://www.cs.cmu.edu/~jgc/publication/The_Use_MMR_Diversity_Based_LTMIR_1998.pdf](https://www.cs.cmu.edu/~jgc/publication/The_Use_MMR_Diversity_Based_LTMIR_1998.pdf)
17. [https://www.cs.cornell.edu/people/tj/publications/joachims_etal_17a.pdf](https://www.cs.cornell.edu/people/tj/publications/joachims_etal_17a.pdf)
18. [https://research.google/pubs/pub46485/](https://research.google/pubs/pub46485/)
19. [https://arxiv.org/abs/1802.07281](https://arxiv.org/abs/1802.07281)
20. [https://www.evanmiller.org/how-not-to-sort-by-average-rating.html](https://www.evanmiller.org/how-not-to-sort-by-average-rating.html)
21. [https://www.staff.city.ac.uk/~sbrp622/papers/foundations_bm25_review.pdf](https://www.staff.city.ac.uk/~sbrp622/papers/foundations_bm25_review.pdf)
22. [https://www.microsoft.com/en-us/research/publication/from-ranknet-to-lambdarank-to-lambdamart-an-overview/](https://www.microsoft.com/en-us/research/publication/from-ranknet-to-lambdarank-to-lambdamart-an-overview/)
23. [https://arxiv.org/abs/1207.6083](https://arxiv.org/abs/1207.6083)
24. [https://web.stanford.edu/~bvr/pubs/TS_Tutorial.pdf](https://web.stanford.edu/~bvr/pubs/TS_Tutorial.pdf)
25. [https://arxiv.org/html/2404.16260v1](https://arxiv.org/html/2404.16260v1)
26. [https://medium.com/pinterest-engineering/pinnersage-multi-modal-user-embedding-framework-for-recommendations-at-pinterest-bfd116b49475](https://medium.com/pinterest-engineering/pinnersage-multi-modal-user-embedding-framework-for-recommendations-at-pinterest-bfd116b49475)
27. [https://medium.com/pinterest-engineering/pinsage-a-new-graph-convolutional-neural-network-for-web-scale-recommender-systems-88795a107f48](https://medium.com/pinterest-engineering/pinsage-a-new-graph-convolutional-neural-network-for-web-scale-recommender-systems-88795a107f48)
28. [https://careersatdoordash.com/blog/doordash-kdd-llm-assisted-personalization-framework/](https://careersatdoordash.com/blog/doordash-kdd-llm-assisted-personalization-framework/)
29. [https://arxiv.org/pdf/2402.02626](https://arxiv.org/pdf/2402.02626)
30. [https://arxiv.org/pdf/2206.11720](https://arxiv.org/pdf/2206.11720)
31. [https://medium.com/justeattakeaway-tech/inverse-propensity-score-based-offline-estimator-for-deterministic-ranking-lists-using-position-89ce866c27dd](https://medium.com/justeattakeaway-tech/inverse-propensity-score-based-offline-estimator-for-deterministic-ranking-lists-using-position-89ce866c27dd)
32. [https://www.elastic.co/blog/practical-bm25-part-3-considerations-for-picking-b-and-k1-in-elasticsearch](https://www.elastic.co/blog/practical-bm25-part-3-considerations-for-picking-b-and-k1-in-elasticsearch)
33. [https://openreview.net/pdf?id=uPWdkoZHgba](https://openreview.net/pdf?id=uPWdkoZHgba)
34. [https://www.cs.cornell.edu/people/tj/publications/radlinski_etal_08a.pdf](https://www.cs.cornell.edu/people/tj/publications/radlinski_etal_08a.pdf)
35. [https://papers.nips.cc/paper/5021-distributed-representations-of-words-and-phrases-and-their-compositionality](https://papers.nips.cc/paper/5021-distributed-representations-of-words-and-phrases-and-their-compositionality)
36. [https://www.jstor.org/stable/2276774](https://www.jstor.org/stable/2276774)
37. [https://dl.acm.org/doi/10.1145/582415.582418](https://dl.acm.org/doi/10.1145/582415.582418)
38. [https://trec.nist.gov/pubs/trec16/appendices/measures.pdf](https://trec.nist.gov/pubs/trec16/appendices/measures.pdf)
39. [https://www.evidentlyai.com/ranking-metrics/ndcg-metric](https://www.evidentlyai.com/ranking-metrics/ndcg-metric)
40. [https://www.shaped.ai/blog/ndcg-evaluating-ranking-quality-with-graded-relevance](https://www.shaped.ai/blog/ndcg-evaluating-ranking-quality-with-graded-relevance)
41. [https://exp-platform.com/Documents/2013-02-OnlineControlledExperimentsAtLargeScale.pdf](https://exp-platform.com/Documents/2013-02-OnlineControlledExperimentsAtLargeScale.pdf)
42. [https://exp-platform.com/Documents/2013-02-CUPED-ImprovingSensitivityOfControlledExperiments.pdf](https://exp-platform.com/Documents/2013-02-CUPED-ImprovingSensitivityOfControlledExperiments.pdf)
43. [https://docs.growthbook.io/statistics/cuped](https://docs.growthbook.io/statistics/cuped)
44. [https://experimentguide.com/](https://experimentguide.com/)
45. [https://docs.geteppo.com/statistics/sample-size-calculator/mde/](https://docs.geteppo.com/statistics/sample-size-calculator/mde/)
46. [https://en.wikipedia.org/wiki/Ablation_(artificial_intelligence)](https://en.wikipedia.org/wiki/Ablation_(artificial_intelligence))
47. [https://capitalone.com/tech/machine-learning/xai-ablation-study](https://capitalone.com/tech/machine-learning/xai-ablation-study)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |