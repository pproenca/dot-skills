---
title: Tune BM25F Field Weights Before k1/b
impact: CRITICAL
impactDescription: 15-30% NDCG gain over single-field BM25
tags: rel, bm25f, multi-field, field-weights
---

## Tune BM25F Field Weights Before k1/b

A marketplace listing has structurally heterogeneous text fields: a short title (5-12 tokens), a long description (100-1000 tokens), and short tag-like amenity fields. Standard BM25 treats them as one bag of words; long descriptions dominate term frequency simply by being long. BM25F (Robertson & Zaragoza 2009) computes IDF once across the virtual combined field but weights term frequencies by field. In OpenSearch this is `combined_fields` or `multi_match` with explicit per-field boosts; the per-field weights are *the* tunable that moves the needle, far more than tweaking `k1`/`b`.

**Incorrect (single concatenated field — long descriptions dominate scoring):**

```json
{
  "query": {
    "match": {
      "all_text": "ocean view loft lisbon"
    }
  }
}
```

A listing whose 800-token description mentions "ocean" 6 times scores higher than one with "ocean view loft" as the title, despite the latter being a stronger match.

**Correct (BM25F-style with field weights tuned by domain):**

```json
{
  "query": {
    "combined_fields": {
      "query": "ocean view loft lisbon",
      "fields": [
        "title^4",
        "neighborhood^3",
        "amenities^2",
        "description^1"
      ],
      "operator": "and"
    }
  }
}
```

**Why `combined_fields` over `multi_match` with the same boosts:** `combined_fields` computes a single IDF across the virtual unified field — equivalent to BM25F semantics. Plain `multi_match: best_fields` picks one field's score; `multi_match: most_fields` sums per-field scores with each field's own IDF, which over-rewards rare tokens that happen to live in low-doc-count fields.

**Field-weight tuning method:**

1. Build a graded relevance set (~500 query-listing pairs scored 0-4).
2. Grid-search field weights on this set, measuring NDCG@10.
3. Re-tune when the document structure changes (added a new field, removed one).

Reference: [OpenSearch `combined_fields`](https://opensearch.org/docs/latest/query-dsl/full-text/combined-fields/) · [Robertson & Zaragoza — The Probabilistic Relevance Framework: BM25 and Beyond](https://www.staff.city.ac.uk/~sbrp622/papers/foundations_bm25_review.pdf)
