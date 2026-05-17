---
title: Train Listing Embeddings from Booking-Session Co-occurrence
impact: HIGH
impactDescription: 21% NDCG@10 lift in Airbnb production (KDD 2018)
tags: pers, embeddings, word2vec, sessions, airbnb
---

## Train Listing Embeddings from Booking-Session Co-occurrence

The Airbnb listing-embedding approach (Grbovic & Cheng, KDD 2018 Best Paper) treats each user's search session as a "sentence" and each viewed/clicked listing as a "word," then trains skip-gram embeddings with negative sampling. Listings that co-occur in sessions land near each other in embedding space, capturing taste similarity without any explicit feature engineering. The booked listing is added as a global positive in every session — this is the key trick that anchors embeddings around conversion, not just clicks. Reported result: 21% relative NDCG@10 lift over the baseline.

**Incorrect (item embeddings from content alone — misses substitutability):**

```python
# Content embedding — text/image features only
listing_vector = encode([listing.title, listing.description, listing.amenities])
```

This captures "looks similar in description" but not "users who consider X also consider Y."

**Correct (session-based skip-gram with booked listing as global positive):**

```python
import gensim
# session_data: list of lists, each inner list is the listing_ids
#               a user viewed in a search session (chronological)
# booked_id_per_session: the listing the user ultimately booked

from gensim.models.word2vec import Word2Vec

# Inject booked listing into every window as a global positive
augmented_sessions = []
for session, booked in zip(session_data, booked_id_per_session):
    aug = []
    for listing_id in session:
        aug.extend([listing_id, booked])  # interleave booked
    augmented_sessions.append(aug)

model = Word2Vec(
    augmented_sessions,
    vector_size=32,
    window=5,
    sg=1,             # skip-gram
    negative=10,      # negative sampling
    epochs=10,
    min_count=10
)

# Persist for indexing
for listing_id in model.wv.key_to_index:
    vec = model.wv[listing_id].tolist()
    opensearch.update(
        index="listings",
        id=listing_id,
        body={"doc": {"session_embedding": vec}}
    )
```

**Index as `knn_vector`:**

```json
PUT /listings/_mapping
{
  "properties": {
    "session_embedding": {
      "type": "knn_vector",
      "dimension": 32,
      "method": { "name": "hnsw", "engine": "lucene" }
    }
  }
}
```

**Use for similar-listing recommendations and personalization:**

```json
POST /listings/_search
{
  "size": 20,
  "query": {
    "knn": {
      "session_embedding": {
        "vector": [/* embedding of the listing the user is viewing */],
        "k": 20
      }
    }
  }
}
```

**Why the "global booked-listing positive" matters:** Without it, the embedding captures "users who view X also view Y" — pure substitutability, which is weakly correlated with conversion. With the booked listing forced into every context window, embeddings shift to capture "users who book X also consider Y" — a much stronger signal for conversion-driven ranking.

**Re-train cadence:** Daily for active marketplaces. Embeddings drift as supply/demand patterns shift; weekly retraining is the safe minimum.

Reference: [Grbovic & Cheng — Real-time Personalization using Embeddings for Search Ranking at Airbnb (KDD 2018 Best Paper)](https://dl.acm.org/doi/10.1145/3219819.3219885) · [Airbnb Engineering — Listing Embeddings in Search Ranking](https://medium.com/airbnb-engineering/listing-embeddings-for-similar-listing-recommendations-and-real-time-personalization-in-search-601172f7603e)
