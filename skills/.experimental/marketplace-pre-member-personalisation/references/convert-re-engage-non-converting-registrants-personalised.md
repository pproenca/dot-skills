---
title: Reengage Non-Converting Registrants with Personalised Triggers
impact: MEDIUM-HIGH
impactDescription: enables targeted reactivation of registered-not-converted cohort
tags: convert, re-engagement, personalised
---

## Reengage Non-Converting Registrants with Personalised Triggers

A registered-but-not-paid visitor is a highly valuable cohort — they converted through the highest-friction step (account creation) and then stopped. Research on lifecycle re-engagement (Tellis et al on persistence of advertising effects, and the broader CRM literature) shows that the difference between a personalised re-engagement trigger and a generic reminder is an order of magnitude in reactivation. Specifically: a visitor who searched Barcelona three times and bookmarked two sitters should receive a Barcelona-specific email referencing those specific sitters, not a generic "complete your signup" template. The personalisation layer owns this — it already knows the search history — and it must ship the signal to the CRM system.

**Incorrect (generic abandoned-signup reminder to every registered non-member):**

```python
def send_reminder(registrant: Registrant) -> None:
    email.send(
        to=registrant.email,
        template="complete_signup_reminder",
        params={"first_name": registrant.first_name},
    )
```

**Correct (personalised trigger referencing the visitor's actual search history):**

```python
def send_reminder(registrant: Registrant) -> None:
    profile = profile_store.get(registrant.anon_session)
    if not profile:
        email.send(to=registrant.email, template="generic_welcome_back")
        return

    top_search = profile.top_search_destination()
    bookmarked = profile.bookmarked_listings()

    if top_search and bookmarked:
        email.send(
            to=registrant.email,
            template="saved_listings_in_destination",
            params={
                "first_name": registrant.first_name,
                "destination": top_search,
                "listings": [l.to_email_card() for l in bookmarked[:3]],
                "local_kennel_rate": rates.local_kennel_nightly(top_search),
            },
        )
    elif top_search:
        email.send(
            to=registrant.email,
            template="destination_availability_update",
            params={
                "first_name": registrant.first_name,
                "destination": top_search,
                "new_stays_count": listings.new_in_destination(top_search, days=7),
            },
        )
    else:
        email.send(to=registrant.email, template="generic_welcome_back")
```

Reference: [Tellis — Effective Frequency in Advertising (Journal of Advertising Research 1997)](https://www.journalofadvertisingresearch.com/)
