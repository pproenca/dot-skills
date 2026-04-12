---
title: Curate Synonyms by Domain Intent
impact: MEDIUM-HIGH
impactDescription: enables domain-specific recall
tags: query, synonyms, domain
---

## Curate Synonyms by Domain Intent

Generic synonym lists (WordNet, thesauri) match vocabulary but not domain intent — they expand "dog" to "puppy, pooch, canine" which is fine, but miss "sitter ↔ carer ↔ walker ↔ minder" which is exactly what the marketplace needs. Domain synonyms must be curated by someone who understands the product vocabulary, versioned alongside the code, and grown from real zero-result query logs. They belong in an OpenSearch synonym file or synonym graph filter, loaded at index time for bidirectional expansion.

**Incorrect (no synonyms — query "dog carer" misses "dog sitter" listings):**

```json
{
  "settings": {
    "analysis": {
      "analyzer": {
        "listing_text": {
          "tokenizer": "standard",
          "filter": ["lowercase", "english_stop", "english_stemmer"]
        }
      }
    }
  }
}
```

**Correct (curated domain synonyms from zero-result query analysis):**

```json
{
  "settings": {
    "analysis": {
      "filter": {
        "marketplace_synonyms": {
          "type": "synonym_graph",
          "synonyms": [
            "sitter, carer, walker, minder, host",
            "stay, visit, booking, trip",
            "dog, puppy, pooch, canine",
            "cat, kitten, feline"
          ]
        }
      },
      "analyzer": {
        "listing_text": {
          "tokenizer": "standard",
          "filter": ["lowercase", "english_stop", "marketplace_synonyms", "english_stemmer"]
        }
      }
    }
  }
}
```

Reference: [OpenSearch Documentation — Creating a Custom Analyzer](https://docs.opensearch.org/latest/analyzers/custom-analyzer/)
