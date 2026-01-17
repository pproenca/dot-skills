---
title: Constant Naming SCREAMING_SNAKE_CASE
impact: MEDIUM
impactDescription: clearly distinguishes constants from mutable variables
tags: name, constants, SCREAMING_SNAKE_CASE
---

## Constant Naming SCREAMING_SNAKE_CASE

Use SCREAMING_SNAKE_CASE for constants to distinguish them from mutable variables.

**Incorrect (anti-pattern):**

```typescript
const reasons = {
  triggerPress: 'trigger-press',
  escapeKey: 'escape-key',
}

const emptyArray: string[] = []
const defaultValue = 0
```

**Correct (recommended):**

```typescript
const REASONS = {
  triggerPress: 'trigger-press',
  escapeKey: 'escape-key',
  outsidePress: 'outside-press',
  focusOut: 'focus-out',
} as const

const EMPTY_ARRAY: readonly string[] = []
const DEFAULT_DELAY = 300
const ANIMATION_DURATION = 200
```

**When to use:**
- Module-level constants
- Enum-like objects
- Default values that should never change
