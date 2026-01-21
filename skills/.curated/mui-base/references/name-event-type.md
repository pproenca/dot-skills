---
title: Event Type Naming Convention
impact: MEDIUM
impactDescription: provides predictable event type names for TypeScript consumers
tags: name, event, types, convention
---

## Event Type Naming Convention

Name event types as `[Component]ChangeEventReason` and `[Component]ChangeEventDetails`.

**Incorrect (anti-pattern):**

```typescript
type DialogOpenReason = string
type DialogEvent = { reason: string }
type OpenChangeReason = 'click' | 'escape'
```

**Correct (recommended):**

```typescript
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

// Usage in props
interface DialogRootProps {
  onOpenChange?: (open: boolean, details: DialogRootChangeEventDetails) => void
}
```

**When to use:**
- Components with events that need to communicate why something changed
- Dialogs, popovers, menus that can close for multiple reasons
