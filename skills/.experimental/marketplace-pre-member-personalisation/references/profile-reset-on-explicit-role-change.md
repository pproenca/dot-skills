---
title: Reset Profile Features on Explicit Role Changes
impact: MEDIUM-HIGH
impactDescription: prevents cross-contamination between sitter and owner profiles
tags: profile, reset, role-switching
---

## Reset Profile Features on Explicit Role Changes

A visitor who starts on the sitter side of the site and then clicks "actually I need a sitter" has revealed the system was wrong about their role — every click they made as an inferred sitter is now misleading evidence for the owner experience they actually want. Continuing to accumulate the two sets of clicks into one profile produces a muddled ranker that satisfies neither side. The fix is to reset role-specific profile features on any explicit role change while preserving stable signals (language, region, device), so the switch feels like a clean start to the visitor and the ranker rebuilds the right side of the profile from the next interaction.

**Incorrect (all clicks accumulated into one profile regardless of role switch):**

```python
def on_role_switch(anon_session: str, new_role: Role) -> None:
    profile_store.update(
        anon_session=anon_session,
        updates={"inferred_role": {"set": new_role}},
    )
```

**Correct (role-specific features cleared, stable features preserved):**

```python
ROLE_SPECIFIC_FEATURES = {
    "clicked_listings",
    "clicked_regions",
    "clicked_species_accepted",
    "dwell_durations",
    "preview_viewed",
}

STABLE_FEATURES = {"language", "geoip_region", "device_type", "entry_point"}

def on_role_switch(anon_session: str, new_role: Role) -> None:
    current = profile_store.get(anon_session)
    preserved = {key: current.get(key) for key in STABLE_FEATURES}
    profile_store.replace(
        anon_session=anon_session,
        profile={
            **preserved,
            "inferred_role": new_role,
            "inferred_role_confidence": 1.0,
            "inferred_role_source": "explicit_user_switch",
            "role_switched_at": datetime.utcnow(),
        },
    )
```

Reference: [Auth0 — Progressive Profiling](https://auth0.com/docs/manage-users/user-accounts/user-profiles/progressive-profiling)
