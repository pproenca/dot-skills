---
title: Anchor Membership Cost Against the Visitor's Local Kennel Alternative
impact: CRITICAL
impactDescription: enables saving-frame perception via local anchor
tags: owner, anchoring, pricing
---

## Anchor Membership Cost Against the Visitor's Local Kennel Alternative

Kahneman and Tversky's price-anchoring research shows that the evaluation of a price depends on the reference point it is compared against, and that reference point is chosen implicitly by whichever number the user sees first. An owner seeing "£129/year" in isolation compares it to other annual subscriptions and hesitates; the same owner seeing "£129/year — about 3 nights in a local kennel" instantly reframes the number as a saving. The critical detail is that the anchor must be the visitor's *local* kennel cost, because London kennels at £50/night make a different anchor than rural Welsh kennels at £18/night, and a global average fails for both.

**Incorrect (abstract price with no anchor):**

```typescript
function PricingCard() {
  return (
    <div>
      <h2>Membership</h2>
      <p className="price">£129 / year</p>
      <button>Join now</button>
    </div>
  )
}
```

**Correct (local-kennel anchor personalised to the visitor's region):**

```typescript
async function PricingCard({ visitorRegion }: { visitorRegion: string }) {
  const kennelRate = await kennels.averageNightlyRate(visitorRegion)
  const equivalentNights = Math.round(129 / kennelRate)

  return (
    <div>
      <h2>Membership</h2>
      <p className="price">£129 / year</p>
      <p className="anchor">
        About {equivalentNights} nights in a local kennel (£{kennelRate}/night average in {visitorRegion}).
      </p>
      <p className="usage">Members book 6-12 nights of sitting per year on average.</p>
      <button>Join now</button>
    </div>
  )
}
```

Reference: [Kahneman and Tversky — Prospect Theory (Econometrica 1979)](https://www.jstor.org/stable/1914185)
