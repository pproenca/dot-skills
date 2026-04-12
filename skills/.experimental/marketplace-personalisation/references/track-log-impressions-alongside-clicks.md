---
title: Log Impressions Alongside Clicks
impact: CRITICAL
impactDescription: enables unbiased CTR training
tags: track, impressions, exposure-logging, selection-bias
---

## Log Impressions Alongside Clicks

A click-only event stream cannot compute CTR, cannot distinguish "unseen" from "rejected", and cannot correct for position bias. The model trained on clicks alone learns that the top slot is always correct, because the top slot is always clicked more — classic exposure bias. Impressions are the denominator that turns clicks into a rate and gives the model negative samples that reflect the true opportunity distribution.

**Incorrect (click-only stream, no exposure record):**

```typescript
async function onListingClick(listing: Listing, seeker: Seeker) {
  await personalize.putEvents({
    trackingId: env.PERSONALIZE_TRACKING_ID,
    userId: seeker.id,
    sessionId: seeker.sessionId,
    eventList: [{
      eventType: 'click',
      itemId: listing.id,
      sentAt: new Date(),
    }],
  })
}
```

**Correct (impression + click share a requestId for exposure join):**

```typescript
async function onListingsRendered(listings: Listing[], requestId: string, seeker: Seeker) {
  await personalize.putEvents({
    trackingId: env.PERSONALIZE_TRACKING_ID,
    userId: seeker.id,
    sessionId: seeker.sessionId,
    eventList: listings.map((listing, slot) => ({
      eventType: 'impression',
      itemId: listing.id,
      sentAt: new Date(),
      properties: JSON.stringify({ requestId, slot }),
    })),
  })
}
```

Reference: [Impression-Aware Recommender Systems (ACM TORS)](https://dl.acm.org/doi/10.1145/3712292)
