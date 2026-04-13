---
title: Attribute Conversion to the Signal That Changed the Profile
impact: MEDIUM
impactDescription: enables intervention-level conversion attribution
tags: measure, attribution, interventions
---

## Attribute Conversion to the Signal That Changed the Profile

Standard last-click attribution answers "which page converted" but not "which intervention actually changed the visitor's mind". For pre-member personalisation, the more useful question is "which signal shift preceded the conversion?" — did the visitor become a member after seeing a specific local peer story, after a price-anchored comparison, after a cold-start honesty warning? Tracking the profile-feature diff across the session and correlating diffs with conversion identifies which interventions drive real lift, which is the only way to tell a working intervention apart from a lucky one.

**Incorrect (last-click attribution identifies URL but not intervention):**

```python
def attribute_conversion(user_id: str) -> Attribution:
    journey = session_log.get_journey(user_id)
    return Attribution(
        last_url=journey.events[-2].url,
        referrer=journey.events[0].referrer,
    )
```

**Correct (intervention-level attribution based on profile-feature diff):**

```python
def attribute_conversion(user_id: str) -> Attribution:
    journey = session_log.get_journey(user_id)
    profile_snapshots = journey.profile_snapshots

    interventions_shown = journey.interventions_shown
    profile_shifts = []
    for i in range(1, len(profile_snapshots)):
        diff = compare_profiles(profile_snapshots[i - 1], profile_snapshots[i])
        if diff.magnitude > 0.1:
            profile_shifts.append((profile_snapshots[i].timestamp, diff, interventions_shown[i]))

    return Attribution(
        primary_intervention=profile_shifts[-1][2] if profile_shifts else None,
        intervention_chain=[shift[2] for shift in profile_shifts],
        final_profile=profile_snapshots[-1],
    )
```

Reference: [Kohavi, Tang, Xu — Trustworthy Online Controlled Experiments](https://experimentguide.com/)
