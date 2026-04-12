---
title: Track NDCG, MRR and Zero-Result Rate
impact: MEDIUM
impactDescription: enables ranking-quality measurement
tags: measure, ndcg, mrr
---

## Track NDCG, MRR and Zero-Result Rate

Three metrics together give a complete picture of search ranking quality: NDCG@10 measures how well the top-10 match graded relevance judgments, MRR measures how often the first relevant result is at rank 1, and zero-result rate measures how often the query finds nothing at all. Tracking any one in isolation hides failure modes — MRR can rise while NDCG drops if the first match improves at the expense of the rest, and a ranker can score perfectly on NDCG while the zero-result rate rises quietly. All three belong on the weekly dashboard.

**Incorrect (only click-through rate tracked as ranking quality):**

```python
def weekly_search_quality() -> dict:
    return {"ctr": click_logs.ctr(window_days=7)}
```

**Correct (NDCG, MRR, zero-result rate plus CTR as the full picture):**

```python
def weekly_search_quality() -> dict:
    return {
        "ndcg_at_10": offline_eval.ndcg_at_k(golden_set.current(), k=10),
        "mrr": offline_eval.mrr(golden_set.current()),
        "zero_result_rate": query_logs.zero_result_fraction(window_days=7),
        "ctr": click_logs.ctr(window_days=7),
        "reformulation_rate": query_logs.reformulation_fraction(window_days=7),
        "session_success_rate": session_success(window_days=7),
    }
```

Reference: [Pinecone — Evaluation Measures in Information Retrieval](https://www.pinecone.io/learn/offline-evaluation/)
