---
title: Degrade Gracefully When Stitching Confidence Is Low
impact: MEDIUM
impactDescription: prevents bad merges worse than no merges
tags: stitch, confidence, degradation
---

## Degrade Gracefully When Stitching Confidence Is Low

Identity-stitching research consistently shows that bad merges are operationally worse than no merges — a confused profile with two people's preferences produces worse recommendations than a fresh profile with one person's preferences. When the stitching confidence is low (probabilistic signals, no deterministic match, ambiguous behaviour), the right behaviour is to treat the new session as separate and start a fresh profile rather than force a merge that might be wrong. The platform's default should be "do not stitch unless you can prove it", and unsure cases fall through to fresh-profile mode.

**Incorrect (best-effort probabilistic merge on any weak signal):**

```python
def try_stitch(anon_session: str, request: Request) -> None:
    candidates = profile_store.find_candidates(
        ip=request.client_ip,
        user_agent=request.headers.get("user-agent"),
        max_distance_hours=72,
    )
    if candidates:
        best = candidates[0]
        profile_store.merge(anon_session, best.id)
```

**Correct (explicit confidence threshold, fresh profile on low confidence):**

```python
STITCH_CONFIDENCE_THRESHOLD = 0.85

def try_stitch(anon_session: str, request: Request) -> StitchResult:
    candidates = profile_store.find_candidates(
        ip=request.client_ip,
        user_agent=request.headers.get("user-agent"),
        max_distance_hours=72,
    )
    if not candidates:
        return StitchResult(action="fresh_profile", reason="no_candidates")

    top = score_candidates(candidates, request)[0]
    if top.confidence < STITCH_CONFIDENCE_THRESHOLD:
        return StitchResult(
            action="fresh_profile",
            reason=f"top_confidence_{top.confidence:.2f}_below_threshold",
        )

    profile_store.merge(anon_session, top.profile_id)
    return StitchResult(action="merged", reason="high_confidence_match")
```

Reference: [Snowplow — Users and Identity Stitching](https://docs.snowplow.io/docs/modeling-your-data/modeling-your-data-with-dbt/package-features/identity-stitching/)
