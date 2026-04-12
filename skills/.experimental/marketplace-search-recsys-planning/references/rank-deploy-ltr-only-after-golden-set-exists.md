---
title: Deploy Learning to Rank Only After Golden Set and Judgments Exist
impact: MEDIUM-HIGH
impactDescription: prevents premature LTR complexity
tags: rank, ltr, golden-set
---

## Deploy Learning to Rank Only After Golden Set and Judgments Exist

Learning to Rank (LTR) is a supervised model trained on query-document pairs with relevance judgments — so it literally cannot work without a labelled dataset. Teams that deploy LTR before building a golden set of judgments end up training on click-through data alone, inheriting all the selection bias of the current production ranker, and producing a model that is subtly worse than the heuristic it replaces. The correct sequence is: golden set → offline evaluation → heuristic ranker tuning → LTR only when the gap to heuristic is worth the operational cost.

**Incorrect (LTR deployed with no golden set, trained on click logs only):**

```python
def train_ltr_model() -> None:
    clicks = click_log.fetch(window_days=30)
    features = extract_features_from_clicks(clicks)
    model = train_xgboost_ranker(features)
    deploy_to_opensearch(model)
```

**Correct (golden-set offline evaluation gates the LTR deployment):**

```python
def train_ltr_model() -> None:
    golden = golden_set.load_version("v3.2-frozen-2026-03")
    if len(golden.judgments) < 1_000:
        logger.info(f"Golden set too small ({len(golden.judgments)} judgments)")
        return

    features = extract_features_from_golden_set(golden)
    model = train_xgboost_ranker(features)

    offline = evaluate_against_golden_set(model, golden)
    heuristic = evaluate_heuristic_against_golden_set(golden)
    if offline.ndcg_at_10 < heuristic.ndcg_at_10 * 1.03:
        logger.info(f"LTR NDCG {offline.ndcg_at_10} does not justify complexity")
        return

    deploy_to_opensearch(model)
```

Reference: [AWS OpenSearch Documentation — Learning to Rank](https://docs.aws.amazon.com/opensearch-service/latest/developerguide/learning-to-rank.html)
