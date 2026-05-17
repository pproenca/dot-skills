---
title: Use Type Embeddings for Cold-Start Users and Listings
impact: HIGH
impactDescription: lifts cold-start ranking quality 12-18% NDCG
tags: pers, cold-start, type-embeddings, user-type, listing-type
---

## Use Type Embeddings for Cold-Start Users and Listings

ID-level embeddings (one vector per user, one per listing) require historical interaction data — they don't exist for brand-new users or listings. Type embeddings (also from Grbovic & Cheng 2018) solve cold-start by bucketing users and listings into types based on attributes (e.g., user_type = `{language, country, price_tier}`, listing_type = `{country, listing_size, price_tier, occupancy}`). The type embeddings are trained on the same session corpus but at a coarser grain — a new user/listing inherits the embedding for its type bucket on day one.

**Incorrect (no fallback for cold users — random ranking on day one):**

```python
def get_user_embedding(user_id):
    return user_vectors.get(user_id)  # None for new users → fallback to non-personalized
```

**Correct (type embeddings as cold-start fallback):**

```python
def user_type(user):
    # Bucketed attributes — finite cardinality
    return f"lang={user.language}|country={user.country}|price={bucket(user.avg_price)}"

def listing_type(listing):
    return (
        f"country={listing.country}|"
        f"size={listing.bedrooms}br|"
        f"price={bucket(listing.price)}|"
        f"occupancy={bucket(listing.occupancy_rate)}"
    )

# Train on session data — same skip-gram, types instead of IDs
session_types = [[user_type(u)] + [listing_type(l) for l in session] for u, session in data]
type_model = Word2Vec(session_types, vector_size=32, window=5, sg=1, negative=10)

def get_user_embedding(user):
    if user.id in user_vectors:
        return user_vectors[user.id]
    return type_model.wv[user_type(user)]  # cold-start fallback

def get_listing_embedding(listing):
    if listing.id in listing_vectors:
        return listing_vectors[listing.id]
    return type_model.wv[listing_type(listing)]  # cold-start fallback
```

**Index both ID and type embeddings, use both at query time:**

```json
POST /listings/_search
{
  "size": 200,
  "query": {
    "knn": {
      "embedding": {
        "vector": [/* user.id embedding OR user_type embedding if cold */],
        "k": 200
      }
    }
  }
}
```

**Bucketing strategy:** Bucket attributes coarse enough that every bucket has thousands of training examples, fine enough that types capture meaningful taste segments. For price, log-bucket (`<$50`, `$50-100`, `$100-200`, `$200-500`, `>$500`); for geography, country or major-city; for occupancy/size, integer counts up to a cap.

**Graceful hand-off ID → type:** Use type embeddings for the first N sessions of a new user, then blend (`0.7 * id_emb + 0.3 * type_emb`) for the next N, then pure ID. The blend prevents sudden ranking shifts that confuse users.

**The deeper marketplace lesson:** Type embeddings are a worked example of the universal cold-start pattern — derive a useful prior from observable attributes when there's no behavior yet. The same idea applies to user CTR estimates (use category CTR until you have personal CTR), pricing (use comparable listings' price until you have demand signal), and ranking quality scores (use completeness until you have engagement).

Reference: [Grbovic & Cheng — Real-time Personalization using Embeddings for Search Ranking at Airbnb (KDD 2018)](https://dl.acm.org/doi/10.1145/3219819.3219885)
