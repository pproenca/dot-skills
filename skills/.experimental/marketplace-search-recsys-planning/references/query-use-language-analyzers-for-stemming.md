---
title: Use Language Analyzers for Stemming and Stopwords
impact: MEDIUM-HIGH
impactDescription: enables stemming and stopword removal
tags: query, analyzers, stemming
---

## Use Language Analyzers for Stemming and Stopwords

A query for "dog sitters in london" searched against a standard analyzer treats "sitters" as an entirely different token than "sitter" — zero recall against a listing titled "Dog sitter". A language analyzer (english, french, spanish) applies stemming at index time and query time so "sitters" and "sitter" map to the same stem, and also strips stopwords like "in" and "the" so they do not pollute scoring. This single setting change is often responsible for double-digit recall improvements on a new project.

**Incorrect (standard analyzer — no stemming, no stopwords):**

```json
{
  "query": {
    "match": {
      "title": {
        "query": "dog sitters in london",
        "analyzer": "standard"
      }
    }
  }
}
```

**Correct (english analyzer — stems and strips stopwords):**

```json
{
  "query": {
    "match": {
      "title": {
        "query": "dog sitters in london",
        "analyzer": "english"
      }
    }
  }
}
```

Reference: [OpenSearch Documentation — English Analyzer](https://docs.opensearch.org/latest/analyzers/language-analyzers/english/)
