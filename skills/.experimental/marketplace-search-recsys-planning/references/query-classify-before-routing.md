---
title: Classify Queries Before Routing
impact: MEDIUM-HIGH
impactDescription: enables intent-aware routing
tags: query, classification, routing
---

## Classify Queries Before Routing

Intent classification turns a raw query string into a structured record — `{type: transactional, region: "london", date_range: next_week, species: dog}` — that downstream retrieval and ranking can use deliberately. Without classification, the system treats every query the same and downstream code tries to reverse-engineer intent from the string repeatedly. Build the classifier as a single-pass component at the top of the request pipeline; it can be rule-based at the start and replaced with a model later without changing the downstream code.

**Incorrect (no classification, downstream code re-parses the query repeatedly):**

```python
def search(query: str, seeker: Seeker) -> list[Listing]:
    has_date = re.search(r"\b(next|this|tomorrow|\d{1,2}[/-]\d{1,2})\b", query)
    has_city = any(city in query.lower() for city in KNOWN_CITIES)
    if has_date and has_city:
        return transactional_search(query, seeker)
    if has_city:
        return exploratory_search(query, seeker)
    return default_search(query, seeker)
```

**Correct (single-pass classifier returns a structured query record):**

```python
def classify(raw: str) -> ClassifiedQuery:
    normalised = normalise_query(raw)
    return ClassifiedQuery(
        raw=raw,
        normalised=normalised,
        intent=rule_based_intent(normalised),
        entities=extract_entities(normalised),
        date_range=extract_date_range(normalised),
        species=extract_species(normalised),
    )

def search(raw: str, seeker: Seeker) -> list[Listing]:
    classified = classify(raw)
    return router.route(classified, seeker)
```

Reference: [Eugene Yan — Improving Recommendation Systems and Search](https://eugeneyan.com/writing/recsys-llm/)
