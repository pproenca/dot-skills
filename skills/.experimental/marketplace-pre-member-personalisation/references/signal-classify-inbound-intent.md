---
title: Classify Inbound Intent from the Acquisition Channel
impact: CRITICAL
impactDescription: enables channel-specific priors without interaction data
tags: signal, intent, acquisition
---

## Classify Inbound Intent from the Acquisition Channel

A visitor coming from paid search on "dog sitter next week london" arrives with transactional intent — they want a specific outcome soon and the session should show realistic inventory fast. A visitor coming from an editorial blog post about "should you trust a stranger with your dog" arrives with informational intent — they are investigating whether the concept is safe and the session should show evidence of safety, not a booking funnel. The acquisition channel is enough to seed this classification before any interaction, and the classification should route the visitor to an intent-appropriate first page rather than a one-size-fits-all landing.

**Incorrect (one landing template for every inbound channel):**

```python
def landing_page(request: Request) -> LandingPage:
    return LandingPage(
        template="default",
        hero="Find your perfect sitter",
        sections=["featured", "how_it_works", "testimonials"],
    )
```

**Correct (channel-driven intent classification routes to the right template):**

```python
def landing_page(request: Request) -> LandingPage:
    intent = classify_intent_from_channel(
        utm_source=request.query.utm_source,
        utm_medium=request.query.utm_medium,
        utm_campaign=request.query.utm_campaign,
        referrer_domain=domain_of(request.headers.get("referer")),
        landing_path=request.url.pathname,
    )

    if intent == InboundIntent.TRANSACTIONAL:
        return LandingPage(template="fast_book", hero="Sitters available for your dates", sections=["local_results", "cta"])
    if intent == InboundIntent.SAFETY_INVESTIGATIVE:
        return LandingPage(template="safety_first", hero="Trusted by 10,000+ owners", sections=["verification_flow", "reviews", "cta"])
    if intent == InboundIntent.CURIOSITY:
        return LandingPage(template="learn_more", hero="How house sitting works", sections=["how_it_works", "stories", "cta"])
    return LandingPage(template="default", hero="Find your perfect sitter", sections=["featured", "how_it_works", "cta"])
```

Reference: [Optimizely — Contextual Bandits in Personalization](https://www.optimizely.com/insights/blog/contextual-bandits-in-personalization/)
