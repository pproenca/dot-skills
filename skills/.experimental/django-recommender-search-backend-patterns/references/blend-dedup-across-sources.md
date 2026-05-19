---
title: Dedup by Canonical ID Across All Sources
impact: HIGH
impactDescription: prevents duplicate items in the final ranking
tags: blend, dedup, canonical-id, recommender
---

## Dedup by Canonical ID Across All Sources

Personalize returns item_id=42. The affinity microservice returns the same item_id=42 from its own model. Databricks returns it too. Without dedup, the blended list shows item 42 three times — once per source contributing — and the user sees the same product as positions 1, 4, and 7. Worse, if the items use slightly different ID formats across sources (`"42"` vs `42` vs `"item_42"`), naïve dedup misses them.

Pick a canonical ID format, normalize every source's outputs to it, then dedup keeping the highest-scoring instance.

**Incorrect (no dedup — same item appears multiple times):**

```python
def blend(personalize, affinity, databricks):
    combined = personalize + affinity + databricks
    # Same item from 3 sources → appears 3 times in the result
    return sorted(combined, key=lambda x: x["score"], reverse=True)
```

**Correct (canonicalize IDs, dedup keeping max score):**

```python
def canonical_id(item: dict, source: str) -> str:
    """Normalize disparate ID formats to a canonical form."""
    raw = item.get("id") or item.get("item_id") or item.get("productId") or ""
    # Strip source prefixes (e.g., Personalize sometimes returns "item_42")
    if isinstance(raw, str) and raw.startswith("item_"):
        raw = raw[5:]
    return str(raw).strip()

def blend_dedup(sources: dict[str, list[dict]]) -> list[dict]:
    """Blend with dedup; keep highest score across sources for the same item."""
    by_id: dict[str, dict] = {}
    for source_name, items in sources.items():
        for item in items:
            cid = canonical_id(item, source_name)
            if not cid:
                continue
            if cid not in by_id or item["score"] > by_id[cid]["score"]:
                by_id[cid] = {
                    "id": cid,
                    "score": item["score"],
                    "primary_source": source_name,
                    "all_sources": [source_name],
                }
            else:
                by_id[cid]["all_sources"].append(source_name)
    return sorted(by_id.values(), key=lambda x: x["score"], reverse=True)
```

**Alternative: bonus for cross-source corroboration:**

If an item appears in multiple recommenders, that's evidence of relevance. Boost it:

```python
def blend_with_corroboration_bonus(sources: dict[str, list[dict]]) -> list[dict]:
    by_id: dict[str, dict] = {}
    for source_name, items in sources.items():
        for item in items:
            cid = canonical_id(item, source_name)
            if cid not in by_id:
                by_id[cid] = {"id": cid, "score": 0, "sources": []}
            by_id[cid]["score"] = max(by_id[cid]["score"], item["score"])
            by_id[cid]["sources"].append(source_name)

    # Bonus for multi-source items
    for item in by_id.values():
        # 1.0x if 1 source, 1.15x if 2 sources, 1.3x if 3+ sources
        multiplier = 1.0 + 0.15 * (len(item["sources"]) - 1)
        item["score"] *= multiplier

    return sorted(by_id.values(), key=lambda x: x["score"], reverse=True)
```

**Dedup with deterministic tie-breaking:**

When two sources return the same item with the same score (after corroboration bonus), the order between them matters for stable pagination:

```python
return sorted(
    by_id.values(),
    key=lambda x: (-x["score"], x["id"]),  # secondary: alphabetical id (deterministic)
)
```

**Handle variant items (sizes/colors of the same product):**

If "iPhone 15 Pro 128GB Black" and "iPhone 15 Pro 256GB Black" should be treated as the same product (deduped) at recommendation time but split at the variant detail page, dedup on the parent product ID:

```python
def canonical_id(item: dict, source: str) -> str:
    # Use parent_product_id when available, otherwise the variant id
    return str(item.get("parent_product_id") or item["id"])
```

**Cross-source ID mapping when IDs aren't aligned:**

If Personalize uses Stock-Keeping-Unit IDs and Databricks uses internal numeric IDs and OpenSearch uses URL slugs, you need a mapping layer:

```python
# Lookup table — typically maintained as a materialized view or Redis hash
ID_MAP = await load_id_mapping()  # {"sku-A": "internal-42", "slug-headphones": "internal-42"}

def canonical_id(item: dict, source: str) -> str:
    raw = str(item["id"])
    if source == "personalize":
        return ID_MAP.get(raw, raw)
    if source == "databricks":
        return raw  # already internal
    if source == "opensearch":
        return ID_MAP.get(raw, raw)
    return raw
```

**Symptom of missing dedup:**
- Same product appears multiple times in a single response
- Pagination shows the same items on consecutive pages
- "We got 20 recommendations but they're only 12 unique products"

**Test for canonical ID coverage:**

```python
def test_canonical_id_normalization():
    cases = [
        ({"id": 42}, "personalize", "42"),
        ({"id": "42"}, "databricks", "42"),
        ({"id": "item_42"}, "personalize", "42"),
        ({"productId": 42}, "affinity", "42"),
    ]
    for item, source, expected in cases:
        assert canonical_id(item, source) == expected
```

Reference: [Recsys deduplication patterns](https://eugeneyan.com/writing/system-design-for-discovery/)
