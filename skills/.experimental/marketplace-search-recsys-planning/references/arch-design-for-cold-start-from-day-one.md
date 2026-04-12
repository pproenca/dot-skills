---
title: Design for Cold Start from Day One
impact: CRITICAL
impactDescription: prevents new-listing discovery failure
tags: arch, cold-start, coverage
---

## Design for Cold Start from Day One

A marketplace accumulates new listings and new seekers continuously — cold start is not a bootstrap problem that goes away, it is a permanent operating condition. An architecture that relies entirely on historical interaction data produces a system that works well after twelve months and fails for every new provider and every new seeker forever. Wire cold-start strategies (metadata-based retrieval, popularity by segment, onboarding intent capture, exploration slots) into the architecture from the first design meeting, not as a retrofit when coverage collapses.

**Incorrect (interaction-only retrieval, new listings invisible):**

```python
def homefeed(seeker: Seeker) -> list[Listing]:
    hits = opensearch.search(
        index="listings",
        body={
            "query": {
                "function_score": {
                    "query": {"term": {"region": seeker.region}},
                    "script_score": {"script": "doc['booking_count'].value"},
                },
            },
            "size": 24,
        },
    )["hits"]["hits"]
    return hydrate(hits)
```

**Correct (cold-start reserved slots, segmented popularity for new seekers):**

```python
def homefeed(seeker: Seeker) -> list[Listing]:
    if seeker.lifetime_events < 5:
        return segment_popularity(seeker.region, seeker.declared_species, limit=24)

    warm = ranked_for_seeker(seeker, limit=20)
    fresh = newly_created_in_region(seeker.region, days=14, limit=4)
    return interleave(warm, fresh, fresh_ratio=0.2)
```

Reference: [Recommending for a Multi-Sided Marketplace: A Multi-Objective Hierarchical Approach](https://pubsonline.informs.org/doi/10.1287/mksc.2022.0238)
