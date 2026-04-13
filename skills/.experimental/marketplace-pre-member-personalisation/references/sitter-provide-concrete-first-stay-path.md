---
title: Provide a Concrete First-Stay Path, Not Abstract Encouragement
impact: HIGH
impactDescription: enables self-efficacy on the cold-start problem
tags: sitter, first-stay, self-efficacy
---

## Provide a Concrete First-Stay Path, Not Abstract Encouragement

Bandura's research on self-efficacy shows that people are more likely to commit to a difficult task when they can see a concrete, sequential path to success and believe they can follow it. New sitters face a hard cold-start problem — no reviews means low acceptance rates, low acceptance rates means no reviews. Abstract encouragement ("we have lots of tips") does not generate self-efficacy; a five-step path with specific actions and typical timelines does. Show the path before payment so the visitor sees a route from "new member" to "first successful stay" and can decide whether they believe they can walk it.

**Incorrect (abstract encouragement with no path):**

```typescript
function FirstStayTips() {
  return (
    <div>
      <h3>Tips for new sitters</h3>
      <ul>
        <li>Write a good profile</li>
        <li>Apply to many stays</li>
        <li>Be patient</li>
      </ul>
    </div>
  )
}
```

**Correct (five-step path with concrete actions and timelines):**

```typescript
function FirstStayPath({ visitorCountry }: { visitorCountry: string }) {
  return (
    <ol>
      <li>
        <strong>Week 1:</strong> Verify your ID and police check.
        These are the two signals owners filter on first.
      </li>
      <li>
        <strong>Week 1:</strong> Write a detailed profile — 500 words,
        3 reference letters, 5 photos of you with pets.
        New sitters with this profile shape get 4× more replies.
      </li>
      <li>
        <strong>Weeks 2-3:</strong> Apply to 10-20 off-season stays in {visitorCountry}.
        Domestic stays have lower competition and faster turnaround than international.
      </li>
      <li>
        <strong>Weeks 3-5:</strong> Complete your first stay and ask the owner
        for a review. Your first 1-2 reviews roughly triple acceptance rate.
      </li>
      <li>
        <strong>After 2 reviews:</strong> Start targeting the destinations
        you actually want. You're now a warm sitter.
      </li>
    </ol>
  )
}
```

Reference: [Bandura — Self-Efficacy: Toward a Unifying Theory of Behavioral Change (Psychological Review 1977)](https://psycnet.apa.org/doi/10.1037/0033-295X.84.2.191)
