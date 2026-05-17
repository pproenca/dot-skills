# Sections

This file defines all sections, their ordering, impact levels, and descriptions.
The section ID (in parentheses) is the filename prefix used to group rules.

Categories appear in **impact order** (CRITICAL → MEDIUM-HIGH), but the search ranking pipeline runs in a different order: Query → Recall → Base Relevance → Quality → Personalization → Decay → Marketplace Balance → Diversity → (Bias Correction and Evaluation are meta concerns applied across all stages). A miss at recall cannot be recovered downstream; a wrong base relevance multiplies every functional score; uncorrected bias poisons every future model trained on click logs; and without evaluation infrastructure you cannot tell whether any of the other rules helped.

---

## 1. Candidate Retrieval & Recall (recall)

**Impact:** CRITICAL  
**Description:** Recall gates everything. A listing missing from the candidate set cannot be ranked, no matter how clever the scoring. Hybrid retrieval (BM25 + kNN with RRF), two-tower embedding-based retrieval, and ANN index selection (HNSW vs IVF) belong here.

## 2. Base Relevance & Field Scoring (rel)

**Impact:** CRITICAL  
**Description:** The base relevance score is the multiplicand for every downstream function. BM25F field weighting, `combined_fields`, `multi_match` strategy selection, and LTR loss-function choice (pairwise vs listwise) determine whether every later boost amplifies signal or noise.

## 3. Quality Signals & Confidence Bounds (qual)

**Impact:** HIGH  
**Description:** Item-intrinsic quality signals computable from the listing alone — ratings, review counts, photo quality, completeness scores. Raw averages and unsmoothed counts are systematically biased toward low-sample items. Wilson Lower Bound, Bayesian average, `rank_feature` saturation/sigmoid, and log1p normalization fix this.

## 4. Personalization & Embeddings (pers)

**Impact:** HIGH  
**Description:** Per-user differentiation via listing/user embeddings, two-tower architectures, real-time session vectors, and cross-encoder re-ranking. The offline/online tower split (precompute item embeddings, score query tower at request time) is what makes embedding-based retrieval feasible at marketplace scale.

## 5. Spatial & Temporal Decay (decay)

**Impact:** HIGH  
**Description:** Geographic and time-based relevance via Gauss, exp, and linear decay functions. Origin, scale, decay, and offset tuning determines whether "near" means 1km or 100km, and whether "fresh" means hours or weeks. Multi-field decay composition (geo × date × seasonality) is standard for accommodation/delivery marketplaces.

## 6. Two-Sided Marketplace Balance (market)

**Impact:** HIGH  
**Description:** Signals that exist only because of two-sided dynamics — conversion rate, host acceptance rate, cancellation rate, supply scarcity, cold-start exposure, inventory health, and multi-objective Pareto balance. This is what distinguishes marketplace ranking from general web search; getting it wrong starves supply or burns demand.

## 7. Bias Correction & Online Learning (bias)

**Impact:** HIGH  
**Description:** Position bias, popularity bias, and cold-start bias all enter through implicit feedback (clicks, bookings). Training on raw click logs without Inverse Propensity Scoring (Joachims et al. 2017) compounds these biases on every retrain. Click models (PBM/cascade/DBN), counterfactual evaluation, and bounded exploration (Thompson Sampling, epsilon-greedy) are required for sustainable online learning.

## 8. Evaluation & Measurement (eval)

**Impact:** HIGH  
**Description:** Infrastructure for empirically validating that ranking changes actually work. Graded judgment sets, NDCG@k as the primary offline metric, online-offline correlation checks, ablation studies for component attribution, A/B test sample-size planning (MDE × power × variance), CUPED variance reduction, and regression query suites. Without measurement infrastructure you cannot tell whether any of the 49 algorithmic rules in the other categories actually helped — and you can't safely test combinations.

## 9. Diversity & Re-ranking (div)

**Impact:** MEDIUM-HIGH  
**Description:** Post-rank reordering to prevent homogeneous result lists. MMR (Carbonell & Goldstein 1998), Determinantal Point Processes, max-per-host constraints, and hierarchical category diversity. Lower impact than upstream stages because it operates on an already-ranked set, but materially affects engagement on the top window.
