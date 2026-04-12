---
title: Treat No-Search as a First-Class Choice
impact: CRITICAL
impactDescription: prevents forcing retrieval where browse is correct
tags: intent, browse, navigation
---

## Treat No-Search as a First-Class Choice

Some surfaces do not need a search box, a ranker or a recommender at all — a curated category tree, a region carousel, or a "featured this week" list is often the right primitive when the user's intent is browse-without-query. Forcing a search-style retrieval into a browse context produces a system that is technically smarter but operationally worse: the user clicks fewer things and reformulates more. Treat "no search, just a hand-curated or rule-based list" as a legitimate design choice for surfaces where intent is unstructured.

**Incorrect (search-style retrieval powering a browse surface):**

```python
def browse_homepage(seeker: Seeker) -> list[Listing]:
    body = {
        "query": {
            "function_score": {
                "query": {"match_all": {}},
                "functions": [{"random_score": {}}],
            },
        },
        "size": 24,
    }
    return opensearch.search(index="listings", body=body)["hits"]["hits"]
```

**Correct (curated, rule-based list served from a content store):**

```python
def browse_homepage(seeker: Seeker) -> list[BrowseModule]:
    return [
        BrowseModule.hero_banner(curated.current_hero()),
        BrowseModule.region_carousel(
            title="Popular this week",
            listings=catalog.top_bookings_last_7_days(seeker.region, limit=12),
        ),
        BrowseModule.category_tree(curated.category_tree()),
        BrowseModule.editorial_collection(curated.editorial_of_the_week()),
    ]
```

Reference: [Eugene Yan — Improving Recommendation Systems and Search](https://eugeneyan.com/writing/recsys-llm/)
