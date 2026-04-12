---
title: Use Language Analyzers for Language-Sensitive Fields
impact: HIGH
impactDescription: enables language-aware stemming and stopwords
tags: index, language, analyzers
---

## Use Language Analyzers for Language-Sensitive Fields

Stemming "sitters" to "sit" only works with a language-aware analyzer — the standard analyzer tokenises but does not stem, so "sitter" and "sitters" are treated as different terms and the ranker loses recall. OpenSearch ships language analyzers for 30+ languages (english, french, spanish, portuguese, german, and more) that apply language-specific stemming and stopwords. For a multi-language marketplace, the standard pattern is a per-language sub-field plus a language-detection processor on ingest so each document is indexed with the correct analyzer per language.

**Incorrect (standard analyzer on multi-language listing title — no stemming):**

```json
{
  "mappings": {
    "properties": {
      "title": { "type": "text", "analyzer": "standard" }
    }
  }
}
```

**Correct (per-language sub-fields with language-specific analyzers):**

```json
{
  "mappings": {
    "properties": {
      "title": {
        "type": "text",
        "analyzer": "english",
        "fields": {
          "fr": { "type": "text", "analyzer": "french" },
          "es": { "type": "text", "analyzer": "spanish" },
          "pt": { "type": "text", "analyzer": "portuguese" },
          "de": { "type": "text", "analyzer": "german" }
        }
      }
    }
  }
}
```

Reference: [OpenSearch Documentation — Language Analyzers](https://docs.opensearch.org/latest/analyzers/language-analyzers/index/)
