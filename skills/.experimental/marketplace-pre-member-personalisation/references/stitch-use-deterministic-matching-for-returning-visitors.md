---
title: Use Deterministic Matching for Returning Visitors
impact: MEDIUM
impactDescription: prevents incorrect profile merges
tags: stitch, deterministic, identity
---

## Use Deterministic Matching for Returning Visitors

Identity resolution research (Treasure Data, Snowplow) consistently favours deterministic matching — hashed email, phone, social login — over probabilistic matching based on IP, fingerprint or timezone, because the false-positive cost of probabilistic matching is high. Merging two different people into one profile produces recommendations that are confusing for both, and unmerging is operationally expensive. Use probabilistic signals only as a hint that two sessions *might* be the same person, and only act on them when a deterministic signal confirms or when the downstream effect of a false merge is negligible.

**Incorrect (probabilistic merge based on IP and user agent):**

```python
def find_or_create_profile(anon_session: str, request: Request) -> Profile:
    ip = request.client_ip
    ua = request.headers.get("user-agent")
    existing = profile_store.find_by_fingerprint(ip=ip, user_agent=ua)
    if existing:
        profile_store.merge(anon_session, existing.id)
        return existing
    return profile_store.create(anon_session)
```

**Correct (deterministic signals win; probabilistic signals only hint):**

```python
def find_or_create_profile(anon_session: str, request: Request) -> Profile:
    email_hash = hash_if_present(request.cookies.get("hashed_email"))
    if email_hash:
        existing = profile_store.find_by_deterministic_key(email_hash)
        if existing:
            profile_store.link(anon_session=anon_session, user_id=existing.user_id)
            return existing

    return profile_store.get_or_create(anon_session)
```

Reference: [Treasure Data — Real-Time ID Stitching Overview](https://docs.treasuredata.com/products/customer-data-platform/real-time/real-time-id-stitching-overview)
