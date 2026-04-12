---
title: Log the Ranking Slot with Every Impression
impact: HIGH
impactDescription: enables position-bias correction
tags: loop, positional-bias, impressions
---

## Log the Ranking Slot with Every Impression

A click on slot 1 is not worth the same as a click on slot 24 — slot 1 is looked at 10× more often, so the same click rate in slot 24 represents stronger preference. Without logging the slot, the training data mixes strong and weak signals as if they were equal, and the model learns that whatever currently sits in slot 1 is the correct answer. Slot logging makes position-bias correction possible (via IPS weighting or similar) and is the cheapest single improvement you can make after impression logging itself.

**Incorrect (impressions logged without slot — positional bias uncorrectable):**

```typescript
await personalize.putEvents({
  trackingId: env.PERSONALIZE_TRACKING_ID,
  userId: seeker.id,
  sessionId: seeker.sessionId,
  eventList: listings.map((listing) => ({
    eventType: 'impression',
    itemId: listing.id,
    sentAt: new Date(),
  })),
})
```

**Correct (slot and surface travel with every impression):**

```typescript
await personalize.putEvents({
  trackingId: env.PERSONALIZE_TRACKING_ID,
  userId: seeker.id,
  sessionId: seeker.sessionId,
  eventList: listings.map((listing, slot) => ({
    eventType: 'impression',
    itemId: listing.id,
    sentAt: new Date(),
    properties: JSON.stringify({
      requestId,
      slot,
      surface: 'homefeed',
      page: Math.floor(slot / 24),
    }),
  })),
})
```

Reference: [Bias and Debias in Recommender System: A Survey (arXiv 2010.03240)](https://arxiv.org/pdf/2010.03240)
