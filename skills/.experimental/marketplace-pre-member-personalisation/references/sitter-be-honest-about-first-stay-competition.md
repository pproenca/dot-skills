---
title: Be Honest About First-Stay Competition for New Sitters
impact: HIGH
impactDescription: prevents first-year churn from expectation violation
tags: sitter, cold-start, honesty
---

## Be Honest About First-Stay Competition for New Sitters

Matching-market research shows that competitive platforms have highly uneven acceptance rates, especially at the supply-new / demand-saturated intersection. A new sitter with no reviews applying to a listing in central Barcelona for the first week of August is competing with 20-40 established sitters who have dozens of completed stays and glowing reviews. The industry data on marketplace churn shows that the single biggest cause of first-year supply-side churn is paying members discovering this reality after they could no longer get a refund. Showing typical first-stay acceptance rates before payment, for the visitor's stated target, protects retention at a small conversion cost.

**Incorrect (encouraging copy with no acceptance-rate data):**

```typescript
function NewSitterPitch() {
  return (
    <div>
      <h2>Start sitting today</h2>
      <p>Join thousands of sitters already earning free accommodation.</p>
      <button>Join and apply</button>
    </div>
  )
}
```

**Correct (honest acceptance-rate estimate for the visitor's target):**

```typescript
async function NewSitterPitch({ targetDest, targetMonth }: Props) {
  const firstStayStats = await analytics.firstStayAcceptanceRate({
    destination: targetDest,
    month: targetMonth,
    sitterCohort: "new_no_reviews",
  })
  return (
    <div>
      <h2>Start sitting in {targetDest}</h2>
      <p>
        New sitters targeting {targetDest} in {targetMonth} typically apply
        to <strong>{firstStayStats.applicationsBeforeAcceptance}</strong> listings
        before being accepted, over <strong>{firstStayStats.weeksToFirstStay}</strong> weeks.
      </p>
      <p>
        {firstStayStats.competitionLevel === "high" && (
          <>Competition is high. Off-season or nearby destinations may give you a faster first stay.</>
        )}
      </p>
      <AlternativeDestinationChooser current={targetDest} />
      <button>Join and apply anyway</button>
    </div>
  )
}
```

Reference: [Alvin Roth — Who Gets What and Why: The New Economics of Matchmaking and Market Design](https://www.hup.harvard.edu/books/9780544291133)
