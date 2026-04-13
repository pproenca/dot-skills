---
title: Avoid Cross-Contamination When Users Switch Accounts
impact: MEDIUM
impactDescription: prevents household-device profile merging
tags: stitch, household, account-switch
---

## Avoid Cross-Contamination When Users Switch Accounts

Households commonly share a browser — a partner logs into the platform to plan a trip, logs out, the other partner logs in to plan a different trip. If the system stitches the anonymous session to both registered accounts, the second person inherits the first person's preferences and the ranker produces confusing recommendations for both. The fix is to clear the anonymous profile on every explicit account switch (logout followed by login), treat the new session as fresh, and rebuild the profile from the new visitor's interactions. This is a small hygiene rule that protects accuracy in a surprisingly common scenario.

**Incorrect (anonymous profile persists across logout and login, contaminating the next account):**

```python
def on_logout(request: Request) -> None:
    users.end_session(request.user.id)

def on_login(request: Request, user: User) -> None:
    anon_profile = profile_store.get(request.anon_session)
    profile_store.merge(anon_session=request.anon_session, user_id=user.id)
```

**Correct (explicit account switch clears anonymous state):**

```python
def on_logout(request: Request) -> None:
    users.end_session(request.user.id)
    request.clear_cookie("anon_session")
    response.set_cookie("anon_session", mint_signed_session_token())

def on_login(request: Request, user: User) -> None:
    if request.session_was_reset_this_request:
        return
    anon_profile = profile_store.get(request.anon_session)
    profile_store.merge(anon_session=request.anon_session, user_id=user.id)
```

Reference: [Snowplow — Users and Identity Stitching](https://docs.snowplow.io/docs/modeling-your-data/modeling-your-data-with-dbt/package-features/identity-stitching/)
