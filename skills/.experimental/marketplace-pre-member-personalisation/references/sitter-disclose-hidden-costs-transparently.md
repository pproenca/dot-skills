---
title: Disclose Hidden Costs Transparently Before Payment
impact: HIGH
impactDescription: prevents first-stay cost-shock churn
tags: sitter, hidden-costs, disclosure
---

## Disclose Hidden Costs Transparently Before Payment

The economics literature on drip pricing (Hossain and Morgan 2006 on eBay shipping-fee non-equivalence, and the FTC's 2015 review of hidden-fee disclosure) shows that non-disclosure of costs the customer will later discover hurts both customer welfare and platform retention, and the harm is worst for first-time users whose expectations form before the hidden costs emerge. For supply-side visitors on a marketplace, the hidden costs of a stay (food, utilities, local transport, sometimes pet supplies) are the most common source of first-stay regret. The platform's job during preview is to surface these honestly alongside the free-accommodation benefit so the visitor can make a complete calculation. The conversion cost of honesty is small; the retention benefit is large because sitters who know what they are signing up for stay subscribed.

**Incorrect (free-accommodation framing hides the cost side entirely):**

```typescript
function SitterBenefits() {
  return (
    <ul>
      <li>Free accommodation in beautiful homes worldwide</li>
      <li>Pet companionship on your travels</li>
      <li>Cultural immersion in real neighbourhoods</li>
    </ul>
  )
}
```

**Correct (honest benefit-and-cost breakdown):**

```typescript
function SitterBenefits() {
  return (
    <div>
      <h3>What you get</h3>
      <ul>
        <li>Free accommodation — typically £60-150 per night saved</li>
        <li>Pet companionship and a real-neighbourhood stay</li>
      </ul>
      <h3>What you typically pay</h3>
      <ul>
        <li>Food and groceries: £20-40 per week</li>
        <li>Local transport: variable, often £10-30 per week</li>
        <li>Travel to and from the stay: your own cost</li>
        <li>Optional extras some owners ask for (pet food, dog treats)</li>
      </ul>
      <p className="muted">
        Net saving versus an equivalent hotel or Airbnb: typically £300-800 per week.
      </p>
    </div>
  )
}
```

Reference: [Hossain and Morgan — Plus Shipping and Handling: Revenue (Non) Equivalence in Field Experiments on eBay (Advances in Economic Analysis and Policy 2006)](https://www.degruyterbrill.com/document/doi/10.2202/1538-0637.1429/html)
