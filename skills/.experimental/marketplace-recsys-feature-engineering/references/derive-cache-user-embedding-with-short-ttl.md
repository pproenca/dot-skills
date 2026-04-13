---
title: Cache the User Embedding with a Short TTL, Not Per-Request
impact: MEDIUM-HIGH
impactDescription: drops u2i latency from 80ms to 5ms per request
tags: derive, caching, user-embedding, ttl, latency
---

## Cache the User Embedding with a Short TTL, Not Per-Request

Recomputing the user tower on every homefeed request is wasteful — a sitter's profile and recent actions do not change between scrolls, and the user embedding is dominated by slow-changing features (wizard answers, history, preferences) with a small fast-moving contextual delta. Compute the user embedding at session start, cache it for 60-300 seconds keyed by session, and optionally update it incrementally as new actions arrive during the session. This drops per-request latency by an order of magnitude while preserving freshness.

**Incorrect (rebuilds the user vector every request):**

```python
def homefeed(sitter_id: str) -> list[Listing]:
    user_features = feature_store.get_online(sitter_id)  # 50ms
    user_vector = user_tower.encode(user_features)        # 30ms
    candidates = ann_index.search(user_vector, k=200)     # 5ms
    return rank(candidates)[:24]
    # 85ms per request, mostly in feature fetch + encode
```

**Correct (session-level cache with TTL):**

```python
USER_VECTOR_TTL_SECONDS = 180

def get_or_compute_user_vector(sitter_id: str, session_id: str) -> np.ndarray:
    cache_key = f"uvec:{session_id}:{sitter_id}"
    cached = redis.get(cache_key)
    if cached is not None:
        return np.frombuffer(cached, dtype=np.float32)

    user_features = feature_store.get_online(sitter_id)
    user_vector = user_tower.encode(user_features)
    redis.set(cache_key, user_vector.tobytes(), ex=USER_VECTOR_TTL_SECONDS)
    return user_vector

def homefeed(sitter_id: str, session_id: str) -> list[Listing]:
    user_vector = get_or_compute_user_vector(sitter_id, session_id)  # 1ms after first call
    candidates = ann_index.search(user_vector, k=200)                 # 5ms
    return rank(candidates)[:24]
```

Reference: [DoorDash — Building a Gigascale ML Feature Store with Redis](https://careersatdoordash.com/blog/building-a-gigascale-ml-feature-store-with-redis/)
