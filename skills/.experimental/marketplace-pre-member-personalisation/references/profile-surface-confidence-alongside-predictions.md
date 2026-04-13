---
title: Surface Profile Confidence Alongside Predictions
impact: MEDIUM-HIGH
impactDescription: enables downstream decisions to respect uncertainty
tags: profile, confidence, uncertainty
---

## Surface Profile Confidence Alongside Predictions

A profile feature computed from one click is not the same thing as a feature computed from thirty clicks, even if the point estimate looks identical. Downstream code that ranks listings, decides what to show, or times a paywall should know the confidence of each feature so it can respect uncertainty — a low-confidence "likely in London" prediction should trigger a region chooser, not hardcode London in the filter. Returning a confidence score alongside every feature prevents over-confident personalisation that looks broken to the visitor when it guesses wrong.

**Incorrect (point estimates only, downstream code cannot distinguish certain from uncertain):**

```python
def get_profile(anon_session: str) -> dict:
    profile = profile_store.get(anon_session)
    return {
        "top_region": most_common(profile.clicked_regions) or profile.geoip_region,
        "top_species": most_common(profile.clicked_species),
        "inferred_role": profile.inferred_role,
    }
```

**Correct (each feature carries a confidence score):**

```python
def get_profile(anon_session: str) -> dict:
    profile = profile_store.get(anon_session)
    return {
        "top_region": {
            "value": most_common(profile.clicked_regions) or profile.geoip_region,
            "confidence": region_confidence(profile),
            "source": "clicks" if profile.clicked_regions else "geoip",
        },
        "top_species": {
            "value": most_common(profile.clicked_species),
            "confidence": min(1.0, len(profile.clicked_species) / 5),
            "source": "clicks",
        },
        "inferred_role": {
            "value": profile.inferred_role,
            "confidence": profile.inferred_role_confidence,
            "source": profile.role_signal_source,
        },
    }
```

Reference: [Li, Chu, Langford, Schapire — A Contextual-Bandit Approach to Personalized News Article Recommendation (WWW 2010)](https://dl.acm.org/doi/10.1145/1772690.1772758)
