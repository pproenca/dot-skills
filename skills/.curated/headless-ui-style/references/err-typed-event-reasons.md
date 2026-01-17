---
title: Type-Safe Event Reasons
impact: MEDIUM
impactDescription: enables TypeScript to catch invalid reason checks at compile time
tags: err, events, types, union
---

## Type-Safe Event Reasons

Define typed union of possible reasons for each component's events. This allows TypeScript to catch invalid reason checks.

**Incorrect (loose string type):**

```typescript
interface DialogChangeEventDetails {
  reason: string // Any string allowed
  cancel: () => void
}

// TypeScript can't catch typos
if (details.reason === 'esacpe-key') { // typo not caught
  // ...
}
```

**Correct (typed union):**

```typescript
const REASONS = {
  triggerPress: 'trigger-press',
  escapeKey: 'escape-key',
  outsidePress: 'outside-press',
  focusOut: 'focus-out',
} as const

type DialogRootChangeEventReason =
  | typeof REASONS.triggerPress
  | typeof REASONS.escapeKey
  | typeof REASONS.outsidePress
  | typeof REASONS.focusOut

interface DialogRootChangeEventDetails {
  reason: DialogRootChangeEventReason
  cancel: () => void
  isCanceled: boolean
}

// TypeScript catches invalid comparisons
if (details.reason === 'esacpe-key') {
  // Error: This comparison appears to be unintentional because...
}

// Exhaustive switch pattern
switch (details.reason) {
  case REASONS.escapeKey:
    // handle escape
    break
  case REASONS.outsidePress:
    // handle outside click
    break
  // TypeScript ensures all cases handled
}
```

**When to use:**
- All event detail interfaces
- Export reason types for consumer use
