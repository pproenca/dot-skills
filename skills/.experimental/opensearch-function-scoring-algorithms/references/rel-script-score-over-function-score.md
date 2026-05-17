---
title: Use script_score Query, Not function_score, for Composition
impact: HIGH
impactDescription: 2-5x faster, supports caching and modern features
tags: rel, script-score, function-score, painless, composition
---

## Use script_score Query, Not function_score, for Composition

`function_score` is OpenSearch's legacy scoring composition mechanism — it works but treats each function as a separate scorer applied to the wrapped query, costs full document evaluation per function, and inflates query DSL with nested boilerplate. The newer `script_score` query lets you write a single Painless expression that has access to `_score`, doc values, and helper functions like `rank_feature.saturation` and `decayGeoExp`. It's faster (one pass), more compact, more debuggable, and the documented OpenSearch idiom going forward.

**Incorrect (`function_score` with 3 functions — verbose, slower):**

```json
{
  "query": {
    "function_score": {
      "query": { "match": { "description": "ocean loft" } },
      "functions": [
        { "field_value_factor": { "field": "rating", "factor": 0.5, "modifier": "log1p" } },
        { "gauss": { "location": { "origin": "38.71,-9.13", "scale": "5km", "decay": 0.5 } } },
        { "field_value_factor": { "field": "booking_count", "modifier": "log1p", "factor": 0.2 } }
      ],
      "score_mode": "sum",
      "boost_mode": "multiply"
    }
  }
}
```

**Correct (single `script_score` expression — one pass):**

```json
{
  "query": {
    "script_score": {
      "query": { "match": { "description": "ocean loft" } },
      "script": {
        "source": """
          double quality = Math.log1p(doc['rating'].value);
          double popularity = Math.log1p(doc['booking_count'].value);
          double distKm = doc['location'].arcDistance(params.lat, params.lon) / 1000;
          double geoDecay = Math.exp(-0.5 * Math.pow(distKm / 5.0, 2));
          return _score * (0.5 * quality + 0.2 * popularity) * geoDecay;
        """,
        "params": { "lat": 38.71, "lon": -9.13 }
      }
    }
  }
}
```

**Why this is faster:** `function_score` re-evaluates docs across multiple function scorers and combines them in a fixed combinator (`sum`/`multiply`/`min`/`max`). `script_score` evaluates all features in a single Painless pass, with the compiler hoisting common subexpressions. For complex compositions, this is measurably 2-5× faster at query time.

**When `function_score` is still appropriate:**
- Single decay function with no composition (`gauss`, `linear`, `exp`) — the DSL form is shorter.
- `random_score` for stable randomization with a seed — `script_score` requires recreating the deterministic random.
- `field_value_factor` with `min`/`max` modifiers used standalone.

**Painless safety:** Whitelist doc-value access; never write `params._source['field']` in `script_score` — `_source` is unloaded JSON, costing a full deserialize per document. Use `doc['field'].value`.

Reference: [OpenSearch script_score query](https://opensearch.org/docs/latest/query-dsl/specialized/script-score/) · [Painless ranking helpers](https://opensearch.org/docs/latest/api-reference/script-apis/exec-script/)
