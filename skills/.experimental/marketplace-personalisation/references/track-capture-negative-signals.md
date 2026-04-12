---
title: Capture Negative Signals Explicitly
impact: CRITICAL
impactDescription: prevents silence-as-acceptance bias
tags: track, negative-feedback, dismissal
---

## Capture Negative Signals Explicitly

Personalize treats any event in the Interactions dataset as a positive signal of interest. A seeker who scrolled past a listing, swiped it away or tapped "not for me" has expressed rejection — but if only clicks and bookings are logged, that rejection is invisible, and the model learns that everyone silently likes what it shows. Explicit negative events are a separate event type that the model can down-weight, not mix with clicks.

**Incorrect (dismissal never recorded, model sees only positives):**

```typescript
async function onListingDismissed(listing: Listing, seeker: Seeker) {
  analytics.track('listing_dismissed', {
    listingId: listing.id,
    seekerId: seeker.id,
  })
}
```

**Correct (dismissal emitted as a distinct event type for the Interactions dataset):**

```typescript
async function onListingDismissed(listing: Listing, seeker: Seeker, requestId: string) {
  await personalize.putEvents({
    trackingId: env.PERSONALIZE_TRACKING_ID,
    userId: seeker.id,
    sessionId: seeker.sessionId,
    eventList: [{
      eventType: 'dismiss',
      itemId: listing.id,
      sentAt: new Date(),
      properties: JSON.stringify({ requestId, reason: 'not_interested' }),
    }],
  })
}
```

Reference: [AWS Personalize — Choosing Item Interaction Data for Training](https://docs.aws.amazon.com/personalize/latest/dg/event-values-types.html)
