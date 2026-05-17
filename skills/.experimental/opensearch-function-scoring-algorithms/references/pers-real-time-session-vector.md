---
title: Update Session Vector in Real-Time from Click Events
impact: HIGH
impactDescription: 3-5% session conversion lift vs static user vector
tags: pers, real-time, session, embedding, exponential-decay
---

## Update Session Vector in Real-Time from Click Events

A user's "tasted preferences" change within a session — they start broad, narrow as they click, and a within-session vector captures this trajectory in a way a static user-level embedding cannot. Maintain a session vector as an exponentially-decayed weighted average of clicked-listing embeddings, push it to the search service per-request, and use it as the kNN probe. Airbnb (Grbovic & Cheng 2018) and Pinterest (PinnerSage, KDD 2020) both report material lifts from real-time session signals over offline-only user vectors.

**Incorrect (using offline-batched user vector that's hours stale):**

```python
# User vector recomputed nightly — does not reflect current session intent
user_vector = batch_user_embedding(user_id)
```

**Correct (real-time session vector, exponentially decayed):**

```python
class SessionEmbedding:
    """In-memory session state; persist to Redis keyed by session_id."""
    def __init__(self, dim=32, decay=0.7):
        self.vec = np.zeros(dim)
        self.weight_sum = 0.0
        self.decay = decay  # per-event decay (older events weigh less)

    def update(self, listing_id):
        listing_vec = listing_embeddings[listing_id]   # cached lookup
        self.vec = self.decay * self.vec + listing_vec
        self.weight_sum = self.decay * self.weight_sum + 1.0

    def current(self):
        if self.weight_sum == 0:
            return None
        return (self.vec / self.weight_sum).tolist()
```

```python
# In the search request handler:
session_vec = SessionEmbedding.load(session_id)
on_click_event = lambda lid: session_vec.update(lid)  # wire to event stream

probe = session_vec.current() or user_long_term_vector(user_id) or type_vector(user)

opensearch.search(index="listings", body={
    "query": {
        "knn": {"embedding": {"vector": probe, "k": 200}}
    }
})
```

**Decay calibration:**

| `decay` | Effective window | When to use |
|---------|------------------|-------------|
| 0.95 | ~20 recent events | Long browsing sessions (e.g., accommodation) |
| 0.7  | ~3-5 recent events | Short purchase intent (e.g., food delivery) |
| 0.3  | Last 1-2 events | Highly transactional, drift-prone |

**Negative signals too:** Push not just clicks but skips (impressions without click) into a *negative* session vector; combine as `probe = positive_vec - 0.3 * negative_vec`. This captures "user is seeing many lofts but skipping them" and shifts the probe away from lofts.

**Latency budget:** Reading session vector from Redis + sending in the search request should fit in <5ms. If your event bus has lag, your "real-time" vector is stale-real-time; design for that, e.g. only accept events <500ms old.

**Why this matters more than offline personalization:** Offline embeddings encode "what kind of user are you" (slow-changing). Session vectors encode "what are you doing right now" (fast-changing). Both matter; session signal dominates for short, high-intent sessions.

Reference: [Grbovic & Cheng — Real-time Personalization using Embeddings (KDD 2018)](https://dl.acm.org/doi/10.1145/3219819.3219885) · [Pinterest — PinnerSage Multi-Modal User Embedding](https://medium.com/pinterest-engineering/pinnersage-multi-modal-user-embedding-framework-for-recommendations-at-pinterest-bfd116b49475)
