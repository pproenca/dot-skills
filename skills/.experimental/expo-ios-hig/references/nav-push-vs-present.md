---
title: Push for hierarchy and present for self-contained tasks
impact: HIGH
impactDescription: prevents broken back stacks and mismatched transitions
tags: nav, modality, presentation, navigation
---

## Push for hierarchy and present for self-contained tasks

Pushing a screen tells the user "this is deeper in the same topic" — they get a back chevron and the swipe-back edge to return. Presenting modally says "step aside to complete one task" — they get Cancel/Done and swipe-down to dismiss. Pushing a self-contained task (compose, sign-in) strands it in the back stack with the wrong affordances; presenting a hierarchical destination breaks the user's sense of place.

**Incorrect (push a self-contained compose task):**

```tsx
import { router } from 'expo-router';

// "Write Review" gets pushed onto the trail's stack: it shows a back chevron
// and stays in history, as if it were a deeper level of the trail
function reviewTrail(trailId: string) {
  router.push(`/trails/${trailId}/review`);
}
```

**Correct (present the task modally):**

```tsx
import { router } from 'expo-router';

// "Write Review" is presented from a (modal) group: Cancel/Done + swipe-to-dismiss,
// and it never pollutes the trail's back stack
function reviewTrail(trailId: string) {
  router.push(`/(modal)/review?trailId=${trailId}`);
}
```

Reference: [Apple HIG — Modality](https://developer.apple.com/design/human-interface-guidelines/modality)
