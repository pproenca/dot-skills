---
title: Normalise Queries Before Anything Else
impact: MEDIUM-HIGH
impactDescription: prevents unicode and whitespace misses
tags: query, normalisation, preprocessing
---

## Normalise Queries Before Anything Else

Raw user queries arrive with trailing whitespace, smart-quote characters, mixed case, zero-width Unicode, mis-entered diacritics and paste artefacts — any of which can cause a match against an index that has the same content in a canonical form to silently miss. Normalising the query at the entry point (lowercase, trim, collapse whitespace, NFKC Unicode normalization, strip zero-width characters) happens before parsing, classification, retrieval or any logging, so every downstream stage sees a canonical string.

**Incorrect (raw query passed directly to OpenSearch):**

```python
def search(raw_query: str, seeker: Seeker) -> list[Listing]:
    return opensearch.search(
        index="listings",
        body={"query": {"match": {"title": raw_query}}, "size": 24},
    )["hits"]["hits"]
```

**Correct (normalisation pipeline runs before retrieval and logging):**

```python
def normalise_query(raw: str) -> str:
    normalised = unicodedata.normalize("NFKC", raw)
    normalised = "".join(c for c in normalised if not is_zero_width(c))
    normalised = normalised.strip().lower()
    normalised = re.sub(r"\s+", " ", normalised)
    return normalised

def search(raw_query: str, seeker: Seeker) -> list[Listing]:
    query = normalise_query(raw_query)
    log_query_event(raw=raw_query, normalised=query, seeker_id=seeker.id)
    return opensearch.search(
        index="listings",
        body={"query": {"match": {"title": query}}, "size": 24},
    )["hits"]["hits"]
```

Reference: [Doug Turnbull & John Berryman — Relevant Search](https://www.manning.com/books/relevant-search)
