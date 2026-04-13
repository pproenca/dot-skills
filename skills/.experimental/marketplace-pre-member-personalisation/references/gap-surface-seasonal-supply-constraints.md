---
title: Surface Seasonal Supply Constraints Before Payment
impact: HIGH
impactDescription: prevents seasonal-expectation mismatch
tags: gap, seasonality, supply
---

## Surface Seasonal Supply Constraints Before Payment

Two-sided marketplaces have strong seasonal cycles that neither side of a first-time visitor tends to understand. Summer months concentrate demand in coastal and urban destinations while supply stays roughly flat, producing acceptance-rate collapses that surprise new users. Winter months in southern Europe often swing the other way. A visitor planning a July trip to the Amalfi Coast needs to know that supply is near-zero for their dates before paying, not after. Surfacing the seasonal pattern for the visitor's destination and dates honestly — with a chart, a sentence, or a soft-route to off-season alternatives — is one of the highest-leverage interventions available pre-payment.

**Incorrect (static trust signal with no seasonal awareness):**

```typescript
function DestinationStats({ destination }: Props) {
  return (
    <div>
      <h3>{destination}</h3>
      <p>Over {totalStaysInDestination(destination)} stays available year-round</p>
    </div>
  )
}
```

**Correct (seasonal curve with the visitor's month highlighted):**

```typescript
async function DestinationStats({ destination, month }: Props) {
  const curve = await analytics.seasonalSupplyCurve({ destination, months: 12 })
  const visitorMonth = curve.find((c) => c.month === month)
  const flag = visitorMonth && visitorMonth.supplyIndex < 0.3 ? "tight" : "ok"

  return (
    <div>
      <h3>{destination} supply by month</h3>
      <SparkChart data={curve} highlight={month} />
      {flag === "tight" && (
        <p className="warning">
          {destination} in {month} is one of the tightest months of the year —{" "}
          {Math.round(visitorMonth!.supplyIndex * 100)}% of annual average supply.
          Consider {curve.filter((c) => c.supplyIndex > 0.8).map((c) => c.month).join(" or ")}.
        </p>
      )}
    </div>
  )
}
```

Reference: [Learning Market Dynamics for Optimal Pricing at Airbnb](https://medium.com/airbnb-engineering/learning-market-dynamics-for-optimal-pricing-97cffbcc53e3)
