---
title: Warn About the Cold-Start Penalty on Both Sides Pre-Payment
impact: HIGH
impactDescription: prevents first-year churn from the cold-start surprise
tags: gap, cold-start, retention
---

## Warn About the Cold-Start Penalty on Both Sides Pre-Payment

Matching-market research (Roth) and applied recommender research (Google Rules of ML) both show that the first transaction on a trust marketplace is disproportionately harder than any subsequent one — a new sitter has no reviews so owners filter them out, a new owner has no reviews so sitters judge them carefully. Visitors pay for membership expecting the typical member experience and discover only after payment that the first transaction is the hardest one they will ever do. This is a known, measurable pattern, and surfacing it honestly — with specific numbers for the visitor's cohort — trades a conversion cost for a retention gain that is several times larger.

**Incorrect (onboarding language that hides the cold-start problem):**

```typescript
function WelcomeScreen() {
  return (
    <div>
      <h2>Welcome — you're ready to go</h2>
      <p>Start browsing now and book your first stay.</p>
      <button>Continue</button>
    </div>
  )
}
```

**Correct (explicit cold-start warning with cohort-specific numbers):**

```typescript
async function WelcomeScreen({ role, targetSegment }: Props) {
  const stats = await analytics.coldStartStats({ role, segment: targetSegment })
  return (
    <div>
      <h2>A few things to expect</h2>
      <p>
        Your first {role === "sitter" ? "stay" : "booking"} is the hardest one —
        new members typically complete it in{" "}
        <strong>{stats.typicalDaysToFirst}</strong> days after applying to{" "}
        <strong>{stats.typicalApplications}</strong> listings.
      </p>
      <p>
        Once you have {stats.reviewsToUnlock} reviews, acceptance rates roughly{" "}
        <strong>triple</strong>. Most members report the experience getting easier fast.
      </p>
      <button>I understand, continue</button>
    </div>
  )
}
```

Reference: [Google — Rules of Machine Learning, Rule 4: Keep the First Model Simple and Get the Infrastructure Right](https://developers.google.com/machine-learning/guides/rules-of-ml)
