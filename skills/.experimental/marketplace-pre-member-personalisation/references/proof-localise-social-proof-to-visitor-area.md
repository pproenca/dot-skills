---
title: Localise Social Proof to the Visitor's Geography
impact: MEDIUM-HIGH
impactDescription: reduces psychological distance of proof
tags: proof, geography, proximity
---

## Localise Social Proof to the Visitor's Geography

Psychological-distance research (Construal Level Theory, Trope and Liberman 2010) shows that the persuasive weight of an example decreases with felt distance — temporal, spatial, social or hypothetical. A visitor in Bristol sees "12 owners in the BS postcode booked sitters this week" as a specific nearby fact; the same visitor sees "15,000 owners booked sitters this week globally" as an abstract aggregate. Localise the denominator of every social proof claim to the visitor's region, postcode or city, inferred from geo-IP or explicit onboarding, and the proof feels closer to the visitor's own decision.

**Incorrect (global aggregate social proof shown to every visitor):**

```typescript
function LiveActivity() {
  return (
    <div>
      <p className="tick">
        <strong>15,427 bookings</strong> made on the platform this week
      </p>
    </div>
  )
}
```

**Correct (local denominator driven by visitor geography):**

```typescript
async function LiveActivity({ visitorRegion }: { visitorRegion: string }) {
  const local = await analytics.recentBookingActivity({
    region: visitorRegion,
    windowDays: 7,
  })

  if (local.bookings < 5) {
    return (
      <p className="tick">
        <strong>{local.bookings} bookings</strong> this week in {visitorRegion} —
        small and growing
      </p>
    )
  }
  return (
    <p className="tick">
      <strong>{local.bookings} bookings</strong> this week in {visitorRegion} from
      members in {local.uniquePostcodes} postcodes
    </p>
  )
}
```

Reference: [Trope and Liberman — Construal-Level Theory of Psychological Distance (Psychological Review 2010)](https://psycnet.apa.org/doi/10.1037/a0018963)
