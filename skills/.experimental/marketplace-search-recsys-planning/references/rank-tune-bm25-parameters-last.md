---
title: Tune BM25 Parameters Last, Not First
impact: MEDIUM-HIGH
impactDescription: prevents premature micro-optimisation
tags: rank, bm25, parameters
---

## Tune BM25 Parameters Last, Not First

BM25 has two tunable parameters: `k1` (how much term frequency saturates) and `b` (how much document length normalises score). Tuning them from defaults produces small, noisy NDCG changes — rarely more than 1-2% — while other interventions (analyzer choice, synonyms, filters, rescoring) routinely deliver double-digit improvements. The rule is therefore to treat `k1` and `b` tuning as the last lever pulled, after every upstream layer has been audited and improved. Attempting to tune them before the index mapping is right produces noise, not signal.

**Incorrect (BM25 parameters tuned before analyzer and synonym work):**

```json
{
  "settings": {
    "index": {
      "similarity": {
        "default": {
          "type": "BM25",
          "k1": 1.8,
          "b": 0.3
        }
      }
    }
  }
}
```

**Correct (default BM25, focus on upstream levers with higher leverage):**

```json
{
  "settings": {
    "analysis": {
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

Reference: [Doug Turnbull & John Berryman — Relevant Search](https://www.manning.com/books/relevant-search)
