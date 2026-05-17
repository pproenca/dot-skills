---
title: Build a Graded Judgment Set for Offline Evaluation
impact: HIGH
impactDescription: enables all offline ranking metrics
tags: eval, judgment-set, ndcg, annotation, cranfield
---

## Build a Graded Judgment Set for Offline Evaluation

Every offline ranking metric (NDCG, MAP, MRR, Precision@k) requires a "ground truth" — a graded judgment set of `(query, item, relevance_grade)` tuples that says "for this query, this item is grade 0/1/2/3/4." Without one, you can't measure whether any of your 49 ranking rules actually improved ranking quality. The set is built once and refreshed quarterly; it's the foundation that turns "I think this ranker is better" into "this ranker is +0.043 NDCG@10 better, p<0.01." Cranfield-style methodology (used by TREC since 1992) is the canonical approach.

**Incorrect (no judgment set — every ranking change is a guess):**

```python
# "I think the new ranker is better — let me just ship it to A/B"
# No offline confidence; every change risks user exposure
def evaluate_ranker(ranker):
    return None  # ¯\_(ツ)_/¯
```

**Correct (graded judgment set with stratified query sampling):**

```python
# 1. Sample queries stratified by head/torso/tail (search-volume buckets)
queries = sample_stratified_queries(
    log_source="search_log_30d",
    n_per_stratum={"head": 200, "torso": 200, "tail": 200},
    strata_def={"head": "rank <= 100", "torso": "100 < rank <= 10000", "tail": "rank > 10000"}
)

# 2. For each query, get top-N from a baseline ranker (avoid annotator effort
#    on irrelevant items by limiting to ranker-recall)
candidate_pairs = []
for q in queries:
    top_50 = baseline_ranker.search(q, k=50)
    candidate_pairs.extend([(q, item) for item in top_50])

# 3. Annotate with 5-grade scale (Cranfield-standard)
GRADE_GUIDELINE = """
0 = Off-topic (different intent)
1 = Related but not what user wanted
2 = On-topic, acceptable result
3 = Strong match (user likely satisfied)
4 = Perfect match (exemplar of intent)
"""

# 4. Multiple annotators per pair to measure inter-annotator agreement (Cohen's κ)
#    Reject the set if κ < 0.6 — grading guidelines need refinement

# 5. Store as JSONL — one record per (query, item, grade) with metadata
import json
with open("judgment_set_v1.jsonl", "w") as f:
    for q, item, grade in annotations:
        f.write(json.dumps({
            "query": q.text,
            "query_stratum": q.stratum,        # head/torso/tail
            "query_intent": q.intent,           # navigational/transactional/exploratory
            "item_id": item.id,
            "grade": grade,                     # 0-4
            "annotator_id": annotator.id,
            "annotated_at": "2026-05-17"
        }) + "\n")
```

**Sizing the judgment set:**

| Marketplace size | Set size | Annotation cost (est.) |
|------------------|----------|------------------------|
| <100k items | 200-500 queries × 30 items | ~6k pairs, 1 week / 2 annotators |
| 100k-10M | 500-1000 queries × 40 items | ~30k pairs, 4 weeks / 4 annotators |
| >10M | 1000-2000 queries × 50 items | ~80k pairs, 8-12 weeks / 6 annotators |

**Stratification matters more than sheer size:** A 600-query set with proper head/torso/tail/intent stratification beats a 6000-query set of random head queries. Tail and edge-case queries are where rankers fail most distinctively.

**Refresh cadence:** Quarterly. The catalogue evolves, user intents drift, new query patterns emerge. Stale judgment sets lie about ranking quality.

**Pair with online-offline correlation:** A judgment set is only useful if it predicts online behavior — see `eval-online-offline-correlation` for the validation step.

**Tooling:** [TREC Eval](https://github.com/usnistgov/trec_eval) is the canonical scorer; [Sproutwords](https://github.com/anrosent/sproutwords) and [Snorkel](https://www.snorkel.org/) help with weak-supervision augmentation if pure human annotation isn't feasible.

Reference: [TREC — Common Evaluation Measures](https://trec.nist.gov/pubs/trec16/appendices/measures.pdf) · [Cranfield methodology overview (Voorhees, NIST)](https://trec.nist.gov/pubs/trec5/papers/voorhees-graphics.ps) · [Shaped.ai — NDCG and graded relevance](https://www.shaped.ai/blog/ndcg-evaluating-ranking-quality-with-graded-relevance)
