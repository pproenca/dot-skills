---
title: Surface Mixed-Positive Reviews, Not Only Five-Star
impact: MEDIUM-HIGH
impactDescription: enables blemishing-effect credibility
tags: proof, reviews, credibility
---

## Surface Mixed-Positive Reviews, Not Only Five-Star

Nielsen Norman Group and the broader consumer-trust literature show that all-positive review sets trigger fake-review skepticism, and that credibility peaks when reviews include some mild criticism alongside praise (the "blemishing effect", Ein-Gar, Shiv, and Tormala 2012). Curating only five-star reviews is therefore counterproductive — it converts less well than showing a realistic mix. When selecting reviews to surface in preview or at the paywall, include at least one honest mild-criticism review alongside the praise, labelled as a real review. Visitors interpret the mild criticism as proof the praise is also real.

**Incorrect (curated five-star reviews only):**

```python
def display_reviews(sitter: Sitter) -> list[Review]:
    return sitter.reviews.filter(rating=5).order_by_recency().limit(3)
```

**Correct (mix of high rating and honest mild criticism):**

```python
def display_reviews(sitter: Sitter) -> list[Review]:
    all_reviews = sitter.reviews.all()
    top_rated = all_reviews.filter(rating=5).order_by_recency().limit(2)
    mixed = (
        all_reviews
        .filter(rating__gte=3, rating__lt=5)
        .filter(has_specific_criticism=True)
        .order_by_recency()
        .limit(1)
    )
    if not mixed:
        return top_rated.limit(3)
    return list(top_rated) + list(mixed)
```

Reference: [Ein-Gar, Shiv, Tormala — When Blemishing Leads to Blossoming: The Positive Effect of Negative Information (Journal of Consumer Research 2012)](https://academic.oup.com/jcr/article-abstract/38/5/846/1791985)
