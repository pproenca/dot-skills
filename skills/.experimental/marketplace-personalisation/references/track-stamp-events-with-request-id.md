---
title: Stamp Events with a Request-ID Join Key
impact: CRITICAL
impactDescription: enables impression-to-outcome attribution
tags: track, attribution, request-id
---

## Stamp Events with a Request-ID Join Key

Every recommendation response gets a `requestId` that travels with every downstream event — impression, click, booking, cancellation, rating. Without it, you cannot answer "which listing was in slot 3 of this session's homepage?", which breaks counterfactual evaluation, position-bias correction and A/B attribution. The server knows the answer at request time and must share it with the client so the telemetry can be joined.

**Incorrect (events sent with no ranking context, attribution broken):**

```typescript
const listings = await api.homefeed({ seekerId: seeker.id })

for (const listing of listings) {
  await personalize.putEvents({
    trackingId: env.PERSONALIZE_TRACKING_ID,
    userId: seeker.id,
    sessionId: seeker.sessionId,
    eventList: [{ eventType: 'impression', itemId: listing.id, sentAt: new Date() }],
  })
}
```

**Correct (server returns requestId, every event carries it):**

```typescript
const { listings, requestId } = await api.homefeed({ seekerId: seeker.id })

for (const [slot, listing] of listings.entries()) {
  await personalize.putEvents({
    trackingId: env.PERSONALIZE_TRACKING_ID,
    userId: seeker.id,
    sessionId: seeker.sessionId,
    eventList: [{
      eventType: 'impression',
      itemId: listing.id,
      sentAt: new Date(),
      properties: JSON.stringify({ requestId, slot, surface: 'homefeed' }),
    }],
  })
}
```

Reference: [Impression-Aware Recommender Systems (ACM TORS)](https://dl.acm.org/doi/10.1145/3712292)
