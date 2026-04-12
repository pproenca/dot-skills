---
title: Audit Live Query Logs Before Designing
impact: CRITICAL
impactDescription: prevents designing for imagined users
tags: intent, audit, query-logs
---

## Audit Live Query Logs Before Designing

Design work based on what the team imagines users type is always wrong on the details. A one-hour audit of the actual query log surfaces the real distribution: how many queries contain a city, how many contain a date, how many are single-word, how many are mis-spelled, how many return zero results, and how many are reformulations of a previous query in the same session. That distribution should drive analyzer choice, synonym investment, autocomplete design and intent classifier boundaries — not whiteboard assumptions.

**Incorrect (designing an analyzer based on imagined queries):**

```python
settings = {
    "analysis": {
        "analyzer": {
            "listing_text": {
                "type": "standard",
                "stopwords": "_english_",
            },
        },
    },
}
opensearch.indices.create(index="listings", body={"settings": settings})
```

**Correct (audit the actual distribution, then design the analyzer):**

```python
def audit_query_log(days: int = 30) -> QueryLogReport:
    logs = query_log_store.fetch(window_days=days)
    return QueryLogReport(
        total=len(logs),
        has_city_token=sum(1 for q in logs if contains_city(q.raw)) / len(logs),
        has_date_token=sum(1 for q in logs if contains_date(q.raw)) / len(logs),
        avg_token_count=mean(len(q.raw.split()) for q in logs),
        zero_result_rate=sum(1 for q in logs if q.result_count == 0) / len(logs),
        reformulation_rate=reformulation_rate(logs),
        top_100_queries=top_n_by_count(logs, 100),
    )
```

Reference: [Doug Turnbull & John Berryman — Relevant Search](https://www.manning.com/books/relevant-search)
