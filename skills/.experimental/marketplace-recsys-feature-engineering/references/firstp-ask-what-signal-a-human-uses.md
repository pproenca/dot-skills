---
title: Ask What Signal a Human Uses to Make the Same Decision
impact: CRITICAL
impactDescription: prevents guessing — surfaces 5-15 evidence-backed candidates per interview round
tags: firstp, human-signal, research, interview
---

## Ask What Signal a Human Uses to Make the Same Decision

A marketplace feature portfolio built by engineers guessing what matters is indistinguishable from random after 40 features. The reliable source is the people who already make the decision: interview 8-12 owners and 8-12 sitters, ask them to talk through three real listings they rejected and three they accepted, and write down every signal they name. Each named signal becomes a candidate feature with a clear hypothesis about the outcome it moves. Features that did not come from this process should justify themselves against features that did.

**Incorrect (guesses what owners care about):**

```python
# engineering team whiteboard session, no owner interviews
CANDIDATE_FEATURES = [
    "listing.price",
    "listing.num_rooms",
    "listing.distance_to_city_center",
    "listing.internet_speed_mbps",  # nobody in the research asked about this
]
```

**Correct (catalogues features from 10 real owner interviews):**

```python
# from structured interviews — each feature tagged with the owner quote that motivates it
CANDIDATE_FEATURES = {
    "has_fenced_garden": 'Owner A: "I wouldn\'t leave my dog with someone who doesn\'t have a fenced garden."',
    "sitter_has_cared_for_same_breed": 'Owner B: "I want someone who has had a labrador before."',
    "sitter_works_from_home": 'Owner C: "My dog gets anxious alone, I need someone home most of the day."',
    "review_count_from_owners_with_same_pet": 'Owner D: "5-star from a cat owner doesn\'t help me — I have two huskies."',
    "response_time_on_previous_requests": 'Owner E: "If they took 3 days to reply once, I skip them."',
}

def build_decision_features(sitter: Sitter, listing: Listing) -> dict:
    return {k: compute_feature(k, sitter, listing) for k in CANDIDATE_FEATURES}
```

Reference: [Eugene Yan — Patterns for Personalization in Recommendations and Search](https://eugeneyan.com/writing/patterns-for-personalization/)
