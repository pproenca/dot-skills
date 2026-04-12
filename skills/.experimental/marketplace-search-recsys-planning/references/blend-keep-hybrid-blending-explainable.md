---
title: Keep Hybrid Blending Explainable
impact: MEDIUM
impactDescription: enables blending debugging and tuning
tags: blend, explainability, debugging
---

## Keep Hybrid Blending Explainable

A blended response where the top-3 listings are from different retrieval primitives needs to be debuggable: which primitive contributed each listing, what was its raw score, what was its normalised score, what was the final weighted score. Attaching a small trace object to each result that records the primitive source, the raw score, and the final weighted contribution is cheap (single-digit extra bytes per listing) and saves hours of blending debugging later. The trace is also invaluable for ranking tuners during relevance work.

**Incorrect (blended response returns only the final ordered list):**

```python
def blend_response(search_hits, rec_hits) -> list[Listing]:
    return blended_sort(search_hits, rec_hits)[:24]
```

**Correct (each result carries a blending trace for debugging and tuning):**

```python
def blend_response(search_hits, rec_hits) -> list[BlendedListing]:
    blended = blended_sort(search_hits, rec_hits)
    return [
        BlendedListing(
            listing=b.listing,
            final_score=b.final_score,
            trace=BlendTrace(
                search_raw=b.search_raw_score,
                search_norm=b.search_normalised,
                rec_raw=b.rec_raw_score,
                rec_norm=b.rec_normalised,
                search_weight=b.search_weight,
                primitive_source=b.primary_primitive,
            ),
        )
        for b in blended[:24]
    ]
```

Reference: [Eugene Yan — Improving Recommendation Systems and Search](https://eugeneyan.com/writing/recsys-llm/)
