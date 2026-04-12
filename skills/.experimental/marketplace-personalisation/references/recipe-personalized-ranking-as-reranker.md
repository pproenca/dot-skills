---
title: Use PERSONALIZED_RANKING_v2 as a Re-ranker, Not a Generator
impact: MEDIUM-HIGH
impactDescription: enables business-rule compatible ranking
tags: recipe, personalized-ranking, reranker
---

## Use PERSONALIZED_RANKING_v2 as a Re-ranker, Not a Generator

PERSONALIZED_RANKING takes a caller-supplied list of items and returns it sorted by relevance to the user — it is a re-ranker, not a candidate generator. That matters because marketplace ranking must start from a set that already respects business rules (geography, availability, legal compliance, provider preferences), so the candidate-generation step belongs to the application and the re-ranking step belongs to Personalize. Trying to use it as a candidate generator produces empty responses — it has no way to retrieve items that were never supplied.

**Incorrect (no input list — recipe treated as a candidate generator):**

```python
response = personalize_runtime.get_personalized_ranking(
    campaignArn=PERSONALIZED_RANKING_CAMPAIGN_ARN,
    userId=seeker.id,
    inputList=[],
)
```

**Correct (application retrieves the feasible set, recipe re-ranks it):**

```python
def search(seeker: Seeker, query: SearchQuery) -> list[Listing]:
    feasible = catalog.search(
        region=query.region,
        date_range=query.date_range,
        accepts_species=seeker.pet_species,
    )
    if not feasible:
        return []

    response = personalize_runtime.get_personalized_ranking(
        campaignArn=PERSONALIZED_RANKING_CAMPAIGN_ARN,
        userId=seeker.id,
        inputList=[listing.id for listing in feasible],
    )
    ranked_ids = [item["itemId"] for item in response["personalizedRanking"]]
    return [catalog.get(item_id) for item_id in ranked_ids]
```

Reference: [AWS Personalize — Choosing a Recipe](https://docs.aws.amazon.com/personalize/latest/dg/working-with-predefined-recipes.html)
