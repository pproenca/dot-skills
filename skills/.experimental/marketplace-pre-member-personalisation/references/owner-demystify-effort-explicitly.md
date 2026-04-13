---
title: Demystify Owner Effort Explicitly Before Payment
impact: CRITICAL
impactDescription: reduces cognitive-load conversion loss
tags: owner, effort, cognitive-ease
---

## Demystify Owner Effort Explicitly Before Payment

The Fogg Behavior Model (Fogg 2009) states that behaviour happens when motivation, ability, and a trigger converge — and ability is governed largely by perceived effort. A pet owner considering the platform is comparing it mentally to kennels, which have one decision (pick the kennel) and one handover (drop off the pet). The platform sounds harder, and the marketing typically obscures the effort with aspirational language. Showing the actual effort breakdown honestly — writing a listing, reviewing applications, interviewing, handing over the home — counterintuitively increases conversion because it replaces unknown effort (which the brain overweights) with known effort.

**Incorrect (aspirational copy that hides the effort):**

```typescript
function HowItWorks() {
  return (
    <Steps>
      <Step title="Post a listing" description="Tell us about your home and pet" />
      <Step title="Meet sitters" description="Connect with trusted sitters" />
      <Step title="Enjoy your trip" description="Travel with peace of mind" />
    </Steps>
  )
}
```

**Correct (explicit time budget against each step with honest framing):**

```typescript
function HowItWorks() {
  return (
    <Steps>
      <Step
        title="Write your listing"
        timeEstimate="15-20 minutes"
        description="Describe your home, your pet and the dates. Photos help a lot."
      />
      <Step
        title="Review applications"
        timeEstimate="15-30 minutes over 2-5 days"
        description="Typical listings get 3-8 sitter applications. You read profiles and pick favourites."
      />
      <Step
        title="Video interview"
        timeEstimate="20-30 minutes"
        description="A call with one or two shortlisted sitters to confirm fit."
      />
      <Step
        title="Hand over the home"
        timeEstimate="45 minutes in person"
        description="Show the sitter the pet routine, the keys, the house rules."
      />
    </Steps>
  )
}
```

Reference: [BJ Fogg — A Behavior Model for Persuasive Design](https://bjfogg.com/fbm_files/page4_1.pdf)
