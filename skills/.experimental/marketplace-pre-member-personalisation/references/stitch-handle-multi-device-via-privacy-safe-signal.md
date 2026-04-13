---
title: Handle Multi-Device Visitors via Privacy-Safe Deterministic Signals
impact: MEDIUM
impactDescription: enables cross-device profile continuity without fingerprinting
tags: stitch, multi-device, privacy
---

## Handle Multi-Device Visitors via Privacy-Safe Deterministic Signals

A visitor commonly researches on mobile during a commute and converts on desktop at home — two different sessions, two different anon tokens, same person. Stitching them is valuable: the desktop session inherits the mobile research. But the legal and reputational cost of cross-device stitching via browser fingerprinting or IP-based probabilistic matching is high, especially under GDPR and similar regimes. The privacy-safe path is to use deterministic signals the visitor explicitly provided — a one-time email-link email click, a social login, a short-code auth — and stitch only when one of those fires. Graceful degradation beats aggressive probabilistic matching.

**Incorrect (cross-device merge via browser fingerprint and IP heuristics):**

```python
def stitch_device_profiles(anon_session: str, request: Request) -> None:
    candidate_matches = profile_store.find_similar_fingerprints(
        fingerprint=browser_fingerprint(request),
        ip_range=request.client_ip.network,
        time_window_hours=24,
    )
    if candidate_matches:
        profile_store.merge(anon_session, candidate_matches[0].id)
```

**Correct (stitch only on explicit deterministic signal):**

```python
def on_email_link_click(request: Request, email: str) -> None:
    email_hash = hash_email(email)
    existing_profile_id = profile_store.find_by_hashed_email(email_hash)

    if existing_profile_id:
        profile_store.link(
            anon_session=request.anon_session,
            profile_id=existing_profile_id,
            link_source="email_link_deterministic",
        )
    else:
        profile_store.associate_email(
            anon_session=request.anon_session,
            email_hash=email_hash,
        )
```

Reference: [Mixpanel — Identifying Users](https://docs.mixpanel.com/docs/tracking-methods/id-management/identifying-users-simplified)
