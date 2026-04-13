---
title: Show Specific Local Owner Reviews, Not Global Averages
impact: CRITICAL
impactDescription: enables identifiable-victim social proof
tags: owner, social-proof, reviews
---

## Show Specific Local Owner Reviews, Not Global Averages

Cialdini's foundational research on social influence shows that specific peer examples convert far more than aggregate statistics, and the identifiable-victim effect (Small and Loewenstein 2003) confirms that a named person with a photo is psychologically weightier than any statistic. A pre-member owner considering paying for the platform is running a risk calculation on their pet's wellbeing, and "trusted by 100,000 members" does not answer "does this work for people like me". A localised, specific review from another owner in the visitor's own city, with a real photo and a real stay date, does.

**Incorrect (aggregate trust signal, no localised evidence):**

```typescript
function TrustBlock({ stats }: { stats: PlatformStats }) {
  return (
    <div>
      <h3>Trusted by {stats.totalOwners} owners worldwide</h3>
      <p>Average rating: {stats.averageRating} across {stats.totalStays} stays</p>
      <StarRating value={stats.averageRating} />
    </div>
  )
}
```

**Correct (specific, localised, named evidence):**

```typescript
async function TrustBlock({ visitorCity }: { visitorCity: string }) {
  const recentStay = await reviews.pickRecentOwnerReview({
    cityWithin: visitorCity,
    maxRadiusKm: 10,
    minRating: 4,
    includeMildCriticism: true,
  })
  return (
    <div>
      <h3>Last week in {recentStay.city}</h3>
      <OwnerAvatar name={recentStay.ownerFirstName} city={recentStay.city} />
      <blockquote>{recentStay.quote}</blockquote>
      <p>{recentStay.ownerFirstName} booked {recentStay.sitterFirstName} for
        a {recentStay.nights}-night stay with their {recentStay.petType}.</p>
    </div>
  )
}
```

Reference: [Small and Loewenstein — Helping a Victim or Helping the Victim (Journal of Risk and Uncertainty 2003)](https://link.springer.com/article/10.1023/A:1022299422219)
