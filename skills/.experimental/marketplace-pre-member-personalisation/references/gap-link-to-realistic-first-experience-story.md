---
title: Link to a Realistic First-Experience Story from a Peer
impact: HIGH
impactDescription: enables narrative-driven expectation setting
tags: gap, narrative, peer-stories
---

## Link to a Realistic First-Experience Story from a Peer

Narrative transportation research (Green and Brock 2000) shows that people absorb information from a first-person story more durably than from statistics or abstract claims, and the effect is strongest when the narrator shares visible characteristics with the listener. A first-time pet owner hesitating on payment will integrate "here is what my first stay was like, good and bad" from another first-time owner more deeply than any testimonial or statistic — especially when the story includes the friction and not just the triumph. Link the visitor to a cohort-matched real story from a member whose first experience happened recently, with honest detail about what was harder than expected as well as what worked.

**Incorrect (polished success-only testimonial, disconnected from visitor):**

```typescript
function Testimonial() {
  return (
    <blockquote>
      "Joining was the best decision I ever made. My pets are happy and I travel without worry!"
      — Sarah T., Member since 2018
    </blockquote>
  )
}
```

**Correct (cohort-matched, recent, honest first-experience narrative):**

```typescript
async function PeerStory({ visitorCohort }: { visitorCohort: Cohort }) {
  const story = await stories.pickRealFirstExperience({
    matchingCohort: visitorCohort,
    includeFriction: true,
    maxAgeMonths: 6,
  })

  return (
    <article>
      <h3>
        {story.author.firstName} in {story.author.city}, {story.monthsSinceJoined} months in
      </h3>
      <p>{story.summary}</p>
      <section>
        <h4>What worked</h4>
        <p>{story.whatWorked}</p>
      </section>
      <section>
        <h4>What was harder than I expected</h4>
        <p>{story.whatWasHard}</p>
      </section>
      <section>
        <h4>What I'd do differently</h4>
        <p>{story.lessonLearned}</p>
      </section>
    </article>
  )
}
```

Reference: [Green and Brock — The Role of Transportation in the Persuasiveness of Public Narratives (Journal of Personality and Social Psychology 2000)](https://psycnet.apa.org/doi/10.1037/0022-3514.79.5.701)
