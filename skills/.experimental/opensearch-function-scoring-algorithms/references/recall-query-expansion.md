---
title: Apply Synonym Expansion at Index Time for Recall, Query Time for Precision
impact: MEDIUM-HIGH
impactDescription: prevents O(synonyms × terms) query blowup
tags: recall, synonyms, query-expansion, analyzer, index-time
---

## Apply Synonym Expansion at Index Time for Recall, Query Time for Precision

Synonym expansion at query time multiplies term count (a 4-term query with 5-synonym-per-term expansion becomes 20 terms across `should` clauses), inflating query latency and distorting BM25 IDF — rare-synonym terms dominate scoring. Index-time expansion stores synonyms in the postings, giving better recall and stable IDF, at the cost of needing reindex on dictionary changes. For marketplaces with stable synonym sets (location aliases, amenity terms), index-time is the right default.

**Incorrect (query-time only, distorts IDF and inflates latency):**

```json
PUT /listings
{
  "settings": {
    "analysis": {
      "filter": {
        "synonyms": {
          "type": "synonym",
          "synonyms": ["loft, studio, flat", "ocean, sea, beach"]
        }
      },
      "analyzer": {
        "search_synonyms": {
          "tokenizer": "standard",
          "filter": ["lowercase", "synonyms"]
        }
      }
    }
  },
  "mappings": {
    "properties": {
      "title": { "type": "text", "analyzer": "standard", "search_analyzer": "search_synonyms" }
    }
  }
}
```

**Correct (index-time expansion writes all synonyms to postings):**

```json
PUT /listings
{
  "settings": {
    "analysis": {
      "filter": {
        "synonyms": {
          "type": "synonym",
          "synonyms": ["loft, studio, flat", "ocean, sea, beach"],
          "expand": true
        }
      },
      "analyzer": {
        "index_with_synonyms": {
          "tokenizer": "standard",
          "filter": ["lowercase", "synonyms"]
        }
      }
    }
  },
  "mappings": {
    "properties": {
      "title": { "type": "text", "analyzer": "index_with_synonyms" }
    }
  }
}
```

**When to use query-time synonyms anyway:**
- Synonym list changes frequently (cannot tolerate reindex).
- Bidirectional vs directional synonyms differ per query (e.g., `iphone => apple iphone` should not expand at index time).
- A/B testing synonym dictionaries — need to swap rapidly.

**The deeper marketplace lesson:** Synonyms are recall — they belong at retrieval. Tie-breaking and precision belong at scoring, where embeddings already capture paraphrase relationships. Don't paper over weak embeddings with query-time synonym hacks.

Reference: [OpenSearch synonym token filter](https://opensearch.org/docs/latest/analyzers/token-filters/synonym/) · [Elastic synonym graphs vs synonyms](https://www.elastic.co/guide/en/elasticsearch/reference/current/analysis-synonym-graph-tokenfilter.html)
