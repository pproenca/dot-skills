---
title: Match Index-Time and Query-Time Analyzers
impact: HIGH
impactDescription: prevents tokenisation mismatch at query time
tags: index, analyzers, tokenisation
---

## Match Index-Time and Query-Time Analyzers

A field indexed with one analyzer and queried with another produces silent recall failures — tokens the indexer produced do not match tokens the query produced, and the listing is invisible to the seeker even though a human would obviously match them. The safe default is to use the same analyzer at both times by declaring it on the field; OpenSearch then uses it automatically for queries. Overriding the search-time analyzer is an expert move reserved for specific cases like autocomplete where index-time shingling and query-time prefix matching are intentional.

**Incorrect (no analyzer declared, default standard analyzer used with no stemming):**

```json
{
  "mappings": {
    "properties": {
      "description": { "type": "text" }
    }
  }
}
```

**Correct (analyzer declared on the field, applied at both index and query time):**

```json
{
  "mappings": {
    "properties": {
      "description": {
        "type": "text",
        "analyzer": "listing_text_en"
      }
    }
  },
  "settings": {
    "analysis": {
      "analyzer": {
        "listing_text_en": {
          "tokenizer": "standard",
          "filter": ["lowercase", "english_stop", "english_stemmer"]
        }
      },
      "filter": {
        "english_stop": { "type": "stop", "stopwords": "_english_" },
        "english_stemmer": { "type": "stemmer", "language": "english" }
      }
    }
  }
}
```

Reference: [OpenSearch Documentation — Text Analysis](https://docs.opensearch.org/latest/analyzers/)
