---
title: Mint Anonymous Session Tokens from the First Request
impact: CRITICAL
impactDescription: enables session-level personalisation without login
tags: signal, session, anonymous-id
---

## Mint Anonymous Session Tokens from the First Request

Every anonymous visitor needs a stable token the moment they hit the first page, before any decision to register is made. Without it, the system cannot join page views, clicks, scrolls and dwell events into a single session profile, and cannot stitch the anonymous session to a registered account when the visitor signs up later. The token is a first-party cookie or localStorage value minted server-side on the first request, signed to prevent tampering, rotated on sensitive boundaries, and preserved for the life of the browser until a real identity replaces it.

**Incorrect (session ID only minted after registration):**

```python
def track_page_view(request: Request, user: User | None) -> None:
    if user is None:
        return  # anonymous visitors are invisible
    event_log.put(
        user_id=user.id,
        event_type="page_view",
        path=request.url.pathname,
    )
```

**Correct (anonymous session token minted on first request, all events joined by it):**

```python
def track_page_view(request: Request) -> Response:
    anon_session = request.cookies.get("anon_session")
    if anon_session is None:
        anon_session = mint_signed_session_token()
        response = set_cookie(
            name="anon_session",
            value=anon_session,
            httponly=True,
            samesite="Lax",
            max_age_days=365,
        )
    event_log.put(
        anon_session=anon_session,
        user_id=request.user.id if request.user else None,
        event_type="page_view",
        path=request.url.pathname,
    )
    return response
```

Reference: [Mixpanel — Identifying Users](https://docs.mixpanel.com/docs/tracking-methods/id-management/identifying-users-simplified)
