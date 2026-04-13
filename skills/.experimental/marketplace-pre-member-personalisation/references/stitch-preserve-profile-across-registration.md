---
title: Preserve Inferred Profile Across the Registration Transition
impact: MEDIUM
impactDescription: prevents personalisation reset at signup
tags: stitch, registration, continuity
---

## Preserve Inferred Profile Across the Registration Transition

The moment an anonymous visitor registers is the worst time to reset the inferred profile — the system has just learned the most about them, and the registration event is the handshake that joins the anonymous token to a persistent identity. Losing the click history, the inferred role, the target destination and the progressive profile at exactly that moment forces the system to cold-start the registered account and gives the visitor an experience that feels dumber after signup than before. The fix is mechanical: copy the anonymous profile into the registered-user profile on signup, flag the provenance, and keep both linked for future stitching.

**Incorrect (registration creates a fresh user profile, anonymous session discarded):**

```python
def on_register(email: str, password: str, anon_session: str) -> User:
    user = users.create(email=email, password_hash=hash(password))
    return user
```

**Correct (anonymous profile carried over, provenance tracked):**

```python
def on_register(email: str, password: str, anon_session: str) -> User:
    anon_profile = profile_store.get(anon_session)
    user = users.create(
        email=email,
        password_hash=hash(password),
        inferred_role=anon_profile.get("inferred_role"),
        inferred_city=anon_profile.get("top_region"),
        inferred_pet_type=anon_profile.get("pet_type"),
        target_destinations=anon_profile.get("clicked_regions", []),
        bookmarked_listings=anon_profile.get("bookmarked", []),
        profile_provenance={
            "source": "anonymous_session_carryover",
            "anon_session": anon_session,
            "features_at_registration": anon_profile,
        },
    )
    profile_store.link(anon_session=anon_session, user_id=user.id)
    return user
```

Reference: [Mixpanel — Identifying Users](https://docs.mixpanel.com/docs/tracking-methods/id-management/identifying-users-simplified)
