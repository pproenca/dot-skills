---
title: Track Outcomes to Completion, Not Clicks
impact: CRITICAL
impactDescription: prevents clickbait reward shaping
tags: track, outcomes, event-value
---

## Track Outcomes to Completion, Not Clicks

A click is cheap and easy to game — sensational photos and aggressive pricing win click fights but produce cancellations, disputes and one-star reviews. The ground-truth signal in a marketplace is the completed, mutually-rated transaction: a confirmed booking that was honoured and satisfied both sides. If the model only reinforces clicks, it learns clickbait; if it reinforces completed outcomes, it learns real fit.

**Incorrect (click is the terminal event, no completion tracked):**

```typescript
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
```

**Correct (lifecycle events reach booking_completed with event value):**

```typescript
async function emitBookingCompleted(booking: Booking, seeker: Seeker) {
  await personalize.putEvents({
    trackingId: env.PERSONALIZE_TRACKING_ID,
    userId: seeker.id,
    sessionId: seeker.sessionId,
    eventList: [{
      eventType: 'booking_completed',
      itemId: booking.listingId,
      sentAt: new Date(),
      eventValue: booking.nightsStayed,
      properties: JSON.stringify({ rating: booking.mutualRating }),
    }],
  })
}
```

Reference: [DoorDash — Homepage Recommendation with Exploitation and Exploration](https://careersatdoordash.com/blog/homepage-recommendation-with-exploitation-and-exploration/)
