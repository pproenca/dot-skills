---
title: Cap Impressions Per Host with Max-Per-Group Constraint
impact: MEDIUM-HIGH
impactDescription: prevents single-host page domination
tags: div, max-per-host, collapse, group, fairness
---

## Cap Impressions Per Host with Max-Per-Group Constraint

A prolific host with 50 listings in Lisbon can occupy 8 of the top-10 slots — relevance-correct but UX-terrible. The user sees one host's brand five times and feels the marketplace is small. OpenSearch's `collapse` query collapses results by a field (e.g., `host_id`) keeping only the top N per group; a per-page hard cap (2-3 listings per host max) is the standard marketplace fix. Airbnb has documented this pattern in their diversity research.

**Incorrect (no per-host cap — single host dominates top page):**

```json
{
  "size": 20,
  "query": { "match": { "city": "lisbon" } },
  "sort": [{ "_score": "desc" }]
}
```

Top-20 might contain 8 listings from one host who happens to have well-optimized titles.

**Correct (collapse by host_id, top-2 per host):**

```json
{
  "size": 20,
  "query": { "match": { "city": "lisbon" } },
  "collapse": {
    "field": "host_id",
    "inner_hits": {
      "name": "more_from_host",
      "size": 1,
      "sort": [{ "_score": "desc" }]
    }
  }
}
```

This returns top-20 distinct hosts (one listing per host) with `inner_hits` carrying the second-best from each host for "more from this host" UI surfacing.

**For top-2 per host (not top-1), use script-based re-ranking:**

```python
def per_host_cap(ranked, max_per_host=2):
    host_count = collections.Counter()
    capped = []
    overflow = []
    for item in ranked:
        if host_count[item.host_id] < max_per_host:
            capped.append(item)
            host_count[item.host_id] += 1
        else:
            overflow.append(item)
    # Append overflow at the bottom to fill page if needed
    return capped + overflow[:max(0, len(ranked) - len(capped))]

candidates = opensearch.search(...)
final_page = per_host_cap(candidates, max_per_host=2)
```

**Why a hard cap is the right tool here (and MMR isn't enough):** MMR uses similarity in embedding space to deduplicate — but two listings from the same host can have very different embeddings (different photos, different titles, different prices) while still being from the same host. The "same host" signal is structural, not semantic; you need a structural constraint to enforce it.

**Tune by surface:**

| Surface | Recommended max-per-host |
|---------|--------------------------|
| Top-of-page search results | 1-2 (strict diversity) |
| Below-fold infinite scroll | 3-5 (looser) |
| "More from this host" carousel | No cap (it's the point) |
| Map view | 1 (one pin per host per region) |

**Combine with category diversity (`div-category-diversity`):** Cap per host AND per category in the top window. Both are independent dimensions of "user perceives the marketplace as diverse."

**Don't collapse on listing_id by accident:** `collapse: {field: "listing_id"}` collapses identical listings into one result — useful for de-duplicating but unrelated to per-host diversity.

**When NOT to cap:** When the user has explicitly searched for a specific host (`host:"Some Inn Lisbon"`), suspend the cap — they want to see that host's full catalog.

Reference: [OpenSearch collapse](https://opensearch.org/docs/latest/search-plugins/searching-data/collapse-search/) · [Airbnb — Learning to Rank Diversely (arXiv 2210.07774)](https://arxiv.org/pdf/2210.07774)
