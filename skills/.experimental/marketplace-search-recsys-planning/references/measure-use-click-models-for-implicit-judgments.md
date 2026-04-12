---
title: Use Click Models for Implicit Relevance Judgments
impact: MEDIUM
impactDescription: enables scalable judgment collection
tags: measure, click-models, judgments
---

## Use Click Models for Implicit Relevance Judgments

Human-graded relevance judgments are the gold standard, but they are slow, expensive and cover only a fraction of queries. Click models (Cascade, Dependent Click Model, Position-Based Model) infer implicit relevance judgments from click-through data by modelling the probability a seeker saw each result, clicked each result, and found it relevant — correcting for position bias in the process. A click-model-derived judgment set is not as clean as a human-judged one, but it scales to every query in the log and stays current automatically, which makes it the right primary source for ongoing offline evaluation.

**Incorrect (raw CTR used as relevance proxy, position-biased):**

```python
def infer_relevance_from_clicks(clicks: list[ClickEvent]) -> dict[str, float]:
    grouped = defaultdict(lambda: {"impressions": 0, "clicks": 0})
    for click in clicks:
        grouped[click.listing_id]["impressions"] += 1
        if click.was_clicked:
            grouped[click.listing_id]["clicks"] += 1
    return {
        listing_id: stats["clicks"] / stats["impressions"]
        for listing_id, stats in grouped.items()
        if stats["impressions"] > 0
    }
```

**Correct (position-based click model corrects for slot bias):**

```python
def infer_relevance_position_based(clicks: list[ClickEvent]) -> dict[str, float]:
    position_ctrs = learn_position_ctrs(clicks)
    relevance = {}
    for click in clicks:
        position_prior = position_ctrs[click.slot]
        examine_prob = position_prior
        relevance[click.listing_id] = relevance.get(click.listing_id, 0.0)
        if click.was_clicked:
            relevance[click.listing_id] += 1.0 / max(examine_prob, 0.01)
    return normalise_to_unit(relevance)
```

Reference: [Pinecone — Evaluation Measures in Information Retrieval](https://www.pinecone.io/learn/offline-evaluation/)
