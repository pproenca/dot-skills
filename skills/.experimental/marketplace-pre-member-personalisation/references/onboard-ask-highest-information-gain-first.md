---
title: Ask the Highest-Information-Gain Question Earliest
impact: MEDIUM
impactDescription: reduces drop-off per unit of signal captured
tags: onboard, information-gain, ordering
---

## Ask the Highest-Information-Gain Question Earliest

Every onboarding question costs friction measured as drop-off, and every question produces some personalisation lift. The optimal question order is descending information gain — the question whose answer most changes the downstream experience goes first, so that visitors who drop out still leave the system with the most valuable answer. For an owner, the highest-gain question after role is typically city plus pet type; for a sitter, it is target destination plus rough date window. Placing low-gain demographic questions before high-gain targeting questions wastes the most-engaged moment of the flow.

**Incorrect (low-gain demographic questions before high-gain targeting questions):**

```typescript
const OWNER_STEPS = [
  { field: "firstName", required: true },
  { field: "lastName", required: true },
  { field: "dateOfBirth", required: false },
  { field: "howDidYouHear", required: true },
  { field: "city", required: true },
  { field: "petType", required: true },
]
```

**Correct (high-information-gain questions first):**

```typescript
const OWNER_STEPS = [
  { field: "city", required: true, informationGainScore: 0.9 },
  { field: "petType", required: true, informationGainScore: 0.85 },
  { field: "travelDateWindow", required: true, informationGainScore: 0.75 },
  { field: "firstName", required: true, informationGainScore: 0.2 },
  { field: "email", required: true, informationGainScore: 0.3 },
  { field: "howDidYouHear", required: false, informationGainScore: 0.05 },
]

OWNER_STEPS.sort((a, b) => b.informationGainScore - a.informationGainScore)
```

Reference: [Luke Wroblewski — Web Form Design: Filling in the Blanks](https://www.lukew.com/resources/web_form_design.asp)
