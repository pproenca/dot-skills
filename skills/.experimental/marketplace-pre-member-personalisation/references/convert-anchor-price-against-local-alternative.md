---
title: Anchor Membership Price Against the Visitor's Most Local Alternative
impact: MEDIUM-HIGH
impactDescription: enables saving-frame perception via local anchor
tags: convert, price-anchoring, local
---

## Anchor Membership Price Against the Visitor's Most Local Alternative

Kahneman's price-anchoring research shows that any number evaluated in isolation is compared implicitly to whatever reference the user's mind first produces, and the best anchors are those the visitor can concretely calculate against their own life. For pet owners, the dominant mental reference is the local kennel. For pet sitters, it is the local hotel or Airbnb. Showing membership price against a local, concrete alternative that the visitor already knows and prices regularly reframes the membership from "an expense" to "a saving", without any change to the actual price.

**Incorrect (isolated price with no anchor):**

```typescript
function PriceLabel() {
  return <span className="price">£129/year</span>
}
```

**Correct (price anchored against the visitor's role-appropriate local alternative):**

```typescript
async function PriceLabel({ visitorRole, visitorRegion }: Props) {
  if (visitorRole === "owner") {
    const kennel = await rates.localKennelNightly(visitorRegion)
    return (
      <div>
        <span className="price">£129/year</span>
        <span className="anchor">
          About {Math.round(129 / kennel)} nights at a local kennel
          (£{kennel}/night in {visitorRegion})
        </span>
      </div>
    )
  }
  if (visitorRole === "sitter") {
    const airbnb = await rates.localAirbnbNightly(visitorRegion)
    return (
      <div>
        <span className="price">£129/year</span>
        <span className="anchor">
          About {Math.round(129 / airbnb)} nights in a budget Airbnb in{" "}
          {visitorRegion} (£{airbnb}/night). Members typically save 30+ nights a year.
        </span>
      </div>
    )
  }
  return <span className="price">£129/year</span>
}
```

Reference: [Kahneman and Tversky — Prospect Theory: An Analysis of Decision under Risk (Econometrica 1979)](https://www.jstor.org/stable/1914185)
