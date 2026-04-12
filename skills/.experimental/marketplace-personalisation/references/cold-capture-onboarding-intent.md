---
title: Capture Explicit Intent at Onboarding
impact: HIGH
impactDescription: saves days of interaction accumulation
tags: cold, onboarding, intent-capture
---

## Capture Explicit Intent at Onboarding

A seeker who just registered has zero interactions, but they can tell the system what they want — in one or two well-designed onboarding screens — if you ask. Explicit intent capture (region, date range, species, budget, trip type) seeds the user profile with stronger signals than clicks would provide in the first ten sessions. These declared preferences go straight into the Users dataset and into every GetRecommendations call's context block, so the first homepage is already differentiated rather than generic.

**Incorrect (new seeker registered with only auth fields, no intent captured):**

```python
def on_signup(email: str, locale: str) -> Seeker:
    seeker = Seeker(id=str(uuid4()), email=email, locale=locale)
    seekers.save(seeker)
    return seeker
```

**Correct (two-question onboarding feeds Users dataset and inference context):**

```python
def on_signup(email: str, locale: str, onboarding: OnboardingAnswers) -> Seeker:
    seeker = Seeker(
        id=str(uuid4()),
        email=email,
        locale=locale,
        declared_region=onboarding.region,
        declared_species=onboarding.species,
        declared_trip_type=onboarding.trip_type,
    )
    seekers.save(seeker)
    personalize_events.put_users(
        datasetArn=USERS_DATASET_ARN,
        users=[{
            "userId": seeker.id,
            "properties": json.dumps({
                "REGION": seeker.declared_region,
                "SPECIES": seeker.declared_species,
                "TRIP_TYPE": seeker.declared_trip_type,
            }),
        }],
    )
    return seeker
```

Reference: [AWS Personalize — Handling New Users with PutUsers](https://docs.aws.amazon.com/personalize/latest/dg/recording-events.html)
