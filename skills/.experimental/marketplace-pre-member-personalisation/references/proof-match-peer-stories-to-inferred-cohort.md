---
title: Match Peer Stories to the Visitor's Inferred Cohort
impact: MEDIUM-HIGH
impactDescription: enables similarity-driven persuasion
tags: proof, similarity, cohort
---

## Match Peer Stories to the Visitor's Inferred Cohort

The similarity principle within social-influence research (Cialdini) and matching-market research on peer effects both show that social proof is stronger when the peer visibly resembles the recipient on dimensions the recipient cares about. A first-time sitter in their 20s targeting city breaks is not persuaded by a retired couple's year-long countryside sit, and a pet owner with an elderly chronically-ill dog is not reassured by a story about a healthy puppy. Tag stories with cohort metadata (age band, role, pet type, target destination, lifecycle stage) and match the displayed story to the visitor's inferred cohort at runtime.

**Incorrect (a single testimonial shown to every visitor regardless of cohort):**

```typescript
const TESTIMONIAL = {
  text: "Joining changed how I travel. Highly recommend.",
  name: "Emma",
  city: "Manchester",
}

function Testimonial() {
  return <Quote author={TESTIMONIAL.name} from={TESTIMONIAL.city}>{TESTIMONIAL.text}</Quote>
}
```

**Correct (story matched to inferred cohort from visitor profile):**

```typescript
async function Testimonial({ profile }: { profile: InferredProfile }) {
  const cohort = {
    role: profile.role,
    ageBand: profile.inferredAgeBand,
    petType: profile.petType,
    targetRegion: profile.targetRegion,
  }
  const story = await stories.pickMatchingCohort(cohort, {
    fallback: "role_only",
    minMatchScore: 0.6,
  })
  return (
    <Quote author={story.firstName} from={story.city} role={story.role}>
      {story.quote}
    </Quote>
  )
}
```

Reference: [Robert Cialdini — Influence: The Psychology of Persuasion](https://www.influenceatwork.com/principles-of-persuasion/)
