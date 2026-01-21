---
title: Event Reason Constants
impact: HIGH
impactDescription: provides type-safe event reasons for analytics and conditional handling
tags: err, events, constants, reasons
---

## Event Reason Constants

Use typed `REASONS` constants for event reasons, not string literals. This enables type-safe reason checking and autocomplete.

**Incorrect (string literals):**

```typescript
function handleClose() {
  onOpenChange?.(false, { reason: 'escape-key' })
}

// Consumer has to guess valid strings
onOpenChange={(open, details) => {
  if (details.reason === 'escapeKey') { // typo, wrong format
    // ...
  }
}}
```

**Correct (typed constants):**

```typescript
// dialog/root/constants.ts
export const REASONS = {
  triggerPress: 'trigger-press',
  escapeKey: 'escape-key',
  outsidePress: 'outside-press',
  focusOut: 'focus-out',
} as const

export type DialogCloseReason = typeof REASONS[keyof typeof REASONS]

// In component
import { REASONS } from './constants'

function handleEscapeKey() {
  const details = createChangeEventDetails(REASONS.escapeKey)
  onOpenChange?.(false, details)
}

// Consumer with type safety
onOpenChange={(open, details) => {
  if (details.reason === REASONS.escapeKey) {
    // TypeScript ensures this is valid
  }
}}
```

**When to use:**
- All event callbacks with reason parameters
- Enables consistent tracking and conditional logic
