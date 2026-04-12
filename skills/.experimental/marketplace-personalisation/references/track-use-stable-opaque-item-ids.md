---
title: Use Stable Opaque Item IDs
impact: CRITICAL
impactDescription: prevents history loss on listing rename
tags: track, identifiers, data-integrity
---

## Use Stable Opaque Item IDs

The item ID is a join key that lives for the lifetime of the listing's interaction history — every click, booking and rating is bound to it. URLs, slugs and display names are unstable: they change when a provider renames the listing, updates the price tier, or moves cities. If the ID changes, all accumulated history becomes orphaned and the model treats the listing as brand new, erasing its learned relevance signal.

**Incorrect (URL slug as ID, history is lost on rename):**

```typescript
await personalize.putEvents({
  trackingId: env.PERSONALIZE_TRACKING_ID,
  userId: seeker.id,
  sessionId: seeker.sessionId,
  eventList: [{
    eventType: 'booking_completed',
    itemId: `/listings/${listing.slug}-${listing.city}`,
    sentAt: new Date(),
  }],
})
```

**Correct (immutable database primary key as itemId):**

```typescript
await personalize.putEvents({
  trackingId: env.PERSONALIZE_TRACKING_ID,
  userId: seeker.id,
  sessionId: seeker.sessionId,
  eventList: [{
    eventType: 'booking_completed',
    itemId: listing.id,
    sentAt: new Date(),
  }],
})
```

Reference: [Amazon Personalize Cheat Sheet — Schema Design](https://github.com/aws-samples/amazon-personalize-samples/blob/master/PersonalizeCheatSheet2.0.md)
