---
title: Use Specific Peer Stories at Decision Points, Not Aggregate Stats
impact: MEDIUM-HIGH
impactDescription: enables specific-beats-aggregate social proof
tags: proof, specific, cialdini
---

## Use Specific Peer Stories at Decision Points, Not Aggregate Stats

Cialdini's *Influence* documents exhaustively that specific social proof — "Jane booked Sarah last Tuesday" — converts dramatically better than aggregate statistics — "4.9 stars across 100,000 stays". The mechanism is the representativeness heuristic: the visitor asks "does this work for people like me?" and a statistic answers "on average" while a specific person answers "yes, concretely". At decision moments, especially near the paywall or at onboarding completion, replace aggregate trust signals with a single named-person story that matches the visitor's inferred cohort.

**Incorrect (aggregate stats at the decision moment):**

```typescript
function ConfirmationStep() {
  return (
    <div>
      <h2>One step to go</h2>
      <p>Join 200,000 members who rate us 4.9 stars</p>
      <button>Complete signup</button>
    </div>
  )
}
```

**Correct (a specific recent named-person story at the decision moment):**

```typescript
async function ConfirmationStep({ visitorCohort }: { visitorCohort: Cohort }) {
  const recent = await stories.pickRecentSuccess({
    matchingCohort: visitorCohort,
    maxAgeDays: 14,
  })
  return (
    <div>
      <h2>One step to go</h2>
      <div>
        <PeerAvatar name={recent.firstName} city={recent.city} />
        <p>
          {recent.firstName} in {recent.city} completed her first stay with{" "}
          {recent.sitterFirstName} {recent.daysAgo} days ago.
        </p>
      </div>
      <button>Complete signup</button>
    </div>
  )
}
```

Reference: [Robert Cialdini — Influence: The Psychology of Persuasion](https://www.influenceatwork.com/principles-of-persuasion/)
